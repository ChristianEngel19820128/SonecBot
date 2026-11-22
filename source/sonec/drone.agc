// D4a: one drone, activated by an explicit spawn request.
// Horizontal patrol inside screen/world X bounds, fixed world-space flight height.
// Three user-provided 46x30 colored images: left, center (turn), right.

#constant DRONE_JET_INTERVAL_MS 30
#constant DRONE_JET_PARTICLE_SCALE 0.6
#constant DRONE_HEALTH_MAX 100
#constant DRONE_HIT_FLASH_MS 150
#constant DRONE_AUTO_SPAWN_MIN_MS 20000
#constant DRONE_AUTO_SPAWN_MAX_MS 35000
#constant DRONE_SPAWN_OFFSET_X 30
#constant DRONE_SPAWN_MIN_SONEC_DISTANCE 160
#constant DRONE_PATROL_MARGIN_X 60
#constant DRONE_WORLD_MARGIN_Y 80
#constant DRONE_PATROL_SPEED 0.10
#constant DRONE_TURN_MS 400
#constant DRONE_SCAN_MIN_INTERVAL_MS 3500
#constant DRONE_SCAN_MAX_INTERVAL_MS 6500
#constant DRONE_SCAN_MIN_DURATION_MS 500
#constant DRONE_SCAN_MAX_DURATION_MS 1000
#constant DRONE_SCAN_NEAR_X 220
#constant DRONE_SCAN_MAX_DISTANCE_X 500
#constant DRONE_SCAN_MAX_SUCCESS_PERCENT 50
#constant DRONE_SHOT_MAX_Y_DIFFERENCE 120
#constant DRONE_CHARGE_MIN_INTERVAL_MS 6000
#constant DRONE_CHARGE_MAX_INTERVAL_MS 10000
#constant DRONE_CHARGE_DURATION_MS 900
// Prevent scan and charge from following one another immediately.
#constant DRONE_ACTION_REST_MS 1200
#constant DRONE_LASER_SPEED 0.35
#constant DRONE_LASER_DAMAGE 20
#constant DRONE_LASER_START_OFFSET_X 53
// D2.1 temporary visibility test: exaggerated hover, not final balancing.
#constant DRONE_BOB_AMPLITUDE 8
#constant DRONE_BOB_DEGREES_PER_MS 0.12

// Temporary standalone spawn scheduler; Chat B will replace its call site.
global DroneNextJetMs as integer
global DroneHitFlashUntilMs as integer
global DroneDeathEffectPending as integer
global DroneDeathPosition as TPosition
global DroneNextAutoSpawnMs as integer
global DroneMotionUseGate as integer
global DroneMotionTimer as TTime
global DroneMotionLastMode as integer
global DroneScanUntilMs as integer
global DroneNextScanMs as integer
global DroneScanActive as integer
global DroneTargetAcquired as integer
global DroneBaseY as float
global DroneBobStartMs as integer
global DroneScanStartMs as integer
global DroneScanFrame as integer
global DroneChargeActive as integer
global DroneChargeStartMs as integer
global DroneChargeUntilMs as integer
global DroneNextChargeMs as integer
global DroneChargeFrame as integer
global DroneActionRestUntilMs as integer
global DroneLaserActive as integer
global DroneLaserX as float
global DroneLaserY as float
global DroneLaserDirection as integer
global DroneLaserLastMs as integer
// D3c: count successful drone laser impacts.
global DroneLaserHits as integer

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
    ProtoDrone.ChargeLeft.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.ChargeLeft.Image.File.Name = "lasercharge_left.png"
    if ImageLoad(ProtoDrone.ChargeLeft.Image) = TRUE
        SpriteLoad(ProtoDrone.ChargeLeft)
        SetSpriteAnimation(ProtoDrone.ChargeLeft.Sprite.ID,30,30,3)
    endif
    ProtoDrone.ChargeRight.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.ChargeRight.Image.File.Name = "lasercharge_right.png"
    if ImageLoad(ProtoDrone.ChargeRight.Image) = TRUE
        SpriteLoad(ProtoDrone.ChargeRight)
        SetSpriteAnimation(ProtoDrone.ChargeRight.Sprite.ID,30,30,3)
    endif
    ProtoDrone.Laser.Image.File.Path = "/media/gfx/enemies/drone"
    ProtoDrone.Laser.Image.File.Name = "laser.png"
    if ImageLoad(ProtoDrone.Laser.Image) = TRUE
        SpriteLoad(ProtoDrone.Laser)
    endif
