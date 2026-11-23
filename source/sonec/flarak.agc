// Flarak silo enemy: deploy, aim and fire independent homing rocket pairs; no damage yet.
// Seven 80x64 cells: 1-5 base, 6 shared rotating launcher, 7 Flak overlay.
#constant FLARAK_VARIANT_ROCKET 0
#constant FLARAK_VARIANT_FLAK 1
#constant FLARAK_HEALTH_MAX 150
#constant FLARAK_WRECK_COLOR 65
// Temporary in-game overlay for diagnosing Flak volleys on either side.
#constant FLARAK_DEBUG_BULLETS 1
#constant FLARAK_FLAK_RISE_PX 12
#constant FLARAK_FLAK_FINAL_OFFSET_Y -12
#constant FLARAK_FLAK_RISE_MS 500
#constant FLARAK_FLAK_SHOT_GAP_MS 75
#constant FLARAK_FLAK_VOLLEY_MIN_GAP_MS 3000
#constant FLARAK_FLAK_VOLLEY_MAX_GAP_MS 5000
#constant FLARAK_FLAK_AIM_ERROR_DEG 8
#constant FLARAK_FLAK_MUZZLE_DISTANCE 25
#constant FLARAK_FLAK_TUBE_OFFSET 3
#constant FLARAK_TEST_CELL_W 80
#constant FLARAK_TEST_CELL_H 64
#constant FLARAK_TEST_BASE_OFFSET_X 40
#constant FLARAK_TEST_BASE_OFFSET_Y 42
// Approved base and launcher pivots; do not change for spawn alignment.
#constant FLARAK_TEST_LAUNCHER_PIVOT_X 40
#constant FLARAK_TEST_LAUNCHER_PIVOT_Y 42
// Adjustable silo behavior (degrees are launcher sprite angles).
#constant FLARAK_DETECT_DISTANCE 650
#constant FLARAK_RETRACT_DISTANCE 750
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
// Keep the rocket attached while its rear half is still passing the muzzle.
#constant FLARAK_TEST_ROCKET_CLEAR_DISTANCE 14
// Perpendicular offset per rocket (8 px between their center lines).
#constant FLARAK_TEST_ROCKET_LANE_OFFSET 3
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
    Attached as integer
    LauncherX as float
    LauncherY as float
    ClearDistance as float
endtype

type TFlarak
    Health as integer
    Destroyed as integer
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
    FlakShotsFired as integer
    FlakNextShotMs as integer
    FlakNextVolleyMs as integer
    FlakVolleyAngle as float
    FlakVolleySide as integer
    FlakAimError as float
    FlakDebugAddCount as integer
    FlakDebugLastShotMs as integer
    FlakDebugLastBulletIndex as integer
    FlakDebugLastMoveStatus as integer
    FlakDebugLastShotX as float
    FlakDebugLastShotY as float
    FlakDebugLastShotAngle as float
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
global FlarakDebugText as integer
global FlarakDebugVisible as integer
global FlarakCollisionDebugVisible as integer
global FlarakCollisionDebugLineSprite as integer

function FlarakVisualTestCreate()
    local Image as TImage
    FlarakList.Length = -1
    Image.File.Path = "/media/gfx/enemies"
    Image.File.Name = "flarak.png"
    if ImageLoad(Image) = TRUE then FlarakBaseImage = Image.ID
    Image.File.Path = "/media/gfx/weapons"
    Image.File.Name = "rocket.png"
    if ImageLoad(Image) = TRUE then FlarakRocketImage = Image.ID
    if FLARAK_DEBUG_BULLETS = 1 and FlarakDebugText = 0
        FlarakDebugText = CreateText("")
        SetTextSize(FlarakDebugText,9)
        SetTextColor(FlarakDebugText,255,235,80,255)
    endif
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
    F.Health = FLARAK_HEALTH_MAX
    F.Destroyed = FALSE
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
    F.FlakNextVolleyMs = NowMs+1500
    F.FlakAimError = Random(-FLARAK_FLAK_AIM_ERROR_DEG,FLARAK_FLAK_AIM_ERROR_DEG)
    F.FlakDebugLastBulletIndex = -1
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

