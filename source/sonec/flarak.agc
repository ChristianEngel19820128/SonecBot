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
#constant FLARAK_TEST_ROCKET_LIFETIME_MS 1500
#constant FLARAK_TEST_ROCKET_SPEED_PX_PER_MS 0.24
#constant FLARAK_TEST_MUZZLE_DISTANCE 22
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
global FlarakTestRocketAngle as float
global FlarakTestRocketSpriteAngle as float
global FlarakTestAimLocked as integer
global FlarakTestAimLockMs as integer
global FlarakTestLockedLauncherAngle as float
global FlarakTestWarningSprite as integer

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
    // A small orange marker at the muzzle signals the imminent shot.
    FlarakTestWarningSprite = CreateSprite(0)
    SetSpriteSize(FlarakTestWarningSprite,7,7)
    SetSpriteOffset(FlarakTestWarningSprite,3.5,3.5)
    SetSpriteColor(FlarakTestWarningSprite,255,155,45,255)
    FlarakTestAimLocked = FALSE
    FlarakTestRocketActive = FALSE
    FlarakTestStartMs = GetMilliseconds()
    FlarakTestRocketNextMs = FlarakTestStartMs+1500
endfunction

function FlarakVisualTestDraw(Screen as TSize)
    local Elapsed as integer
    local Frame as integer
    local Angle as float
    local LauncherAngle as float
    local X as float
    local Y as float
    local RocketDistance as float
    local NowMs as integer
    local MuzzleAngle as float
    if FlarakTestBaseSprite = 0 or FlarakTestLauncherSprite = 0 then exitfunction

    NowMs = GetMilliseconds()
    Elapsed = NowMs-FlarakTestStartMs
    Frame = 1+Elapsed/FLARAK_TEST_FRAME_MS
    if Frame > 5 then Frame = 5
    SetSpriteFrame(FlarakTestBaseSprite,Frame)
    X = Screen.Width*0.5
    Y = Screen.Height-45
    SetSpritePositionByOffset(FlarakTestBaseSprite,X,Y)
    // Frame 5 stays visible as the base while frame 6 rotates above it.
    DrawSprite(FlarakTestBaseSprite)

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
        SetSpriteAngle(FlarakTestLauncherSprite,LauncherAngle)
        // Preserve the unrotated overlay while moving the pivot to the joint.
        SetSpritePositionByOffset(FlarakTestLauncherSprite,X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X,Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y)
        // Capture the launcher angle when firing; the projectile does not turn.
        if FlarakTestAimLocked = TRUE and FlarakTestRocketSprite > 0 and FlarakTestRocketActive = FALSE and NowMs-FlarakTestAimLockMs >= FLARAK_TEST_AIM_HOLD_MS
            FlarakTestRocketAngle = LauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            // The rocket art points opposite to the barrel at this angle.
            // Flip only the visual sprite, not its launch vector.
            FlarakTestRocketSpriteAngle = LauncherAngle+180
            FlarakTestRocketStartX = X+Sin(FlarakTestRocketAngle)*FLARAK_TEST_MUZZLE_DISTANCE
            FlarakTestRocketStartY = Y-Cos(FlarakTestRocketAngle)*FLARAK_TEST_MUZZLE_DISTANCE
            FlarakTestRocketLaunchMs = NowMs
            FlarakTestRocketActive = TRUE
            FlarakTestRocketNextMs = NowMs+FLARAK_TEST_ROCKET_INTERVAL_MS
        endif
        // Warning light is visible only during the final 300 ms of aim hold.
        if FlarakTestAimLocked = TRUE and FlarakTestRocketActive = FALSE and NowMs-FlarakTestAimLockMs >= FLARAK_TEST_AIM_HOLD_MS-FLARAK_TEST_WARNING_MS
            MuzzleAngle = FlarakTestLockedLauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            SetSpritePositionByOffset(FlarakTestWarningSprite,X+Sin(MuzzleAngle)*FLARAK_TEST_MUZZLE_DISTANCE,Y-Cos(MuzzleAngle)*FLARAK_TEST_MUZZLE_DISTANCE)
            DrawSprite(FlarakTestWarningSprite)
        endif
        // Draw between base and launcher: the launcher masks the emerging rocket.
        if FlarakTestRocketActive = TRUE
            RocketDistance = (GetMilliseconds()-FlarakTestRocketLaunchMs)*FLARAK_TEST_ROCKET_SPEED_PX_PER_MS
            if GetMilliseconds()-FlarakTestRocketLaunchMs >= FLARAK_TEST_ROCKET_LIFETIME_MS
                FlarakTestRocketActive = FALSE
            else
                // Rocket sprite orientation is independent of its launch vector.
                SetSpriteAngle(FlarakTestRocketSprite,FlarakTestRocketSpriteAngle)
                SetSpritePositionByOffset(FlarakTestRocketSprite,FlarakTestRocketStartX+Sin(FlarakTestRocketAngle)*RocketDistance,FlarakTestRocketStartY-Cos(FlarakTestRocketAngle)*RocketDistance)
                DrawSprite(FlarakTestRocketSprite)
            endif
        endif
        DrawSprite(FlarakTestLauncherSprite)
        if FlarakTestAimLocked = TRUE and FlarakTestRocketActive = TRUE and NowMs-FlarakTestRocketLaunchMs >= FLARAK_TEST_POST_SHOT_HOLD_MS
            FlarakTestAimLocked = FALSE
        endif
    endif
endfunction
