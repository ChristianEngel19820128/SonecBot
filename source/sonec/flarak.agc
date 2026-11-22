// Flarak visual test: dual homing rockets with impact fuses; no damage yet.
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
// Dual-rocket launch and homing test; impact detection does not deal damage yet.
#constant FLARAK_TEST_ROCKET_INTERVAL_MS 2400
#constant FLARAK_TEST_ROCKET_LIFETIME_MS 6000
#constant FLARAK_TEST_HOMING_DELAY_MS 600
#constant FLARAK_TEST_HOMING_TURN_DEG_PER_MS 0.06
#constant FLARAK_TEST_ROCKET_SPEED_PX_PER_MS 0.32
#constant FLARAK_TEST_MUZZLE_DISTANCE 22
#constant FLARAK_TEST_ROCKET_LANE_OFFSET 2.5
#constant FLARAK_TEST_SECOND_ROCKET_DELAY_MS 120
#constant FLARAK_TEST_JET_INTERVAL_MS 20
#constant FLARAK_TEST_JET_BACK_SPACING 3
#constant FLARAK_TEST_JET_SCALE 0.37
#constant FLARAK_TEST_JET_TAIL_DISTANCE 8
#constant FLARAK_TEST_AIM_HOLD_MS 1000
#constant FLARAK_TEST_WARNING_MS 300
#constant FLARAK_TEST_POST_SHOT_HOLD_MS 200
// The launcher barrel points sideways in its source frame, not upward.
#constant FLARAK_TEST_BARREL_ANGLE_OFFSET 90

type TFlarakTestRocket
    Sprite as integer
    Active as integer
    LaunchMs as integer
    StartX as float
    StartY as float
    PosX as float
    PosY as float
    LastMs as integer
    Angle as float
    SpriteAngle as float
    TipDistance as float
    NextJetMs as integer
endtype

global FlarakTestRocket1 as TFlarakTestRocket
global FlarakTestRocket2 as TFlarakTestRocket
global FlarakTestSecondPending as integer
global FlarakTestSecondFireMs as integer
global FlarakTestVolleyStartMs as integer
global FlarakTestVolleyFired as integer
global FlarakTestVolleyAngle as float

global FlarakTestBaseSprite as integer
global FlarakTestLauncherSprite as integer
global FlarakTestStartMs as integer
global FlarakTestRocketNextMs as integer
global FlarakTestAimLocked as integer
global FlarakTestAimLockMs as integer
global FlarakTestLockedLauncherAngle as float
global FlarakTestWarningSprite as integer
global FlarakTestCurrentFrame as integer
global FlarakTestCurrentLauncherAngle as float
global FlarakTestNowMs as integer
global FlarakTestWorldX as float
global FlarakTestWorldY as float

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
        FlarakTestRocket1.Sprite = CreateSprite(Image.ID)
        SetSpriteOffset(FlarakTestRocket1.Sprite,GetSpriteWidth(FlarakTestRocket1.Sprite)*0.5,GetSpriteHeight(FlarakTestRocket1.Sprite)*0.5)
        SetSpriteColor(FlarakTestRocket1.Sprite,170,215,170,255)
        FlarakTestRocket1.TipDistance = GetSpriteWidth(FlarakTestRocket1.Sprite)*0.5
        FlarakTestRocket2.Sprite = CreateSprite(Image.ID)
        SetSpriteOffset(FlarakTestRocket2.Sprite,GetSpriteWidth(FlarakTestRocket2.Sprite)*0.5,GetSpriteHeight(FlarakTestRocket2.Sprite)*0.5)
        SetSpriteColor(FlarakTestRocket2.Sprite,170,215,170,255)
        FlarakTestRocket2.TipDistance = GetSpriteWidth(FlarakTestRocket2.Sprite)*0.5
    endif
    // Small warning lamp; it steps across three points on the barrel.
    FlarakTestWarningSprite = CreateSprite(0)
    SetSpriteSize(FlarakTestWarningSprite,2,2)
    SetSpriteOffset(FlarakTestWarningSprite,1,1)
    SetSpriteColor(FlarakTestWarningSprite,255,155,45,255)
    FlarakTestAimLocked = FALSE
    FlarakTestRocket1.Active = FALSE
    FlarakTestRocket2.Active = FALSE
    FlarakTestSecondPending = FALSE
    FlarakTestVolleyFired = FALSE
    FlarakTestStartMs = -1
    FlarakTestCurrentFrame = 1
    FlarakTestRocketNextMs = 0
