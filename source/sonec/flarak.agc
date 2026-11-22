// Flarak silo enemy: deploy, aim and fire independent homing rocket pairs; no damage yet.
// Seven 80x64 cells: 1-5 base, 6 shared rotating launcher, 7 Flak overlay.
#constant FLARAK_VARIANT_ROCKET 0
#constant FLARAK_VARIANT_FLAK 1
#constant FLARAK_FLAK_RISE_PX 12
#constant FLARAK_FLAK_FINAL_OFFSET_Y -12
#constant FLARAK_FLAK_RISE_MS 500
#constant FLARAK_TEST_CELL_W 80
#constant FLARAK_TEST_CELL_H 64
#constant FLARAK_TEST_BASE_OFFSET_X 40
#constant FLARAK_TEST_BASE_OFFSET_Y 42
// Approved base and launcher pivots; do not change for spawn alignment.
#constant FLARAK_TEST_LAUNCHER_PIVOT_X 40
#constant FLARAK_TEST_LAUNCHER_PIVOT_Y 42
// Adjustable silo behavior (degrees are launcher sprite angles).
#constant FLARAK_DETECT_DISTANCE 550
#constant FLARAK_RETRACT_DISTANCE 650
#constant FLARAK_MIN_DISTANCE 95
#constant FLARAK_REOPEN_DISTANCE 120
#constant FLARAK_RIGHT_MIN_ANGLE -60
#constant FLARAK_RIGHT_MAX_ANGLE 0
#constant FLARAK_LEFT_MIN_ANGLE 0
#constant FLARAK_LEFT_MAX_ANGLE 60
#constant FLARAK_TURN_DEG_PER_MS 0.18
#constant FLARAK_AIM_TOLERANCE_DEG 9
#constant FLARAK_TEST_FRAME_MS 140
#constant FLARAK_CLOSED 0
#constant FLARAK_OPENING 1
#constant FLARAK_READY 2
#constant FLARAK_RETURNING 3
#constant FLARAK_CLOSING 4
#constant FLARAK_SWITCHING 5
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
    FlakSprite as integer
    Variant as integer
    FlakRiseStartMs as integer
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
    State as integer
    FrameStampMs as integer
    LastUpdateMs as integer
    AimSide as integer
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

// Find the free 80px footprint nearest the platform center, avoiding chests.
function FlarakFindFreeOffsetX(Plate ref as TPlate,PlateIndex as integer,ChestList ref as TChestList)
    local Candidate as integer
    local MaxLeft as integer
    local ChestIndex as integer
    local Blocked as integer
    local BestLeft as integer
    local BestDistance as float
    local Distance as float
    local ChestLeft as float
    local ChestRight as float
    MaxLeft = Floor(Plate.ObjectData.Size.Width-FLARAK_TEST_CELL_W)
    BestLeft = -1
    BestDistance = Plate.ObjectData.Size.Width+1
    for Candidate = 0 to MaxLeft
        Blocked = FALSE
        for ChestIndex = 0 to ChestList.Chest.Length
            if ChestList.Chest[ChestIndex].Enabled = TRUE and ChestList.Chest[ChestIndex].CollisionData.Index = PlateIndex
                ChestLeft = ChestList.Chest[ChestIndex].CollisionData.Position.x
                ChestRight = ChestLeft+ChestList.Chest[ChestIndex].ObjectData.Size.Width
                if Candidate < ChestRight and Candidate+FLARAK_TEST_CELL_W > ChestLeft
                    Blocked = TRUE
                endif
            endif
        next ChestIndex
        if Blocked = FALSE
            Distance = Abs(Candidate+FLARAK_TEST_CELL_W*0.5-Plate.ObjectData.Size.Width*0.5)
            if Distance < BestDistance
                BestDistance = Distance
                BestLeft = Candidate
            endif
        endif
    next Candidate
endfunction BestLeft

