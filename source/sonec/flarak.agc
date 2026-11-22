// Flarak F1: visual-only pivot test. No missiles, collisions or gameplay state.
// The 480x64 sheet contains six 80x64 cells: 1-5 base, 6 launcher.
#constant FLARAK_TEST_CELL_W 80
#constant FLARAK_TEST_CELL_H 64
#constant FLARAK_TEST_BASE_OFFSET_X 40
#constant FLARAK_TEST_BASE_OFFSET_Y 42
// Approximate red-dot joint in the launcher cell; refine after visual test.
#constant FLARAK_TEST_LAUNCHER_PIVOT_X 40
#constant FLARAK_TEST_LAUNCHER_PIVOT_Y 42
#constant FLARAK_TEST_TILT_DEGREES 60
// Slow F1 animation for visual inspection: 500 ms per base frame.
#constant FLARAK_TEST_FRAME_MS 500
// F2 visual launch test: straight flight, no homing, damage or collision.
#constant FLARAK_TEST_ROCKET_INTERVAL_MS 2400
#constant FLARAK_TEST_ROCKET_LIFETIME_MS 3000
#constant FLARAK_TEST_HOMING_DELAY_MS 600
#constant FLARAK_TEST_HOMING_TURN_DEG_PER_MS 0.06
#constant FLARAK_TEST_ROCKET_SPEED_PX_PER_MS 0.32
#constant FLARAK_TEST_MUZZLE_DISTANCE 22
#constant FLARAK_TEST_JET_INTERVAL_MS 20
#constant FLARAK_TEST_JET_BACK_SPACING 3
#constant FLARAK_TEST_JET_SCALE 0.37
#constant FLARAK_TEST_JET_TAIL_DISTANCE 8
#constant FLARAK_TEST_AIM_HOLD_MS 1000
#constant FLARAK_TEST_WARNING_MS 300
#constant FLARAK_TEST_POST_SHOT_HOLD_MS 200
// The launcher barrel points sideways in its source frame, not upward.
#constant FLARAK_TEST_BARREL_ANGLE_OFFSET 90

global FlarakTestBaseSprite as integer
global FlarakTestLauncherSprite as integer
global FlarakTestStartMs as integer
global FlarakTestRocketSprite as integer
global FlarakTestRocketActive as integer
global FlarakTestRocketLaunchMs as integer
global FlarakTestRocketNextMs as integer
global FlarakTestRocketStartX as float
global FlarakTestRocketStartY as float
global FlarakTestRocketPosX as float
global FlarakTestRocketPosY as float
global FlarakTestRocketLastMs as integer
global FlarakTestRocketAngle as float
global FlarakTestRocketSpriteAngle as float
global FlarakTestAimLocked as integer
global FlarakTestAimLockMs as integer
global FlarakTestLockedLauncherAngle as float
global FlarakTestWarningSprite as integer
global FlarakTestNextJetMs as integer
global FlarakTestCurrentFrame as integer
global FlarakTestCurrentLauncherAngle as float
global FlarakTestNowMs as integer

function FlarakVisualTestCreate()
    local Image as TImage
    Image.File.Path = "/media/gfx/enemies"
    Image.File.Name = "flarak.png"
    if ImageLoad(Image) = TRUE
        FlarakTestBaseSprite = CreateSprite(Image.ID)
        SetSpriteAnimation(FlarakTestBaseSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,6)
        SetSpriteFrame(FlarakTestBaseSprite,1)
        SetSpriteOffset(FlarakTestBaseSprite,FLARAK_TEST_BASE_OFFSET_X,FLARAK_TEST_BASE_OFFSET_Y)
        FlarakTestLauncherSprite = CreateSprite(Image.ID)
        SetSpriteAnimation(FlarakTestLauncherSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,6)
        SetSpriteFrame(FlarakTestLauncherSprite,6)
        SetSpriteOffset(FlarakTestLauncherSprite,FLARAK_TEST_LAUNCHER_PIVOT_X,FLARAK_TEST_LAUNCHER_PIVOT_Y)
        SetSpriteColor(FlarakTestBaseSprite,80,232,80,255)
        SetSpriteColor(FlarakTestLauncherSprite,80,232,80,255)
    endif
    Image.File.Path = "/media/gfx/weapons"
    Image.File.Name = "rocket.png"
    if ImageLoad(Image) = TRUE
        FlarakTestRocketSprite = CreateSprite(Image.ID)
        SetSpriteOffset(FlarakTestRocketSprite,GetSpriteWidth(FlarakTestRocketSprite)*0.5,GetSpriteHeight(FlarakTestRocketSprite)*0.5)
        SetSpriteColor(FlarakTestRocketSprite,170,215,170,255)
    endif
    // Small warning lamp; it steps across three points on the barrel.
    FlarakTestWarningSprite = CreateSprite(0)
    SetSpriteSize(FlarakTestWarningSprite,2,2)
    SetSpriteOffset(FlarakTestWarningSprite,1,1)
    SetSpriteColor(FlarakTestWarningSprite,255,155,45,255)
    FlarakTestAimLocked = FALSE
    FlarakTestRocketActive = FALSE
    FlarakTestRocketLastMs = 0
    FlarakTestNextJetMs = 0
    FlarakTestStartMs = -1
    FlarakTestCurrentFrame = 1
    FlarakTestRocketNextMs = 0
