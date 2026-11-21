// B1: one unarmed spacejet overflight for visual speed/size evaluation.
// Temporary once-per-game test entry; Chat B will later own spawn scheduling.
#constant BOMBER_TEST_WAIT_MS 4000
#constant BOMBER_WARNING_LEAD_MS 2200
#constant BOMBER_SPEED_PX_PER_MS 0.40
#constant BOMBER_ENTRY_MARGIN_X 65
#constant BOMBER_SPAWN_EXTRA_SCREEN_FRACTION 0.25
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

// Phase: 0 = waiting for a visible flight corridor, 1 = warning,
// 2 = flying, 3 = finished. At most one bomber; no bomber array.
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
    Bomber.Phase = 0
    Bomber.NextWarningMs = Now+BOMBER_TEST_WAIT_MS
    Bomber.SpawnAtMs = 0
    Bomber.LastMoveMs = Now
    Bomber.NextJetMs = Now
    Bomber.LastJetX = 0
    Bomber.BombCount = 0
    Bomber.NextBombAtMs = 0
    for i = 0 to BOMBER_BOMB_COUNT-1
        Bomber.Bomb[i].Enabled = FALSE
        Bomber.Bomb[i].LastMoveMs = Now
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

    if ProtoBomber.Body.Sprite.ID <= 0 then exitfunction

    HalfHeight = GetSpriteHeight(ProtoBomber.Body.Sprite.ID)*0.5
    HalfWidth = GetSpriteWidth(ProtoBomber.Body.Sprite.ID)*0.5

    if Bomber.Phase = 0 and Now >= Bomber.NextWarningMs
        // World-relative altitude 10%-30%; only preview while the whole
        // ship can be seen in the current camera view.
        MinY = World.Size.Height*0.10
        MaxY = World.Size.Height*0.30
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
        Bomber.Position.x = Screen.Width+HalfWidth+BOMBER_ENTRY_MARGIN_X+Screen.Width*BOMBER_SPAWN_EXTRA_SCREEN_FRACTION
        Bomber.LastMoveMs = Now
        Bomber.NextJetMs = Now
        Bomber.LastJetX = Bomber.Position.x+GetSpriteWidth(ProtoBomber.Body.Sprite.ID)*0.5-BOMBER_JET_UPPER_X_FROM_RIGHT
        Bomber.Enabled = TRUE
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
            DeltaMs = Now-Bomber.Bomb[i].LastMoveMs
            if DeltaMs > 0
                Bomber.Bomb[i].PreviousPosition = Bomber.Bomb[i].Position
                DragFactor = 1.0/(1.0+BOMBER_BOMB_DRAG_PER_MS*DeltaMs)
                Bomber.Bomb[i].Velocity.x = Bomber.Bomb[i].Velocity.x*DragFactor
                Bomber.Bomb[i].Velocity.y = Bomber.Bomb[i].Velocity.y+BOMBER_BOMB_GRAVITY_PX_PER_MS2*DeltaMs
                Bomber.Bomb[i].Position.x = Bomber.Bomb[i].Position.x+Bomber.Bomb[i].Velocity.x*DeltaMs
                Bomber.Bomb[i].Position.y = Bomber.Bomb[i].Position.y+Bomber.Bomb[i].Velocity.y*DeltaMs
                HorizontalSpeed = Abs(Bomber.Bomb[i].Velocity.x)
                Bomber.Bomb[i].SpriteData.Angle = -90.0*Bomber.Bomb[i].Velocity.y/(HorizontalSpeed+Bomber.Bomb[i].Velocity.y+0.00001)
                Bomber.Bomb[i].LastMoveMs = Now
            endif
            if Bomber.Bomb[i].Position.y > World.Size.Height+32 or Bomber.Bomb[i].Position.x < -32
                Bomber.Bomb[i].Enabled = FALSE
            endif
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

