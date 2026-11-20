// D1: one unarmed persistent test drone.
// Horizontal patrol inside screen/world X bounds, fixed world-space flight height.
// Three user-provided 46x30 colored images: left, center (turn), right.

#constant DRONE_PATROL_MARGIN_X 60
#constant DRONE_WORLD_MARGIN_Y 80
#constant DRONE_PATROL_SPEED 0.10
#constant DRONE_TURN_MS 400
#constant DRONE_SCAN_MIN_INTERVAL_MS 2400
#constant DRONE_SCAN_MAX_INTERVAL_MS 5000
#constant DRONE_SCAN_MIN_DURATION_MS 500
#constant DRONE_SCAN_MAX_DURATION_MS 1000
#constant DRONE_SCAN_NEAR_X 220
// D2.1 temporary visibility test: exaggerated hover, not final balancing.
#constant DRONE_BOB_AMPLITUDE 8
#constant DRONE_BOB_DEGREES_PER_MS 0.12

global DroneMotionUseGate as integer
global DroneMotionTimer as TTime
global DroneMotionLastMode as integer
global DroneScanUntilMs as integer
global DroneNextScanMs as integer
global DroneScanActive as integer
global DroneBaseY as float
global DroneBobStartMs as integer
global DroneScanStartMs as integer
global DroneScanFrame as integer

function DroneProtoLoad(ProtoDrone ref as TProtoDrone)
    ProtoDrone.Left.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.Left.Image.File.Name = "drone_left.png"
    if ImageLoad(ProtoDrone.Left.Image) = TRUE
        SpriteLoad(ProtoDrone.Left)
    endif

    ProtoDrone.Center.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.Center.Image.File.Name = "drone_center.png"
    if ImageLoad(ProtoDrone.Center.Image) = TRUE
        SpriteLoad(ProtoDrone.Center)
    endif

    ProtoDrone.Right.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.Right.Image.File.Name = "drone_right.png"
    if ImageLoad(ProtoDrone.Right.Image) = TRUE
        SpriteLoad(ProtoDrone.Right)
    endif
    // D3a: layered art, with a three-frame ice-blue scan cone.
    ProtoDrone.Torso.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.Torso.Image.File.Name = "drone_torso.png"
    if ImageLoad(ProtoDrone.Torso.Image) = TRUE then SpriteLoad(ProtoDrone.Torso)

    ProtoDrone.SensorLeft.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.SensorLeft.Image.File.Name = "drone_sensor_left.png"
    if ImageLoad(ProtoDrone.SensorLeft.Image) = TRUE then SpriteLoad(ProtoDrone.SensorLeft)

    ProtoDrone.SensorCenter.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.SensorCenter.Image.File.Name = "drone_sensor_center.png"
    if ImageLoad(ProtoDrone.SensorCenter.Image) = TRUE then SpriteLoad(ProtoDrone.SensorCenter)

    ProtoDrone.SensorRight.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.SensorRight.Image.File.Name = "drone_sensor_right.png"
    if ImageLoad(ProtoDrone.SensorRight.Image) = TRUE then SpriteLoad(ProtoDrone.SensorRight)

    ProtoDrone.ScanLeft.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.ScanLeft.Image.File.Name = "scan_left.png"
    if ImageLoad(ProtoDrone.ScanLeft.Image) = TRUE
        SpriteLoad(ProtoDrone.ScanLeft)
        SetSpriteAnimation(ProtoDrone.ScanLeft.Sprite.ID,30,30,3)
    endif

    ProtoDrone.ScanRight.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.ScanRight.Image.File.Name = "scan_right.png"
    if ImageLoad(ProtoDrone.ScanRight.Image) = TRUE
        SpriteLoad(ProtoDrone.ScanRight)
        SetSpriteAnimation(ProtoDrone.ScanRight.Sprite.ID,30,30,3)
    endif
endfunction

function DroneInit(Drone ref as TDrone,Screen as TSize,World ref as TWorld,Now as integer)
    Drone.Enabled = TRUE
    Drone.Direction = MOVELEFT
    Drone.IsTurning = FALSE
    Drone.TurnUntilMs = 0
    Drone.LastMoveMs = Now
    DroneScanActive = FALSE
    DroneScanUntilMs = 0
    DroneNextScanMs = Now + random(DRONE_SCAN_MIN_INTERVAL_MS,DRONE_SCAN_MAX_INTERVAL_MS)
    DroneBobStartMs = Now
    DroneScanStartMs = 0
    DroneScanFrame = 1
    TimeSet(DroneMotionTimer,10,10)
    TimeReset(DroneMotionTimer,Now)
    DroneMotionLastMode = DroneMotionUseGate

    Drone.Position.x = Screen.Width - DRONE_PATROL_MARGIN_X
    Drone.Position.y = World.Position.y + Screen.Height*0.5
    if Drone.Position.y < DRONE_WORLD_MARGIN_Y
        Drone.Position.y = DRONE_WORLD_MARGIN_Y
    endif
    if Drone.Position.y > World.Size.Height-DRONE_WORLD_MARGIN_Y
        Drone.Position.y = World.Size.Height-DRONE_WORLD_MARGIN_Y
    endif

    DroneBaseY = Drone.Position.y

    Drone.SpriteData.Center = TRUE
    Drone.SpriteData.Scale = 1
    Drone.SpriteData.Angle = 0
    ColorSet(Drone.SpriteData.Color,255,255,255,255)
endfunction

