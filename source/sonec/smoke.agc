// A5/J4: reusable world-space smoke; no gameplay collision or RNG calls.
// All owners share one set of particle parameters; only density differs.
#constant SMOKE_IMAGE_COUNT 6
#constant SMOKE_EMISSION_INTERVAL_MS 180
#constant SMOKE_EMISSION_JITTER_MS 40
#constant SMOKE_RAMP_MS 2200
#constant SMOKE_RAMP_START 0.15
#constant SMOKE_LIFE_MIN_MS 1800
#constant SMOKE_LIFE_MAX_MS 2700
#constant SMOKE_DRIFT_MIN_PX_S 12
#constant SMOKE_DRIFT_MAX_PX_S 28
#constant SMOKE_RISE_MIN_PX_S 24
#constant SMOKE_RISE_MAX_PX_S 42
#constant SMOKE_ROTATE_MIN_DEG_S -30
#constant SMOKE_ROTATE_MAX_DEG_S 30
#constant SMOKE_ALPHA_MIN 35
#constant SMOKE_ALPHA_MAX 75
#constant SMOKE_SIZE_MIN_PX 5
#constant SMOKE_SIZE_MAX_PX 25
#constant SMOKE_END_SIZE_FACTOR 7.5
#constant SMOKE_DENSITY_JUMPPOD 2
#constant SMOKE_DENSITY_LANDMINE 4
#constant SMOKE_DENSITY_FLAK 5
#constant SMOKE_DENSITY_FLARAK 5

type TSmokeParticle
    Enabled as integer
    ImageIndex as integer
    BirthMs as integer
    LifetimeMs as integer
    Origin as TPosition
    Velocity as TSpeed
    InitialAngle as float
    AngularSpeed as float
    InitialAlpha as integer
    InitialSize as float
    AgeFraction as float
    Position as TPosition
    Angle as float
endtype

global SmokeParticles as TSmokeParticle[-1]
global SmokeSprites as integer[-1]
// Unscaled maximum image dimension; retain the source aspect ratio.
global SmokeSpriteNativeSize as float[-1]
global SmokeLoadedCount as integer
global SmokeSessionID as integer
global SmokeVisualSeed as integer

// Dedicated 16-bit full-period visual PRNG, with exact integer intermediates
// below 2^24. It never advances AGK's gameplay Random() sequence.
function SmokeRandomInt(MinValue as integer,MaxValue as integer)
    local Sample as integer
    Sample = SmokeVisualSeed*253+13849
    SmokeVisualSeed = Sample-65536*Floor(Sample/65536.0)
    Sample = MinValue+Floor(SmokeVisualSeed*(1.0/65536.0)*(MaxValue-MinValue+1))
endfunction Sample

function ProtoSmokeLoad()
    local Image as TImage
    local i as integer
    local SpriteID as integer
    local NativeSize as float
    SmokeLoadedCount = 0
    SmokeSprites.Length = SMOKE_IMAGE_COUNT-1
    SmokeSpriteNativeSize.Length = SMOKE_IMAGE_COUNT-1
    for i = 1 to SMOKE_IMAGE_COUNT
        Image.ID = 0
        Image.File.Path = "/media/gfx/effects/smoke"
        Image.File.Name = "smoke_"+Str(i)+".png"
        if ImageLoad(Image) = TRUE
            SpriteID = CreateSprite(Image.ID)
            if SpriteID > 0
                NativeSize = GetImageWidth(Image.ID)
                if GetImageHeight(Image.ID) > NativeSize then NativeSize = GetImageHeight(Image.ID)
                if NativeSize > 0
                    SmokeSprites[SmokeLoadedCount] = SpriteID
                    SmokeSpriteNativeSize[SmokeLoadedCount] = NativeSize
                    SetSpriteOffset(SpriteID,GetImageWidth(Image.ID)*0.5,GetImageHeight(Image.ID)*0.5)
                    SmokeLoadedCount = SmokeLoadedCount+1
                else
                    DeleteSprite(SpriteID)
                endif
            endif
        endif
    next i
endfunction

// Shared prototypes remain loaded. No particle owns an engine sprite.
function SmokeDeleteAll()
    SmokeParticles.Length = -1
    // Invalidate every existing owner even if its own reset is incomplete.
    SmokeSessionID = SmokeSessionID+1
endfunction

function SmokeInit()
    SmokeDeleteAll()
    SmokeVisualSeed = 12345
endfunction

// Called once at the source's destruction event, not on each update.
function SmokeStartEmitter(Emitter ref as TSmokeEmitter,Now as integer)
    Emitter.Active = TRUE
    Emitter.SessionID = SmokeSessionID
    Emitter.StartMs = Now
    Emitter.NextMs = Now
    Emitter.ParticleCredit = 0.85
endfunction