// Flak uses the regular enemy bullet system. Both muzzles follow the
// rotated frame-7 center; shots have no individual angular spread.
function FlarakFireBullet(F ref as TFlarak,Game ref as TGame,NowMs as integer)
    local Position as TPosition
    local VisualAngle as float
    local FlightAngle as float
    local TubeOffset as float
    local NewBulletIndex as integer
    // The Flak barrels point upward in their source art. Use exactly the
    // displayed barrel angle from the developer's aiming fix (no +/-90).
    VisualAngle = -F.FlakVolleyAngle
    // BulletNew uses CalcPosition, which only handles angles from 0 to 360.
    // Keep the same direction but normalize negative left-side Flak angles.
    FlightAngle = NormalizeAngle(VisualAngle)
    TubeOffset = -FLARAK_FLAK_TUBE_OFFSET
    if Mod(F.FlakShotsFired,2) = 1 then TubeOffset = FLARAK_FLAK_TUBE_OFFSET
    Position.x = F.WorldX-FLARAK_FLAK_FINAL_OFFSET_Y*Sin(VisualAngle)+Sin(FlightAngle)*FLARAK_FLAK_MUZZLE_DISTANCE+Cos(FlightAngle)*TubeOffset
    Position.y = F.WorldY+FLARAK_FLAK_FINAL_OFFSET_Y*Cos(VisualAngle)-Cos(FlightAngle)*FLARAK_FLAK_MUZZLE_DISTANCE+Sin(FlightAngle)*TubeOffset
    NewBulletIndex = BulletAdd(Game.BulletList,Game.ProtoBullet,Game.World,Position,FlightAngle,0,TYPEENEMY,NowMs)
    BulletSetModification(Game.BulletList,NewBulletIndex,BULLET_MOD_EXPLOSIVE,NowMs)
    if FLARAK_DEBUG_BULLETS = 1
        F.FlakDebugAddCount = F.FlakDebugAddCount+1
        F.FlakDebugLastShotMs = NowMs
        F.FlakDebugLastShotX = Position.x
        F.FlakDebugLastShotY = Position.y
        F.FlakDebugLastShotAngle = FlightAngle
        F.FlakDebugLastMoveStatus = 1
        F.FlakDebugLastBulletIndex = NewBulletIndex
    endif
endfunction

// Perpendicular launch offset rotates with flight direction:
// at 0 degrees (up), the rockets start side-by-side at X +/-4px.
// Both use the same FlightAngle until their independent homing begins.
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
    Rocket.Attached = TRUE
    Rocket.LauncherX = X
    Rocket.LauncherY = Y
    Rocket.ClearDistance = 0
    Rocket.Active = TRUE
endfunction

// Follow platform translation only while the rocket still clears the muzzle.
// The launch angle stays locked; once detached, position is world-independent.
function FlarakRocketFollowLauncher(Rocket ref as TFlarakTestRocket,X as float,Y as float)
    if Rocket.Active = FALSE or Rocket.Attached = FALSE then exitfunction
    Rocket.PosX = Rocket.PosX+X-Rocket.LauncherX
    Rocket.PosY = Rocket.PosY+Y-Rocket.LauncherY
    Rocket.LauncherX = X
    Rocket.LauncherY = Y
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
    if Rocket.Attached = TRUE
        Rocket.ClearDistance = Rocket.ClearDistance+FLARAK_TEST_ROCKET_SPEED_PX_PER_MS*RocketDeltaMs
        if Rocket.ClearDistance >= FLARAK_TEST_ROCKET_CLEAR_DISTANCE then Rocket.Attached = FALSE
    endif
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

// Destruction is a one-shot event. Keep the base sprite as a dark frame-1
// wreck; fired rockets remain independently simulated by FlarakDoAll.
function FlarakDestroy(F ref as TFlarak,Game ref as TGame,NowMs as integer)
    local Impact as TPosition
    if F.Enabled = FALSE or F.Destroyed = TRUE then exitfunction
    F.Destroyed = TRUE
    F.Health = 0
    F.SecondPending = FALSE
    F.FlakShotsFired = 4
    F.CurrentFrame = 1
    F.Rocket1.Attached = FALSE
    F.Rocket2.Attached = FALSE
    SetSpriteColor(F.BaseSprite,FLARAK_WRECK_COLOR,FLARAK_WRECK_COLOR,FLARAK_WRECK_COLOR,255)
    Impact.x = F.WorldX
    Impact.y = F.WorldY-10
    ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,4,Impact,NowMs)
    RewardDrop(Game,REWARD_OBJECT_FLARAK,Impact,NowMs)
