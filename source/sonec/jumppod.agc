// A5/J1/J2: platform-bound jumper, landmine decoy and persistent two-rectangle base.
// All dimensions are native pixels from the idle 80x21 frame.
#constant JUMPPOD_CELL_W 80
#constant JUMPPOD_CELL_H 21
#constant JUMPPOD_BASE_W 58
#constant JUMPPOD_BASE_H 5
#constant JUMPPOD_TOP_W 34
#constant JUMPPOD_TOP_H 8
#constant JUMPPOD_JUMP_FACTOR 1.6
#constant JUMPPOD_FRAME2_MS 150
#constant JUMPPOD_HEALTH_MAX 80
#constant JUMPPOD_TEST_SPAWN_MS 2500
#constant JUMPPOD_BLAST_TYPE 3
#constant JUMPPOD_BLAST_SCALE 0.85
#constant JUMPPOD_BLAST_DAMAGE 12

// J2 provisional values; both variants use the very same mechanical base.
#constant JUMPPOD_KIND 0
#constant LANDMINE_KIND 1
#constant LANDMINE_SPAWN_PERCENT 25
#constant LANDMINE_HEALTH_MAX 80
#constant LANDMINE_BLAST_TYPE 3
#constant LANDMINE_BLAST_SCALE 1.8
#constant LANDMINE_BLAST_DAMAGE 36
#constant LANDMINE_BLINK_HALF_MS 140
#constant LANDMINE_WARNING_RANGE 160.0
#constant LANDMINE_WARNING_SIZE 2
#constant LANDMINE_WARNING_R 255
#constant LANDMINE_WARNING_G 155
#constant LANDMINE_WARNING_B 45

type TJumppod
    FlameTargetId as integer
    SmokeEmitter as TSmokeEmitter
    ObjectKind as integer
    ContactTriggered as integer
    Enabled as integer
    Destroyed as integer
    Health as integer
    PlateIndex as integer
    OffsetX as float
    WorldX as float
    WorldY as float
    ActiveUntil as integer
    HitFlashUntil as integer
    Lower as TChest
    Upper as TChest
endtype

global JumppodList as TJumppod[-1]
global JumppodSprite as integer
global LandmineSprite as integer
global LandmineWarningSprite as integer
global JumppodNextSpawnMs as integer
global JumppodNowMs as integer
// Resolver-only geometry, never passed to weapon/chest/Walker logic.
// Stable slots across list growth: chest i -> 5*i, pod/mine -> +1/+2,
// Flak/Flarak -> +3/+4. Every base has adjacent lower/upper slots.
#constant SONEC_MECHANICAL_SLOT_STRIDE 5
#constant SONEC_MECHANICAL_CHEST_SLOT 0
#constant SONEC_MECHANICAL_POD_LOWER_SLOT 1
#constant SONEC_MECHANICAL_POD_UPPER_SLOT 2
#constant SONEC_MECHANICAL_FLARAK_LOWER_SLOT 3
#constant SONEC_MECHANICAL_FLARAK_UPPER_SLOT 4
global SonecMechanicalList as TChestList

function ProtoJumppodLoad()
    local Image as TImage
    Image.File.Path = "/media/gfx/plate"
    Image.File.Name = "jumppod.png"
    if ImageLoad(Image) = TRUE
        JumppodSprite = CreateSprite(Image.ID)
        SetSpriteAnimation(JumppodSprite,JUMPPOD_CELL_W,JUMPPOD_CELL_H,2)
        SetSpriteOffset(JumppodSprite,JUMPPOD_CELL_W*0.5,JUMPPOD_CELL_H)
        SetSpriteFrame(JumppodSprite,1)
    endif
    Image.File.Path = "/media/gfx/enemies"
    Image.File.Name = "landmine.png"
    if ImageLoad(Image) = TRUE
        LandmineSprite = CreateSprite(Image.ID)
        SetSpriteOffset(LandmineSprite,JUMPPOD_CELL_W*0.5,JUMPPOD_BASE_H+JUMPPOD_TOP_H)
        LandmineWarningSprite = CreateSprite(0)
        SetSpriteSize(LandmineWarningSprite,LANDMINE_WARNING_SIZE,LANDMINE_WARNING_SIZE)
        SetSpriteOffset(LandmineWarningSprite,LANDMINE_WARNING_SIZE*0.5,LANDMINE_WARNING_SIZE*0.5)
        SetSpriteColor(LandmineWarningSprite,LANDMINE_WARNING_R,LANDMINE_WARNING_G,LANDMINE_WARNING_B,255)
    endif
