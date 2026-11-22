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

type TFlarak
    Rocket1 as TFlarakTestRocket
    Rocket2 as TFlarakTestRocket
    SecondPending as integer
    SecondFireMs as integer
    VolleyStartMs as integer
    VolleyFired as integer
    VolleyAngle as float
    BaseSprite as integer
    LauncherSprite as integer
    StartMs as integer
    RocketNextMs as integer
    AimLocked as integer
    AimLockMs as integer
    LockedLauncherAngle as float
    WarningSprite as integer
    CurrentFrame as integer
    CurrentLauncherAngle as float
    NowMs as integer
    WorldX as float
    WorldY as float
    Enabled as integer
    PlateIndex as integer
    PlateOffsetX as float
    PlateOffsetY as float
endtype

global FlarakList as TFlarak[]
global FlarakBaseImage as integer
global FlarakRocketImage as integer

function FlarakVisualTestCreate()
    local Image as TImage
    FlarakList.Length = -1
    Image.File.Path = "/media/gfx/enemies"
    Image.File.Name = "flarak.png"
    if ImageLoad(Image) = TRUE then FlarakBaseImage = Image.ID
    Image.File.Path = "/media/gfx/weapons"
    Image.File.Name = "rocket.png"
    if ImageLoad(Image) = TRUE then FlarakRocketImage = Image.ID
endfunction

function FlarakSpawn(PlateList ref as TPlateList,PlateIndex as integer,NowMs as integer)
    local F as TFlarak
    local Plate as TPlate
    local i as integer
    if FlarakBaseImage = 0 or FlarakRocketImage = 0 then exitfunction
    if PlateIndex < 0 or PlateIndex > PlateList.Plate.Length then exitfunction
    Plate = PlateList.Plate[PlateIndex]
    if Plate.Enabled = FALSE or Plate.ObjectData.Size.Width < FLARAK_TEST_CELL_W+20 then exitfunction
    F.Enabled = TRUE
    F.PlateIndex = PlateIndex
    F.PlateOffsetX = Plate.ObjectData.Size.Width*0.5
    // Platform position is its vertical center (8 px high); align the sprite bottom to its top.
    // Keep the approved sprite pivot (40,42) separate from platform anchoring.
    F.PlateOffsetY = -Plate.ObjectData.Size.Height*0.5-(FLARAK_TEST_CELL_H-FLARAK_TEST_BASE_OFFSET_Y)
    F.WorldX = Plate.ObjectData.Position.x+F.PlateOffsetX
    F.WorldY = Plate.ObjectData.Position.y+F.PlateOffsetY
    F.BaseSprite = CreateSprite(FlarakBaseImage)
    SetSpriteAnimation(F.BaseSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,6)
    SetSpriteFrame(F.BaseSprite,1)
    SetSpriteOffset(F.BaseSprite,FLARAK_TEST_BASE_OFFSET_X,FLARAK_TEST_BASE_OFFSET_Y)
    SetSpriteColor(F.BaseSprite,80,232,80,255)
    F.LauncherSprite = CreateSprite(FlarakBaseImage)
    SetSpriteAnimation(F.LauncherSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,6)
    SetSpriteFrame(F.LauncherSprite,6)
    SetSpriteOffset(F.LauncherSprite,FLARAK_TEST_LAUNCHER_PIVOT_X,FLARAK_TEST_LAUNCHER_PIVOT_Y)
    SetSpriteColor(F.LauncherSprite,80,232,80,255)
    F.Rocket1.Sprite = CreateSprite(FlarakRocketImage)
    F.Rocket2.Sprite = CreateSprite(FlarakRocketImage)
    SetSpriteOffset(F.Rocket1.Sprite,GetSpriteWidth(F.Rocket1.Sprite)*0.5,GetSpriteHeight(F.Rocket1.Sprite)*0.5)
    SetSpriteOffset(F.Rocket2.Sprite,GetSpriteWidth(F.Rocket2.Sprite)*0.5,GetSpriteHeight(F.Rocket2.Sprite)*0.5)
    SetSpriteColor(F.Rocket1.Sprite,170,215,170,255)
    SetSpriteColor(F.Rocket2.Sprite,170,215,170,255)
    F.Rocket1.TipDistance = GetSpriteWidth(F.Rocket1.Sprite)*0.5
    F.Rocket2.TipDistance = GetSpriteWidth(F.Rocket2.Sprite)*0.5
    F.WarningSprite = CreateSprite(0)
    SetSpriteSize(F.WarningSprite,2,2)
    SetSpriteOffset(F.WarningSprite,1,1)
    SetSpriteColor(F.WarningSprite,255,155,45,255)
    F.StartMs = NowMs
    F.RocketNextMs = NowMs+1500
    F.CurrentFrame = 1
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = FALSE and FlarakList[i].Rocket1.Active = FALSE and FlarakList[i].Rocket2.Active = FALSE
            // Recycle the old instance's five sprites before replacing the slot.
            if FlarakList[i].BaseSprite > 0 then DeleteSprite(FlarakList[i].BaseSprite)
            if FlarakList[i].LauncherSprite > 0 then DeleteSprite(FlarakList[i].LauncherSprite)
            if FlarakList[i].Rocket1.Sprite > 0 then DeleteSprite(FlarakList[i].Rocket1.Sprite)
            if FlarakList[i].Rocket2.Sprite > 0 then DeleteSprite(FlarakList[i].Rocket2.Sprite)
            if FlarakList[i].WarningSprite > 0 then DeleteSprite(FlarakList[i].WarningSprite)
            FlarakList[i] = F
            exitfunction
        endif
    next i
    FlarakList.Insert(F)
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

