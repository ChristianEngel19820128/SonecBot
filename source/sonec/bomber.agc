// B1: one unarmed spacejet overflight for visual speed/size evaluation.
// Temporary once-per-game test entry; Chat B will later own spawn scheduling.
#constant BOMBER_TEST_WAIT_MS 4000
#constant BOMBER_WARNING_LEAD_MS 2200
#constant BOMBER_SPEED_PX_PER_MS 0.40
#constant BOMBER_ENTRY_MARGIN_X 65
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
// B2a: one visual-only test bomb; values are provisional.
#constant BOMBER_BOMB_GRAVITY_PX_PER_MS2 0.00022
#constant BOMBER_BOMB_DRAG_PER_MS 0.0005
#constant BOMBER_BOMB_RELEASE_Y 20

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
    Bomber.Enabled = FALSE
    Bomber.Phase = 0
    Bomber.NextWarningMs = Now+BOMBER_TEST_WAIT_MS
    Bomber.SpawnAtMs = 0
    Bomber.LastMoveMs = Now
    Bomber.NextJetMs = Now
    Bomber.LastJetX = 0
    Bomber.BombDropped = FALSE
    Bomber.BombEnabled = FALSE
    Bomber.BombLastMoveMs = Now
    Bomber.BombPosition.x = 0
    Bomber.BombPosition.y = 0
    Bomber.BombVelocity.x = 0
    Bomber.BombVelocity.y = 0
    Bomber.BombSpriteData.Angle = 0
    Bomber.BombSpriteData.Scale = 1
    Bomber.BombSpriteData.Center = TRUE
    ColorSet(Bomber.BombSpriteData.Color,255,255,255,255)
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
        Bomber.Position.x = Screen.Width+HalfWidth+BOMBER_ENTRY_MARGIN_X
        Bomber.LastMoveMs = Now
        Bomber.NextJetMs = Now
        Bomber.LastJetX = Bomber.Position.x+GetSpriteWidth(ProtoBomber.Body.Sprite.ID)*0.5-BOMBER_JET_UPPER_X_FROM_RIGHT
        Bomber.Enabled = TRUE
        Bomber.Phase = 2
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

// B2a: independent world-space motion, no collisions or damage yet.
function BomberBombDo(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,World ref as TWorld,Screen as TSize,Now as integer)
    local DeltaMs as integer
    local DragFactor as float
    local HorizontalSpeed as float

    if Bomber.Enabled = TRUE and Bomber.BombDropped = FALSE and ProtoBomber.Bomb.Sprite.ID > 0
        if Bomber.Position.x <= Screen.Width*0.5
            Bomber.BombDropped = TRUE
            Bomber.BombEnabled = TRUE
            Bomber.BombPosition.x = Bomber.Position.x
            Bomber.BombPosition.y = Bomber.Position.y+BOMBER_BOMB_RELEASE_Y
            Bomber.BombVelocity.x = -BOMBER_SPEED_PX_PER_MS
            Bomber.BombVelocity.y = 0
            Bomber.BombLastMoveMs = Now
            Bomber.BombSpriteData.Angle = 0
        endif
    endif

    if Bomber.BombEnabled = TRUE
        DeltaMs = Now-Bomber.BombLastMoveMs
        if DeltaMs > 0
            // Exponential-like horizontal damping, bounded for long frames.
            DragFactor = 1.0/(1.0+BOMBER_BOMB_DRAG_PER_MS*DeltaMs)
            Bomber.BombVelocity.x = Bomber.BombVelocity.x*DragFactor
            Bomber.BombVelocity.y = Bomber.BombVelocity.y+BOMBER_BOMB_GRAVITY_PX_PER_MS2*DeltaMs
            Bomber.BombPosition.x = Bomber.BombPosition.x+Bomber.BombVelocity.x*DeltaMs
            Bomber.BombPosition.y = Bomber.BombPosition.y+Bomber.BombVelocity.y*DeltaMs
            // Sprite points left at 0 degrees; lean toward -90 as it falls.
            HorizontalSpeed = Abs(Bomber.BombVelocity.x)
            Bomber.BombSpriteData.Angle = -90.0*Bomber.BombVelocity.y/(HorizontalSpeed+Bomber.BombVelocity.y+0.00001)
            Bomber.BombLastMoveMs = Now
        endif
        if Bomber.BombPosition.y > World.Size.Height+32 or Bomber.BombPosition.x < -32
            Bomber.BombEnabled = FALSE
        endif
    endif
endfunction

function BomberBombDraw(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,World ref as TWorld)
    if Bomber.BombEnabled = TRUE and ProtoBomber.Bomb.Sprite.ID > 0
        SpritePositionCalc(Bomber.BombSpriteData.Position,Bomber.BombPosition,World.Position)
        SpriteDraw(ProtoBomber.Bomb.Sprite,Bomber.BombSpriteData)
    endif
endfunction

function BomberDraw(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,World ref as TWorld)
    if Bomber.Enabled = TRUE
        SpritePositionCalc(Bomber.SpriteData.Position,Bomber.Position,World.Position)
        SpriteDraw(ProtoBomber.Body.Sprite,Bomber.SpriteData)
    endif
endfunction