endfunction

function JumppodInit(Now as integer)
    JumppodList.Length = -1
    SonecMechanicalList.Chest.Length = -1
    JumppodNextSpawnMs = Now
    JumppodNowMs = Now
endfunction

// A generic platform-bound mechanical rectangle: same geometry before/after destruction.
function JumppodRectUpdate(Rect ref as TChest,Plate ref as TPlate,PlateIndex as integer,OffsetX as float,OffsetY as float,W as float,H as float)
    Rect.Enabled = TRUE
    Rect.CollisionData.Index = PlateIndex
    Rect.CollisionData.Position.x = OffsetX
    Rect.CollisionData.Position.y = OffsetY
    Rect.ObjectData.Size.Width = W
    Rect.ObjectData.Size.Height = H
    Rect.ObjectData.MoveSpeed = Plate.ObjectData.MoveSpeed
    Rect.CollisionMoveStart.x = Plate.CollisionMoveStart.x+OffsetX
    Rect.CollisionMoveStart.y = Plate.CollisionMoveStart.y+OffsetY
    Rect.ObjectData.Position.x = Plate.ObjectData.Position.x+OffsetX
    Rect.ObjectData.Position.y = Plate.ObjectData.Position.y+OffsetY
    Rect.CollisionData.Position1 = Rect.ObjectData.Position
    Rect.CollisionData.Position2.x = Rect.ObjectData.Position.x+W
    Rect.CollisionData.Position2.y = Rect.ObjectData.Position.y+H
endfunction

// Same fixed closed-frame base for all A5 objects. The sprite pivot
// and deployable launcher parts are not mechanical geometry.
function SockelUpdateRects(LowerRect ref as TChest,UpperRect ref as TChest,Plate ref as TPlate,PlateIndex as integer,CenterOffsetX as float)
    JumppodRectUpdate(LowerRect,Plate,PlateIndex,CenterOffsetX-JUMPPOD_BASE_W*0.5,-JUMPPOD_BASE_H,JUMPPOD_BASE_W,JUMPPOD_BASE_H)
    JumppodRectUpdate(UpperRect,Plate,PlateIndex,CenterOffsetX-JUMPPOD_TOP_W*0.5,-JUMPPOD_BASE_H-JUMPPOD_TOP_H,JUMPPOD_TOP_W,JUMPPOD_TOP_H)
    LowerRect.MechanicalStepLevel = 1
    UpperRect.MechanicalStepLevel = 2
endfunction

function JumppodFollow(Pod ref as TJumppod,Plate ref as TPlate)
    Pod.WorldX = Plate.ObjectData.Position.x+Pod.OffsetX
    Pod.WorldY = Plate.ObjectData.Position.y
    SockelUpdateRects(Pod.Lower,Pod.Upper,Plate,Pod.PlateIndex,Pod.OffsetX)
endfunction