endfunction

function FlarakApplyDamage(F ref as TFlarak,Game ref as TGame,Damage as integer,NowMs as integer)
    if F.Enabled = FALSE or F.Destroyed = TRUE or Damage <= 0 then exitfunction
    F.Health = F.Health-Damage
    if F.Health <= 0 then FlarakDestroy(F,Game,NowMs)
endfunction

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
    local FlakTargetInArc as integer
    if F.Enabled = FALSE or F.Destroyed = TRUE then exitfunction
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
    // Flak cannot engage targets below its platform: retract instead of
    // remaining deployed at the +/-80 degree firing limit.
    if F.Variant = FLARAK_VARIANT_FLAK and Dy > 0 then ValidRange = FALSE
    // Hysteresis: a closed silo only opens in the narrower safe range.
    if F.State = FLARAK_CLOSED
        if Game.Sonec.IsLost = FALSE and Distance >= FLARAK_REOPEN_DISTANCE and Distance <= FLARAK_DETECT_DISTANCE and (F.Variant <> FLARAK_VARIANT_FLAK or Dy <= 0)
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
        // Flak has a horizontal zero angle. Its mirrored artwork needs a
        // separate signed elevation: lower targets tilt down on either side.
        // VisualAngle is -CurrentLauncherAngle for Flak in FlarakDraw.
        FlakTargetInArc = TRUE
        if F.Variant = FLARAK_VARIANT_FLAK
            // Keep the developer's left/right angle conversion. Check the
            // unmodified target before clamping: no fire beyond +/-80 degrees.
            if TargetSide < 0 then DesiredAngle = ATan2(Dy,Abs(Dx)) + 90
            if TargetSide > 0 then DesiredAngle = -ATan2(Dy,Abs(Dx)) - 90
            if DesiredAngle < -80 or DesiredAngle > 80 then FlakTargetInArc = FALSE
            // One small random aiming error per volley, not bullet spread.
            DesiredAngle = DesiredAngle+F.FlakAimError
            if DesiredAngle < -80 then DesiredAngle = -80
            if DesiredAngle > 80 then DesiredAngle = 80
        endif
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
            if F.AimLocked = TRUE and F.Variant = FLARAK_VARIANT_ROCKET then F.CurrentLauncherAngle = F.LockedLauncherAngle
        endif
        // Four straight bullets: left, right, left, right; lock the aim for the burst.
        if F.Variant = FLARAK_VARIANT_FLAK and F.State = FLARAK_READY and F.AimLocked = FALSE and FlakTargetInArc = TRUE and NowMs >= F.FlakNextVolleyMs and NowMs-F.FlakRiseStartMs >= FLARAK_FLAK_RISE_MS
            // Fire using the current barrel direction even if Sonec is moving.
            // The burst itself freezes this angle; no aim-tolerance gate.
            F.FlakVolleyAngle = F.CurrentLauncherAngle
            F.FlakVolleySide = F.AimSide
            F.FlakShotsFired = 0
            F.FlakNextShotMs = NowMs
            F.AimLocked = TRUE
        endif
        if F.Variant = FLARAK_VARIANT_FLAK and F.State = FLARAK_READY and F.AimLocked = TRUE and F.FlakShotsFired < 4 and NowMs >= F.FlakNextShotMs
            FlarakFireBullet(F,Game,NowMs)
            F.FlakShotsFired = F.FlakShotsFired+1
            F.FlakNextShotMs = NowMs+FLARAK_FLAK_SHOT_GAP_MS
            if F.FlakShotsFired = 4
                F.FlakNextVolleyMs = NowMs+Random(FLARAK_FLAK_VOLLEY_MIN_GAP_MS,FLARAK_FLAK_VOLLEY_MAX_GAP_MS)
                F.FlakAimError = Random(-FLARAK_FLAK_AIM_ERROR_DEG,FLARAK_FLAK_AIM_ERROR_DEG)
                F.AimLocked = FALSE
            endif
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
    // Rockets inherit platform translation only until their tail clears the muzzle.
    FlarakRocketFollowLauncher(F.Rocket1,F.WorldX,F.WorldY)
    FlarakRocketFollowLauncher(F.Rocket2,F.WorldX,F.WorldY)
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
    // Draw rockets first so the silo and rotating launcher cover their in-barrel section.
    FlarakRocketDraw(F.Rocket1,World)
    FlarakRocketDraw(F.Rocket2,World)
    SetSpriteFrame(F.BaseSprite,F.CurrentFrame)
    SetSpritePositionByOffset(F.BaseSprite,X,Y)
    DrawSprite(F.BaseSprite)
    if F.Destroyed = TRUE then exitfunction
    if F.CurrentFrame = 5
        VisualAngle = F.CurrentLauncherAngle
        if F.Variant = FLARAK_VARIANT_FLAK then VisualAngle = -VisualAngle
        if F.AimSide < 0
            SetSpriteFlip(F.LauncherSprite,1,0)
        else
            SetSpriteFlip(F.LauncherSprite,0,0)
        endif
        if F.Variant = FLARAK_VARIANT_FLAK and F.FlakSprite > 0
            RiseProgress = (F.NowMs-F.FlakRiseStartMs)*1.0/FLARAK_FLAK_RISE_MS
            if RiseProgress < 0 then RiseProgress = 0
            if RiseProgress > 1 then RiseProgress = 1
            RiseOffset = FLARAK_FLAK_RISE_PX*(1.0-RiseProgress)
            if F.AimSide < 0
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
                    if FlarakList[i].Destroyed = FALSE
                        FlarakDo(FlarakList[i],Game,JetfireList,ProtoJetfire,World,NowMs)
                    else
                        // Active rockets keep flying after the launcher is destroyed.
                        FlarakRocketDo(FlarakList[i].Rocket1,Game,JetfireList,ProtoJetfire,World,NowMs)
                        FlarakRocketDo(FlarakList[i].Rocket2,Game,JetfireList,ProtoJetfire,World,NowMs)
                    endif
                endif
            endif
        endif
        // Fired rockets continue even after their platform disappears.
        if FlarakList[i].Enabled = FALSE
            // A removed platform cannot anchor an in-barrel rocket.
            FlarakList[i].Rocket1.Attached = FALSE
            FlarakList[i].Rocket2.Attached = FALSE
            FlarakRocketDo(FlarakList[i].Rocket1,Game,JetfireList,ProtoJetfire,World,NowMs)
            FlarakRocketDo(FlarakList[i].Rocket2,Game,JetfireList,ProtoJetfire,World,NowMs)
        endif
    next i