function DroneMove(Drone ref as TDrone,Screen as TSize,SonecX as float,Now as integer)
    local DeltaMs as integer
    local TurnChance as integer

    if Drone.Enabled = TRUE
        if DroneMotionLastMode <> DroneMotionUseGate
            Drone.LastMoveMs = Now
            TimeReset(DroneMotionTimer,Now)
            DroneMotionLastMode = DroneMotionUseGate
        endif
        DeltaMs = Now-Drone.LastMoveMs
        if DeltaMs < 0 then DeltaMs = 0
        if DroneMotionUseGate = 1
            if TimeGet(DroneMotionTimer,Now) > 0
                DeltaMs = DroneMotionTimer.FullDifference
                TimeReset(DroneMotionTimer,Now)
            else
                DeltaMs = 0
            endif
        endif
        if DroneMotionUseGate = 0 or DeltaMs > 0
            Drone.LastMoveMs = Now
        endif

        // Slow physical hover: the drawn sprite and future collision use the same Y.
        Drone.Position.y = DroneBaseY + sin((Now-DroneBobStartMs)*DRONE_BOB_DEGREES_PER_MS)*DRONE_BOB_AMPLITUDE

        if DroneScanActive = TRUE
            if Now >= DroneScanUntilMs
                DroneScanActive = FALSE
                DroneNextScanMs = Now + random(DRONE_SCAN_MIN_INTERVAL_MS,DRONE_SCAN_MAX_INTERVAL_MS)
                // Proximity can influence a turn, but never guarantees one.
                TurnChance = 5
                if abs(Drone.Position.x-SonecX) <= DRONE_SCAN_NEAR_X then TurnChance = 25
                if random(1,100) <= TurnChance
                    if Drone.Direction = MOVELEFT
                        Drone.Direction = MOVERIGHT
                    else
                        Drone.Direction = MOVELEFT
                    endif
                    Drone.IsTurning = TRUE
                    Drone.TurnUntilMs = Now+DRONE_TURN_MS
                endif
            endif
        else
            if Drone.IsTurning = FALSE and Now >= DroneNextScanMs
                DroneScanActive = TRUE
                DroneScanStartMs = Now
                DroneScanFrame = 1
                DroneScanUntilMs = Now + random(DRONE_SCAN_MIN_DURATION_MS,DRONE_SCAN_MAX_DURATION_MS)
            endif
        endif

        if DroneScanActive = TRUE
            DroneScanFrame = 1 + mod((Now-DroneScanStartMs)/150,3)
            // Stationary scan; the center view is a temporary visual placeholder.
        else
        if Drone.IsTurning = TRUE
            if Now >= Drone.TurnUntilMs
                Drone.IsTurning = FALSE
            endif
        else
            if Drone.Direction = MOVELEFT
                Drone.Position.x = Drone.Position.x - DeltaMs*DRONE_PATROL_SPEED
                if Drone.Position.x <= DRONE_PATROL_MARGIN_X
                    Drone.Position.x = DRONE_PATROL_MARGIN_X
                    Drone.IsTurning = TRUE
                    Drone.TurnUntilMs = Now+DRONE_TURN_MS
                    Drone.Direction = MOVERIGHT
                endif
            else
                Drone.Position.x = Drone.Position.x + DeltaMs*DRONE_PATROL_SPEED
                if Drone.Position.x >= Screen.Width-DRONE_PATROL_MARGIN_X
                    Drone.Position.x = Screen.Width-DRONE_PATROL_MARGIN_X
                    Drone.IsTurning = TRUE
                    Drone.TurnUntilMs = Now+DRONE_TURN_MS
                    Drone.Direction = MOVELEFT
                endif
            endif
        endif
        endif
    endif
endfunction

function DroneDraw(Drone ref as TDrone,ProtoDrone ref as TProtoDrone,World ref as TWorld)
    local EffectData as TSpriteData
    if Drone.Enabled = TRUE
        SpritePositionCalc(Drone.SpriteData.Position,Drone.Position,World.Position)

        // Keep the old full-body art as a fallback if the layered torso is unavailable.
        if ProtoDrone.Torso.Sprite.ID = 0
            if Drone.IsTurning = TRUE or DroneScanActive = TRUE
                SpriteDraw(ProtoDrone.Center.Sprite,Drone.SpriteData)
            else
                if Drone.Direction = MOVELEFT
                    SpriteDraw(ProtoDrone.Left.Sprite,Drone.SpriteData)
                else
                    SpriteDraw(ProtoDrone.Right.Sprite,Drone.SpriteData)
                endif
            endif
        else
            // The cone is drawn behind the body, using the same physical hover position.
            if DroneScanActive = TRUE
                EffectData = Drone.SpriteData
                ColorSet(EffectData.Color,160,225,255,90)
                if Drone.Direction = MOVELEFT
                    EffectData.Position.x = EffectData.Position.x-28
                    if ProtoDrone.ScanLeft.Sprite.ID > 0
                        SetSpriteFrame(ProtoDrone.ScanLeft.Sprite.ID,DroneScanFrame)
                        SpriteDraw(ProtoDrone.ScanLeft.Sprite,EffectData)
                    endif
                else
                    EffectData.Position.x = EffectData.Position.x+28
                    if ProtoDrone.ScanRight.Sprite.ID > 0
                        SetSpriteFrame(ProtoDrone.ScanRight.Sprite.ID,DroneScanFrame)
                        SpriteDraw(ProtoDrone.ScanRight.Sprite,EffectData)
                    endif
                endif
            endif

            SpriteDraw(ProtoDrone.Torso.Sprite,Drone.SpriteData)
            if Drone.IsTurning = TRUE or DroneScanActive = TRUE
                SpriteDraw(ProtoDrone.SensorCenter.Sprite,Drone.SpriteData)
            else
                if Drone.Direction = MOVELEFT
                    SpriteDraw(ProtoDrone.SensorLeft.Sprite,Drone.SpriteData)
                else
                    SpriteDraw(ProtoDrone.SensorRight.Sprite,Drone.SpriteData)
                endif
            endif
        endif
    endif
endfunction