function FlarakDo(F ref as TFlarak,Game ref as TGame,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,NowMs as integer)
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
    if F.Enabled = FALSE then exitfunction
    F.NowMs = NowMs
    Elapsed = NowMs-F.StartMs
    Frame = 1+Elapsed/FLARAK_TEST_FRAME_MS
    if Frame > 5 then Frame = 5
    F.CurrentFrame = Frame
    X = F.WorldX
    Y = F.WorldY
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
        if F.AimLocked = FALSE and F.Rocket1.Active = FALSE and F.Rocket2.Active = FALSE and F.SecondPending = FALSE and NowMs >= F.RocketNextMs
            F.LockedLauncherAngle = LauncherAngle
            F.AimLockMs = NowMs
            F.AimLocked = TRUE
            F.VolleyFired = FALSE
        endif
        if F.AimLocked = TRUE
            LauncherAngle = F.LockedLauncherAngle
        endif
        F.CurrentLauncherAngle = LauncherAngle
        // Launch two missiles from parallel tubes, 5 px apart.
        // At 0 degrees, the first tube is above and the second below.
        if F.AimLocked = TRUE and F.Rocket1.Sprite > 0 and F.SecondPending = FALSE and F.Rocket1.Active = FALSE and F.Rocket2.Active = FALSE and NowMs-F.AimLockMs >= FLARAK_TEST_AIM_HOLD_MS
            F.VolleyAngle = LauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            FlarakRocketLaunch(F.Rocket1,X,Y,F.VolleyAngle,-FLARAK_TEST_ROCKET_LANE_OFFSET,NowMs)
            F.SecondFireMs = NowMs+FLARAK_TEST_SECOND_ROCKET_DELAY_MS
            F.SecondPending = TRUE
            F.VolleyStartMs = NowMs
            F.VolleyFired = TRUE
            F.RocketNextMs = NowMs+FLARAK_TEST_ROCKET_INTERVAL_MS
        endif
        if F.SecondPending = TRUE and NowMs >= F.SecondFireMs
            FlarakRocketLaunch(F.Rocket2,X,Y,F.VolleyAngle,FLARAK_TEST_ROCKET_LANE_OFFSET,NowMs)
            F.SecondPending = FALSE
        endif
        FlarakRocketDo(F.Rocket1,Game,JetfireList,ProtoJetfire,World,NowMs)
        FlarakRocketDo(F.Rocket2,Game,JetfireList,ProtoJetfire,World,NowMs)
        if F.AimLocked = TRUE and F.VolleyFired = TRUE and F.SecondPending = FALSE and NowMs-F.VolleyStartMs >= FLARAK_TEST_SECOND_ROCKET_DELAY_MS+FLARAK_TEST_POST_SHOT_HOLD_MS
            F.AimLocked = FALSE
        endif
    endif