// Only fresh, off-screen platforms are offered to the periodic test spawner.
// Reserve full sprite cell widths for placement, including wrecks.
// Mechanical and damage rectangles remain independent of this reserve.
function JumppodFreeCenter(Plate ref as TPlate,PlateIndex as integer,ChestList ref as TChestList)
    local Candidate as integer
    local k as integer
    local Blocked as integer
    local LeftX as float
    local RightX as float
    local OtherLeft as float
    local OtherRight as float
    local Best as float
    local Dist as float
    local BestDist as float
    Best = -1
    BestDist = Plate.ObjectData.Size.Width+1
    for Candidate = Ceil(JUMPPOD_CELL_W*0.5) to Floor(Plate.ObjectData.Size.Width-JUMPPOD_CELL_W*0.5)
        LeftX = Candidate-JUMPPOD_CELL_W*0.5
        RightX = Candidate+JUMPPOD_CELL_W*0.5
        Blocked = FALSE
        for k = 0 to ChestList.Chest.Length
            if ChestList.Chest[k].Enabled = TRUE and ChestList.Chest[k].CollisionData.Index = PlateIndex
                OtherLeft = ChestList.Chest[k].CollisionData.Position.x
                OtherRight = OtherLeft+ChestList.Chest[k].ObjectData.Size.Width
                if LeftX < OtherRight and RightX > OtherLeft then Blocked = TRUE
            endif
        next k
        for k = 0 to FlarakList.Length
            if FlarakList[k].Enabled = TRUE and FlarakList[k].PlateIndex = PlateIndex
                OtherLeft = FlarakList[k].PlateOffsetX-FLARAK_TEST_CELL_W*0.5
                OtherRight = OtherLeft+FLARAK_TEST_CELL_W
                if LeftX < OtherRight and RightX > OtherLeft then Blocked = TRUE
            endif
        next k
        for k = 0 to JumppodList.Length
            if JumppodList[k].Enabled = TRUE and JumppodList[k].PlateIndex = PlateIndex
                OtherLeft = JumppodList[k].OffsetX-JUMPPOD_CELL_W*0.5
                OtherRight = OtherLeft+JUMPPOD_CELL_W
                if LeftX < OtherRight and RightX > OtherLeft then Blocked = TRUE
            endif
        next k
        if Blocked = FALSE
            Dist = Abs(Candidate-Plate.ObjectData.Size.Width*0.5)
            if Dist < BestDist
                Best = Candidate
                BestDist = Dist
            endif
        endif
    next Candidate
endfunction Best

function JumppodSpawnOnPlate(Game ref as TGame,PlateIndex as integer,Now as integer)
    local Pod as TJumppod
    local CenterX as float
    local Slot as integer
    local i as integer
    if JumppodSprite = 0 or Now < JumppodNextSpawnMs then exitfunction
    if Game.PlateList.Plate[PlateIndex].ObjectData.Size.Width < JUMPPOD_CELL_W then exitfunction
    CenterX = JumppodFreeCenter(Game.PlateList.Plate[PlateIndex],PlateIndex,Game.ChestList)
    if CenterX < 0 then exitfunction
    // Draw the variant only after a free position has been found.
    // One successful spawn consumes the same timer for either variant.
    Pod.ObjectKind = JUMPPOD_KIND
    Pod.Health = JUMPPOD_HEALTH_MAX
    if Random(1,100) <= LANDMINE_SPAWN_PERCENT
        if LandmineSprite = 0 then exitfunction
        Pod.ObjectKind = LANDMINE_KIND
        Pod.Health = LANDMINE_HEALTH_MAX
    endif
    JumppodNextSpawnMs = Now+JUMPPOD_TEST_SPAWN_MS
    Pod.Enabled = TRUE
    Pod.FlameTargetId = FlameNewTargetId()
    Pod.PlateIndex = PlateIndex
    Pod.OffsetX = CenterX
    JumppodFollow(Pod,Game.PlateList.Plate[PlateIndex])
    Slot = JumppodList.Length+1
    for i = 0 to JumppodList.Length
        if JumppodList[i].Enabled = FALSE and Slot = JumppodList.Length+1 then Slot = i
    next i
    if Slot > JumppodList.Length
        JumppodList.Insert(Pod)
    else
        JumppodList[Slot] = Pod
    endif
    // A recycled pod slot is a new target, not an old blast cooldown.
    for i = 0 to Game.ExplosionList.Explosion.Length
        if Game.ExplosionList.Explosion[i].LastJumppodHitMs.Length >= Slot
            Game.ExplosionList.Explosion[i].LastJumppodHitMs[Slot] = 0
        endif
    next i
endfunction

function JumppodMoveAll(PlateList ref as TPlateList,Now as integer)
    local i as integer
    local p as integer
    JumppodNowMs = Now
    for i = 0 to JumppodList.Length
        if JumppodList[i].Enabled = TRUE
            p = JumppodList[i].PlateIndex
            if p < 0 or p > PlateList.Plate.Length
                JumppodList[i].Enabled = FALSE
            else
                if PlateList.Plate[p].Enabled = FALSE or PlateList.Plate[p].ObjectData.Position.x+PlateList.Plate[p].ObjectData.Size.Width < 0
                    JumppodList[i].Enabled = FALSE
                else
                    JumppodFollow(JumppodList[i],PlateList.Plate[p])
                endif
            endif
        endif
    next i