endfunction

function DroneInit(Drone ref as TDrone,Screen as TSize,World ref as TWorld,Now as integer)
    Drone.Enabled = FALSE
    Drone.Health.StateMax = DRONE_HEALTH_MAX
    Drone.Health.State = DRONE_HEALTH_MAX
    DroneHitFlashUntilMs = 0
    DroneNextJetMs = Now
    DroneNextAutoSpawnMs = Now+random(DRONE_AUTO_SPAWN_MIN_MS,DRONE_AUTO_SPAWN_MAX_MS)
    Drone.Direction = MOVELEFT
    Drone.IsTurning = FALSE
    Drone.TurnUntilMs = 0
    Drone.LastMoveMs = Now
    DroneScanActive = FALSE
    DroneTargetAcquired = FALSE
    DroneScanUntilMs = 0
    DroneNextScanMs = Now + random(DRONE_SCAN_MIN_INTERVAL_MS,DRONE_SCAN_MAX_INTERVAL_MS)
    DroneBobStartMs = Now
    DroneScanStartMs = 0
    DroneScanFrame = 1
    DroneChargeActive = FALSE
    DroneChargeStartMs = 0
    DroneChargeUntilMs = 0
    DroneNextChargeMs = Now + random(DRONE_CHARGE_MIN_INTERVAL_MS,DRONE_CHARGE_MAX_INTERVAL_MS)
    DroneChargeFrame = 1
    DroneActionRestUntilMs = Now
    DroneLaserActive = FALSE
    DroneLaserX = 0
    DroneLaserY = 0
    DroneLaserDirection = MOVELEFT
    DroneLaserLastMs = Now
    DroneLaserHits = 0
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

// D5a: shared entry point for all player weapons.
function DroneTakeDamage(Drone ref as TDrone,Damage as integer)
    if Drone.Enabled = TRUE and Damage > 0
        Drone.Health.State = Drone.Health.State-Damage
        DroneHitFlashUntilMs = GetMilliseconds()+DRONE_HIT_FLASH_MS
        if Drone.Health.State <= 0
            Drone.Health.State = 0
            DroneDeathPosition = Drone.Position
            DroneDeathEffectPending = TRUE
            Drone.Enabled = FALSE
            DroneLaserActive = FALSE
            DroneScanActive = FALSE
            DroneTargetAcquired = FALSE
            DroneChargeActive = FALSE
        endif
    endif
endfunction