endfunction

// Inspect the most recent Flak bullet immediately after BulletMoveAll,
// before collision processing can remove it for unrelated reasons.
function FlarakDebugAfterBulletMove(BulletList ref as TBulletList,NowMs as integer)
    local i as integer
    local BulletIndex as integer
    if FLARAK_DEBUG_BULLETS = 0 then exitfunction
    for i = 0 to FlarakList.Length
        if FlarakList[i].Variant = FLARAK_VARIANT_FLAK and FlarakList[i].FlakDebugLastMoveStatus = 1 and FlarakList[i].FlakDebugLastShotMs = NowMs
            BulletIndex = FlarakList[i].FlakDebugLastBulletIndex
            FlarakList[i].FlakDebugLastMoveStatus = 3
            if BulletIndex >= 0 and BulletIndex <= BulletList.Bullet.Length
                if BulletList.Bullet[BulletIndex].Enabled = TRUE then FlarakList[i].FlakDebugLastMoveStatus = 2
            endif
        endif
    next i
endfunction

// Temporary local HUD for every visible Flak: READY, aim, time gates and
// whether the last BulletAdd survived BulletMoveAll.
function FlarakDebugDrawAll(World ref as TWorld)
    local i as integer
    local X as float
    local Y as float
    local WaitMs as integer
    local RiseMs as integer
    local SideText as string
    local MoveText as string
    local DebugLine as string
    if FLARAK_DEBUG_BULLETS = 0 or FlarakDebugText = 0 or FlarakDebugVisible = 0 then exitfunction
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = TRUE and FlarakList[i].Variant = FLARAK_VARIANT_FLAK
            X = FlarakList[i].WorldX-World.Position.x
            Y = FlarakList[i].WorldY-World.Position.y
            if X >= 0 and X <= GetVirtualWidth() and Y >= 0 and Y <= GetVirtualHeight()
                SideText = "R"
                if FlarakList[i].AimSide < 0 then SideText = "L"
                if FlarakList[i].AimSide = 0 then SideText = "0"
                WaitMs = FlarakList[i].FlakNextVolleyMs-FlarakList[i].NowMs
                if WaitMs < 0 then WaitMs = 0
                RiseMs = FLARAK_FLAK_RISE_MS-(FlarakList[i].NowMs-FlarakList[i].FlakRiseStartMs)
                if RiseMs < 0 then RiseMs = 0
                MoveText = "none"
                if FlarakList[i].FlakDebugLastMoveStatus = 1 then MoveText = "ADDED"
                if FlarakList[i].FlakDebugLastMoveStatus = 2 then MoveText = "ALIVE"
                if FlarakList[i].FlakDebugLastMoveStatus = 3 then MoveText = "REMOVED"
                DebugLine = "FLAK "+SideText+" state="+Str(FlarakList[i].State)+" lock="+Str(FlarakList[i].AimLocked)+" shots="+Str(FlarakList[i].FlakShotsFired)+" added="+Str(FlarakList[i].FlakDebugAddCount)
                DebugLine = DebugLine+Chr(10)+"gun="+Str(FlarakList[i].CurrentLauncherAngle,1)+" drawn="+Str(-FlarakList[i].CurrentLauncherAngle,1)+" wait="+Str(WaitMs)+" rise="+Str(RiseMs)
                DebugLine = DebugLine+Chr(10)+"bullet="+MoveText+" angle="+Str(FlarakList[i].FlakDebugLastShotAngle,1)+" x="+Str(FlarakList[i].FlakDebugLastShotX,0)+" y="+Str(FlarakList[i].FlakDebugLastShotY,0)
                SetTextString(FlarakDebugText,DebugLine)
                X = X-50
                if X < 4 then X = 4
                if X > GetVirtualWidth()-235 then X = GetVirtualWidth()-235
                Y = Y-80
                if Y < 4 then Y = 4
                SetTextPosition(FlarakDebugText,X,Y)
                DrawText(FlarakDebugText)
            endif
        endif
    next i
