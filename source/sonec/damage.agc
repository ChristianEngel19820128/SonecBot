// B01b: passive foundation. No existing combat caller uses these functions yet.
// OwnerKind identifies the original cause; SourceKind the immediate delivery.
// IDs are value snapshots, never array slot indices.
#constant DAMAGE_OBJECT_UNKNOWN 0
#constant DAMAGE_OBJECT_SONEC 1
#constant DAMAGE_OBJECT_WALKER 2
#constant DAMAGE_OBJECT_ORB 3
#constant DAMAGE_OBJECT_SMART_MINE 4
#constant DAMAGE_OBJECT_SIMPLE_MINE 5
#constant DAMAGE_OBJECT_CHEST 6
#constant DAMAGE_OBJECT_DRONE 7
#constant DAMAGE_OBJECT_BOMBER 8
#constant DAMAGE_OBJECT_FLARAK 9
#constant DAMAGE_OBJECT_JUMPPOD 10
#constant DAMAGE_OBJECT_LANDMINE 11
#constant DAMAGE_SOURCE_BULLET 20
#constant DAMAGE_SOURCE_GRENADE 21
#constant DAMAGE_SOURCE_FLAME 22
#constant DAMAGE_SOURCE_PLASMA 23
#constant DAMAGE_SOURCE_EXPLOSION 24
#constant DAMAGE_SOURCE_LASER 25
#constant DAMAGE_SOURCE_BOMB 26
#constant DAMAGE_SOURCE_ROCKET 27
#constant DAMAGE_SOURCE_CONTACT 28

// Bounded event snapshots; future consumers attach at the publish functions.
// These are not a queue and do not implement XP or relief.
global DamageLastHit as TDamageResult
global DamageLastDestruction as TDamageDestruction
global DamageHitAvailable as integer
global DamageDestructionAvailable as integer

function DamageReset()
    local EmptyHit as TDamageResult
    local EmptyDestruction as TDamageDestruction
    DamageLastHit = EmptyHit
    DamageLastDestruction = EmptyDestruction
    DamageHitAvailable = FALSE
    DamageDestructionAvailable = FALSE
endfunction

function DamageEffectiveHealthLoss(BeforeHP as integer,AfterHP as integer)
    local PositiveBefore as integer
    local PositiveAfter as integer
    local Loss as integer
    PositiveBefore = BeforeHP
    PositiveAfter = AfterHP
    if PositiveBefore < 0 then PositiveBefore = 0
    if PositiveAfter < 0 then PositiveAfter = 0
    Loss = PositiveBefore-PositiveAfter
    if Loss < 0 then Loss = 0
endfunction Loss

function DamagePublishHit(Result ref as TDamageResult)
    DamageLastHit = Result
    DamageHitAvailable = TRUE
endfunction

function DamagePublishDestruction(Event ref as TDamageDestruction)
    DamageLastDestruction = Event
    DamageDestructionAvailable = TRUE
endfunction

// Preserve the raw subtraction, including negative HP and exact zero.
// Target-specific thresholds, clamping, flashes and rewards remain with callers.
function DamageApplyHP(BeforeHP as integer,RequestedDamage as integer,ShieldAbsorbed as integer,Origin ref as TDamageOrigin,TargetKind as integer,TargetId as integer,Result ref as TDamageResult)
    Result.Origin = Origin
    Result.TargetKind = TargetKind
    Result.TargetId = TargetId
    Result.RequestedDamage = RequestedDamage
    Result.ShieldAbsorbed = ShieldAbsorbed
    Result.HealthBefore = BeforeHP
    Result.HealthAfter = BeforeHP-(RequestedDamage-ShieldAbsorbed)
    Result.EffectiveHealthLoss = DamageEffectiveHealthLoss(BeforeHP,Result.HealthAfter)
endfunction Result.HealthAfter

// Explicit opt-in for existing shield-aware attack paths only.
function DamageApplySonec(Sonec ref as TSonec,Shield ref as TShield,RequestedDamage as integer,Origin ref as TDamageOrigin,TargetId as integer,Now as integer,Result ref as TDamageResult)
    local Absorbed as integer
    Absorbed = ShieldAbsorbDamage(Shield,Sonec,RequestedDamage,Now)
    Sonec.Health.State = DamageApplyHP(Sonec.Health.State,RequestedDamage,Absorbed,Origin,DAMAGE_OBJECT_SONEC,TargetId,Result)
    DamagePublishHit(Result)
endfunction

// Immediate removal (e.g. bomb/chest) without inventing an HP subtraction.
// The caller still owns deletion, support release and reward order.
function DamageRecordImmediateDestruction(BeforeHP as integer,Origin ref as TDamageOrigin,TargetKind as integer,TargetId as integer,Now as integer)
    local Event as TDamageDestruction
    Event.Origin = Origin
    Event.TargetKind = TargetKind
    Event.TargetId = TargetId
    Event.EffectiveHealthLoss = DamageEffectiveHealthLoss(BeforeHP,0)
    Event.TimeMs = Now
    DamagePublishDestruction(Event)
endfunction