// D4a: caller requests one spawn; no wave timing or automatic retries here.
// Side: 0 = choose, MOVELEFT = enter from right, MOVERIGHT = enter from left.
// Return FALSE when the current world view offers no safe entry position.
function DroneSpawn(Drone ref as TDrone,Screen as TSize,World ref as TWorld,Sonec ref as TSonec,Now as integer,Side as integer)
    local SpawnY as float
    local SpawnX as float
    local ChosenSide as integer
    local MinY as float
    local MaxY as float
    local Success as integer
    Success = FALSE
    if Drone.Enabled = FALSE
        MinY = World.Position.y+DRONE_WORLD_MARGIN_Y+DRONE_BOB_AMPLITUDE
        MaxY = World.Position.y+Screen.Height-DRONE_WORLD_MARGIN_Y-DRONE_BOB_AMPLITUDE
        if MinY < DRONE_WORLD_MARGIN_Y+DRONE_BOB_AMPLITUDE then MinY = DRONE_WORLD_MARGIN_Y+DRONE_BOB_AMPLITUDE
        if MaxY > World.Size.Height-DRONE_WORLD_MARGIN_Y-DRONE_BOB_AMPLITUDE then MaxY = World.Size.Height-DRONE_WORLD_MARGIN_Y-DRONE_BOB_AMPLITUDE
        if MaxY >= MinY and Screen.Width > DRONE_PATROL_MARGIN_X*2
            SpawnY = (MinY+MaxY)*0.5
            ChosenSide = Side
            if ChosenSide <> MOVELEFT and ChosenSide <> MOVERIGHT
                if random(0,1) = 0
                    ChosenSide = MOVELEFT
                else
                    ChosenSide = MOVERIGHT
                endif
            endif
            if ChosenSide = MOVELEFT
                SpawnX = Screen.Width+DRONE_SPAWN_OFFSET_X
            else
                SpawnX = -DRONE_SPAWN_OFFSET_X
            endif
            if abs(SpawnX-Sonec.ObjectData.Position.x) >= DRONE_SPAWN_MIN_SONEC_DISTANCE
                DroneInit(Drone,Screen,World,Now)
                Drone.Position.x = SpawnX
                Drone.Position.y = SpawnY
                DroneBaseY = SpawnY
                Drone.Direction = ChosenSide
                Drone.Enabled = TRUE
                Success = TRUE
            endif
        endif
    endif
endfunction Success

// D4b: temporary pause-aware scheduler. Chat B will remove this caller,
// not the position-checked DroneSpawn API.
function DroneAutoSpawnDo(Drone ref as TDrone,Screen as TSize,World ref as TWorld,Sonec ref as TSonec,Now as integer)
    if Now >= DroneNextAutoSpawnMs
        if Drone.Enabled = FALSE
            DroneSpawn(Drone,Screen,World,Sonec,Now,0)
        endif
        DroneNextAutoSpawnMs = Now+random(DRONE_AUTO_SPAWN_MIN_MS,DRONE_AUTO_SPAWN_MAX_MS)
    endif
endfunction