endfunction


// Lane offset is perpendicular to the flight axis: negative = upper tube at 0 degrees.
function FlarakRocketLaunch(Rocket ref as TFlarakTestRocket,X as float,Y as float,FlightAngle as float,LaneOffset as float,NowMs as integer)
    Rocket.Angle = FlightAngle
    Rocket.SpriteAngle = FlightAngle+90
    Rocket.StartX = X+Sin(FlightAngle)*FLARAK_TEST_MUZZLE_DISTANCE+Cos(FlightAngle)*LaneOffset
    Rocket.StartY = Y-Cos(FlightAngle)*FLARAK_TEST_MUZZLE_DISTANCE+Sin(FlightAngle)*LaneOffset
    Rocket.PosX = Rocket.StartX
    Rocket.PosY = Rocket.StartY
    Rocket.LastMs = NowMs
    Rocket.NextJetMs = NowMs
    Rocket.LaunchMs = NowMs
    Rocket.Active = TRUE
endfunction

function FlarakRocketDo(Rocket ref as TFlarakTestRocket,Game ref as TGame,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,NowMs as integer)
    local RocketDeltaMs as integer
    local OldX as float
    local OldY as float
    local OldAngle as float
    local ImpactPosition as TPosition
    local TargetAngle as float
    local AngleDiff as float
    local MaxTurn as float
    local JetPosition as TPosition
    local Jetfire as TJetfire
    local JetIndex as integer
    local JetFound as integer
    local JetOutlet as integer
    local JetBackDistance as float
    if Rocket.Active = FALSE then exitfunction
    if NowMs-Rocket.LaunchMs >= FLARAK_TEST_ROCKET_LIFETIME_MS
        ImpactPosition.x = Rocket.PosX
        ImpactPosition.y = Rocket.PosY
        ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,3,ImpactPosition,NowMs)
        Rocket.Active = FALSE
        exitfunction
    endif
    RocketDeltaMs = NowMs-Rocket.LastMs
    if RocketDeltaMs < 0 then RocketDeltaMs = 0
    if RocketDeltaMs > 50 then RocketDeltaMs = 50
    Rocket.LastMs = NowMs
    OldAngle = Rocket.Angle
    if NowMs-Rocket.LaunchMs >= FLARAK_TEST_HOMING_DELAY_MS
        TargetAngle = ATan2(Game.Sonec.ObjectData.Position.x-Rocket.PosX,Rocket.PosY-(Game.Sonec.ObjectData.Position.y))
        AngleDiff = TargetAngle-Rocket.Angle
        while AngleDiff > 180
            AngleDiff = AngleDiff-360
        endwhile
        while AngleDiff < -180
            AngleDiff = AngleDiff+360
        endwhile
        MaxTurn = FLARAK_TEST_HOMING_TURN_DEG_PER_MS*RocketDeltaMs
        if AngleDiff > MaxTurn then AngleDiff = MaxTurn
        if AngleDiff < -MaxTurn then AngleDiff = -MaxTurn
        Rocket.Angle = Rocket.Angle+AngleDiff
    endif
    OldX = Rocket.PosX
    OldY = Rocket.PosY
    Rocket.PosX = Rocket.PosX+Sin(Rocket.Angle)*FLARAK_TEST_ROCKET_SPEED_PX_PER_MS*RocketDeltaMs
    Rocket.PosY = Rocket.PosY-Cos(Rocket.Angle)*FLARAK_TEST_ROCKET_SPEED_PX_PER_MS*RocketDeltaMs
    Rocket.SpriteAngle = Rocket.Angle+90
    // Remove rockets at world bounds, independently of the six-second fuse.
    if Rocket.PosX < 0 or Rocket.PosX > World.Size.Width or Rocket.PosY < 0 or Rocket.PosY > World.Size.Height
        Rocket.Active = FALSE
        exitfunction
    endif
    // Swept impact fuse: test the movement segment against both Sonec circles.
    if FlarakRocketHitsSonec(Rocket,OldX,OldY,OldAngle,Game.Sonec) = TRUE
        ImpactPosition.x = Rocket.PosX+Sin(Rocket.Angle)*Rocket.TipDistance
        ImpactPosition.y = Rocket.PosY-Cos(Rocket.Angle)*Rocket.TipDistance
        ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,3,ImpactPosition,NowMs)
        Rocket.Active = FALSE
        exitfunction
    endif
    if NowMs >= Rocket.NextJetMs and ProtoJetfire.AnimJetfire.Sprite.ID > 0
        for JetOutlet = 0 to 3
            JetBackDistance = FLARAK_TEST_JET_TAIL_DISTANCE+JetOutlet*FLARAK_TEST_JET_BACK_SPACING
            JetPosition.x = Rocket.PosX-Sin(Rocket.Angle)*JetBackDistance
            JetPosition.y = Rocket.PosY+Cos(Rocket.Angle)*JetBackDistance
            JetfireNew(Jetfire,ProtoJetfire,World,JetPosition,NowMs)
            Jetfire.SpriteData.Angle = Rocket.Angle
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
        Rocket.NextJetMs = NowMs+FLARAK_TEST_JET_INTERVAL_MS
    endif
