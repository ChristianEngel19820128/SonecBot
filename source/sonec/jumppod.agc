// A5/J1: platform-bound jumper and persistent two-rectangle base.
// All dimensions are native pixels from the idle 80x21 frame.
#constant JUMPPOD_CELL_W 80
#constant JUMPPOD_CELL_H 21
#constant JUMPPOD_BASE_W 58
#constant JUMPPOD_BASE_H 5
#constant JUMPPOD_TOP_W 34
#constant JUMPPOD_TOP_H 8
#constant JUMPPOD_JUMP_FACTOR 2.0
#constant JUMPPOD_FRAME2_MS 150
#constant JUMPPOD_HEALTH_MAX 80
#constant JUMPPOD_TEST_SPAWN_MS 2500
#constant JUMPPOD_BLAST_TYPE 3
#constant JUMPPOD_BLAST_SCALE 0.85
#constant JUMPPOD_BLAST_DAMAGE 12

type TJumppod
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
global JumppodNextSpawnMs as integer
global JumppodNowMs as integer
// Resolver-only geometry, never passed to weapon/chest/Walker logic.
// Stable slots: chest i -> 3*i, pod i lower -> 3*i+1, upper -> 3*i+2.
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

function JumppodFollow(Pod ref as TJumppod,Plate ref as TPlate)
    Pod.WorldX = Plate.ObjectData.Position.x+Pod.OffsetX
    Pod.WorldY = Plate.ObjectData.Position.y
    JumppodRectUpdate(Pod.Lower,Plate,Pod.PlateIndex,Pod.OffsetX-JUMPPOD_BASE_W*0.5,-JUMPPOD_BASE_H,JUMPPOD_BASE_W,JUMPPOD_BASE_H)
    JumppodRectUpdate(Pod.Upper,Plate,Pod.PlateIndex,Pod.OffsetX-JUMPPOD_TOP_W*0.5,-JUMPPOD_BASE_H-JUMPPOD_TOP_H,JUMPPOD_TOP_W,JUMPPOD_TOP_H)
    Pod.Lower.MechanicalStepLevel = 1
    Pod.Upper.MechanicalStepLevel = 2
endfunction

// Only fresh, off-screen platforms are offered to the periodic test spawner.
// Existing station footprints (including wrecks) and chests reserve space.
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
    for Candidate = Ceil(JUMPPOD_BASE_W*0.5) to Floor(Plate.ObjectData.Size.Width-JUMPPOD_BASE_W*0.5)
        LeftX = Candidate-JUMPPOD_BASE_W*0.5
        RightX = Candidate+JUMPPOD_BASE_W*0.5
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
                OtherLeft = JumppodList[k].OffsetX-JUMPPOD_BASE_W*0.5
                OtherRight = OtherLeft+JUMPPOD_BASE_W
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
    if Game.PlateList.Plate[PlateIndex].ObjectData.Size.Width < JUMPPOD_BASE_W then exitfunction
    CenterX = JumppodFreeCenter(Game.PlateList.Plate[PlateIndex],PlateIndex,Game.ChestList)
    if CenterX < 0 then exitfunction
    JumppodNextSpawnMs = Now+JUMPPOD_TEST_SPAWN_MS
    Pod.Enabled = TRUE
    Pod.Health = JUMPPOD_HEALTH_MAX
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

function JumppodBuildMechanicalList(ChestList ref as TChestList)
    local i as integer
    local Last as integer
    local Empty as TChest
    Last = ChestList.Chest.Length
    if JumppodList.Length > Last then Last = JumppodList.Length
    if Last < 0
        SonecMechanicalList.Chest.Length = -1
        exitfunction
    endif
    SonecMechanicalList.Chest.Length = Last*3+2
    for i = 0 to SonecMechanicalList.Chest.Length
        SonecMechanicalList.Chest[i] = Empty
    next i
    for i = 0 to ChestList.Chest.Length
        SonecMechanicalList.Chest[i*3] = ChestList.Chest[i]
    next i
    for i = 0 to JumppodList.Length
        if JumppodList[i].Enabled = TRUE
            SonecMechanicalList.Chest[i*3+1] = JumppodList[i].Lower
            SonecMechanicalList.Chest[i*3+2] = JumppodList[i].Upper
        endif
    next i