function DroneMove(Drone ref as TDrone,Screen as TSize,Sonec ref as TSonec,Shield ref as TShield,Now as integer)
    local DeltaMs as integer
    local TurnChance as integer
    local LaserOldX as float
    local TargetDx as float
    local TargetDy as float
    local ScanChance as integer

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

        if DroneChargeActive = TRUE
            if Now >= DroneChargeUntilMs
                DroneChargeActive = FALSE
                DroneActionRestUntilMs = Now+DRONE_ACTION_REST_MS
                // A scan only authorizes a shot while Sonec remains in front and in the laser lane.
                TargetDx = Sonec.ObjectData.Position.x-Drone.Position.x
                TargetDy = Drone.Position.y-Sonec.ObjectData.Position.y
                DroneLaserActive = FALSE
                if Sonec.IsLost = FALSE and DroneTargetAcquired = TRUE and ((Drone.Direction = MOVELEFT and TargetDx < 0) or (Drone.Direction = MOVERIGHT and TargetDx > 0))
                    if abs(TargetDy) <= DRONE_SHOT_MAX_Y_DIFFERENCE
                        DroneLaserActive = TRUE
                    endif
                endif
                DroneTargetAcquired = FALSE
                DroneLaserDirection = Drone.Direction
                DroneLaserX = Drone.Position.x
                if DroneLaserDirection = MOVELEFT
                    DroneLaserX = DroneLaserX-DRONE_LASER_START_OFFSET_X
                else
                    DroneLaserX = DroneLaserX+DRONE_LASER_START_OFFSET_X
                endif
                DroneLaserY = Drone.Position.y
                DroneLaserLastMs = Now
                DroneNextChargeMs = Now + random(DRONE_CHARGE_MIN_INTERVAL_MS,DRONE_CHARGE_MAX_INTERVAL_MS)
            endif
        endif

        // The projectile flies independently of subsequent drone movement.
        if DroneLaserActive = TRUE
            LaserOldX = DroneLaserX
            if DroneLaserDirection = MOVELEFT
                DroneLaserX = DroneLaserX-(Now-DroneLaserLastMs)*DRONE_LASER_SPEED
            else
                DroneLaserX = DroneLaserX+(Now-DroneLaserLastMs)*DRONE_LASER_SPEED
            endif
            DroneLaserLastMs = Now
            DroneLaserDetectHit(Sonec,Shield,LaserOldX,DroneLaserX,Now)
            if DroneLaserX < -30 or DroneLaserX > Screen.Width+30
                DroneLaserActive = FALSE
            endif
        endif

        if DroneScanActive = TRUE
            if Now >= DroneScanUntilMs
                DroneScanActive = FALSE
                DroneActionRestUntilMs = Now+DRONE_ACTION_REST_MS
                DroneNextScanMs = Now + random(DRONE_SCAN_MIN_INTERVAL_MS,DRONE_SCAN_MAX_INTERVAL_MS)
                // A completed scan can acquire a target ahead with a linearly
                // decreasing chance: 50% nearby, 0% at 500px or farther.
                TargetDx = Sonec.ObjectData.Position.x-Drone.Position.x
                DroneTargetAcquired = FALSE
                if Sonec.IsLost = FALSE and ((Drone.Direction = MOVELEFT and TargetDx < 0) or (Drone.Direction = MOVERIGHT and TargetDx > 0))
                    if abs(TargetDx) < DRONE_SCAN_MAX_DISTANCE_X
                        ScanChance = DRONE_SCAN_MAX_SUCCESS_PERCENT*(DRONE_SCAN_MAX_DISTANCE_X-abs(TargetDx))/DRONE_SCAN_MAX_DISTANCE_X
                        if random(1,100) <= ScanChance then DroneTargetAcquired = TRUE
                    endif
                endif
                // A successful scan keeps its target; a failed scan may trigger a random turn.
                if DroneTargetAcquired = TRUE
                    DroneNextChargeMs = Now+DRONE_ACTION_REST_MS
                else
                TurnChance = 10
                if abs(Drone.Position.x-Sonec.ObjectData.Position.x) <= DRONE_SCAN_NEAR_X then TurnChance = 30
                if random(1,100) <= TurnChance
                    if Drone.Direction = MOVELEFT
                        Drone.Direction = MOVERIGHT
                    else
                        Drone.Direction = MOVELEFT
                    endif
                    Drone.IsTurning = TRUE
                    DroneTargetAcquired = FALSE
                    Drone.TurnUntilMs = Now+DRONE_TURN_MS
                endif
                endif
            endif
        else
            if DroneChargeActive = FALSE and DroneTargetAcquired = FALSE and Drone.IsTurning = FALSE and Now >= DroneNextScanMs and Now >= DroneActionRestUntilMs
                DroneScanActive = TRUE
                DroneScanStartMs = Now
                DroneScanFrame = 1
                DroneScanUntilMs = Now + random(DRONE_SCAN_MIN_DURATION_MS,DRONE_SCAN_MAX_DURATION_MS)
            endif
        endif

        if DroneTargetAcquired = TRUE and DroneChargeActive = FALSE and DroneScanActive = FALSE and Drone.IsTurning = FALSE and Now >= DroneNextChargeMs and Now >= DroneActionRestUntilMs
            DroneChargeActive = TRUE
            DroneChargeStartMs = Now
            DroneChargeUntilMs = Now+DRONE_CHARGE_DURATION_MS
            DroneChargeFrame = 1
        endif

        if DroneChargeActive = TRUE
            DroneChargeFrame = 1 + (Now-DroneChargeStartMs)/300
            if DroneChargeFrame > 3 then DroneChargeFrame = 3
        endif

        if DroneScanActive = TRUE or DroneChargeActive = TRUE
            if DroneScanActive = TRUE
                DroneScanFrame = 1 + Mod((Now-DroneScanStartMs)/150,3)
            endif
        else
        if Drone.IsTurning = TRUE
            if Now >= Drone.TurnUntilMs
                Drone.IsTurning = FALSE
                DroneTargetAcquired = FALSE
                DroneNextScanMs = Now
            endif
        else
            if Drone.Direction = MOVELEFT
                Drone.Position.x = Drone.Position.x - DeltaMs*DRONE_PATROL_SPEED
                if Drone.Position.x <= DRONE_PATROL_MARGIN_X
                    Drone.Position.x = DRONE_PATROL_MARGIN_X
                    Drone.IsTurning = TRUE
                    Drone.TurnUntilMs = Now+DRONE_TURN_MS
                    Drone.Direction = MOVERIGHT
                    DroneTargetAcquired = FALSE
                    DroneNextScanMs = Now+DRONE_TURN_MS
                endif
            else
                Drone.Position.x = Drone.Position.x + DeltaMs*DRONE_PATROL_SPEED
                if Drone.Position.x >= Screen.Width-DRONE_PATROL_MARGIN_X
                    Drone.Position.x = Screen.Width-DRONE_PATROL_MARGIN_X
                    Drone.IsTurning = TRUE
                    Drone.TurnUntilMs = Now+DRONE_TURN_MS
                    Drone.Direction = MOVELEFT
                    DroneTargetAcquired = FALSE
                    DroneNextScanMs = Now+DRONE_TURN_MS
                endif
            endif
        endif
        endif
    endif