endfunction

// Use Sonec's shared two-circle geometry, in screen coordinates.
function FlarakRocketHitsSonec(Rocket ref as TFlarakTestRocket,OldX as float,OldY as float,OldAngle as float,Sonec ref as TSonec)
    local TipOldX as float
    local TipOldY as float
    local TipNewX as float
    local TipNewY as float
    local Dx as float
    local Dy as float
    local LengthSquared as float
    local T as float
    local ClosestX as float
    local ClosestY as float
    local CircleY as float
    local DistanceX as float
    local DistanceY as float
    local Radius as float
    local CircleIndex as integer
    if Sonec.IsLost = TRUE then exitfunction FALSE
    // The image is centered; its nose is half a sprite width ahead along flight.
    // Rotate both the previous and current nose points to sweep the actual fuse.
    TipOldX = OldX+Sin(OldAngle)*Rocket.TipDistance
    TipOldY = OldY-Cos(OldAngle)*Rocket.TipDistance
    TipNewX = Rocket.PosX+Sin(Rocket.Angle)*Rocket.TipDistance
    TipNewY = Rocket.PosY-Cos(Rocket.Angle)*Rocket.TipDistance
    Dx = TipNewX-TipOldX
    Dy = TipNewY-TipOldY
    LengthSquared = Dx*Dx+Dy*Dy
    Radius = SonecHitCircleRadius(Sonec)
    for CircleIndex = 0 to 1
        CircleY = SonecHitCircleY(Sonec,CircleIndex)
        T = 0
        if LengthSquared > 0
            T = ((Sonec.ObjectData.Position.x-TipOldX)*Dx+(CircleY-TipOldY)*Dy)/LengthSquared
            if T < 0 then T = 0
            if T > 1 then T = 1
        endif
        ClosestX = TipOldX+Dx*T
        ClosestY = TipOldY+Dy*T
        DistanceX = Sonec.ObjectData.Position.x-ClosestX
        DistanceY = CircleY-ClosestY
        if DistanceX*DistanceX+DistanceY*DistanceY <= Radius*Radius then exitfunction TRUE
    next CircleIndex
endfunction FALSE

function FlarakRocketDraw(Rocket ref as TFlarakTestRocket,World ref as TWorld)
    if Rocket.Active = FALSE then exitfunction
    SetSpriteAngle(Rocket.Sprite,Rocket.SpriteAngle)
    SetSpritePositionByOffset(Rocket.Sprite,Rocket.PosX-World.Position.x,Rocket.PosY-World.Position.y)
    DrawSprite(Rocket.Sprite)
endfunction