endfunction

function FlarakDraw(F ref as TFlarak,World ref as TWorld)
    local X as float
    local Y as float
    local WarningStep as integer
    local WarningLamp as integer
    local WarningDistance as float
    local MuzzleAngle as float
    if F.BaseSprite = 0 or F.LauncherSprite = 0 then exitfunction
    X = F.WorldX-World.Position.x
    Y = F.WorldY-World.Position.y
    SetSpriteFrame(F.BaseSprite,F.CurrentFrame)
    SetSpritePositionByOffset(F.BaseSprite,X,Y)
    DrawSprite(F.BaseSprite)
    if F.CurrentFrame = 5
        SetSpriteAngle(F.LauncherSprite,F.CurrentLauncherAngle)
        SetSpritePositionByOffset(F.LauncherSprite,X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X,Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y)
        FlarakRocketDraw(F.Rocket1,World)
        FlarakRocketDraw(F.Rocket2,World)
        DrawSprite(F.LauncherSprite)
        if F.AimLocked = TRUE and F.Rocket1.Active = FALSE and F.Rocket2.Active = FALSE and F.SecondPending = FALSE and F.NowMs-F.AimLockMs >= FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS
            WarningStep = (F.NowMs-F.AimLockMs-(FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS))/100
            if WarningStep > 2 then WarningStep = 2
            MuzzleAngle = F.LockedLauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            for WarningLamp = 0 to WarningStep
                WarningDistance = 3+WarningLamp*4
                SetSpritePositionByOffset(F.WarningSprite,X+Sin(MuzzleAngle)*WarningDistance,Y-Cos(MuzzleAngle)*WarningDistance)
                DrawSprite(F.WarningSprite)
            next WarningLamp
        endif
    endif
endfunction

function FlarakDoAll(Game ref as TGame,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,PlateList ref as TPlateList,NowMs as integer)
    local i as integer
    local PlateIndex as integer
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = TRUE
            PlateIndex = FlarakList[i].PlateIndex
            if PlateIndex < 0 or PlateIndex > PlateList.Plate.Length
                FlarakList[i].Enabled = FALSE
            else
                if PlateList.Plate[PlateIndex].Enabled = FALSE
                    FlarakList[i].Enabled = FALSE
                else
                    FlarakList[i].WorldX = PlateList.Plate[PlateIndex].ObjectData.Position.x+FlarakList[i].PlateOffsetX
                    FlarakList[i].WorldY = PlateList.Plate[PlateIndex].ObjectData.Position.y+FlarakList[i].PlateOffsetY
                    FlarakDo(FlarakList[i],Game,JetfireList,ProtoJetfire,World,NowMs)
                endif
            endif
        endif
        // Fired rockets continue even after their platform disappears.
        if FlarakList[i].Enabled = FALSE
            FlarakRocketDo(FlarakList[i].Rocket1,Game,JetfireList,ProtoJetfire,World,NowMs)
            FlarakRocketDo(FlarakList[i].Rocket2,Game,JetfireList,ProtoJetfire,World,NowMs)
        endif
    next i
endfunction

function FlarakDrawAll(World ref as TWorld)
    local i as integer
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = TRUE then FlarakDraw(FlarakList[i],World)
        if FlarakList[i].Enabled = FALSE
            FlarakRocketDraw(FlarakList[i].Rocket1,World)
            FlarakRocketDraw(FlarakList[i].Rocket2,World)
        endif
    next i
endfunction