endfunction

// Called only for the resolver's selected valid top contact, before landing effects.
function JumppodTryLaunch(SurfaceIndex as integer)
    local i as integer
    if SurfaceIndex < 2 then exitfunction FALSE
    i = Floor(SurfaceIndex/3.0)
    if SurfaceIndex <> i*3+2 or i > JumppodList.Length then exitfunction FALSE
    if JumppodList[i].Enabled = FALSE or JumppodList[i].Destroyed = TRUE then exitfunction FALSE
    if JumppodNowMs < JumppodList[i].ActiveUntil then exitfunction FALSE
    JumppodList[i].ActiveUntil = JumppodNowMs+JUMPPOD_FRAME2_MS
endfunction TRUE

function JumppodDrawPlate(PlateIndex as integer,World ref as TWorld)
    local i as integer
    if JumppodSprite = 0 then exitfunction
    for i = 0 to JumppodList.Length
        if JumppodList[i].Enabled = TRUE and JumppodList[i].PlateIndex = PlateIndex
            SetSpriteFrame(JumppodSprite,1)
            if JumppodList[i].Destroyed = TRUE
                SetSpriteColor(JumppodSprite,FLARAK_WRECK_COLOR-8,FLARAK_WRECK_COLOR+14,FLARAK_WRECK_COLOR-8,255)
            else
                if JumppodNowMs < JumppodList[i].ActiveUntil then SetSpriteFrame(JumppodSprite,2)
                if JumppodNowMs < JumppodList[i].HitFlashUntil
                    SetSpriteColor(JumppodSprite,255,0,0,255)
                else
                    SetSpriteColor(JumppodSprite,0,255,0,255)
                endif
            endif
            SetSpritePositionByOffset(JumppodSprite,JumppodList[i].WorldX-World.Position.x,JumppodList[i].WorldY-World.Position.y)
            DrawSprite(JumppodSprite)
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
        JumppodList[Index].ActiveUntil = 0
        Impact.x = JumppodList[Index].WorldX
        Impact.y = JumppodList[Index].WorldY-JUMPPOD_BASE_H-JUMPPOD_TOP_H*0.5
        ExplosionNew(Blast,Game.ProtoExplosion,Game,JUMPPOD_BLAST_TYPE,Impact,Now)
        Blast.SpriteData.Scale = JUMPPOD_BLAST_SCALE
        Blast.BulletData.Damage = JUMPPOD_BLAST_DAMAGE
        ExplosionInsert(Game.ExplosionList,Blast)
        PlaySound(Game.Sound.ImpactSound)
    endif
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
                if Game.FlameList.Flame[i].Enabled = TRUE and JumppodList[k].Enabled = TRUE
                    if JumppodCircleHits(JumppodList[k],Game.FlameList.Flame[i].ObjectData.Position,R)
                        JumppodApplyDamage(k,Game,Game.FlameList.Flame[i].BulletData.Damage,Now)
                        FlameDelete(Game.FlameList,i)
                    endif
                endif
            next k
        endif
    next i
endfunction

function JumppodCollideGrenades(Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local Impact as TPosition
    for i = 0 to Game.GrenadeList.Grenade.Length
        if Game.GrenadeList.Grenade[i].Enabled = TRUE
            for k = 0 to JumppodList.Length
                if Game.GrenadeList.Grenade[i].Enabled = TRUE and JumppodList[k].Enabled = TRUE
                    if JumppodBoxHits(JumppodList[k],Game.GrenadeList.Grenade[i].CollisionData.Position1,Game.GrenadeList.Grenade[i].CollisionData.Position2)
                        Impact = Game.GrenadeList.Grenade[i].ObjectData.Position
                        JumppodApplyDamage(k,Game,Game.GrenadeList.Grenade[i].BulletData.Damage,Now)
                        GrenadeDestroy(Game.GrenadeList,i,Game.ExplosionList,Game.ProtoExplosion,Game,Impact,Now)
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
