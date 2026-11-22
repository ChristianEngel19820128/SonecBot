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
#constant FLARAK_TEST_FRAME_MS 220
// F2 visual launch test: straight flight, no homing, damage or collision.
#constant FLARAK_TEST_ROCKET_INTERVAL_MS 2400
#constant FLARAK_TEST_ROCKET_LIFETIME_MS 1500
#constant FLARAK_TEST_ROCKET_SPEED_PX_PER_MS 0.24
#constant FLARAK_TEST_MUZZLE_DISTANCE 22
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
    endif
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
    if FlarakTestBaseSprite = 0 or FlarakTestLauncherSprite = 0 then exitfunction

    Elapsed = GetMilliseconds()-FlarakTestStartMs
    Frame = 1+Elapsed/FLARAK_TEST_FRAME_MS
    if Frame > 5 then Frame = 5
    SetSpriteFrame(FlarakTestBaseSprite,Frame)
    X = Screen.Width*0.5
    Y = Screen.Height-45
    SetSpritePositionByOffset(FlarakTestBaseSprite,X,Y)
    DrawSprite(FlarakTestBaseSprite)

    if Frame = 5
        // First pivot experiment: swing to both sides without pointing straight up.
        Angle = Sin(Elapsed*0.045)*FLARAK_TEST_TILT_DEGREES
        // Negative angles aim up-right. Positive angles switch the barrel
        // by 180 degrees to aim up-left; neither side aims into the ground.
        LauncherAngle = Angle
        if Angle > 0 then LauncherAngle = Angle+180
        SetSpriteAngle(FlarakTestLauncherSprite,LauncherAngle)
        // Preserve the unrotated overlay while moving the pivot to the joint.
        SetSpritePositionByOffset(FlarakTestLauncherSprite,X+FLARAK_TEST_LAUNCHER_PIVOT_X-FLARAK_TEST_BASE_OFFSET_X,Y+FLARAK_TEST_LAUNCHER_PIVOT_Y-FLARAK_TEST_BASE_OFFSET_Y)
        // Capture the launcher angle when firing; the projectile does not turn.
        if FlarakTestRocketSprite > 0 and FlarakTestRocketActive = FALSE and GetMilliseconds() >= FlarakTestRocketNextMs
            FlarakTestRocketAngle = LauncherAngle+FLARAK_TEST_BARREL_ANGLE_OFFSET
            // The rocket art points opposite to the barrel at this angle.
            // Flip only the visual sprite, not its launch vector.
            FlarakTestRocketSpriteAngle = LauncherAngle+180
            FlarakTestRocketStartX = X+Sin(FlarakTestRocketAngle)*FLARAK_TEST_MUZZLE_DISTANCE
            FlarakTestRocketStartY = Y-Cos(FlarakTestRocketAngle)*FLARAK_TEST_MUZZLE_DISTANCE
            FlarakTestRocketLaunchMs = GetMilliseconds()
            FlarakTestRocketActive = TRUE
            FlarakTestRocketNextMs = GetMilliseconds()+FLARAK_TEST_ROCKET_INTERVAL_MS
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
    endif
endfunction
