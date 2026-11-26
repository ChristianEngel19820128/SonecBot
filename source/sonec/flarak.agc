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
    CenterSweepStart as TPosition
    OutsideWorld as integer
    SweepStart as TPosition
    SweepStartMs as integer
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
    FlameTargetId as integer
    SmokeEmitter as TSmokeEmitter
    Health as integer
    Destroyed as integer
    HitFlashUntil as integer
    Rocket1 as TFlarakTestRocket
    Rocket2 as TFlarakTestRocket
    SecondPending as integer
    SecondFireMs as integer
    VolleyStartMs as integer
    VolleyFired as integer
    VolleyAngle as float
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
    CurrentFrame as integer
    CurrentLauncherAngle as float
    NowMs as integer
    WorldX as float
    WorldY as float
    Enabled as integer
    PlateIndex as integer
    CarrierPlateId as integer
    PlateOffsetX as float
    PlateOffsetY as float
    State as integer
    FrameStampMs as integer
    LastUpdateMs as integer
    AimSide as integer
endtype

type TProtoFlarak
    BaseImage as integer
    RocketImage as integer
    BaseSprite as integer
    LauncherSprite as integer
    FlakSprite as integer
    RocketSprite as integer
    WarningSprite as integer
    RocketTipDistance as float
endtype

global ProtoFlarak as TProtoFlarak
global FlarakList as TFlarak[]
global FlarakFirstFree as integer
global FlarakDebugText as integer
global FlarakDebugVisible as integer
global FlarakCollisionDebugVisible as integer
global FlarakCollisionDebugLineSprite as integer

// Round state only; shared drawing resources belong to the program lifetime.
function FlarakInit()
    FlarakList.Length = -1
    FlarakFirstFree = 0
endfunction

function FlarakSlotFree(F ref as TFlarak)
    if F.Enabled = FALSE and F.Rocket1.Active = FALSE and F.Rocket2.Active = FALSE then exitfunction TRUE
endfunction FALSE

function FlarakMarkFree(Index as integer)
    if FlarakSlotFree(FlarakList[Index]) = TRUE
        if Index < FlarakFirstFree then FlarakFirstFree = Index
    endif
endfunction

// A slot is a storage address, not the identity of its current carrier.
function FlarakCarrierMatches(F ref as TFlarak,Plate ref as TPlate)
    if Plate.Enabled = FALSE or F.CarrierPlateId <= 0 then exitfunction FALSE
    if F.CarrierPlateId = Plate.WeaponDepthId then exitfunction TRUE
endfunction FALSE

// Called before a free plate slot is overwritten, before new placement checks.
// Do not advance rockets here; their regular update owns movement.
function FlarakDetachRecycledPlate(PlateIndex as integer)
    local i as integer
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = TRUE and FlarakList[i].PlateIndex = PlateIndex
            FlarakList[i].Enabled = FALSE
            FlarakList[i].Rocket1.Attached = FALSE
            FlarakList[i].Rocket2.Attached = FALSE
            FlarakMarkFree(i)
        endif
    next i
endfunction