endfunction

function JumppodBuildMechanicalList(ChestList ref as TChestList,PlateList ref as TPlateList)
    local i as integer
    local PlateIndex as integer
    local Slot as integer
    local Last as integer
    local Empty as TChest
    local LowerRect as TChest
    local UpperRect as TChest
    Last = ChestList.Chest.Length
    if JumppodList.Length > Last then Last = JumppodList.Length
    if FlarakList.Length > Last then Last = FlarakList.Length
    if Last < 0
        SonecMechanicalList.Chest.Length = -1
        exitfunction
    endif
    SonecMechanicalList.Chest.Length = Last*SONEC_MECHANICAL_SLOT_STRIDE+SONEC_MECHANICAL_FLARAK_UPPER_SLOT
    for i = 0 to SonecMechanicalList.Chest.Length
        SonecMechanicalList.Chest[i] = Empty
    next i
    for i = 0 to ChestList.Chest.Length
        Slot = i*SONEC_MECHANICAL_SLOT_STRIDE
        // Keep stable slot indices; only foreground chests are Sonec supports.
        if ChestList.Chest[i].IsBackground = FALSE
            SonecMechanicalList.Chest[Slot+SONEC_MECHANICAL_CHEST_SLOT] = ChestList.Chest[i]
        endif
    next i
    for i = 0 to JumppodList.Length
        if JumppodList[i].Enabled = TRUE
            Slot = i*SONEC_MECHANICAL_SLOT_STRIDE
            SonecMechanicalList.Chest[Slot+SONEC_MECHANICAL_POD_LOWER_SLOT] = JumppodList[i].Lower
            SonecMechanicalList.Chest[Slot+SONEC_MECHANICAL_POD_UPPER_SLOT] = JumppodList[i].Upper
        endif
    next i
    // Only live platform bindings own a base, including destroyed stations.
    // Fired rockets are independent; never create a base for a rocket-only slot.
    // Use the plate's own start/end snapshots, not the elevated sprite pivot.
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = TRUE
            PlateIndex = FlarakList[i].PlateIndex
            if PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
                if PlateList.Plate[PlateIndex].Enabled = TRUE
                    Slot = i*SONEC_MECHANICAL_SLOT_STRIDE
                    LowerRect = Empty
                    UpperRect = Empty
                    SockelUpdateRects(LowerRect,UpperRect,PlateList.Plate[PlateIndex],PlateIndex,FlarakList[i].PlateOffsetX)
                    SonecMechanicalList.Chest[Slot+SONEC_MECHANICAL_FLARAK_LOWER_SLOT] = LowerRect
                    SonecMechanicalList.Chest[Slot+SONEC_MECHANICAL_FLARAK_UPPER_SLOT] = UpperRect
                endif
            endif
        endif
    next i
endfunction

// Called only for the resolver's selected valid landing or upward step.
// Return TRUE for a pod impulse; queue a mine detonation instead, to be
// consumed after the sweep in the same GameDo tick (where Game is available).
function JumppodHandleUpperContact(SurfaceIndex as integer)
    local i as integer
    if SurfaceIndex < SONEC_MECHANICAL_POD_UPPER_SLOT then exitfunction FALSE
    i = Floor(SurfaceIndex/(SONEC_MECHANICAL_SLOT_STRIDE*1.0))
    // Only pod/mine upper slots have a contact effect; Flak/Flarak do not.
    if SurfaceIndex <> i*SONEC_MECHANICAL_SLOT_STRIDE+SONEC_MECHANICAL_POD_UPPER_SLOT or i > JumppodList.Length then exitfunction FALSE
    if JumppodList[i].Enabled = FALSE or JumppodList[i].Destroyed = TRUE then exitfunction FALSE
    if JumppodList[i].ObjectKind = LANDMINE_KIND
        JumppodList[i].ContactTriggered = TRUE
        exitfunction FALSE
    endif
    if JumppodNowMs < JumppodList[i].ActiveUntil then exitfunction FALSE
    JumppodList[i].ActiveUntil = JumppodNowMs+JUMPPOD_FRAME2_MS