function BomberBombCollideBullets(Bomber ref as TBomber,BulletList ref as TBulletList,ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local Dx as float
    local Dy as float
    local LengthSq as float
    local Fraction as float
    local NearestX as float
    local NearestY as float
    local HitX as float
    local HitY as float
    local Radius as float
    local HitPosition as TPosition

    for i = 0 to BulletList.Bullet.Length
        if BulletList.Bullet[i].Enabled = TRUE and BulletList.Bullet[i].CollisionData.CollisionType = TYPEPLAYERONE
            Dx = BulletList.Bullet[i].ObjectData.Position.x-BulletList.Bullet[i].PreviousPosition.x
            Dy = BulletList.Bullet[i].ObjectData.Position.y-BulletList.Bullet[i].PreviousPosition.y
            LengthSq = Dx*Dx+Dy*Dy
            Radius = BOMBER_BOMB_SHOT_RADIUS+BulletList.Bullet[i].ObjectData.Radius
            for k = 0 to BOMBER_BOMB_COUNT-1
                if BulletList.Bullet[i].Enabled = TRUE and Bomber.Bomb[k].Enabled = TRUE
                    Fraction = 0
                    if LengthSq > 0
                        Fraction = ((Bomber.Bomb[k].Position.x-BulletList.Bullet[i].PreviousPosition.x)*Dx+(Bomber.Bomb[k].Position.y-BulletList.Bullet[i].PreviousPosition.y)*Dy)/LengthSq
                        if Fraction < 0 then Fraction = 0
                        if Fraction > 1 then Fraction = 1
                    endif
                    NearestX = BulletList.Bullet[i].PreviousPosition.x+Fraction*Dx
                    NearestY = BulletList.Bullet[i].PreviousPosition.y+Fraction*Dy
                    HitX = NearestX-Bomber.Bomb[k].Position.x
                    HitY = NearestY-Bomber.Bomb[k].Position.y
                    if HitX*HitX+HitY*HitY <= Radius*Radius
                        Bomber.Bomb[k].Enabled = FALSE
                        BulletDelete(BulletList,i)
                        HitPosition = Bomber.Bomb[k].Position
                        ExplosionAdd(ExplosionList,ProtoExplosion,Game,1,HitPosition,Now)
                    endif
                endif
            next k
        endif
    next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BomberBombCollideSonec(Bomber ref as TBomber,Game ref as TGame,Now as integer)
    local i as integer
    local DeltaX as float
    local DeltaY as float
    local Fraction as float
    local LengthSquared as float
    local NearestX as float
    local NearestY as float
    local Radius as float
    local HealthBeforeHit as integer
    local HitPosition as TPosition

    if Game.Sonec.IsLost = TRUE then exitfunction
    Radius = Game.Sonec.ObjectData.Radius+BOMBER_BOMB_HIT_RADIUS
    for i = 0 to BOMBER_BOMB_COUNT-1
        if Bomber.Bomb[i].Enabled = TRUE
            DeltaX = Bomber.Bomb[i].Position.x-Bomber.Bomb[i].PreviousPosition.x
            DeltaY = Bomber.Bomb[i].Position.y-Bomber.Bomb[i].PreviousPosition.y
            LengthSquared = DeltaX*DeltaX+DeltaY*DeltaY
            Fraction = 0
            if LengthSquared > 0
                Fraction = ((Game.Sonec.ObjectData.Position.x-Bomber.Bomb[i].PreviousPosition.x)*DeltaX+(Game.Sonec.ObjectData.Position.y-Bomber.Bomb[i].PreviousPosition.y)*DeltaY)/LengthSquared
                if Fraction < 0 then Fraction = 0
                if Fraction > 1 then Fraction = 1
            endif
            NearestX = Bomber.Bomb[i].PreviousPosition.x+Fraction*DeltaX
            NearestY = Bomber.Bomb[i].PreviousPosition.y+Fraction*DeltaY
            if (NearestX-Game.Sonec.ObjectData.Position.x)*(NearestX-Game.Sonec.ObjectData.Position.x)+(NearestY-Game.Sonec.ObjectData.Position.y)*(NearestY-Game.Sonec.ObjectData.Position.y) <= Radius*Radius
                Bomber.Bomb[i].Enabled = FALSE
                HealthBeforeHit = Game.Sonec.Health.State
                Game.Sonec.Health.State = Game.Sonec.Health.State-(BOMBER_BOMB_DIRECT_DAMAGE-ShieldAbsorbDamage(Game.Shield,Game.Sonec,BOMBER_BOMB_DIRECT_DAMAGE,Now))
                if Game.Sonec.Health.State < HealthBeforeHit then SonecHitFlashUntil = Now+SONEC_HIT_FLASH_MS
                HitPosition.x = NearestX
                HitPosition.y = NearestY
                ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,1,HitPosition,Now)
            endif
        endif
    next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BomberBombCollidePlate(Bomber ref as TBomber,PlateList ref as TPlateList,Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local TopY as float
    local OldTipY as float
    local NewTipY as float
    local HitX as float
    local Fraction as float
    local HitPosition as TPosition

    for i = 0 to BOMBER_BOMB_COUNT-1
        if Bomber.Bomb[i].Enabled = TRUE and Bomber.Bomb[i].Velocity.y > 0
            OldTipY = Bomber.Bomb[i].PreviousPosition.y+5
            NewTipY = Bomber.Bomb[i].Position.y+5
            for k = 0 to PlateList.Plate.Length
                if Bomber.Bomb[i].Enabled = TRUE and PlateList.Plate[k].Enabled = TRUE
                    TopY = PlateList.Plate[k].CollisionData.Position1.y
                    if OldTipY <= TopY and NewTipY >= TopY and NewTipY > OldTipY
                        Fraction = (TopY-OldTipY)/(NewTipY-OldTipY)
                        HitX = Bomber.Bomb[i].PreviousPosition.x+(Bomber.Bomb[i].Position.x-Bomber.Bomb[i].PreviousPosition.x)*Fraction
                        if HitX >= PlateList.Plate[k].CollisionData.Position1.x and HitX <= PlateList.Plate[k].CollisionData.Position2.x
                            HitPosition.x = HitX
                            HitPosition.y = TopY
                            Bomber.Bomb[i].Enabled = FALSE
                            ExplosionAddAboveY(Game.ExplosionList,Game.ProtoExplosion,Game,1,HitPosition,TopY,PlateList.Plate[k].CollisionData.Position1.x,PlateList.Plate[k].CollisionData.Position2.x,k,Now)
                        endif
                    endif
                endif
            next k
        endif
    next i
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
        SpriteDraw(ProtoBomber.Body.Sprite,Bomber.SpriteData)
    endif
endfunction