endfunction

function FlarakVisualTestDo(Screen as TSize,SonecX as float,SonecY as float,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,NowMs as integer)
    local Elapsed as integer
    local Frame as integer
    local Angle as float
    local LauncherAngle as float
    local X as float
    local Y as float
    local RocketDeltaMs as integer
    local TargetAngle as float
    local AngleDiff as float
    local MaxTurn as float
    local JetPosition as TPosition
    local Jetfire as TJetfire
    local JetIndex as integer
    local JetFound as integer
    local JetOutlet as integer
    local JetBackDistance as float
    if FlarakTestBaseSprite = 0 or FlarakTestLauncherSprite = 0 then exitfunction
    if FlarakTestStartMs < 0
        FlarakTestStartMs = NowMs
        FlarakTestRocketNextMs = NowMs+1500
        FlarakTestRocketLastMs = NowMs
    endif
    FlarakTestNowMs = NowMs
    Elapsed = NowMs-FlarakTestStartMs
    Frame = 1+Elapsed/FLARAK_TEST_FRAME_MS
    if Frame > 5 then Frame = 5
    FlarakTestCurrentFrame = Frame
    X = Screen.Width*0.5
    Y = Screen.Height-45
    if Frame = 5
        // Start at 0 degrees when frame 5 first appears, then change
        // the angle gradually. The old absolute-time sine jumped on deployment.
        Angle = Sin((Elapsed-4*FLARAK_TEST_FRAME_MS)*0.001)*FLARAK_TEST_TILT_DEGREES
        // Negative angles aim up-right. Positive angles switch the barrel
        // by 180 degrees to aim up-left; neither side aims into the ground.
        LauncherAngle = Angle
        if Angle > 0 then LauncherAngle = Angle+180
        // Lock the aim for the entire warning and shot, including a short
        // post-launch hold, so the launcher never turns while firing.
        if FlarakTestAimLocked = FALSE and FlarakTestRocketActive = FALSE and NowMs >= FlarakTestRocketNextMs
            FlarakTestLockedLauncherAngle = LauncherAngle
            FlarakTestAimLockMs = NowMs
            FlarakTestAimLocked = TRUE
        endif
        if FlarakTestAimLocked = TRUE
            LauncherAngle = FlarakTestLockedLauncherAngle
        endif
        FlarakTestCurrentLauncherAngle = LauncherAngle
        // Capture the launcher angle when firing; the projectile does not turn.
        if FlarakTestAimLocked = TRUE and FlarakTestRocketSprite > 0 and FlarakTestRocketActive = FALSE and NowMs-FlarakTestAimLockMs >= FLARAK_TEST_AIM_HOLD_MS
            FlarakTestRocketAngle = LauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            // The rocket art points opposite to the barrel at this angle.
            // Flip only the visual sprite, not its launch vector.
            FlarakTestRocketSpriteAngle = LauncherAngle+180
            FlarakTestRocketStartX = X+Sin(FlarakTestRocketAngle)*FLARAK_TEST_MUZZLE_DISTANCE
            FlarakTestRocketStartY = Y-Cos(FlarakTestRocketAngle)*FLARAK_TEST_MUZZLE_DISTANCE
            FlarakTestRocketPosX = FlarakTestRocketStartX
            FlarakTestRocketPosY = FlarakTestRocketStartY
            FlarakTestRocketLastMs = NowMs
            FlarakTestNextJetMs = NowMs
            FlarakTestRocketLaunchMs = NowMs
            FlarakTestRocketActive = TRUE
            FlarakTestRocketNextMs = NowMs+FLARAK_TEST_ROCKET_INTERVAL_MS
        endif
        if FlarakTestRocketActive = TRUE
            if NowMs-FlarakTestRocketLaunchMs >= FLARAK_TEST_ROCKET_LIFETIME_MS
                FlarakTestRocketActive = FALSE
            else
                RocketDeltaMs = NowMs-FlarakTestRocketLastMs
                if RocketDeltaMs < 0 then RocketDeltaMs = 0
                if RocketDeltaMs > 50 then RocketDeltaMs = 50
                FlarakTestRocketLastMs = NowMs
                // The first 600 ms remain straight. Then steer toward Sonec's
                // current screen position, with a limited turn rate.
                if NowMs-FlarakTestRocketLaunchMs >= FLARAK_TEST_HOMING_DELAY_MS
                    TargetAngle = ATan2(SonecX-FlarakTestRocketPosX,FlarakTestRocketPosY-SonecY)
                    AngleDiff = TargetAngle-FlarakTestRocketAngle
                    while AngleDiff > 180
                        AngleDiff = AngleDiff-360
                    endwhile
                    while AngleDiff < -180
                        AngleDiff = AngleDiff+360
                    endwhile
                    MaxTurn = FLARAK_TEST_HOMING_TURN_DEG_PER_MS*RocketDeltaMs
                    if AngleDiff > MaxTurn then AngleDiff = MaxTurn
                    if AngleDiff < -MaxTurn then AngleDiff = -MaxTurn
                    FlarakTestRocketAngle = FlarakTestRocketAngle+AngleDiff
                endif
                FlarakTestRocketPosX = FlarakTestRocketPosX+Sin(FlarakTestRocketAngle)*FLARAK_TEST_ROCKET_SPEED_PX_PER_MS*RocketDeltaMs
                FlarakTestRocketPosY = FlarakTestRocketPosY-Cos(FlarakTestRocketAngle)*FLARAK_TEST_ROCKET_SPEED_PX_PER_MS*RocketDeltaMs
                // The rocket art is 90 degrees offset from the travel vector.
                FlarakTestRocketSpriteAngle = FlarakTestRocketAngle+90
                // Four particles in a row behind the rocket, along its flight axis.
                if NowMs >= FlarakTestNextJetMs and ProtoJetfire.AnimJetfire.Sprite.ID > 0
                    for JetOutlet = 0 to 3
                        JetBackDistance = FLARAK_TEST_JET_TAIL_DISTANCE+JetOutlet*FLARAK_TEST_JET_BACK_SPACING
                        JetPosition.x = FlarakTestRocketPosX-Sin(FlarakTestRocketAngle)*JetBackDistance
                        JetPosition.y = FlarakTestRocketPosY+Cos(FlarakTestRocketAngle)*JetBackDistance+World.Position.y
                        JetfireNew(Jetfire,ProtoJetfire,World,JetPosition,NowMs)
                        Jetfire.SpriteData.Angle = FlarakTestRocketAngle
                        Jetfire.SpriteData.Scale = FLARAK_TEST_JET_SCALE
                        JetFound = FALSE
                        JetIndex = JetfireList.FirstFree
                        while JetFound = FALSE and JetIndex <= JetfireList.Jetfire.Length
                            if JetfireList.Jetfire[JetIndex].Enabled = FALSE
                                JetFound = TRUE
                            else
                                JetIndex = JetIndex+1
                            endif
                        endwhile
                        if JetFound = FALSE
                            JetfireList.Jetfire.Insert(Jetfire)
                            JetfireList.FirstFree = JetfireList.Jetfire.Length
                        else
                            JetfireList.Jetfire[JetIndex] = Jetfire
                            JetfireList.FirstFree = JetIndex+1
                        endif
                    next JetOutlet
                    FlarakTestNextJetMs = NowMs+FLARAK_TEST_JET_INTERVAL_MS
                endif
            endif
        endif
        if FlarakTestAimLocked = TRUE and FlarakTestRocketActive = TRUE and NowMs-FlarakTestRocketLaunchMs >= FLARAK_TEST_POST_SHOT_HOLD_MS
            FlarakTestAimLocked = FALSE
        endif
    endif