endfunction TRUE

function JumppodDrawPlate(PlateIndex as integer,World ref as TWorld,PlayerPosition as TPosition)
    local i as integer
    local SpriteID as integer
    local LampPosition as TPosition
    local BlinkPhase as integer
    if JumppodSprite = 0 then exitfunction
    BlinkPhase = Floor(JumppodNowMs/(LANDMINE_BLINK_HALF_MS*1.0))
    for i = 0 to JumppodList.Length
        if JumppodList[i].Enabled = TRUE and JumppodList[i].PlateIndex = PlateIndex
            SpriteID = JumppodSprite
            if JumppodList[i].ObjectKind = LANDMINE_KIND then SpriteID = LandmineSprite
            if SpriteID > 0
                if JumppodList[i].ObjectKind = JUMPPOD_KIND
                    SetSpriteFrame(SpriteID,1)
                    if JumppodList[i].Destroyed = FALSE and JumppodNowMs < JumppodList[i].ActiveUntil then SetSpriteFrame(SpriteID,2)
                endif
                if JumppodList[i].Destroyed = TRUE
                    SetSpriteColor(SpriteID,FLARAK_WRECK_COLOR-8,FLARAK_WRECK_COLOR+14,FLARAK_WRECK_COLOR-8,255)
                else
                    if JumppodNowMs < JumppodList[i].HitFlashUntil
                        SetSpriteColor(SpriteID,255,0,0,255)
                    else
                        SetSpriteColor(SpriteID,0,255,0,255)
                    endif
                endif
                SetSpritePositionByOffset(SpriteID,JumppodList[i].WorldX-World.Position.x,JumppodList[i].WorldY-World.Position.y)
                DrawSprite(SpriteID)
                // A single shared 2x2 marker, visible only near a live mine.
                if JumppodList[i].ObjectKind = LANDMINE_KIND and JumppodList[i].Destroyed = FALSE and LandmineWarningSprite > 0
                    if BlinkPhase-2*Floor(BlinkPhase/2.0) = 0
                        LampPosition.x = JumppodList[i].WorldX
                        LampPosition.y = JumppodList[i].WorldY-JUMPPOD_BASE_H-JUMPPOD_TOP_H*0.5
                        if CalcRadius(PlayerPosition,LampPosition) <= LANDMINE_WARNING_RANGE
                            SetSpritePositionByOffset(LandmineWarningSprite,LampPosition.x-World.Position.x,LampPosition.y-World.Position.y)
                            DrawSprite(LandmineWarningSprite)
                        endif
                    endif
                endif
            endif
        endif
    next i
endfunction

// Damage acceptance is independent of the geometry; wrecks remain solid.
function JumppodApplyDamage(Index as integer,Game ref as TGame,Damage as integer,Now as integer)
    local Blast as TExplosion
    local Impact as TPosition
    if JumppodList[Index].Enabled = FALSE or JumppodList[Index].Destroyed = TRUE or Damage <= 0 then exitfunction
    JumppodList[Index].Health = JumppodList[Index].Health-Damage
    JumppodList[Index].HitFlashUntil = Now+150
    if JumppodList[Index].Health <= 0
        JumppodList[Index].Health = 0
        JumppodList[Index].Destroyed = TRUE
        SmokeStartEmitter(JumppodList[Index].SmokeEmitter,Now)
        JumppodList[Index].ActiveUntil = 0
        JumppodList[Index].ContactTriggered = FALSE
        Impact.x = JumppodList[Index].WorldX
        Impact.y = JumppodList[Index].WorldY-JUMPPOD_BASE_H-JUMPPOD_TOP_H*0.5
        if JumppodList[Index].ObjectKind = LANDMINE_KIND
            ExplosionNew(Blast,Game.ProtoExplosion,Game,LANDMINE_BLAST_TYPE,Impact,Now)
            Blast.SpriteData.Scale = LANDMINE_BLAST_SCALE
            Blast.BulletData.Damage = LANDMINE_BLAST_DAMAGE
            PlaySound(Game.Sound.ExplosionSound)
        else
            ExplosionNew(Blast,Game.ProtoExplosion,Game,JUMPPOD_BLAST_TYPE,Impact,Now)
            Blast.SpriteData.Scale = JUMPPOD_BLAST_SCALE
            Blast.BulletData.Damage = JUMPPOD_BLAST_DAMAGE
            PlaySound(Game.Sound.ImpactSound)
        endif
        ExplosionInsert(Game.ExplosionList,Blast)
    endif