function FlarakVisualTestDo(Screen as TSize,Game ref as TGame,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,NowMs as integer)
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
        FlarakTestWorldX = World.Size.Width-45
        FlarakTestWorldY = World.Size.Height-45
        FlarakTestStartMs = NowMs
        FlarakTestRocketNextMs = NowMs+1500
    endif
    FlarakTestNowMs = NowMs
    Elapsed = NowMs-FlarakTestStartMs
    Frame = 1+Elapsed/FLARAK_TEST_FRAME_MS
    if Frame > 5 then Frame = 5
    FlarakTestCurrentFrame = Frame
    X = FlarakTestWorldX
    Y = FlarakTestWorldY
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
        if FlarakTestAimLocked = FALSE and FlarakTestRocket1.Active = FALSE and FlarakTestRocket2.Active = FALSE and FlarakTestSecondPending = FALSE and NowMs >= FlarakTestRocketNextMs
            FlarakTestLockedLauncherAngle = LauncherAngle
            FlarakTestAimLockMs = NowMs
            FlarakTestAimLocked = TRUE
            FlarakTestVolleyFired = FALSE
        endif
        if FlarakTestAimLocked = TRUE
            LauncherAngle = FlarakTestLockedLauncherAngle
        endif
        FlarakTestCurrentLauncherAngle = LauncherAngle
        // Launch two missiles from parallel tubes, 5 px apart.
        // At 0 degrees, the first tube is above and the second below.
        if FlarakTestAimLocked = TRUE and FlarakTestRocket1.Sprite > 0 and FlarakTestSecondPending = FALSE and FlarakTestRocket1.Active = FALSE and FlarakTestRocket2.Active = FALSE and NowMs-FlarakTestAimLockMs >= FLARAK_TEST_AIM_HOLD_MS
            FlarakTestVolleyAngle = LauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            FlarakRocketLaunch(FlarakTestRocket1,X,Y,FlarakTestVolleyAngle,-FLARAK_TEST_ROCKET_LANE_OFFSET,NowMs)
            FlarakTestSecondFireMs = NowMs+FLARAK_TEST_SECOND_ROCKET_DELAY_MS
            FlarakTestSecondPending = TRUE
            FlarakTestVolleyStartMs = NowMs
            FlarakTestVolleyFired = TRUE
            FlarakTestRocketNextMs = NowMs+FLARAK_TEST_ROCKET_INTERVAL_MS
        endif
        if FlarakTestSecondPending = TRUE and NowMs >= FlarakTestSecondFireMs
            FlarakRocketLaunch(FlarakTestRocket2,X,Y,FlarakTestVolleyAngle,FLARAK_TEST_ROCKET_LANE_OFFSET,NowMs)
            FlarakTestSecondPending = FALSE
        endif
        FlarakRocketDo(FlarakTestRocket1,Game,JetfireList,ProtoJetfire,World,NowMs)
        FlarakRocketDo(FlarakTestRocket2,Game,JetfireList,ProtoJetfire,World,NowMs)
        if FlarakTestAimLocked = TRUE and FlarakTestVolleyFired = TRUE and FlarakTestSecondPending = FALSE and NowMs-FlarakTestVolleyStartMs >= FLARAK_TEST_SECOND_ROCKET_DELAY_MS+FLARAK_TEST_POST_SHOT_HOLD_MS
            FlarakTestAimLocked = FALSE
        endif
    endif
endfunction

function FlarakVisualTestDraw(World ref as TWorld)
    local X as float
    local Y as float
    local WarningStep as integer
    local WarningLamp as integer
    local WarningDistance as float
    local MuzzleAngle as float
    if FlarakTestBaseSprite = 0 or FlarakTestLauncherSprite = 0 then exitfunction
    X = FlarakTestWorldX-World.Position.x
    Y = FlarakTestWorldY-World.Position.y
    SetSpriteFrame(FlarakTestBaseSprite,FlarakTestCurrentFrame)
    SetSpritePositionByOffset(FlarakTestBaseSprite,X,Y)
    DrawSprite(FlarakTestBaseSprite)
    if FlarakTestCurrentFrame = 5
        SetSpriteAngle(FlarakTestLauncherSprite,FlarakTestCurrentLauncherAngle)
        SetSpritePositionByOffset(FlarakTestLauncherSprite,X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X,Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y)
        FlarakRocketDraw(FlarakTestRocket1,World)
        FlarakRocketDraw(FlarakTestRocket2,World)
        DrawSprite(FlarakTestLauncherSprite)
        if FlarakTestAimLocked = TRUE and FlarakTestRocket1.Active = FALSE and FlarakTestRocket2.Active = FALSE and FlarakTestSecondPending = FALSE and FlarakTestNowMs-FlarakTestAimLockMs >= FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS
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