endfunction

// D3c: swept horizontal segment against Sonec's two-circle body approximation.
// Apply damage once per projectile, using the existing shield rules.
function DroneLaserDetectHit(Sonec ref as TSonec,Shield ref as TShield,OldX as float,NewX as float,Now as integer)
    local ClosestX as float
    local Dx as float
    local Dy as float
    local Radius as float
    local CircleIndex as integer
    local Hit as integer
    local HealthBeforeHit as integer
    Hit = FALSE
    if DroneLaserActive = TRUE and Sonec.IsLost = FALSE
        // Include the 30px-long sprite, avoiding gaps at high frame times.
        ClosestX = Sonec.ObjectData.Position.x
        if DroneLaserDirection = MOVELEFT
            if ClosestX > OldX+15 then ClosestX = OldX+15
            if ClosestX < NewX-15 then ClosestX = NewX-15
        else
            if ClosestX < OldX-15 then ClosestX = OldX-15
            if ClosestX > NewX+15 then ClosestX = NewX+15
        endif
        Dx = Sonec.ObjectData.Position.x-ClosestX
        // S5: reuse Sonec's shared standing/ducking two-circle geometry.
        Radius = SonecHitCircleRadius(Sonec)
        for CircleIndex = 0 to 1
            Dy = SonecHitCircleY(Sonec,CircleIndex)-DroneLaserY
            if Dx*Dx+Dy*Dy <= Radius*Radius then Hit = TRUE
        next CircleIndex
        if Hit = TRUE
            DroneLaserActive = FALSE
            DroneLaserHits = DroneLaserHits+1
            // Same proportional shield absorption and hit flash as enemy bullets.
            HealthBeforeHit = Sonec.Health.State
            Sonec.Health.State = Sonec.Health.State - (DRONE_LASER_DAMAGE - ShieldAbsorbDamage(Shield,Sonec,DRONE_LASER_DAMAGE,Now))
            if Sonec.Health.State < HealthBeforeHit then SonecHitFlashUntil = Now+SONEC_HIT_FLASH_MS
        endif
    endif
endfunction Hit

// Draw the charge frames at native size, with a centered 30x30 pivot.
function DroneChargeDraw(SpriteID as integer,Frame as integer,Position as TPosition)
    if SpriteID > 0
        SetSpriteFrame(SpriteID,Frame)
        SetSpriteScaleByOffset(SpriteID,1.0,1.0)
        SetSpriteOffset(SpriteID,15.0,15.0)
        SetSpritePositionByOffset(SpriteID,Position.x,Position.y)
        SetSpriteColor(SpriteID,30,255,60,190)
        DrawSprite(SpriteID)
    endif
endfunction