endfunction

// Detonate only after an accepted upper contact, before weapon processing.
// No arming delay, no second blast or special Sonec damage path. All blast
// targets use the existing timed explosion/central body-circle damage rules.
function JumppodResolveContactTriggers(Game ref as TGame,Now as integer)
    local i as integer
    for i = 0 to JumppodList.Length
        if JumppodList[i].Enabled = TRUE and JumppodList[i].Destroyed = FALSE and JumppodList[i].ObjectKind = LANDMINE_KIND and JumppodList[i].ContactTriggered = TRUE
            JumppodApplyDamage(i,Game,JumppodList[i].Health,Now)
        endif
    next i
endfunction

// The owner supplies only its current top-center world position and density.
// Disabled sources are no longer submitted; their particles expire normally.
function JumppodSmokeDoAll(PlateList ref as TPlateList,Now as integer)
    local i as integer
    local PlateIndex as integer
    local Density as integer
    local Position as TPosition
    local CarrierY as float
    for i = 0 to JumppodList.Length
        if JumppodList[i].Enabled = TRUE and JumppodList[i].Destroyed = TRUE
            PlateIndex = JumppodList[i].PlateIndex
            if PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
                if PlateList.Plate[PlateIndex].Enabled = TRUE
                    Density = SMOKE_DENSITY_JUMPPOD
                    if JumppodList[i].ObjectKind = LANDMINE_KIND then Density = SMOKE_DENSITY_LANDMINE
                    Position.x = JumppodList[i].WorldX
                    Position.y = JumppodList[i].WorldY-JUMPPOD_BASE_H-JUMPPOD_TOP_H
                    CarrierY = SmokePlateVelocityY(PlateList.Plate[PlateIndex])
                    SmokeAdd(JumppodList[i].SmokeEmitter,Position,Density,CarrierY,Now)
                endif
            endif
        endif
    next i
endfunction

function JumppodBulletEntry(Bullet ref as TBullet,Pod ref as TJumppod)
    local Entry as float
    local Other as float
    Entry = BulletBoxSweepEntry(Bullet,Pod.Lower.CollisionData.Position1,Pod.Lower.CollisionData.Position2)
    Other = BulletBoxSweepEntry(Bullet,Pod.Upper.CollisionData.Position1,Pod.Upper.CollisionData.Position2)
    if Other >= 0 and (Entry < 0 or Other < Entry) then Entry = Other
endfunction Entry

function JumppodNearestPoint(Rect ref as TChest,Center as TPosition)
    local P as TPosition
    P = Center
    if P.x < Rect.CollisionData.Position1.x then P.x = Rect.CollisionData.Position1.x
    if P.x > Rect.CollisionData.Position2.x then P.x = Rect.CollisionData.Position2.x
    if P.y < Rect.CollisionData.Position1.y then P.y = Rect.CollisionData.Position1.y
    if P.y > Rect.CollisionData.Position2.y then P.y = Rect.CollisionData.Position2.y
endfunction P

function JumppodCircleHits(Pod ref as TJumppod,Center as TPosition,Radius as float)
    local P as TPosition
    P = JumppodNearestPoint(Pod.Lower,Center)
    if CalcRadius(Center,P) <= Radius then exitfunction TRUE
    P = JumppodNearestPoint(Pod.Upper,Center)
    if CalcRadius(Center,P) <= Radius then exitfunction TRUE
endfunction FALSE