function FlarakProtoLoad()
    local Image as TImage
    Image.File.Path = "/media/gfx/enemies"
    Image.File.Name = "flarak.png"
    if ImageLoad(Image) = TRUE
        ProtoFlarak.BaseImage = Image.ID
        ProtoFlarak.BaseSprite = CreateSprite(Image.ID)
        SetSpriteAnimation(ProtoFlarak.BaseSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,7)
        SetSpriteFrame(ProtoFlarak.BaseSprite,1)
        SetSpriteOffset(ProtoFlarak.BaseSprite,FLARAK_TEST_BASE_OFFSET_X,FLARAK_TEST_BASE_OFFSET_Y)
        ProtoFlarak.LauncherSprite = CreateSprite(Image.ID)
        SetSpriteAnimation(ProtoFlarak.LauncherSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,7)
        SetSpriteFrame(ProtoFlarak.LauncherSprite,6)
        SetSpriteOffset(ProtoFlarak.LauncherSprite,FLARAK_TEST_LAUNCHER_PIVOT_X,FLARAK_TEST_LAUNCHER_PIVOT_Y)
        ProtoFlarak.FlakSprite = CreateSprite(Image.ID)
        SetSpriteAnimation(ProtoFlarak.FlakSprite,FLARAK_TEST_CELL_W,FLARAK_TEST_CELL_H,7)
        SetSpriteFrame(ProtoFlarak.FlakSprite,7)
        SetSpriteOffset(ProtoFlarak.FlakSprite,FLARAK_TEST_LAUNCHER_PIVOT_X,FLARAK_TEST_LAUNCHER_PIVOT_Y)
    endif
    Image.File.Path = "/media/gfx/weapons"
    Image.File.Name = "rocket.png"
    if ImageLoad(Image) = TRUE
        ProtoFlarak.RocketImage = Image.ID
        ProtoFlarak.RocketSprite = CreateSprite(Image.ID)
        SetSpriteOffset(ProtoFlarak.RocketSprite,GetSpriteWidth(ProtoFlarak.RocketSprite)*0.5,GetSpriteHeight(ProtoFlarak.RocketSprite)*0.5)
        SetSpriteColor(ProtoFlarak.RocketSprite,170,215,170,255)
        ProtoFlarak.RocketTipDistance = GetSpriteWidth(ProtoFlarak.RocketSprite)*0.5
    endif
    ProtoFlarak.WarningSprite = CreateSprite(0)
    SetSpriteSize(ProtoFlarak.WarningSprite,2,2)
    SetSpriteOffset(ProtoFlarak.WarningSprite,1,1)
    SetSpriteColor(ProtoFlarak.WarningSprite,255,155,45,255)
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
    if ProtoFlarak.BaseSprite = 0 or ProtoFlarak.LauncherSprite = 0 or ProtoFlarak.RocketSprite = 0 then exitfunction
    if ProtoFlarak.FlakSprite = 0 or ProtoFlarak.WarningSprite = 0 then exitfunction
    if PlateIndex < 0 or PlateIndex > PlateList.Plate.Length then exitfunction
    Plate = PlateList.Plate[PlateIndex]
    if Plate.Enabled = FALSE or Plate.ObjectData.Size.Width < FLARAK_TEST_CELL_W+20 then exitfunction
    FreeLeft = FlarakFindFreeOffsetX(Plate,PlateIndex,ChestList)
    if FreeLeft < 0 then exitfunction
    F.Enabled = TRUE
    F.FlameTargetId = FlameNewTargetId()
    F.Health = FLARAK_HEALTH_MAX
    F.Destroyed = FALSE
    F.HitFlashUntil = 0
    F.Variant = Random(0,1)
    F.PlateIndex = PlateIndex
    F.CarrierPlateId = Plate.WeaponDepthId
    F.PlateOffsetX = FreeLeft+FLARAK_TEST_BASE_OFFSET_X
    // Developer-verified platform alignment; no extra platform-height correction.
    F.PlateOffsetY = -(FLARAK_TEST_CELL_H-FLARAK_TEST_BASE_OFFSET_Y)
    F.WorldX = Plate.ObjectData.Position.x+F.PlateOffsetX
    F.WorldY = Plate.ObjectData.Position.y+F.PlateOffsetY
    F.Rocket1.TipDistance = ProtoFlarak.RocketTipDistance
    F.Rocket2.TipDistance = ProtoFlarak.RocketTipDistance
    F.StartMs = NowMs
    F.RocketNextMs = NowMs+1500
    F.FlakNextVolleyMs = NowMs+1500
    F.FlakAimError = Random(-FLARAK_FLAK_AIM_ERROR_DEG,FLARAK_FLAK_AIM_ERROR_DEG)
    F.FlakDebugLastBulletIndex = -1
    F.CurrentFrame = 1
    F.State = FLARAK_CLOSED
    F.FrameStampMs = NowMs
    F.LastUpdateMs = NowMs
    i = FlarakFirstFree
    while i <= FlarakList.Length
        if FlarakSlotFree(FlarakList[i]) = TRUE
            FlarakList[i] = F
            FlarakFirstFree = i+1
            exitfunction
        endif
        i = i+1
    endwhile
    FlarakList.Insert(F)
    FlarakFirstFree = FlarakList.Length+1
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
    Rocket.OutsideWorld = FALSE
    FlarakRocketCaptureStart(Rocket)
endfunction