endfunction


// Visual-only hitbox proposal. The frame-1 lower silo is always excluded.
// Positions are in screen space; tune these outlines against the actual art.
function FlarakDebugLine(X1 as float,Y1 as float,X2 as float,Y2 as float,R as integer,G as integer,B as integer)
    local Dx as float
    local Dy as float
    local Length as float
    if FlarakCollisionDebugLineSprite = 0
        FlarakCollisionDebugLineSprite = CreateSprite(0)
    endif
    Dx = X2-X1
    Dy = Y2-Y1
    Length = Sqrt(Dx*Dx+Dy*Dy)
    SetSpriteSize(FlarakCollisionDebugLineSprite,Length,2)
    SetSpriteOffset(FlarakCollisionDebugLineSprite,0,1)
    SetSpriteAngle(FlarakCollisionDebugLineSprite,ATan2(Dy,Dx))
    SetSpritePositionByOffset(FlarakCollisionDebugLineSprite,X1,Y1)
    SetSpriteColor(FlarakCollisionDebugLineSprite,R,G,B,255)
    DrawSprite(FlarakCollisionDebugLineSprite)
endfunction

function FlarakDebugRect(X as float,Y as float,HalfW as float,HalfH as float,Angle as float,R as integer,G as integer,B as integer)
    local AX as float
    local AY as float
    local BX as float
    local BY as float
    local CX as float
    local CY as float
    local DX as float
    local DY as float
    local C as float
    local S as float
    C = Cos(Angle)
    S = Sin(Angle)
    AX = X-HalfW*C+HalfH*S
    AY = Y-HalfW*S-HalfH*C
    BX = X+HalfW*C+HalfH*S
    BY = Y+HalfW*S-HalfH*C
    CX = X+HalfW*C-HalfH*S
    CY = Y+HalfW*S+HalfH*C
    DX = X-HalfW*C-HalfH*S
    DY = Y-HalfW*S+HalfH*C
    FlarakDebugLine(AX,AY,BX,BY,R,G,B)
    FlarakDebugLine(BX,BY,CX,CY,R,G,B)
    FlarakDebugLine(CX,CY,DX,DY,R,G,B)
    FlarakDebugLine(DX,DY,AX,AY,R,G,B)
