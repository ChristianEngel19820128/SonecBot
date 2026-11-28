// Temporary repeatable test appearances until wave scheduling owns bomber spawns.
#constant BOMBER_TEST_WAIT_MIN_MS 8000
#constant BOMBER_TEST_WAIT_MAX_MS 15000
#constant BOMBER_WARNING_LEAD_MS 2200
#constant BOMBER_SPEED_PX_PER_MS 0.40
#constant BOMBER_ENTRY_MARGIN_X 65
#constant BOMBER_SPAWN_EXTRA_SCREEN_FRACTION1 15
#constant BOMBER_SPAWN_EXTRA_SCREEN_FRACTION2 55
#constant BOMBER_VIEW_MARGIN_Y 16
#constant BOMBER_JET_INTERVAL_MS 20
#constant BOMBER_JET_PARTICLE_SCALE 1.0
#constant BOMBER_JET_SPACING_PX 4.0
// Experimental two-outlet exhaust; offsets measured from the 176x64 sprite center.
// Upper nozzle ends near x=171,y=30; lower near x=168,y=40.
#constant BOMBER_JET_UPPER_X_FROM_RIGHT 5
#constant BOMBER_JET_LOWER_X_FROM_RIGHT 8
#constant BOMBER_JET_UPPER_Y_FROM_CENTER 1
#constant BOMBER_JET_LOWER_Y_FROM_CENTER 11
// B2b: five visual-only test bombs; physics values are provisional.
#constant BOMBER_BOMB_GRAVITY_PX_PER_MS2 0.00022
#constant BOMBER_BOMB_DRAG_PER_MS 0.0005
#constant BOMBER_BOMB_RELEASE_Y 20
#constant BOMBER_BOMB_COUNT 5
#constant BOMBER_BOMB_INTERVAL_MS 250
// B4: provisional bomber durability and per-weapon damage.
#constant BOMBER_HEALTH_MAX 50
#constant BOMBER_PLASMA_HIT_INTERVAL_MS 100
#constant BOMBER_HIT_FLASH_MS 150
#constant BOMBER_HIT_HALF_WIDTH 78
#constant BOMBER_HIT_HALF_HEIGHT 24

// Phase: 0 = waiting for a visible flight corridor, 1 = warning,
// 2 = flying, 3 = waiting for remaining bombs to resolve. At most one bomber.
function BomberProtoLoad(ProtoBomber ref as TProtoBomber)
    ProtoBomber.Body.Image.File.Path = "/media/gfx/enemies"
    ProtoBomber.Body.Image.File.Name = "spacejet.png"
    if ImageLoad(ProtoBomber.Body.Image) = TRUE
        SpriteLoad(ProtoBomber.Body)
    endif
    ProtoBomber.Bomb.Image.File.Path = "/media/gfx/weapons"
    ProtoBomber.Bomb.Image.File.Name = "bomb.png"
    if ImageLoad(ProtoBomber.Bomb.Image) = TRUE
        SpriteLoad(ProtoBomber.Bomb)
    endif
endfunction

function BomberInit(Bomber ref as TBomber,Now as integer)
    local i as integer
    Bomber.Enabled = FALSE
    Bomber.Health = BOMBER_HEALTH_MAX
    Bomber.HitFlashUntil = 0
    Bomber.LastPlasmaHitMs = 0
    Bomber.Phase = 0
    Bomber.NextWarningMs = Now+random(BOMBER_TEST_WAIT_MIN_MS,BOMBER_TEST_WAIT_MAX_MS)
    Bomber.SpawnAtMs = 0
    Bomber.LastMoveMs = Now
    Bomber.NextJetMs = Now
    Bomber.LastJetX = 0
    Bomber.BombCount = 0
    Bomber.NextBombAtMs = 0
    for i = 0 to BOMBER_BOMB_COUNT-1
        Bomber.Bomb[i].Enabled = FALSE
        Bomber.Bomb[i].LastMoveMs = Now
        Bomber.Bomb[i].SweepStartMs = Now
        Bomber.Bomb[i].Position.x = 0
        Bomber.Bomb[i].Position.y = 0
        Bomber.Bomb[i].PreviousPosition = Bomber.Bomb[i].Position
        Bomber.Bomb[i].Velocity.x = 0
        Bomber.Bomb[i].Velocity.y = 0
        Bomber.Bomb[i].SpriteData.Angle = 0
        Bomber.Bomb[i].SpriteData.Scale = 1
        Bomber.Bomb[i].SpriteData.Center = TRUE
        ColorSet(Bomber.Bomb[i].SpriteData.Color,255,255,255,255)
    next i
    Bomber.Position.x = 0
    Bomber.Position.y = 0
    Bomber.SpriteData.Angle = 0
    Bomber.SpriteData.Scale = 1
    Bomber.SpriteData.Center = TRUE
    ColorSet(Bomber.SpriteData.Color,80,232,80,255)
endfunction