function FlarakSpawn(PlateList ref as TPlateList,ChestList ref as TChestList,PlateIndex as integer,NowMs as integer)
    local F as TFlarak
    local Plate as TPlate
    local i as integer
    local FreeLeft as integer
    if FlarakBaseImage = 0 or FlarakRocketImage = 0 then exitfunction
    if PlateIndex < 0 or PlateIndex > PlateList.Plate.Length then exitfunction
    Plate = PlateList.Plate[PlateIndex]
    if Plate.Enabled = FALSE or Plate.ObjectData.Size.Width < FLARAK_TEST_CELL_W+20 then exitfunction
    FreeLeft = FlarakFindFreeOffsetX(Plate,PlateIndex,ChestList)
    if FreeLeft < 0 then exitfunction
    F.Enabled = TRUE
    F.Variant = Random(0,1)
    F.PlateIndex = PlateIndex
    F.PlateOffsetX = FreeLeft+FLARAK_TEST_BASE_OFFSET_X
    // Developer-verified platform alignment; no extra platform-height correction.
    F.PlateOffsetY = -(FLARAK_TEST_CELL_H-FLARAK_TEST_BASE_OFFSET_Y)
    F.WorldX = Plate.ObjectData.Position.x+F.PlateOffsetX
    F.WorldY = Plate.ObjectData.Position.y+F.PlateOffsetY
    F.BaseSprite = CreateSprite(FlarakBaseImage)
    SetSpriteAnimation(F.BaseSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,7)
    SetSpriteFrame(F.BaseSprite,1)
    SetSpriteOffset(F.BaseSprite,FLARAK_TEST_BASE_OFFSET_X,FLARAK_TEST_BASE_OFFSET_Y)
    SetSpriteColor(F.BaseSprite,0,255,0,255)
    F.LauncherSprite = CreateSprite(FlarakBaseImage)
    SetSpriteAnimation(F.LauncherSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,7)
    SetSpriteFrame(F.LauncherSprite,6)
    SetSpriteOffset(F.LauncherSprite,FLARAK_TEST_LAUNCHER_PIVOT_X,FLARAK_TEST_LAUNCHER_PIVOT_Y)
    SetSpriteColor(F.LauncherSprite,0,255,0,255)
    if F.Variant = FLARAK_VARIANT_FLAK
        F.FlakSprite = CreateSprite(FlarakBaseImage)
        SetSpriteAnimation(F.FlakSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,7)
        SetSpriteFrame(F.FlakSprite,7)
        SetSpriteOffset(F.FlakSprite,FLARAK_TEST_LAUNCHER_PIVOT_X,FLARAK_TEST_LAUNCHER_PIVOT_Y)
        SetSpriteColor(F.FlakSprite,0,255,0,255)
    endif
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
    F.State = FLARAK_CLOSED
    F.FrameStampMs = NowMs
    F.LastUpdateMs = NowMs
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = FALSE and FlarakList[i].Rocket1.Active = FALSE and FlarakList[i].Rocket2.Active = FALSE
            // Recycle the old instance's five sprites before replacing the slot.
            if FlarakList[i].BaseSprite > 0 then DeleteSprite(FlarakList[i].BaseSprite)
            if FlarakList[i].LauncherSprite > 0 then DeleteSprite(FlarakList[i].LauncherSprite)
            if FlarakList[i].FlakSprite > 0 then DeleteSprite(FlarakList[i].FlakSprite)
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

// Move a launcher towards its desired sprite angle without crossing the ground.
function FlarakTurnTowards(CurrentAngle as float,TargetAngle as float,StepAngle as float)
    if CurrentAngle < TargetAngle
        CurrentAngle = CurrentAngle+StepAngle
        if CurrentAngle > TargetAngle then CurrentAngle = TargetAngle
    else
        CurrentAngle = CurrentAngle-StepAngle
        if CurrentAngle < TargetAngle then CurrentAngle = TargetAngle
    endif
endfunction CurrentAngle