function JumppodBoxHits(Pod ref as TJumppod,MinPos as TPosition,MaxPos as TPosition)
    if BoxInBox(MinPos,MaxPos,Pod.Lower.CollisionData.Position1,Pod.Lower.CollisionData.Position2) then exitfunction TRUE
    if BoxInBox(MinPos,MaxPos,Pod.Upper.CollisionData.Position1,Pod.Upper.CollisionData.Position2) then exitfunction TRUE
endfunction FALSE

function JumppodCollideFlames(Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local R as float
    for i = 0 to Game.FlameList.Flame.Length
        if Game.FlameList.Flame[i].Enabled = TRUE
            R = FlameCollisionRadius(Game.FlameList.Flame[i])
            for k = 0 to JumppodList.Length
                if Game.FlameList.Flame[i].Enabled = TRUE and JumppodList[k].Enabled = TRUE and JumppodList[k].Destroyed = FALSE
                    if JumppodCircleHits(JumppodList[k],Game.FlameList.Flame[i].ObjectData.Position,R)
                        if FlameCanDamage(Game.FlameList.Flame[i],JumppodList[k].FlameTargetId,Now) = TRUE
                            JumppodApplyDamage(k,Game,Game.FlameList.Flame[i].BulletData.Damage,Now)
                        endif
                    endif
                endif
            next k
        endif
    next i
endfunction


// Like existing chest plasma contacts: damage once per collision timer, not per rectangle.
function JumppodCollidePlasma(Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    for i = 0 to Game.PlasmaBlitzList.PlasmaBlitz.Length
        if Game.PlasmaBlitzList.PlasmaBlitz[i].Enabled = TRUE
            if TimeGet(Game.PlasmaBlitzList.PlasmaBlitz[i].CollisionData.CollisionTimer,Now) > 0
                for k = 0 to JumppodList.Length
                    if JumppodList[k].Enabled = TRUE
                        if JumppodBoxHits(JumppodList[k],Game.PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position1,Game.PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position2)
                            JumppodApplyDamage(k,Game,Game.PlasmaBlitzList.PlasmaBlitz[i].BulletData.Damage,Now)
                        endif
                    endif
                next k
            endif
        endif
    next i
endfunction

function JumppodCollideExplosions(Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local Last as integer
    local R as float
    local Center as TPosition
    local Target as TPosition
    local Hit as integer
    Last = Game.ExplosionList.Explosion.Length
    for i = 0 to Last
        if Game.ExplosionList.Explosion[i].Enabled = TRUE and Game.ExplosionList.Explosion[i].ExplosionType <= EXPLOSION_DAMAGE_TYPE_MAX
            R = Game.ExplosionList.Explosion[i].ObjectData.Radius
            Center = Game.ExplosionList.Explosion[i].ObjectData.Position
            if R > 0
                for k = 0 to JumppodList.Length
                    if JumppodList[k].Enabled = TRUE and JumppodList[k].Destroyed = FALSE
                        Hit = FALSE
                        Target = JumppodNearestPoint(JumppodList[k].Lower,Center)
                        if CalcRadius(Center,Target) <= R and ExplosionDamageAllowed(Game.ExplosionList.Explosion[i],Target) then Hit = TRUE
                        Target = JumppodNearestPoint(JumppodList[k].Upper,Center)
                        if CalcRadius(Center,Target) <= R and ExplosionDamageAllowed(Game.ExplosionList.Explosion[i],Target) then Hit = TRUE
                        if Hit = TRUE
                            if Game.ExplosionList.Explosion[i].LastJumppodHitMs.Length < k then Game.ExplosionList.Explosion[i].LastJumppodHitMs.Length = k
                            if EXPLOSION_TIMED_DAMAGE = 0 or Game.ExplosionList.Explosion[i].LastJumppodHitMs[k] = 0 or Now+1-Game.ExplosionList.Explosion[i].LastJumppodHitMs[k] >= EXPLOSION_DAMAGE_INTERVAL_MS
                                Game.ExplosionList.Explosion[i].LastJumppodHitMs[k] = Now+1
                                JumppodApplyDamage(k,Game,Game.ExplosionList.Explosion[i].BulletData.Damage,Now)
                            endif
                        endif
                    endif
                next k
            endif
        endif
    next i
endfunction