// Dedicated emitter timer: Sonec and drone retain their own jetfire cadence.
// Particles use the shared existing list/lifecycle, but not its add timer.
function BomberJetfireDo(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Now as integer)
    local Position as TPosition
    local Jetfire as TJetfire
    local i as integer
    local j as integer
    local Outlet as integer
    local Count as integer
    local Found as integer
    local EngineX as float
    local OutletX as float
    local OutletY as float
    local Distance as float

    if Bomber.Enabled = TRUE and Now >= Bomber.NextJetMs and ProtoJetfire.AnimJetfire.Sprite.ID > 0
        // Reference point: upper nozzle at the right edge of the sprite.
        // Two trails share the same travel interpolation and emission timer.
        EngineX = Bomber.Position.x+GetSpriteWidth(ProtoBomber.Body.Sprite.ID)*0.5-BOMBER_JET_UPPER_X_FROM_RIGHT
        Distance = Bomber.LastJetX-EngineX
        Count = 2
        if Distance > BOMBER_JET_SPACING_PX*2
            Count = Floor(Distance/BOMBER_JET_SPACING_PX)+1
        endif
        if Count > 16 then Count = 16

        for Outlet = 0 to 1
            OutletX = EngineX
            OutletY = Bomber.Position.y+BOMBER_JET_UPPER_Y_FROM_CENTER
            if Outlet = 1
                OutletX = EngineX+BOMBER_JET_UPPER_X_FROM_RIGHT-BOMBER_JET_LOWER_X_FROM_RIGHT
                OutletY = Bomber.Position.y+BOMBER_JET_LOWER_Y_FROM_CENTER
            endif
            for j = 1 to Count
                Position.x = Bomber.LastJetX+(OutletX-EngineX)+(EngineX-Bomber.LastJetX)*j/Count
                // JetfireNew uses center positioning; nozzle offsets are sprite-center based.
                Position.y = OutletY
                JetfireNew(Jetfire,ProtoJetfire,World,Position,Now)
                Jetfire.SpriteData.Angle = -90
                Jetfire.SpriteData.Scale = BOMBER_JET_PARTICLE_SCALE

                Found = FALSE
                i = JetfireList.FirstFree
                while Found = FALSE and i <= JetfireList.Jetfire.Length
                    if JetfireList.Jetfire[i].Enabled = FALSE
                        Found = TRUE
                    else
                        i = i+1
                    endif
                endwhile
                if Found = FALSE
                    JetfireList.Jetfire.Insert(Jetfire)
                    JetfireList.FirstFree = JetfireList.Jetfire.Length
                else
                    JetfireList.Jetfire[i] = Jetfire
                    JetfireList.FirstFree = i+1
                endif
            next j
        next Outlet

        Bomber.LastJetX = EngineX
        Bomber.NextJetMs = Now+BOMBER_JET_INTERVAL_MS
    endif
endfunction

function BomberDo(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,Warning ref as TWarning,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Screen as TSize,Now as integer)
    local MinY as float
    local MaxY as float
    local HalfHeight as float
    local HalfWidth as float
    local DeltaMs as integer
    local i as integer
    local ActiveBombs as integer

    if ProtoBomber.Body.Sprite.ID <= 0 then exitfunction

    // Re-arm only after the previous flight and all released bombs have finished.
    // This avoids clearing live bombs when the next flight resets bomb slots.
    if Bomber.Phase = 3
        ActiveBombs = 0
        for i = 0 to BOMBER_BOMB_COUNT-1
            if Bomber.Bomb[i].Enabled = TRUE then ActiveBombs = ActiveBombs+1
        next i
        if ActiveBombs = 0
            Bomber.Phase = 0
            Bomber.NextWarningMs = Now+random(BOMBER_TEST_WAIT_MIN_MS,BOMBER_TEST_WAIT_MAX_MS)
        endif
    endif

    HalfHeight = GetSpriteHeight(ProtoBomber.Body.Sprite.ID)*0.5
    HalfWidth = GetSpriteWidth(ProtoBomber.Body.Sprite.ID)*0.5

    if Bomber.Phase = 0 and Now >= Bomber.NextWarningMs
        // World-relative altitude 10%-30%; only preview while the whole
        // ship can be seen in the current camera view.
        MinY = World.Size.Height*0.1
        MaxY = World.Size.Height*0.2
        if MinY < World.Position.y+HalfHeight+BOMBER_VIEW_MARGIN_Y
            MinY = World.Position.y+HalfHeight+BOMBER_VIEW_MARGIN_Y
        endif
        if MaxY > World.Position.y+Screen.Height-HalfHeight-BOMBER_VIEW_MARGIN_Y
            MaxY = World.Position.y+Screen.Height-HalfHeight-BOMBER_VIEW_MARGIN_Y
        endif
        if MaxY >= MinY and Warning.Count < NOTICE_MAX
            Bomber.Position.y = (MinY+MaxY)*0.5
            WarningShow(Warning,"SPACEJET INCOMING!",1,BOMBER_WARNING_LEAD_MS,Now)
            Bomber.SpawnAtMs = Now+BOMBER_WARNING_LEAD_MS
            Bomber.Phase = 1
        endif
    endif

    if Bomber.Phase = 1 and Now >= Bomber.SpawnAtMs
        Bomber.Position.x = Screen.Width+HalfWidth+BOMBER_ENTRY_MARGIN_X+Screen.Width*0.01*random(BOMBER_SPAWN_EXTRA_SCREEN_FRACTION1,BOMBER_SPAWN_EXTRA_SCREEN_FRACTION2)
        Bomber.LastMoveMs = Now
        Bomber.NextJetMs = Now
        Bomber.LastJetX = Bomber.Position.x+GetSpriteWidth(ProtoBomber.Body.Sprite.ID)*0.5-BOMBER_JET_UPPER_X_FROM_RIGHT
        Bomber.Enabled = TRUE
        Bomber.FlameTargetId = FlameNewTargetId()
        Bomber.Health = BOMBER_HEALTH_MAX
        Bomber.HitFlashUntil = 0
        Bomber.LastPlasmaHitMs = 0
        Bomber.Phase = 2
        Bomber.BombCount = 0
        // First release is timed from the actual spawn.
        Bomber.NextBombAtMs = Now+BOMBER_BOMB_INTERVAL_MS
    endif

    if Bomber.Enabled = TRUE
        DeltaMs = Now-Bomber.LastMoveMs
        if DeltaMs > 0
            Bomber.Position.x = Bomber.Position.x-DeltaMs*BOMBER_SPEED_PX_PER_MS
            Bomber.LastMoveMs = Now
        endif
        if Bomber.Position.x < -HalfWidth-BOMBER_ENTRY_MARGIN_X
            Bomber.Enabled = FALSE
            Bomber.Phase = 3
        else
            BomberJetfireDo(Bomber,ProtoBomber,JetfireList,ProtoJetfire,World,Now)
        endif
    endif