// D6: three exhaust streams use Sonec's existing jetfire sprites and lifecycle.
// Separate emission clock avoids competing with Sonec's shared JetfireAdd timer.
function DroneJetfireDo(Drone ref as TDrone,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Now as integer)
    local Outlet as integer
    local Position as TPosition
    local Jetfire as TJetfire
    local i as integer
    local Found as integer
    if Drone.Enabled = TRUE and Now >= DroneNextJetMs and ProtoJetfire.AnimJetfire.Sprite.ID > 0
        for Outlet = 0 to 2
            // Match the three visible exhaust outlets of the 46x30 drone sprite.
            // The center outlet extends slightly farther downward.
            Position.x = Drone.Position.x+(Outlet-1)*8
            Position.y = Drone.Position.y+8
            if Outlet = 1 then Position.y = Drone.Position.y+10
            JetfireNew(Jetfire,ProtoJetfire,World,Position,Now)
            // Only drone exhaust particles are smaller; Sonec's effect is unchanged.
            Jetfire.SpriteData.Scale = DRONE_JET_PARTICLE_SCALE
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
        next Outlet
        DroneNextJetMs = Now+DRONE_JET_INTERVAL_MS
    endif
endfunction

function DroneDraw(Drone ref as TDrone,ProtoDrone ref as TProtoDrone,World ref as TWorld)
    local EffectData as TSpriteData
    local TorsoData as TSpriteData
    local SensorData as TSpriteData
    local LaserData as TSpriteData
    if Drone.Enabled = TRUE
        SpritePositionCalc(Drone.SpriteData.Position,Drone.Position,World.Position)
        if GetMilliseconds() < DroneHitFlashUntilMs
            ColorSet(Drone.SpriteData.Color,255,0,0,255)
        else
            ColorSet(Drone.SpriteData.Color,255,255,255,255)
        endif

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

            // D3a color test: tint torso and sensors independently, without editing PNGs.
            TorsoData = Drone.SpriteData
            if GetMilliseconds() < DroneHitFlashUntilMs
                ColorSet(TorsoData.Color,255,0,0,255)
            else
                ColorSet(TorsoData.Color,45,140,65,255)
            endif
            SpriteDraw(ProtoDrone.Torso.Sprite,TorsoData)

            // 46px torso + 30px charge frame: center offset 23+15=38px.
            // Frames begin at the torso edge, without overlap.
            if DroneChargeActive = TRUE
                EffectData = Drone.SpriteData
                ColorSet(EffectData.Color,30,255,60,190)
                if Drone.Direction = MOVELEFT
                    EffectData.Position.x = EffectData.Position.x-38
                    if ProtoDrone.ChargeLeft.Sprite.ID > 0
                        DroneChargeDraw(ProtoDrone.ChargeLeft.Sprite.ID,DroneChargeFrame,EffectData.Position)
                    endif
                else
                    EffectData.Position.x = EffectData.Position.x+38
                    if ProtoDrone.ChargeRight.Sprite.ID > 0
                        DroneChargeDraw(ProtoDrone.ChargeRight.Sprite.ID,DroneChargeFrame,EffectData.Position)
                    endif
                endif
            endif

            SensorData = Drone.SpriteData
            if GetMilliseconds() < DroneHitFlashUntilMs
                ColorSet(SensorData.Color,255,0,0,255)
            else
                ColorSet(SensorData.Color,230,45,45,255)
            endif
            if Drone.IsTurning = TRUE
                SpriteDraw(ProtoDrone.SensorCenter.Sprite,SensorData)
            else
                if Drone.Direction = MOVELEFT
                    SpriteDraw(ProtoDrone.SensorLeft.Sprite,SensorData)
                else
                    SpriteDraw(ProtoDrone.SensorRight.Sprite,SensorData)
                endif
            endif
        endif

        // Visual-only 3px-high projectile; world Y stays fixed after firing.
        if DroneLaserActive = TRUE and ProtoDrone.Laser.Sprite.ID > 0
            LaserData = Drone.SpriteData
            LaserData.Position.x = DroneLaserX
            LaserData.Position.y = DroneLaserY-World.Position.y
            ColorSet(LaserData.Color,30,255,60,230)
            SpriteDraw(ProtoDrone.Laser.Sprite,LaserData)
        endif
    endif
endfunction