endfunction

function FlarakDebugCircle(X as float,Y as float,Radius as float,R as integer,G as integer,B as integer)
    local i as integer
    local A as float
    local NextA as float
    for i = 0 to 23
        A = i*15
        NextA = (i+1)*15
        FlarakDebugLine(X+Cos(A)*Radius,Y+Sin(A)*Radius,X+Cos(NextA)*Radius,Y+Sin(NextA)*Radius,R,G,B)
    next i
endfunction

function FlarakCollisionDebugDrawAll(World ref as TWorld)
    local i as integer
    local X as float
    local Y as float
    local Frame as integer
    local StemTop as float
    local StemBottom as float
    local StemHeight as float
    local StemCenterY as float
    local GunX as float
    local GunY as float
    local Angle as float
    local CircleCenterX as float
    local CircleCenterY as float
    local CircleLocalY as float
    if GAME_DEBUG_ENABLED = 0 or FlarakCollisionDebugVisible = 0 then exitfunction
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = TRUE and FlarakList[i].Destroyed = FALSE
            X = FlarakList[i].WorldX-World.Position.x
            Y = FlarakList[i].WorldY-World.Position.y
            Frame = FlarakList[i].CurrentFrame
            // Frame 1 has no hitbox. Frames 2-5 expose progressively more stem.
            if Frame > 1
                // Keep the frame-1 silo protected; fully deployed stem is 14 px high.
                StemBottom = Y+15
                StemHeight = (Frame-1)*3.5
                StemTop = StemBottom-StemHeight
                StemCenterY = (StemTop+StemBottom)*0.5
                FlarakDebugRect(X,StemCenterY,6,StemHeight*0.5,0,60,230,255)
            endif
            if Frame = 5
                Angle = FlarakList[i].CurrentLauncherAngle
                if FlarakList[i].Variant = FLARAK_VARIANT_FLAK then Angle = -Angle
                // The shared frame-6 launcher rectangle belongs to BOTH variants.
                // Keep the approved 34x14 px shape anchored to its actual pivot.
                GunX = GetSpriteXByOffset(FlarakList[i].LauncherSprite)
                GunY = GetSpriteYByOffset(FlarakList[i].LauncherSprite)
                FlarakDebugRect(GunX,GunY,17,7,Angle,255,205,45)
                // The Flak additionally has its independently rotating head circle.
                if FlarakList[i].Variant = FLARAK_VARIANT_FLAK
                    GunX = GetSpriteXByOffset(FlarakList[i].FlakSprite)
                    GunY = GetSpriteYByOffset(FlarakList[i].FlakSprite)
                    // Rotate the circle's LOCAL center around the actual sprite
                    // pivot (GunX,GunY), not around an invented pivot.
                    // Preserve the accepted X and neutral-angle Y: GunY+11.
                    CircleLocalY = 11
                    CircleCenterX = GunX-CircleLocalY*Sin(Angle)
                    CircleCenterY = GunY+CircleLocalY*Cos(Angle)
                    FlarakDebugCircle(CircleCenterX,CircleCenterY,15,255,205,45)
                    // Calibration: magenta cross = actual sprite pivot,
                    // white cross = calculated circle center; connecting line
                    // makes any unexpected orbit direction immediately visible.
                    FlarakDebugLine(GunX,GunY,CircleCenterX,CircleCenterY,255,255,255)
                    FlarakDebugLine(GunX-3,GunY,GunX+3,GunY,255,80,220)
                    FlarakDebugLine(GunX,GunY-3,GunX,GunY+3,255,80,220)
                    FlarakDebugLine(CircleCenterX-3,CircleCenterY,CircleCenterX+3,CircleCenterY,255,255,255)
                    FlarakDebugLine(CircleCenterX,CircleCenterY-3,CircleCenterX,CircleCenterY+3,255,255,255)
                endif
            endif
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