// Snapshot before muzzle-follow translation or homing, also at launch.
function FlarakRocketCaptureStart(Rocket ref as TFlarakTestRocket)
    if Rocket.Active = FALSE then exitfunction
    Rocket.CenterSweepStart.x = Rocket.PosX
    Rocket.CenterSweepStart.y = Rocket.PosY
    Rocket.SweepStart.x = Rocket.PosX+Sin(Rocket.Angle)*Rocket.TipDistance
    Rocket.SweepStart.y = Rocket.PosY-Cos(Rocket.Angle)*Rocket.TipDistance
    Rocket.SweepStartMs = Rocket.LastMs
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
    local ImpactPosition as TPosition
    local TargetAngle as float
    local AngleDiff as float
    local MaxTurn as float
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
    Rocket.PosX = Rocket.PosX+Sin(Rocket.Angle)*FLARAK_TEST_ROCKET_SPEED_PX_PER_MS*RocketDeltaMs
    Rocket.PosY = Rocket.PosY-Cos(Rocket.Angle)*FLARAK_TEST_ROCKET_SPEED_PX_PER_MS*RocketDeltaMs
    if Rocket.Attached = TRUE
        Rocket.ClearDistance = Rocket.ClearDistance+FLARAK_TEST_ROCKET_SPEED_PX_PER_MS*RocketDeltaMs
        if Rocket.ClearDistance >= FLARAK_TEST_ROCKET_CLEAR_DISTANCE then Rocket.Attached = FALSE
    endif
    Rocket.SpriteAngle = Rocket.Angle+90
    // Keep the last sweep until all impact/interception checks finish.
    Rocket.OutsideWorld = FALSE
    if Rocket.PosX < 0 or Rocket.PosX > World.Size.Width or Rocket.PosY < 0 or Rocket.PosY > World.Size.Height then Rocket.OutsideWorld = TRUE
endfunction

// Resolve after Sonec's mechanical path is complete, before player weapon
// interception. A destroyed rocket emits no extra trail at its endpoint.
function FlarakRocketResolve(Rocket ref as TFlarakTestRocket,Game ref as TGame,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,NowMs as integer)
    local ImpactPosition as TPosition
    local JetPosition as TPosition
    local Jetfire as TJetfire
    local JetIndex as integer
    local JetFound as integer
    local JetOutlet as integer
    local JetBackDistance as float
    if Rocket.Active = FALSE then exitfunction
    if FlarakRocketHitsSonec(Rocket,Game.Sonec,ImpactPosition) = TRUE
        Rocket.Active = FALSE
        ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,3,ImpactPosition,NowMs)
        exitfunction
    endif
    if Rocket.OutsideWorld = TRUE then exitfunction
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
function FlarakRocketHitsSonec(Rocket ref as TFlarakTestRocket,Sonec ref as TSonec,Impact ref as TPosition)
    local TipNew as TPosition
    local CircleIndex as integer
    local Entry as float
    local BestEntry as float
    if Sonec.IsLost = TRUE then exitfunction FALSE
    TipNew.x = Rocket.PosX+Sin(Rocket.Angle)*Rocket.TipDistance
    TipNew.y = Rocket.PosY-Cos(Rocket.Angle)*Rocket.TipDistance
    BestEntry = 2.0
    for CircleIndex = 0 to 1
        Entry = SonecDamageSweepEntry(Sonec,Rocket.SweepStart,TipNew,Rocket.SweepStartMs,Rocket.LastMs,CircleIndex,0,0,FALSE)
        if Entry >= 0 and Entry < BestEntry then BestEntry = Entry
    next CircleIndex
    if BestEntry <= 1
        Impact.x = Rocket.SweepStart.x+(TipNew.x-Rocket.SweepStart.x)*BestEntry
        Impact.y = Rocket.SweepStart.y+(TipNew.y-Rocket.SweepStart.y)*BestEntry
        exitfunction TRUE
    endif
endfunction FALSE

// Bomber-bomb interception model: a single hit destroys an airborne rocket.
// Rocket sprite position is its world-space center; attached rockets are also valid.
#constant FLARAK_ROCKET_SHOT_RADIUS 7

function FlarakRocketIntercept(Rocket ref as TFlarakTestRocket,Game ref as TGame,Now as integer)
    local Impact as TPosition
    if Rocket.Active = FALSE then exitfunction
    Impact.x = Rocket.PosX
    Impact.y = Rocket.PosY
    Rocket.Active = FALSE
    Rocket.Attached = FALSE
    ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,3,Impact,Now)
endfunction

function FlarakRocketBulletEntry(Rocket ref as TFlarakTestRocket,Bullet ref as TBullet)
    local P as TPosition
    local StartMs as integer
    local Entry as float
    if Rocket.Active = FALSE then exitfunction -1.0
    P.x = Rocket.PosX
    P.y = Rocket.PosY
    StartMs = Bullet.SonecSweepStartMs
    if Bullet.SonecSweepReady = FALSE
        if StartMs < SonecDamageFrameStartMs then StartMs = SonecDamageFrameStartMs
    endif
    Entry = CollisionTimedCircleEntry(Bullet.PreviousPosition,Bullet.ObjectData.Position,StartMs,Bullet.SonecSweepEndMs,Rocket.CenterSweepStart,P,Rocket.SweepStartMs,Rocket.LastMs,FLARAK_ROCKET_SHOT_RADIUS+Bullet.ObjectData.Radius)