function FlarakDo(F ref as TFlarak,Game ref as TGame,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,NowMs as integer)
    local Dx as float
    local Dy as float
    local Distance as float
    local DesiredAngle as float
    local StepAngle as float
    local DeltaMs as integer
    local ValidRange as integer
    local FrameSteps as integer
    local TargetSide as integer
    if F.Enabled = FALSE then exitfunction
    F.NowMs = NowMs
    DeltaMs = NowMs-F.LastUpdateMs
    if DeltaMs < 0 then DeltaMs = 0
    if DeltaMs > 50 then DeltaMs = 50
    F.LastUpdateMs = NowMs
    StepAngle = FLARAK_TURN_DEG_PER_MS*DeltaMs
    Dx = Game.Sonec.ObjectData.Position.x-F.WorldX
    Dy = Game.Sonec.ObjectData.Position.y-F.WorldY
    Distance = Sqrt(Dx*Dx+Dy*Dy)
    ValidRange = TRUE
    if Game.Sonec.IsLost = TRUE then ValidRange = FALSE
    if Distance < FLARAK_MIN_DISTANCE then ValidRange = FALSE
    if Distance > FLARAK_RETRACT_DISTANCE then ValidRange = FALSE
    // Hysteresis: a closed silo only opens in the narrower safe range.
    if F.State = FLARAK_CLOSED
        if Game.Sonec.IsLost = FALSE and Distance >= FLARAK_REOPEN_DISTANCE and Distance <= FLARAK_DETECT_DISTANCE
            F.State = FLARAK_OPENING
            F.FrameStampMs = NowMs
            F.CurrentLauncherAngle = 0
        endif
    endif
    if F.State = FLARAK_OPENING or F.State = FLARAK_READY or F.State = FLARAK_SWITCHING
        if ValidRange = FALSE
            F.AimLocked = FALSE
            F.State = FLARAK_RETURNING
        endif
    endif
    // Complete the already started second rocket even during a retreat.
    if F.SecondPending = TRUE and NowMs >= F.SecondFireMs
        FlarakRocketLaunch(F.Rocket2,F.WorldX,F.WorldY,F.VolleyAngle,FLARAK_TEST_ROCKET_LANE_OFFSET,NowMs)
        F.SecondPending = FALSE
    endif
    if F.State = FLARAK_OPENING
        FrameSteps = (NowMs-F.FrameStampMs)/FLARAK_TEST_FRAME_MS
        if FrameSteps > 0
            F.CurrentFrame = F.CurrentFrame+FrameSteps
            F.FrameStampMs = F.FrameStampMs+FrameSteps*FLARAK_TEST_FRAME_MS
        endif
        if F.CurrentFrame >= 5
            F.CurrentFrame = 5
            F.State = FLARAK_READY
            F.CurrentLauncherAngle = 0
            F.AimSide = 0
            F.FlakRiseStartMs = NowMs
        endif
    endif
    if F.State = FLARAK_READY
        TargetSide = 1
        if Dx < 0 then TargetSide = -1
        // Finish an already locked volley before changing sides.
        if F.AimSide <> 0 and TargetSide <> F.AimSide and F.AimLocked = FALSE and F.SecondPending = FALSE
            F.State = FLARAK_SWITCHING
        endif
        // Mirror the launcher visually on the left: both sides lift from 0
        // without the former 180-degree rotation.
        DesiredAngle = ATan2(Dx,-Dy)-FLARAK_TEST_BARREL_ANGLE_OFFSET
        if TargetSide < 0
            // Convert the old left-side negative angle into a small mirrored lift.
            if DesiredAngle > 0 then DesiredAngle = DesiredAngle-360
            DesiredAngle = DesiredAngle+180
            if DesiredAngle < FLARAK_LEFT_MIN_ANGLE then DesiredAngle = FLARAK_LEFT_MIN_ANGLE
            if DesiredAngle > FLARAK_LEFT_MAX_ANGLE then DesiredAngle = FLARAK_LEFT_MAX_ANGLE
        else
            if DesiredAngle < FLARAK_RIGHT_MIN_ANGLE then DesiredAngle = FLARAK_RIGHT_MIN_ANGLE
            if DesiredAngle > FLARAK_RIGHT_MAX_ANGLE then DesiredAngle = FLARAK_RIGHT_MAX_ANGLE
        endif
        // Flak artwork faces correctly after mirroring, but its elevation angle
        // must run opposite to the rocket launcher on both target sides.
        if F.Variant = FLARAK_VARIANT_FLAK then DesiredAngle = -DesiredAngle
        if F.State = FLARAK_READY and F.AimSide = 0 then F.AimSide = TargetSide
        if F.State = FLARAK_READY and F.AimLocked = FALSE
            F.CurrentLauncherAngle = FlarakTurnTowards(F.CurrentLauncherAngle,DesiredAngle,StepAngle)
            if F.Variant = FLARAK_VARIANT_ROCKET and F.Rocket1.Active = FALSE and F.Rocket2.Active = FALSE and F.SecondPending = FALSE and NowMs >= F.RocketNextMs
                if Abs(F.CurrentLauncherAngle-DesiredAngle) <= FLARAK_AIM_TOLERANCE_DEG
                    F.LockedLauncherAngle = F.CurrentLauncherAngle
                    F.AimLockMs = NowMs
                    F.AimLocked = TRUE
                    F.VolleyFired = FALSE
                endif
            endif
        else
            if F.AimLocked = TRUE then F.CurrentLauncherAngle = F.LockedLauncherAngle
        endif
        if F.Variant = FLARAK_VARIANT_ROCKET and F.State = FLARAK_READY and F.AimLocked = TRUE and F.Rocket1.Sprite > 0 and F.SecondPending = FALSE and F.Rocket1.Active = FALSE and F.Rocket2.Active = FALSE and F.VolleyFired = FALSE and NowMs-F.AimLockMs >= FLARAK_TEST_AIM_HOLD_MS
            // Keep the original rocket flight angles while only mirroring the launcher artwork.
            F.VolleyAngle = F.CurrentLauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            if F.AimSide < 0 then F.VolleyAngle = F.CurrentLauncherAngle-180+FLARAK_TEST_BARREL_ANGLE_OFFSET
            FlarakRocketLaunch(F.Rocket1,F.WorldX,F.WorldY,F.VolleyAngle,-FLARAK_TEST_ROCKET_LANE_OFFSET,NowMs)
            F.SecondFireMs = NowMs+FLARAK_TEST_SECOND_ROCKET_DELAY_MS
            F.SecondPending = TRUE
            F.VolleyStartMs = NowMs
            F.VolleyFired = TRUE
            F.RocketNextMs = NowMs+FLARAK_TEST_ROCKET_INTERVAL_MS
        endif
        if F.AimLocked = TRUE and F.VolleyFired = TRUE and F.SecondPending = FALSE and NowMs-F.VolleyStartMs >= FLARAK_TEST_SECOND_ROCKET_DELAY_MS+FLARAK_TEST_POST_SHOT_HOLD_MS
            F.AimLocked = FALSE
        endif
    endif
    if F.State = FLARAK_SWITCHING
        F.CurrentLauncherAngle = FlarakTurnTowards(F.CurrentLauncherAngle,0,StepAngle)
        if F.CurrentLauncherAngle = 0
            F.AimSide = 0
            F.State = FLARAK_READY
        endif
    endif
    if F.State = FLARAK_RETURNING
        F.CurrentLauncherAngle = FlarakTurnTowards(F.CurrentLauncherAngle,0,StepAngle)
        if F.CurrentLauncherAngle = 0 and F.SecondPending = FALSE
            F.State = FLARAK_CLOSING
            F.FrameStampMs = NowMs
        endif
    endif
    if F.State = FLARAK_CLOSING
        FrameSteps = (NowMs-F.FrameStampMs)/FLARAK_TEST_FRAME_MS
        if FrameSteps > 0
            F.CurrentFrame = F.CurrentFrame-FrameSteps
            F.FrameStampMs = F.FrameStampMs+FrameSteps*FLARAK_TEST_FRAME_MS
        endif
        if F.CurrentFrame <= 1
            F.CurrentFrame = 1
            F.State = FLARAK_CLOSED
        endif
    endif
    // Missiles keep moving regardless of the silo state.
    FlarakRocketDo(F.Rocket1,Game,JetfireList,ProtoJetfire,World,NowMs)
    FlarakRocketDo(F.Rocket2,Game,JetfireList,ProtoJetfire,World,NowMs)