function SmokeInsertParticle(Position as TPosition,Now as integer)
    local P as TSmokeParticle
    local i as integer
    if SmokeLoadedCount <= 0 then exitfunction
    P.Enabled = TRUE
    P.ImageIndex = SmokeRandomInt(0,SmokeLoadedCount-1)
    P.BirthMs = Now
    P.LifetimeMs = SmokeRandomInt(SMOKE_LIFE_MIN_MS,SMOKE_LIFE_MAX_MS)
    P.Origin = Position
    P.Position = Position
    P.Velocity.x = SmokeRandomInt(SMOKE_DRIFT_MIN_PX_S,SMOKE_DRIFT_MAX_PX_S)
    P.Velocity.y = -SmokeRandomInt(SMOKE_RISE_MIN_PX_S,SMOKE_RISE_MAX_PX_S)
    P.InitialAngle = SmokeRandomInt(0,359)
    P.Angle = P.InitialAngle
    P.AngularSpeed = SmokeRandomInt(SMOKE_ROTATE_MIN_DEG_S,SMOKE_ROTATE_MAX_DEG_S)
    P.InitialAlpha = SmokeRandomInt(SMOKE_ALPHA_MIN,SMOKE_ALPHA_MAX)
    P.InitialSize = SmokeRandomInt(SMOKE_SIZE_MIN_PX,SMOKE_SIZE_MAX_PX)
    for i = 0 to SmokeParticles.Length
        if SmokeParticles[i].Enabled = FALSE
            SmokeParticles[i] = P
            exitfunction
        endif
    next i
    SmokeParticles.Insert(P)
endfunction

// Submit the source's current world position each active game tick.
// Density affects only particle count. Fractional credit smoothly ramps
// emission; no backlog burst after an interrupted or slow frame.
function SmokeAdd(Emitter ref as TSmokeEmitter,Position as TPosition,Density as integer,Now as integer)
    local Ramp as float
    local ParticleCount as integer
    local i as integer
    local RandomPosition as TPosition
    if Emitter.Active = FALSE or Emitter.SessionID <> SmokeSessionID or Density <= 0 or SmokeLoadedCount <= 0 then exitfunction
    if Now < Emitter.NextMs then exitfunction
    Ramp = (Now-Emitter.StartMs)/(SMOKE_RAMP_MS*1.0)
    if Ramp < 0 then Ramp = 0
    if Ramp > 1 then Ramp = 1
    Ramp = SMOKE_RAMP_START+(1.0-SMOKE_RAMP_START)*Ramp
    Emitter.ParticleCredit = Emitter.ParticleCredit+Density*Ramp
    ParticleCount = Floor(Emitter.ParticleCredit)
    Emitter.ParticleCredit = Emitter.ParticleCredit-ParticleCount
    Emitter.NextMs = Now+SmokeRandomInt(SMOKE_EMISSION_INTERVAL_MS-SMOKE_EMISSION_JITTER_MS,SMOKE_EMISSION_INTERVAL_MS+SMOKE_EMISSION_JITTER_MS)
    for i = 1 to ParticleCount
        RandomPosition = Position
        RandomPosition.x = RandomPosition.x - 25.0 + random(0,50000)/100
        SmokeInsertParticle(Position,Now)
    next i
endfunction

// Absolute age in virtual game milliseconds: independent of frame rate,
// frozen by pause. Emitted particles do not track their former owner.
function SmokeDoAll(Now as integer)
    local i as integer
    local AgeMs as integer
    local AgeSeconds as float
    for i = 0 to SmokeParticles.Length
        if SmokeParticles[i].Enabled = TRUE
            AgeMs = Now-SmokeParticles[i].BirthMs
            if AgeMs < 0 then AgeMs = 0
            if AgeMs >= SmokeParticles[i].LifetimeMs
                SmokeParticles[i].Enabled = FALSE
            else
                AgeSeconds = AgeMs*0.001
                SmokeParticles[i].AgeFraction = AgeMs/(SmokeParticles[i].LifetimeMs*1.0)
                SmokeParticles[i].Position.x = SmokeParticles[i].Origin.x+SmokeParticles[i].Velocity.x*AgeSeconds
                SmokeParticles[i].Position.y = SmokeParticles[i].Origin.y+SmokeParticles[i].Velocity.y*AgeSeconds
                SmokeParticles[i].Angle = SmokeParticles[i].InitialAngle+SmokeParticles[i].AngularSpeed*AgeSeconds
            endif
        endif
    next i
endfunction

function SmokeDrawAll(World ref as TWorld)
    local i as integer
    local SpriteID as integer
    local DrawSize as float
    local DrawScale as float
    local DrawAlpha as integer
    for i = 0 to SmokeParticles.Length
        if SmokeParticles[i].Enabled = TRUE
            SpriteID = SmokeSprites[SmokeParticles[i].ImageIndex]
            DrawSize = SmokeParticles[i].InitialSize*(1.0-(1.0-SMOKE_END_SIZE_FACTOR)*SmokeParticles[i].AgeFraction)
            DrawAlpha = Floor(SmokeParticles[i].InitialAlpha*(1.0-SmokeParticles[i].AgeFraction))
            DrawScale = DrawSize/SmokeSpriteNativeSize[SmokeParticles[i].ImageIndex]
            // Same centered scaled pivot convention as SpriteDraw.
            SetSpriteOffset(SpriteID,GetSpriteWidth(SpriteID)*0.5,GetSpriteHeight(SpriteID)*0.5)
            SetSpriteScaleByOffset(SpriteID,DrawScale,DrawScale)
            SetSpriteAngle(SpriteID,SmokeParticles[i].Angle)
            SetSpriteColor(SpriteID,55+random(0,55),125,55+random(0,55),DrawAlpha)
            SetSpritePositionByOffset(SpriteID,SmokeParticles[i].Position.x-World.Position.x,SmokeParticles[i].Position.y-World.Position.y)
            DrawSprite(SpriteID)
        endif
    next i
endfunction