endfunction Entry

function FlarakRocketCollideBullets(Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local Entry as float
    local BestEntry as float
    local BestIndex as integer
    local BestRocket as integer
    for i = 0 to Game.BulletList.Bullet.Length
        if Game.BulletList.Bullet[i].Enabled = TRUE and Game.BulletList.Bullet[i].CollisionData.CollisionType = TYPEPLAYERONE
            BestEntry = 2.0
            BestIndex = -1
            BestRocket = 0
            for k = 0 to FlarakList.Length
                Entry = FlarakRocketBulletEntry(FlarakList[k].Rocket1,Game.BulletList.Bullet[i])
                if Entry >= 0 and Entry < BestEntry
                    BestEntry = Entry
                    BestIndex = k
                    BestRocket = 1
                endif
                Entry = FlarakRocketBulletEntry(FlarakList[k].Rocket2,Game.BulletList.Bullet[i])
                if Entry >= 0 and Entry < BestEntry
                    BestEntry = Entry
                    BestIndex = k
                    BestRocket = 2
                endif
            next k
            if BestIndex >= 0
                if BestRocket = 1
                    FlarakRocketIntercept(FlarakList[BestIndex].Rocket1,Game,Now)
                else
                    FlarakRocketIntercept(FlarakList[BestIndex].Rocket2,Game,Now)
                endif
                FlarakMarkFree(BestIndex)
                BulletDelete(Game.BulletList,i)
            endif
        endif
    next i
endfunction

function FlarakRocketHitByFlame(Rocket ref as TFlarakTestRocket,Flame ref as TFlame)
    local P as TPosition
    local Radius as float
    local Entry as float
    if Rocket.Active = FALSE then exitfunction FALSE
    P.x = Rocket.PosX
    P.y = Rocket.PosY
    Radius = FlameCollisionRadius(Flame)+FLARAK_ROCKET_SHOT_RADIUS
    Entry = CollisionTimedCircleEntry(Flame.PreviousPosition,Flame.ObjectData.Position,Flame.SweepStartMs,Flame.SweepEndMs,Rocket.CenterSweepStart,P,Rocket.SweepStartMs,Rocket.LastMs,Radius)
    if Entry >= 0 then exitfunction TRUE
endfunction FALSE

function FlarakRocketCollideFlames(Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    for i = 0 to Game.FlameList.Flame.Length
        if Game.FlameList.Flame[i].Enabled = TRUE
            for k = 0 to FlarakList.Length
                if Game.FlameList.Flame[i].Enabled = TRUE
                    if FlarakRocketHitByFlame(FlarakList[k].Rocket1,Game.FlameList.Flame[i])
                        FlarakRocketIntercept(FlarakList[k].Rocket1,Game,Now)
                        FlarakMarkFree(k)
                    endif
                endif
                if Game.FlameList.Flame[i].Enabled = TRUE
                    if FlarakRocketHitByFlame(FlarakList[k].Rocket2,Game.FlameList.Flame[i])
                        FlarakRocketIntercept(FlarakList[k].Rocket2,Game,Now)
                        FlarakMarkFree(k)
                    endif
                endif
            next k
        endif
    next i
endfunction



function FlarakRocketHitByPlasma(Rocket ref as TFlarakTestRocket,Plasma ref as TPlasmaBlitz)
    local P as TPosition
    local Entry as float
    if Rocket.Active = FALSE then exitfunction FALSE
    P.x = Rocket.PosX
    P.y = Rocket.PosY
    Entry = CollisionTimedAreaEntry(Rocket.CenterSweepStart,P,Rocket.SweepStartMs,Rocket.LastMs,Plasma.CreatedMs,Plasma.CollisionData.Position1,Plasma.CollisionData.Position2,FLARAK_ROCKET_SHOT_RADIUS)
    if Entry >= 0 then exitfunction TRUE
endfunction FALSE

function FlarakRocketCollidePlasma(Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    for i = 0 to Game.PlasmaBlitzList.PlasmaBlitz.Length
        if Game.PlasmaBlitzList.PlasmaBlitz[i].Enabled = TRUE
            for k = 0 to FlarakList.Length
                if FlarakRocketHitByPlasma(FlarakList[k].Rocket1,Game.PlasmaBlitzList.PlasmaBlitz[i])
                    FlarakRocketIntercept(FlarakList[k].Rocket1,Game,Now)
                    FlarakMarkFree(k)
                endif
                if FlarakRocketHitByPlasma(FlarakList[k].Rocket2,Game.PlasmaBlitzList.PlasmaBlitz[i])
                    FlarakRocketIntercept(FlarakList[k].Rocket2,Game,Now)
                    FlarakMarkFree(k)
                endif
            next k
        endif
    next i
endfunction

function FlarakRocketDraw(Rocket ref as TFlarakTestRocket,World ref as TWorld)
    if Rocket.Active = FALSE or ProtoFlarak.RocketSprite = 0 then exitfunction
    SetSpriteAngle(ProtoFlarak.RocketSprite,Rocket.SpriteAngle)
    SetSpritePositionByOffset(ProtoFlarak.RocketSprite,Rocket.PosX-World.Position.x,Rocket.PosY-World.Position.y)
    DrawSprite(ProtoFlarak.RocketSprite)
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
    SmokeStartEmitter(F.SmokeEmitter,NowMs)
    F.Health = 0
    F.SecondPending = FALSE
    F.FlakShotsFired = 4
    F.CurrentFrame = 1
    F.Rocket1.Attached = FALSE
    F.Rocket2.Attached = FALSE
    Impact.x = F.WorldX
    Impact.y = F.WorldY-10
    ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,4,Impact,NowMs)
    RewardDrop(Game,REWARD_OBJECT_FLARAK,Impact,NowMs)
endfunction

// Visual-only emission at the fixed common wreck base, not the elevated
// launcher pivot. Validate the carrier again after PlateCheckAll.
function FlarakSmokeDoAll(PlateList ref as TPlateList,Now as integer)
    local i as integer
    local PlateIndex as integer
    local Density as integer
    local Position as TPosition
    local CarrierY as float
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = TRUE and FlarakList[i].Destroyed = TRUE
            PlateIndex = FlarakList[i].PlateIndex
            if PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
                if FlarakCarrierMatches(FlarakList[i],PlateList.Plate[PlateIndex]) = TRUE
                    Density = SMOKE_DENSITY_FLARAK
                    if FlarakList[i].Variant = FLARAK_VARIANT_FLAK then Density = SMOKE_DENSITY_FLAK
                    Position.x = PlateList.Plate[PlateIndex].ObjectData.Position.x+FlarakList[i].PlateOffsetX
                    Position.y = PlateList.Plate[PlateIndex].ObjectData.Position.y-JUMPPOD_BASE_H-JUMPPOD_TOP_H
                    CarrierY = SmokePlateVelocityY(PlateList.Plate[PlateIndex])
                    SmokeAdd(FlarakList[i].SmokeEmitter,Position,Density,CarrierY,Now)
                endif
            endif
        endif
    next i
endfunction

function FlarakApplyDamage(F ref as TFlarak,Game ref as TGame,Damage as integer,NowMs as integer)
    if F.Enabled = FALSE or F.Destroyed = TRUE or Damage <= 0 then exitfunction
    F.Health = F.Health-Damage
    F.HitFlashUntil = NowMs+150
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
        if F.Variant = FLARAK_VARIANT_ROCKET and F.State = FLARAK_READY and F.AimLocked = TRUE and ProtoFlarak.RocketSprite > 0 and F.SecondPending = FALSE and F.Rocket1.Active = FALSE and F.Rocket2.Active = FALSE and F.VolleyFired = FALSE and NowMs-F.AimLockMs >= FLARAK_TEST_AIM_HOLD_MS
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
    if ProtoFlarak.BaseSprite = 0 or ProtoFlarak.LauncherSprite = 0 then exitfunction
    X = F.WorldX-World.Position.x
    Y = F.WorldY-World.Position.y
    // Standard short red damage flash on all exposed gun parts.
    if F.Destroyed = TRUE
        SetSpriteColor(ProtoFlarak.BaseSprite,FLARAK_WRECK_COLOR-8,FLARAK_WRECK_COLOR+14,FLARAK_WRECK_COLOR-8,255)
    else
        if F.NowMs < F.HitFlashUntil
            SetSpriteColor(ProtoFlarak.BaseSprite,255,0,0,255)
            SetSpriteColor(ProtoFlarak.LauncherSprite,255,0,0,255)
            if ProtoFlarak.FlakSprite > 0 then SetSpriteColor(ProtoFlarak.FlakSprite,255,0,0,255)
        else
            SetSpriteColor(ProtoFlarak.BaseSprite,0,255,0,255)
            SetSpriteColor(ProtoFlarak.LauncherSprite,0,255,0,255)
            if ProtoFlarak.FlakSprite > 0 then SetSpriteColor(ProtoFlarak.FlakSprite,0,255,0,255)
        endif
    endif
    // Only muzzle-attached rockets belong to this plate's draw group.
    // Draw before the silo so it covers the in-barrel section.
    if F.Rocket1.Attached = TRUE then FlarakRocketDraw(F.Rocket1,World)
    if F.Rocket2.Attached = TRUE then FlarakRocketDraw(F.Rocket2,World)
    SetSpriteFrame(ProtoFlarak.BaseSprite,F.CurrentFrame)
    SetSpritePositionByOffset(ProtoFlarak.BaseSprite,X,Y)
    DrawSprite(ProtoFlarak.BaseSprite)
    if F.Destroyed = TRUE then exitfunction
    if F.CurrentFrame = 5
        VisualAngle = F.CurrentLauncherAngle
        if F.Variant = FLARAK_VARIANT_FLAK then VisualAngle = -VisualAngle
        if F.AimSide < 0
            SetSpriteFlip(ProtoFlarak.LauncherSprite,1,0)
        else
            SetSpriteFlip(ProtoFlarak.LauncherSprite,0,0)
        endif
        if F.Variant = FLARAK_VARIANT_FLAK and ProtoFlarak.FlakSprite > 0
            RiseProgress = (F.NowMs-F.FlakRiseStartMs)*1.0/FLARAK_FLAK_RISE_MS
            if RiseProgress < 0 then RiseProgress = 0
            if RiseProgress > 1 then RiseProgress = 1
            RiseOffset = FLARAK_FLAK_RISE_PX*(1.0-RiseProgress)
            if F.AimSide < 0
                SetSpriteFlip(ProtoFlarak.FlakSprite,1,0)
            else
                SetSpriteFlip(ProtoFlarak.FlakSprite,0,0)
            endif
            SetSpriteAngle(ProtoFlarak.FlakSprite,VisualAngle)
            // Rotate the deployment offset around the same world pivot as frame 6.
            FlakOffsetY = FLARAK_FLAK_FINAL_OFFSET_Y+RiseOffset
            SetSpritePositionByOffset(ProtoFlarak.FlakSprite,X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X-FlakOffsetY*Sin(VisualAngle),Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y+FlakOffsetY*Cos(VisualAngle))
            DrawSprite(ProtoFlarak.FlakSprite)
        endif
        SetSpriteAngle(ProtoFlarak.LauncherSprite,VisualAngle)
        SetSpritePositionByOffset(ProtoFlarak.LauncherSprite,X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X,Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y)
        DrawSprite(ProtoFlarak.LauncherSprite)
        if F.Variant = FLARAK_VARIANT_ROCKET and F.State = FLARAK_READY and F.AimLocked = TRUE and F.VolleyFired = FALSE and F.Rocket1.Active = FALSE and F.Rocket2.Active = FALSE and F.SecondPending = FALSE and F.NowMs-F.AimLockMs >= FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS
            WarningStep = (F.NowMs-F.AimLockMs-(FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS))/100
            if WarningStep > 2 then WarningStep = 2
            MuzzleAngle = F.LockedLauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            if F.AimSide < 0 then MuzzleAngle = F.LockedLauncherAngle-180+FLARAK_TEST_BARREL_ANGLE_OFFSET
            for WarningLamp = 0 to WarningStep
                WarningDistance = 3+WarningLamp*4
                SetSpritePositionByOffset(ProtoFlarak.WarningSprite,X+Sin(MuzzleAngle)*WarningDistance,Y-Cos(MuzzleAngle)*WarningDistance)
                DrawSprite(ProtoFlarak.WarningSprite)
            next WarningLamp
        endif
    endif
endfunction

function FlarakDoAll(Game ref as TGame,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,PlateList ref as TPlateList,NowMs as integer)
    local i as integer
    local PlateIndex as integer
    for i = 0 to FlarakList.Length
        FlarakRocketCaptureStart(FlarakList[i].Rocket1)
        FlarakRocketCaptureStart(FlarakList[i].Rocket2)
        if FlarakList[i].Enabled = TRUE
            PlateIndex = FlarakList[i].PlateIndex
            if PlateIndex < 0 or PlateIndex > PlateList.Plate.Length
                FlarakList[i].Enabled = FALSE
            else
                if FlarakCarrierMatches(FlarakList[i],PlateList.Plate[PlateIndex]) = FALSE
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
            FlarakMarkFree(i)
        endif
    next i
endfunction

function FlarakRocketResolveAll(Game ref as TGame,NowMs as integer)
    local i as integer
    for i = 0 to FlarakList.Length
        FlarakRocketResolve(FlarakList[i].Rocket1,Game,Game.JetfireList,Game.ProtoJetfire,Game.World,NowMs)
        FlarakRocketResolve(FlarakList[i].Rocket2,Game,Game.JetfireList,Game.ProtoJetfire,Game.World,NowMs)
        FlarakMarkFree(i)
    next i
endfunction

function FlarakRocketCullAll()
    local i as integer
    for i = 0 to FlarakList.Length
        if FlarakList[i].Rocket1.Active = TRUE and FlarakList[i].Rocket1.OutsideWorld = TRUE
            FlarakList[i].Rocket1.Active = FALSE
            FlarakList[i].Rocket1.Attached = FALSE
        endif
        if FlarakList[i].Rocket2.Active = TRUE and FlarakList[i].Rocket2.OutsideWorld = TRUE
            FlarakList[i].Rocket2.Active = FALSE
            FlarakList[i].Rocket2.Attached = FALSE
        endif
        FlarakMarkFree(i)
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
                if BulletList.Bullet[BulletIndex].Enabled = TRUE and BulletList.Bullet[BulletIndex].OutsideWorld = FALSE then FlarakList[i].FlakDebugLastMoveStatus = 2
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


// World-space point test for the approved live hitboxes. The lower silo
// never receives damage; frame 1 and destroyed wrecks are fully protected.
// Launcher and Flak head centers use the same real sprite pivots as debug.
function FlarakPointInRotatedRect(PX as float,PY as float,CX as float,CY as float,HalfW as float,HalfH as float,Angle as float)
    local DX as float
    local DY as float
    local LX as float
    local LY as float
    DX = PX-CX
    DY = PY-CY
    LX = DX*Cos(Angle)+DY*Sin(Angle)
    LY = -DX*Sin(Angle)+DY*Cos(Angle)
    local Hit as integer
    Hit = FALSE
    if Abs(LX) <= HalfW and Abs(LY) <= HalfH then Hit = TRUE
endfunction Hit

// Conservative area overlap using samples over a source circle or AABB.
// Reuses the precise point shapes, never the protected silo sprite.
function FlarakAreaHits(F ref as TFlarak,World ref as TWorld,CX as float,CY as float,HalfW as float,HalfH as float,IsCircle as integer)
    local IX as integer
    local IY as integer
    local PX as float
    local PY as float
    local Radius as float
    if F.Enabled = FALSE or F.Destroyed = TRUE or F.CurrentFrame <= 1 then exitfunction FALSE
    if HalfW <= 0 or HalfH <= 0 then exitfunction FALSE
    // Broad phase covers the complete deployed assembly and avoids scanning
    // the full area of a large explosion.
    if CX+HalfW < F.WorldX-45 or CX-HalfW > F.WorldX+45 then exitfunction FALSE
    if CY+HalfH < F.WorldY-55 or CY-HalfH > F.WorldY+40 then exitfunction FALSE
    Radius = HalfW
    // Sample the TARGET footprint at 2px spacing, independent of blast size.
    for IX = -23 to 23
        PX = F.WorldX+IX*2
        if PX >= CX-HalfW and PX <= CX+HalfW
            for IY = -28 to 20
                PY = F.WorldY+IY*2
                if PY >= CY-HalfH and PY <= CY+HalfH
                    if IsCircle = FALSE or (PX-CX)*(PX-CX)+(PY-CY)*(PY-CY) <= Radius*Radius
                        if FlarakPointHits(F,World,PX,PY) then exitfunction TRUE
                    endif
                endif
            next IY
        endif
    next IX
endfunction FALSE

function FlarakPointHits(F ref as TFlarak,World ref as TWorld,PX as float,PY as float)
    local StemHeight as float
    local Angle as float
    local GunX as float
    local GunY as float
    local CircleX as float
    local CircleY as float
    local DX as float
    local DY as float
    local RiseProgress as float
    local RiseOffset as float
    local FlakOffsetY as float
    if F.Enabled = FALSE or F.Destroyed = TRUE or F.CurrentFrame <= 1 then exitfunction FALSE
    StemHeight = (F.CurrentFrame-1)*3.5
    if Abs(PX-F.WorldX) <= 6 and PY >= F.WorldY+15-StemHeight and PY <= F.WorldY+15 then exitfunction TRUE
    if F.CurrentFrame <> 5 then exitfunction FALSE
    Angle = F.CurrentLauncherAngle
    if F.Variant = FLARAK_VARIANT_FLAK then Angle = -Angle
    // The frame-6 launcher pivot is aligned with the base pivot in FlarakDraw.
    // Derive it from the world position, never from last frame's sprite pose.
    GunX = F.WorldX
    GunY = F.WorldY
    if FlarakPointInRotatedRect(PX,PY,GunX,GunY,17,7,Angle) then exitfunction TRUE
    if F.Variant = FLARAK_VARIANT_FLAK and ProtoFlarak.FlakSprite > 0
        RiseProgress = (F.NowMs-F.FlakRiseStartMs)*1.0/FLARAK_FLAK_RISE_MS
        if RiseProgress < 0 then RiseProgress = 0
        if RiseProgress > 1 then RiseProgress = 1
        RiseOffset = FLARAK_FLAK_RISE_PX*(1.0-RiseProgress)
        FlakOffsetY = FLARAK_FLAK_FINAL_OFFSET_Y+RiseOffset
        GunX = F.WorldX-FlakOffsetY*Sin(Angle)
        GunY = F.WorldY+FlakOffsetY*Cos(Angle)
        CircleX = GunX-11*Sin(Angle)
        CircleY = GunY+11*Cos(Angle)
        DX = PX-CircleX
        DY = PY-CircleY
        // Only the upper SCREEN-facing half of the circle takes damage.
        if DY <= 0 and DX*DX+DY*DY <= 225 then exitfunction TRUE
    endif
endfunction FALSE

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
    local RiseProgress as float
    local FlakOffsetY as float
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
                GunX = X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X
                GunY = Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y
                FlarakDebugRect(GunX,GunY,17,7,Angle,255,205,45)
                // The Flak additionally has its independently rotating head circle.
                if FlarakList[i].Variant = FLARAK_VARIANT_FLAK
                    RiseProgress = (FlarakList[i].NowMs-FlarakList[i].FlakRiseStartMs)*1.0/FLARAK_FLAK_RISE_MS
                    if RiseProgress < 0 then RiseProgress = 0
                    if RiseProgress > 1 then RiseProgress = 1
                    FlakOffsetY = FLARAK_FLAK_FINAL_OFFSET_Y+FLARAK_FLAK_RISE_PX*(1.0-RiseProgress)
                    GunX = X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X-FlakOffsetY*Sin(Angle)
                    GunY = Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y+FlakOffsetY*Cos(Angle)
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

// Draw the complete station (including wrecks) in its carrier's layer.
function FlarakDrawPlate(PlateIndex as integer,Plate ref as TPlate,World ref as TWorld)
    local i as integer
    for i = 0 to FlarakList.Length
        if FlarakList[i].Enabled = TRUE and FlarakList[i].PlateIndex = PlateIndex and FlarakCarrierMatches(FlarakList[i],Plate) = TRUE
            FlarakDraw(FlarakList[i],World)
        endif
    next i
endfunction

// Flight visuals remain independent after detachment, destruction or removal.
// A carrier can disappear in PlateCheckAll after FlarakDoAll: an attached
// rocket must still be drawn exactly once during that transitional frame.
function FlarakFreeRocketDrawAll(PlateList ref as TPlateList,World ref as TWorld)
    local i as integer
    local PlateIndex as integer
    local HasDrawCarrier as integer
    for i = 0 to FlarakList.Length
        HasDrawCarrier = FALSE
        if FlarakList[i].Enabled = TRUE and ProtoFlarak.BaseSprite > 0 and ProtoFlarak.LauncherSprite > 0
            PlateIndex = FlarakList[i].PlateIndex
            if PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
                if FlarakCarrierMatches(FlarakList[i],PlateList.Plate[PlateIndex]) = TRUE then HasDrawCarrier = TRUE
            endif
        endif
        if HasDrawCarrier = FALSE or FlarakList[i].Rocket1.Attached = FALSE then FlarakRocketDraw(FlarakList[i].Rocket1,World)
        if HasDrawCarrier = FALSE or FlarakList[i].Rocket2.Attached = FALSE then FlarakRocketDraw(FlarakList[i].Rocket2,World)
    next i
endfunction