endfunction

function FlarakDraw(F ref as TFlarak,World ref as TWorld)
    local X as float
    local Y as float
    local WarningStep as integer
    local WarningLamp as integer
    local WarningDistance as float
    local MuzzleAngle as float
    local RiseProgress as float
    local RiseOffset as float
    local FlakOffsetY as float
    local VisualAngle as float
    if F.BaseSprite = 0 or F.LauncherSprite = 0 then exitfunction
    X = F.WorldX-World.Position.x
    Y = F.WorldY-World.Position.y
    SetSpriteFrame(F.BaseSprite,F.CurrentFrame)
    SetSpritePositionByOffset(F.BaseSprite,X,Y)
    DrawSprite(F.BaseSprite)
    if F.CurrentFrame = 5
        VisualAngle = F.CurrentLauncherAngle
        if F.Variant = FLARAK_VARIANT_FLAK then VisualAngle = -VisualAngle
        if (F.AimSide < 0 and F.Variant = FLARAK_VARIANT_ROCKET) or (F.AimSide >= 0 and F.Variant = FLARAK_VARIANT_FLAK)
            SetSpriteFlip(F.LauncherSprite,1,0)
        else
            SetSpriteFlip(F.LauncherSprite,0,0)
        endif
        if F.Variant = FLARAK_VARIANT_FLAK and F.FlakSprite > 0
            RiseProgress = (F.NowMs-F.FlakRiseStartMs)*1.0/FLARAK_FLAK_RISE_MS
            if RiseProgress < 0 then RiseProgress = 0
            if RiseProgress > 1 then RiseProgress = 1
            RiseOffset = FLARAK_FLAK_RISE_PX*(1.0-RiseProgress)
            if F.AimSide >= 0
                SetSpriteFlip(F.FlakSprite,1,0)
            else
                SetSpriteFlip(F.FlakSprite,0,0)
            endif
            SetSpriteAngle(F.FlakSprite,VisualAngle)
            // Rotate the deployment offset around the same world pivot as frame 6.
            FlakOffsetY = FLARAK_FLAK_FINAL_OFFSET_Y+RiseOffset
            SetSpritePositionByOffset(F.FlakSprite,X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X-FlakOffsetY*Sin(VisualAngle),Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y+FlakOffsetY*Cos(VisualAngle))
            DrawSprite(F.FlakSprite)
        endif
        SetSpriteAngle(F.LauncherSprite,VisualAngle)
        SetSpritePositionByOffset(F.LauncherSprite,X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X,Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y)
        DrawSprite(F.LauncherSprite)
        if F.Variant = FLARAK_VARIANT_ROCKET and F.State = FLARAK_READY and F.AimLocked = TRUE and F.VolleyFired = FALSE and F.Rocket1.Active = FALSE and F.Rocket2.Active = FALSE and F.SecondPending = FALSE and F.NowMs-F.AimLockMs >= FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS
            WarningStep = (F.NowMs-F.AimLockMs-(FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS))/100
            if WarningStep > 2 then WarningStep = 2
            MuzzleAngle = F.LockedLauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            if F.AimSide < 0 then MuzzleAngle = F.LockedLauncherAngle-180+FLARAK_TEST_BARREL_ANGLE_OFFSET
            for WarningLamp = 0 to WarningStep
                WarningDistance = 3+WarningLamp*4
                SetSpritePositionByOffset(F.WarningSprite,X+Sin(MuzzleAngle)*WarningDistance,Y-Cos(MuzzleAngle)*WarningDistance)
                DrawSprite(F.WarningSprite)
            next WarningLamp
        endif
    endif
    FlarakRocketDraw(F.Rocket1,World)
    FlarakRocketDraw(F.Rocket2,World)
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
