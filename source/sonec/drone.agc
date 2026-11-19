// D1: one unarmed persistent test drone.
// Horizontal patrol inside screen/world X bounds, fixed world-space flight height.
// Three user-provided 46x30 colored images: left, center (turn), right.

#constant DRONE_PATROL_MARGIN_X 60
#constant DRONE_WORLD_MARGIN_Y 80
#constant DRONE_PATROL_SPEED 0.10
#constant DRONE_TURN_MS 400

global DroneMotionUseGate as integer
global DroneMotionTimer as TTime
global DroneMotionLastMode as integer

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
endfunction

function DroneInit(Drone ref as TDrone,Screen as TSize,World ref as TWorld,Now as integer)
    Drone.Enabled = TRUE
    Drone.Direction = MOVELEFT
    Drone.IsTurning = FALSE
    Drone.TurnUntilMs = 0
    Drone.LastMoveMs = Now
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

    Drone.SpriteData.Center = TRUE
    Drone.SpriteData.Scale = 1
    Drone.SpriteData.Angle = 0
    ColorSet(Drone.SpriteData.Color,255,255,255,255)
endfunction

function DroneMove(Drone ref as TDrone,Screen as TSize,Now as integer)
    local DeltaMs as integer

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
endfunction

function DroneDraw(Drone ref as TDrone,ProtoDrone ref as TProtoDrone,World ref as TWorld)
    if Drone.Enabled = TRUE
        SpritePositionCalc(Drone.SpriteData.Position,Drone.Position,World.Position)
        if Drone.IsTurning = TRUE
            SpriteDraw(ProtoDrone.Center.Sprite,Drone.SpriteData)
        else
            if Drone.Direction = MOVELEFT
                SpriteDraw(ProtoDrone.Left.Sprite,Drone.SpriteData)
            else
                SpriteDraw(ProtoDrone.Right.Sprite,Drone.SpriteData)
            endif
        endif
    endif
endfunction