endfunction

// B2b: five independent bombs, spaced by time along the overflight.
// First release 250 ms after spawn; subsequent releases every 250 ms.
function BomberBombDo(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,World ref as TWorld,Screen as TSize,Now as integer)
    local DeltaMs as integer
    local DragFactor as float
    local HorizontalSpeed as float
    local i as integer

    if Bomber.Enabled = TRUE and Bomber.BombCount < BOMBER_BOMB_COUNT and ProtoBomber.Bomb.Sprite.ID > 0
        if Bomber.NextBombAtMs > 0 and Now >= Bomber.NextBombAtMs
            i = Bomber.BombCount
            Bomber.Bomb[i].Enabled = TRUE
            DamageOriginStart(Bomber.Bomb[i].DamageOrigin,DAMAGE_OBJECT_BOMBER,Bomber.FlameTargetId,DAMAGE_SOURCE_BOMB)
            Bomber.Bomb[i].Position.x = Bomber.Position.x
            Bomber.Bomb[i].Position.y = Bomber.Position.y+BOMBER_BOMB_RELEASE_Y
            Bomber.Bomb[i].PreviousPosition = Bomber.Bomb[i].Position
            Bomber.Bomb[i].Velocity.x = -BOMBER_SPEED_PX_PER_MS
            Bomber.Bomb[i].Velocity.y = 0
            Bomber.Bomb[i].LastMoveMs = Now
            Bomber.Bomb[i].SpriteData.Angle = 0
            Bomber.BombCount = Bomber.BombCount+1
            Bomber.NextBombAtMs = Now+BOMBER_BOMB_INTERVAL_MS
        endif
    endif

    for i = 0 to BOMBER_BOMB_COUNT-1
        if Bomber.Bomb[i].Enabled = TRUE
            // A closed/zero-duration update must not replay the prior sweep.
            Bomber.Bomb[i].SweepStartMs = Bomber.Bomb[i].LastMoveMs
            Bomber.Bomb[i].PreviousPosition = Bomber.Bomb[i].Position
            DeltaMs = Now-Bomber.Bomb[i].LastMoveMs
            if DeltaMs > 0
                DragFactor = 1.0/(1.0+BOMBER_BOMB_DRAG_PER_MS*DeltaMs)
                Bomber.Bomb[i].Velocity.x = Bomber.Bomb[i].Velocity.x*DragFactor
                Bomber.Bomb[i].Velocity.y = Bomber.Bomb[i].Velocity.y+BOMBER_BOMB_GRAVITY_PX_PER_MS2*DeltaMs
                Bomber.Bomb[i].Position.x = Bomber.Bomb[i].Position.x+Bomber.Bomb[i].Velocity.x*DeltaMs
                Bomber.Bomb[i].Position.y = Bomber.Bomb[i].Position.y+Bomber.Bomb[i].Velocity.y*DeltaMs
                HorizontalSpeed = Abs(Bomber.Bomb[i].Velocity.x)
                Bomber.Bomb[i].SpriteData.Angle = -90.0*Bomber.Bomb[i].Velocity.y/(HorizontalSpeed+Bomber.Bomb[i].Velocity.y+0.00001)
                Bomber.Bomb[i].LastMoveMs = Now
            endif
        endif
    next i
