// B01d1: direct player damage enabled; other paths retain their legacy execution.
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
global DamageSourceSerial as integer
global DamageHitAvailable as integer
global DamageDestructionAvailable as integer

function DamageReset()
    local EmptyHit as TDamageResult
    local EmptyDestruction as TDamageDestruction
    DamageLastHit = EmptyHit
    DamageLastDestruction = EmptyDestruction
    DamageSourceSerial = 0
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

// Independent source IDs, reset each round.
function DamageOriginStart(Origin ref as TDamageOrigin,OwnerKind as integer,OwnerId as integer,SourceKind as integer)
    DamageSourceSerial = DamageSourceSerial+1
    Origin.OwnerKind = OwnerKind
    Origin.OwnerId = OwnerId
    Origin.SourceKind = SourceKind
    Origin.SourceId = DamageSourceSerial
endfunction

// B01c2: record only a crossing of the legacy strictly-negative threshold.
// Later hits on already-negative HP must not replace the original cause.
function DamagePrepareDelayedOrigin(Health ref as THealth,Damage as integer,Origin ref as TDamageOrigin)
    if Health.State >= 0 and Health.State-Damage < 0
        Health.PendingDamageOrigin = Origin
    endif
endfunction

function DamageClearDelayedOrigin(Health ref as THealth)
    local EmptyOrigin as TDamageOrigin
    Health.PendingDamageOrigin = EmptyOrigin
endfunction

// D1 activation: shared target handlers also receive explosions/contact.
// Leave those paths on their old subtraction until the next activation steps.
function DamageDirectPlayerEnabled(Origin ref as TDamageOrigin)
    if Origin.OwnerKind <> DAMAGE_OBJECT_SONEC then exitfunction FALSE
    if Origin.SourceKind = DAMAGE_SOURCE_BULLET or Origin.SourceKind = DAMAGE_SOURCE_GRENADE or Origin.SourceKind = DAMAGE_SOURCE_FLAME or Origin.SourceKind = DAMAGE_SOURCE_PLASMA then exitfunction TRUE
endfunction FALSE

function DamageApplyDirectValue(BeforeHP as integer,Damage as integer,Origin ref as TDamageOrigin,TargetKind as integer,TargetId as integer)
    local Result as TDamageResult
    local AfterHP as integer
    if DamageDirectPlayerEnabled(Origin) = FALSE then exitfunction BeforeHP-Damage
    AfterHP = DamageApplyHP(BeforeHP,Damage,0,Origin,TargetKind,TargetId,Result)
    DamagePublishHit(Result)
endfunction AfterHP

function DamageApplyDelayedHealth(Health ref as THealth,Damage as integer,Origin ref as TDamageOrigin,TargetKind as integer,TargetId as integer)
    DamagePrepareDelayedOrigin(Health,Damage,Origin)
    Health.State = DamageApplyDirectValue(Health.State,Damage,Origin,TargetKind,TargetId)
endfunction