endfunction

function FlarakVisualTestDraw(Screen as TSize)
    local X as float
    local Y as float
    local WarningStep as integer
    local WarningLamp as integer
    local WarningDistance as float
    local MuzzleAngle as float
    if FlarakTestBaseSprite = 0 or FlarakTestLauncherSprite = 0 then exitfunction
    X = Screen.Width*0.5
    Y = Screen.Height-45
    SetSpriteFrame(FlarakTestBaseSprite,FlarakTestCurrentFrame)
    SetSpritePositionByOffset(FlarakTestBaseSprite,X,Y)
    DrawSprite(FlarakTestBaseSprite)
    if FlarakTestCurrentFrame = 5
        SetSpriteAngle(FlarakTestLauncherSprite,FlarakTestCurrentLauncherAngle)
        SetSpritePositionByOffset(FlarakTestLauncherSprite,X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X,Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y)
        if FlarakTestRocketActive = TRUE
            SetSpriteAngle(FlarakTestRocketSprite,FlarakTestRocketSpriteAngle)
            SetSpritePositionByOffset(FlarakTestRocketSprite,FlarakTestRocketPosX,FlarakTestRocketPosY)
            DrawSprite(FlarakTestRocketSprite)
        endif
        DrawSprite(FlarakTestLauncherSprite)
        if FlarakTestAimLocked = TRUE and FlarakTestRocketActive = FALSE and FlarakTestNowMs-FlarakTestAimLockMs >= FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS
            WarningStep = (FlarakTestNowMs-FlarakTestAimLockMs-(FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS))/100
            if WarningStep > 2 then WarningStep = 2
            MuzzleAngle = FlarakTestLockedLauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            for WarningLamp = 0 to WarningStep
                WarningDistance = 3+WarningLamp*4
                SetSpritePositionByOffset(FlarakTestWarningSprite,X+Sin(MuzzleAngle)*WarningDistance,Y-Cos(MuzzleAngle)*WarningDistance)
                DrawSprite(FlarakTestWarningSprite)
            next WarningLamp
        endif
    endif
endfunction