endfunction

// Cull after direct contacts and all interception passes.
function BomberBombCullAll(Bomber ref as TBomber,World ref as TWorld)
    local i as integer
    for i = 0 to BOMBER_BOMB_COUNT-1
        if Bomber.Bomb[i].Enabled = TRUE
            if Bomber.Bomb[i].Position.y > World.Size.Height+32 or Bomber.Bomb[i].Position.x < -32 then Bomber.Bomb[i].Enabled = FALSE
        endif
    next i
endfunction

// B2c: detect a downward crossing of a platform's upper surface.
// Interpolate X at the crossing so fast-moving bombs cannot skip a thin plate.
// The bomb tip is approximated by a small vertical offset; later polishing
// can use a rotated shape. Explosion damage uses the existing game system.
// B2g: swept bomb-versus-Sonec contact; one direct hit per bomb.
// A direct impact consumes the bomb and uses the existing shield/health rules.
#constant BOMBER_BOMB_DIRECT_DAMAGE 100
#constant BOMBER_BOMB_HIT_RADIUS 7

// B3a: only Sonec's machine-gun bullets can intercept falling bombs.
// Sweep the bullet's last movement segment against a small bomb hit circle.
#constant BOMBER_BOMB_SHOT_RADIUS 7

// B3b: use the existing growing flame radius to intercept bomber bombs.
// Consume the bomb only; penetrating flame remains active.
// B3c: a plasma discharge intercepts bombs inside its existing hit area.
// Plasma persists, as it does against other targets; each bomb can explode once.
// B3d: a player grenade directly intercepts a falling bomb.
// Both projectiles are consumed and one normal red blast is created.

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BomberBombCollidePlasmaBlitz(Bomber ref as TBomber,PlasmaBlitzList ref as TPlasmaBlitzList,Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local Entry as float
    local HitPosition as TPosition

    for i = 0 to PlasmaBlitzList.PlasmaBlitz.Length
        if PlasmaBlitzList.PlasmaBlitz[i].Enabled = TRUE
            for k = 0 to BOMBER_BOMB_COUNT-1
                if Bomber.Bomb[k].Enabled = TRUE
                    Entry = CollisionTimedAreaEntry(Bomber.Bomb[k].PreviousPosition,Bomber.Bomb[k].Position,Bomber.Bomb[k].SweepStartMs,Bomber.Bomb[k].LastMoveMs,PlasmaBlitzList.PlasmaBlitz[i].CreatedMs,PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position1,PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position2,BOMBER_BOMB_SHOT_RADIUS)
                    if Entry >= 0
                        HitPosition = Bomber.Bomb[k].Position
                        Bomber.Bomb[k].Enabled = FALSE
                        ExplosionAddAttributed(Game.ExplosionList,Game.ProtoExplosion,Game,1,HitPosition,Now,PlasmaBlitzList.PlasmaBlitz[i].BulletData.DamageOrigin)
                    endif
                endif
            next k
        endif
    next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BomberBombCollideFlames(Bomber ref as TBomber,FlameList ref as TFlameList,Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local Radius as float
    local Entry as float
    local HitPosition as TPosition

    for i = 0 to FlameList.Flame.Length
        if FlameList.Flame[i].Enabled = TRUE
            Radius = FlameCollisionRadius(FlameList.Flame[i])+BOMBER_BOMB_SHOT_RADIUS
            for k = 0 to BOMBER_BOMB_COUNT-1
                if FlameList.Flame[i].Enabled = TRUE and Bomber.Bomb[k].Enabled = TRUE
                    Entry = CollisionTimedCircleEntry(FlameList.Flame[i].PreviousPosition,FlameList.Flame[i].ObjectData.Position,FlameList.Flame[i].SweepStartMs,FlameList.Flame[i].SweepEndMs,Bomber.Bomb[k].PreviousPosition,Bomber.Bomb[k].Position,Bomber.Bomb[k].SweepStartMs,Bomber.Bomb[k].LastMoveMs,Radius)
                    if Entry >= 0
                        HitPosition = Bomber.Bomb[k].Position
                        Bomber.Bomb[k].Enabled = FALSE
                        ExplosionAddAttributed(Game.ExplosionList,Game.ProtoExplosion,Game,1,HitPosition,Now,FlameList.Flame[i].BulletData.DamageOrigin)
                    endif
                endif
            next k
        endif
    next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BomberBombCollideBullets(Bomber ref as TBomber,BulletList ref as TBulletList,ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local StartMs as integer
    local Entry as float
    local BestEntry as float
    local BestIndex as integer
    local Radius as float
    local HitPosition as TPosition
    for i = 0 to BulletList.Bullet.Length
        if BulletList.Bullet[i].Enabled = TRUE and BulletList.Bullet[i].CollisionData.CollisionType = TYPEPLAYERONE
            StartMs = BulletList.Bullet[i].SonecSweepStartMs
            if BulletList.Bullet[i].SonecSweepReady = FALSE
                if StartMs < SonecDamageFrameStartMs then StartMs = SonecDamageFrameStartMs
            endif
            Radius = BOMBER_BOMB_SHOT_RADIUS+BulletList.Bullet[i].ObjectData.Radius
            BestEntry = 2.0
            BestIndex = -1
            for k = 0 to BOMBER_BOMB_COUNT-1
                if Bomber.Bomb[k].Enabled = TRUE
                    Entry = CollisionTimedCircleEntry(BulletList.Bullet[i].PreviousPosition,BulletList.Bullet[i].ObjectData.Position,StartMs,BulletList.Bullet[i].SonecSweepEndMs,Bomber.Bomb[k].PreviousPosition,Bomber.Bomb[k].Position,Bomber.Bomb[k].SweepStartMs,Bomber.Bomb[k].LastMoveMs,Radius)
                    if Entry >= 0 and Entry < BestEntry
                        BestEntry = Entry
                        BestIndex = k
                    endif
                endif
            next k
            if BestIndex >= 0
                HitPosition = Bomber.Bomb[BestIndex].Position
                Bomber.Bomb[BestIndex].Enabled = FALSE
                BulletDelete(BulletList,i)
                ExplosionAddAttributed(ExplosionList,ProtoExplosion,Game,1,HitPosition,Now,BulletList.Bullet[i].BulletData.DamageOrigin)
            endif
        endif
    next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Convert the start of this bomb's flight step to the current frame's
// platform/chest interpolation fraction (newly released bombs start at 1).
function BomberBombFrameStart(Bomb ref as TBomberBomb)
    local Fraction as float
    local FrameMs as integer
    FrameMs = SonecDamageFrameEndMs-SonecDamageFrameStartMs
    if FrameMs <= 0 then exitfunction 1.0
    Fraction = (Bomb.SweepStartMs-SonecDamageFrameStartMs)*1.0/FrameMs
    if Fraction < 0 then Fraction = 0
    if Fraction > 1 then Fraction = 1
endfunction Fraction

// A chest is a translating AABB. Transform the bomb's start point into
// the final chest reference frame, retaining the existing radius expansion.
function BomberBombChestEntry(Bomb ref as TBomberBomb,Chest ref as TChest,FrameStart as float,NewCarrier as integer)
    local StartPos as TPosition
    local Entry as float
    if NewCarrier = TRUE
        // A chest created in this update cannot be hit before its creation.
        Entry = CollisionBoxSweepEntry(Bomb.Position,Bomb.Position,Chest.CollisionData.Position1,Chest.CollisionData.Position2,BOMBER_BOMB_HIT_RADIUS,BOMBER_BOMB_HIT_RADIUS)
        if Entry >= 0 then exitfunction 1.0
        exitfunction -1.0
    endif
    StartPos.x = Bomb.PreviousPosition.x+(Chest.ObjectData.Position.x-Chest.CollisionMoveStart.x)*(1.0-FrameStart)
    StartPos.y = Bomb.PreviousPosition.y+(Chest.ObjectData.Position.y-Chest.CollisionMoveStart.y)*(1.0-FrameStart)
    Entry = CollisionBoxSweepEntry(StartPos,Bomb.Position,Chest.CollisionData.Position1,Chest.CollisionData.Position2,BOMBER_BOMB_HIT_RADIUS,BOMBER_BOMB_HIT_RADIUS)
endfunction Entry

// One-way top-surface test in the moving plate's frame, retaining the
// original +5px vertical bomb tip and inclusive horizontal edge rule.
function BomberBombPlateEntry(Bomb ref as TBomberBomb,Plate ref as TPlate,FrameStart as float)
    local RelativeOldY as float
    local RelativeNewY as float
    local RelativeOldX as float
    local RelativeNewX as float
    local HitX as float
    local Fraction as float
    if Bomb.Velocity.y <= 0 or FrameStart >= 1 then exitfunction -1.0
    // New plates have not existed through the frame's earlier interval.
    if Plate.DebugFrameMs <= 0 then exitfunction -1.0
    RelativeOldY = Bomb.PreviousPosition.y+5-Plate.CollisionData.Position1.y+(Plate.ObjectData.Position.y-Plate.CollisionMoveStart.y)*(1.0-FrameStart)
    RelativeNewY = Bomb.Position.y+5-Plate.CollisionData.Position1.y
    if RelativeOldY > 0 or RelativeNewY < 0 or RelativeNewY <= RelativeOldY then exitfunction -1.0
    Fraction = -RelativeOldY/(RelativeNewY-RelativeOldY)
    RelativeOldX = Bomb.PreviousPosition.x-Plate.CollisionData.Position1.x+(Plate.ObjectData.Position.x-Plate.CollisionMoveStart.x)*(1.0-FrameStart)
    RelativeNewX = Bomb.Position.x-Plate.CollisionData.Position1.x
    HitX = RelativeOldX+(RelativeNewX-RelativeOldX)*Fraction
    if HitX >= 0 and HitX <= Plate.CollisionData.Position2.x-Plate.CollisionData.Position1.x then exitfunction Fraction
endfunction -1.0

// Keep the explosion at its contact offset on the carrier. The remaining
// movement of the carrier has already been simulated for this frame.
function BomberBombAddPlateExplosion(Game ref as TGame,PlateIndex as integer,Impact as TPosition,FrameContact as float,Now as integer,Origin ref as TDamageOrigin)
    Impact.x = Impact.x+(Game.PlateList.Plate[PlateIndex].ObjectData.Position.x-Game.PlateList.Plate[PlateIndex].CollisionMoveStart.x)*(1.0-FrameContact)
    Impact.y = Impact.y+(Game.PlateList.Plate[PlateIndex].ObjectData.Position.y-Game.PlateList.Plate[PlateIndex].CollisionMoveStart.y)*(1.0-FrameContact)
    ExplosionAddAboveYAttributed(Game.ExplosionList,Game.ProtoExplosion,Game,1,Impact,Game.PlateList.Plate[PlateIndex].CollisionData.Position1.y,Game.PlateList.Plate[PlateIndex].CollisionData.Position1.x,Game.PlateList.Plate[PlateIndex].CollisionData.Position2.x,PlateIndex,Now,Origin)
endfunction

// Earliest contact across the three existing target families, once per bomb.
// Exact ties preserve the previous order (Sonec, chest, plate; lowest slot).
function BomberBombCollideAll(Bomber ref as TBomber,Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local CircleIndex as integer
    local BestType as integer
    local BestIndex as integer
    local BestFraction as float
    local Entry as float
    local FrameStart as float
    local FrameContact as float
    local HitPosition as TPosition
    local PlateIndex as integer
    local NewCarrier as integer
    local HealthBeforeHit as integer
    local DamageResult as TDamageResult
    local MechanicalSlot as integer

    for i = 0 to BOMBER_BOMB_COUNT-1
        if Bomber.Bomb[i].Enabled = TRUE
            BestType = 0
            BestIndex = -1
            BestFraction = 2.0
            FrameStart = BomberBombFrameStart(Bomber.Bomb[i])
            if Game.Sonec.IsLost = FALSE
                for CircleIndex = 0 to 1
                    Entry = SonecDamageSweepEntry(Game.Sonec,Bomber.Bomb[i].PreviousPosition,Bomber.Bomb[i].Position,Bomber.Bomb[i].SweepStartMs,Bomber.Bomb[i].LastMoveMs,CircleIndex,BOMBER_BOMB_HIT_RADIUS,0,FALSE)
                    if Entry >= 0 and Entry < BestFraction
                        BestFraction = Entry
                        BestType = 1
                    endif
                next CircleIndex
            endif
            for k = 0 to Game.ChestList.Chest.Length
                if Game.ChestList.Chest[k].Enabled = TRUE
                    NewCarrier = FALSE
                    PlateIndex = Game.ChestList.Chest[k].CollisionData.Index
                    if PlateIndex >= 0 and PlateIndex <= Game.PlateList.Plate.Length
                        if Game.PlateList.Plate[PlateIndex].Enabled = TRUE and Game.PlateList.Plate[PlateIndex].DebugFrameMs <= 0 then NewCarrier = TRUE
                    endif
                    Entry = BomberBombChestEntry(Bomber.Bomb[i],Game.ChestList.Chest[k],FrameStart,NewCarrier)
                    if Entry >= 0 and Entry < BestFraction
                        BestFraction = Entry
                        BestType = 2
                        BestIndex = k
                    endif
                endif
            next k
            for k = 0 to Game.PlateList.Plate.Length
                if Game.PlateList.Plate[k].Enabled = TRUE
                    Entry = BomberBombPlateEntry(Bomber.Bomb[i],Game.PlateList.Plate[k],FrameStart)
                    if Entry >= 0 and Entry < BestFraction
                        BestFraction = Entry
                        BestType = 3
                        BestIndex = k
                    endif
                endif
            next k
            if BestType > 0
                HitPosition.x = Bomber.Bomb[i].PreviousPosition.x+(Bomber.Bomb[i].Position.x-Bomber.Bomb[i].PreviousPosition.x)*BestFraction
                HitPosition.y = Bomber.Bomb[i].PreviousPosition.y+(Bomber.Bomb[i].Position.y-Bomber.Bomb[i].PreviousPosition.y)*BestFraction
                FrameContact = FrameStart+(1.0-FrameStart)*BestFraction
                Bomber.Bomb[i].Enabled = FALSE
                if BestType = 1
                    HealthBeforeHit = Game.Sonec.Health.State
                    DamageApplySonec(Game.Sonec,Game.Shield,BOMBER_BOMB_DIRECT_DAMAGE,Bomber.Bomb[i].DamageOrigin,0,Now,DamageResult)
                    if Game.Sonec.Health.State < HealthBeforeHit then SonecHitFlashUntil = Now+SONEC_HIT_FLASH_MS
                    ExplosionAddAttributed(Game.ExplosionList,Game.ProtoExplosion,Game,1,HitPosition,Now,Bomber.Bomb[i].DamageOrigin)
                endif
                if BestType = 2
                    PlateIndex = Game.ChestList.Chest[BestIndex].CollisionData.Index
                    DamageRecordImmediateDestruction(Game.ChestList.Chest[BestIndex].Health.State,Bomber.Bomb[i].DamageOrigin,DAMAGE_OBJECT_CHEST,Game.ChestList.Chest[BestIndex].FlameTargetId,Now)
                    RewardDrop(Game,REWARD_OBJECT_CHEST,Game.ChestList.Chest[BestIndex].ObjectData.Position,Now)
                    ChestDelete(Game.ChestList,BestIndex)
                    // The mechanical pass has finished. Release a destroyed
                    // foreground support through the established reset path.
                    MechanicalSlot = BestIndex*SONEC_MECHANICAL_SLOT_STRIDE+SONEC_MECHANICAL_CHEST_SLOT
                    if Game.ChestList.Chest[BestIndex].IsBackground = FALSE
                        if MechanicalSlot >= 0 and MechanicalSlot <= SonecMechanicalList.Chest.Length
                            SonecMechanicalList.Chest[MechanicalSlot].Enabled = FALSE
                        endif
                        if Game.Sonec.GroundContactActive = TRUE and Game.Sonec.CollisionData.ListType = TYPECHEST and Game.Sonec.CollisionData.Index = MechanicalSlot then SonecCollideReset(Game.Sonec)
                    endif
                    if PlateIndex >= 0 and PlateIndex <= Game.PlateList.Plate.Length
                        if Game.PlateList.Plate[PlateIndex].Enabled = TRUE
                            BomberBombAddPlateExplosion(Game,PlateIndex,HitPosition,FrameContact,Now,Bomber.Bomb[i].DamageOrigin)
                        else
                            ExplosionAddAttributed(Game.ExplosionList,Game.ProtoExplosion,Game,1,HitPosition,Now,Bomber.Bomb[i].DamageOrigin)
                        endif
                    else
                        ExplosionAddAttributed(Game.ExplosionList,Game.ProtoExplosion,Game,1,HitPosition,Now,Bomber.Bomb[i].DamageOrigin)
                    endif
                endif
                if BestType = 3
                    // The tip, not the center, contacts the top surface.
                    HitPosition.y = HitPosition.y+5
                    BomberBombAddPlateExplosion(Game,BestIndex,HitPosition,FrameContact,Now,Bomber.Bomb[i].DamageOrigin)
                endif
            endif
        endif
    next i
endfunction

// B4: one shared damage/death path for all four Sonec weapons.
function BomberTakeDamage(Bomber ref as TBomber,Game ref as TGame,Damage as integer,Now as integer,Origin ref as TDamageOrigin)
    local i as integer
    local Position as TPosition
    if Bomber.Enabled = FALSE then exitfunction
    Bomber.Health = DamageApplyDirectValue(Bomber.Health,Damage,Origin,DAMAGE_OBJECT_BOMBER,Bomber.FlameTargetId)
    Bomber.HitFlashUntil = Now+BOMBER_HIT_FLASH_MS
    if Bomber.Health <= 0
        DamageRecordDestruction(Origin,DAMAGE_OBJECT_BOMBER,Bomber.FlameTargetId,Now)
        Position = Bomber.Position
        Bomber.Enabled = FALSE
        Bomber.Phase = 3
        // Already released bombs continue to fall; no further bombs are released.
        ExplosionAddAttributed(Game.ExplosionList,Game.ProtoExplosion,Game,1,Position,Now,Origin)
        RewardDrop(Game,REWARD_OBJECT_BOMBER,Position,Now)
    endif
endfunction

function BomberCollideWeapons(Bomber ref as TBomber,Game ref as TGame,Now as integer)
    local i as integer
    local MinPos as TPosition
    local MaxPos as TPosition
    local Dx as float
    local Dy as float
    local LengthSq as float
    local Fraction as float
    local NearX as float
    local NearY as float
    local Radius as float

    if Bomber.Enabled = FALSE then exitfunction
    MinPos.x = Bomber.Position.x-BOMBER_HIT_HALF_WIDTH
    MinPos.y = Bomber.Position.y-BOMBER_HIT_HALF_HEIGHT
    MaxPos.x = Bomber.Position.x+BOMBER_HIT_HALF_WIDTH
    MaxPos.y = Bomber.Position.y+BOMBER_HIT_HALF_HEIGHT

    // MG: swept segment versus enlarged body rectangle.
    for i = 0 to Game.BulletList.Bullet.Length
        if Bomber.Enabled = TRUE and Game.BulletList.Bullet[i].Enabled = TRUE and Game.BulletList.Bullet[i].CollisionData.CollisionType = TYPEPLAYERONE
            Dx = Game.BulletList.Bullet[i].ObjectData.Position.x-Game.BulletList.Bullet[i].PreviousPosition.x
            Dy = Game.BulletList.Bullet[i].ObjectData.Position.y-Game.BulletList.Bullet[i].PreviousPosition.y
            LengthSq = Dx*Dx+Dy*Dy
            Fraction = 0
            if LengthSq > 0
                Fraction = ((Bomber.Position.x-Game.BulletList.Bullet[i].PreviousPosition.x)*Dx+(Bomber.Position.y-Game.BulletList.Bullet[i].PreviousPosition.y)*Dy)/LengthSq
                if Fraction < 0 then Fraction = 0
                if Fraction > 1 then Fraction = 1
            endif
            NearX = Game.BulletList.Bullet[i].PreviousPosition.x+Fraction*Dx
            NearY = Game.BulletList.Bullet[i].PreviousPosition.y+Fraction*Dy
            Radius = Game.BulletList.Bullet[i].ObjectData.Radius
            if NearX >= MinPos.x-Radius and NearX <= MaxPos.x+Radius and NearY >= MinPos.y-Radius and NearY <= MaxPos.y+Radius
                BomberTakeDamage(Bomber,Game,Game.BulletList.Bullet[i].BulletData.Damage,Now,Game.BulletList.Bullet[i].BulletData.DamageOrigin)
                BulletDelete(Game.BulletList,i)
            endif
        endif
    next i

    // Flamethrower: penetrating particles damage each live body at timed intervals.
    for i = 0 to Game.FlameList.Flame.Length
        if Bomber.Enabled = TRUE and Game.FlameList.Flame[i].Enabled = TRUE
            Radius = FlameCollisionRadius(Game.FlameList.Flame[i])
            NearX = Game.FlameList.Flame[i].ObjectData.Position.x
            NearY = Game.FlameList.Flame[i].ObjectData.Position.y
            if NearX >= MinPos.x-Radius and NearX <= MaxPos.x+Radius and NearY >= MinPos.y-Radius and NearY <= MaxPos.y+Radius
                if FlameCanDamage(Game.FlameList.Flame[i],Bomber.FlameTargetId,Now) = TRUE
                    BomberTakeDamage(Bomber,Game,Game.FlameList.Flame[i].BulletData.Damage,Now,Game.FlameList.Flame[i].BulletData.DamageOrigin)
                endif
            endif
        endif
    next i

    // Plasma: sustained contact damages at the existing 100 ms interval.
    if Bomber.Enabled = TRUE and (Bomber.LastPlasmaHitMs = 0 or Now-Bomber.LastPlasmaHitMs >= BOMBER_PLASMA_HIT_INTERVAL_MS)
        for i = 0 to Game.PlasmaBlitzList.PlasmaBlitz.Length
            if Bomber.Enabled = TRUE and Game.PlasmaBlitzList.PlasmaBlitz[i].Enabled = TRUE
                if BoxInBox(Game.PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position1,Game.PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position2,MinPos,MaxPos)
                    BomberTakeDamage(Bomber,Game,Game.PlasmaBlitzList.PlasmaBlitz[i].BulletData.Damage,Now,Game.PlasmaBlitzList.PlasmaBlitz[i].BulletData.DamageOrigin)
                    Bomber.LastPlasmaHitMs = Now
                    exitfunction
                endif
            endif
        next i
    endif
endfunction

function BomberBombDraw(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,World ref as TWorld)
    local i as integer
    if ProtoBomber.Bomb.Sprite.ID > 0
        for i = 0 to BOMBER_BOMB_COUNT-1
            if Bomber.Bomb[i].Enabled = TRUE
                SpritePositionCalc(Bomber.Bomb[i].SpriteData.Position,Bomber.Bomb[i].Position,World.Position)
                SpriteDraw(ProtoBomber.Bomb.Sprite,Bomber.Bomb[i].SpriteData)
            endif
        next i
    endif
endfunction

function BomberDraw(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,World ref as TWorld)
    if Bomber.Enabled = TRUE
        SpritePositionCalc(Bomber.SpriteData.Position,Bomber.Position,World.Position)
        if GetMilliseconds() < Bomber.HitFlashUntil
            ColorSet(Bomber.SpriteData.Color,255,0,0,255)
        else
            ColorSet(Bomber.SpriteData.Color,80,232,80,255)
        endif
        SpriteDraw(ProtoBomber.Body.Sprite,Bomber.SpriteData)
    endif
endfunction
