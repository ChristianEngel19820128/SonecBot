// B01d3: all active combat damage paths use the central foundation.
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
global DamageTraceEnabled as integer
global DamageTraceStarted as integer
global DamageTraceSequence as integer
global DamageTraceRound as integer
global DamageTraceText as integer
global DamageHitAvailable as integer
global DamageDestructionAvailable as integer

function DamageReset()
    local EmptyHit as TDamageResult
    local EmptyDestruction as TDamageDestruction
    DamageLastHit = EmptyHit
    DamageLastDestruction = EmptyDestruction
    DamageSourceSerial = 0
    DamageTraceRound = DamageTraceRound+1
    DamageTraceEnabled = FALSE
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
    if DamageTraceEnabled = TRUE then DamageTraceHit(Result)
endfunction

function DamagePublishDestruction(Event ref as TDamageDestruction)
    DamageLastDestruction = Event
    DamageDestructionAvailable = TRUE
    if DamageTraceEnabled = TRUE then DamageTraceDestruction(Event)
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
    DamagePrepareDelayedOrigin(Sonec.Health,RequestedDamage-Absorbed,Origin)
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

// All accepted combat HP hits use the same subtraction and event hook.
function DamageApplyDirectValue(BeforeHP as integer,Damage as integer,Origin ref as TDamageOrigin,TargetKind as integer,TargetId as integer)
    local Result as TDamageResult
    local AfterHP as integer
    AfterHP = DamageApplyHP(BeforeHP,Damage,0,Origin,TargetKind,TargetId,Result)
    DamagePublishHit(Result)
endfunction AfterHP

function DamageApplyDelayedHealth(Health ref as THealth,Damage as integer,Origin ref as TDamageOrigin,TargetKind as integer,TargetId as integer)
    DamagePrepareDelayedOrigin(Health,Damage,Origin)
    Health.State = DamageApplyDirectValue(Health.State,Damage,Origin,TargetKind,TargetId)
endfunction

// Normal destruction follows the accepted HP hits; do not count HP twice.
// Direct removal without HP processing uses DamageRecordImmediateDestruction.
function DamageRecordDestruction(Origin ref as TDamageOrigin,TargetKind as integer,TargetId as integer,Now as integer)
    local Event as TDamageDestruction
    Event.Origin = Origin
    Event.TargetKind = TargetKind
    Event.TargetId = TargetId
    Event.EffectiveHealthLoss = 0
    Event.TimeMs = Now
    DamagePublishDestruction(Event)
endfunction

// B01e developer-only trace. Off by default and after each GameInit.
// One CSV per application run, including round and sequence for slot reuse checks.
// File operations are restricted to enabled diagnostic sessions.
function DamageTraceWrite(Row as string)
    local FileID as integer
    local CsvPath as TFilePath
    CsvPath.Path = "/"
    CsvPath.Name = ""
    FilePathSetAndCheck(CsvPath)
    if DamageTraceStarted = FALSE
        FileID = OpenToWrite("sonec_damage_diagnostics.csv",0)
        if FileID = 0
            DamageTraceEnabled = FALSE
            exitfunction
        endif
        WriteLine(FileID,"round,sequence,event,owner_kind,owner_id,source_kind,source_id,target_kind,target_id,requested,shield_absorbed,hp_before,hp_after,effective_hp")
        CloseFile(FileID)
        DamageTraceStarted = TRUE
    endif
    FileID = OpenToWrite("sonec_damage_diagnostics.csv",1)
    if FileID = 0
        DamageTraceEnabled = FALSE
        exitfunction
    endif
    DamageTraceSequence = DamageTraceSequence+1
    WriteLine(FileID,Str(DamageTraceRound)+","+Str(DamageTraceSequence)+","+Row)
    CloseFile(FileID)
endfunction

function DamageTraceOrigin(Origin ref as TDamageOrigin)
    local Row as string
    Row = Str(Origin.OwnerKind)+","+Str(Origin.OwnerId)+","+Str(Origin.SourceKind)+","+Str(Origin.SourceId)
endfunction Row

function DamageTraceHit(Result ref as TDamageResult)
    local Row as string
    Row = "hit,"+DamageTraceOrigin(Result.Origin)+","+Str(Result.TargetKind)+","+Str(Result.TargetId)+","+Str(Result.RequestedDamage)+","+Str(Result.ShieldAbsorbed)+","+Str(Result.HealthBefore)+","+Str(Result.HealthAfter)+","+Str(Result.EffectiveHealthLoss)
    DamageTraceWrite(Row)
endfunction

function DamageTraceDestruction(Event ref as TDamageDestruction)
    local Row as string
    Row = "destroy,"+DamageTraceOrigin(Event.Origin)+","+Str(Event.TargetKind)+","+Str(Event.TargetId)+",,,,,"+Str(Event.EffectiveHealthLoss)
    DamageTraceWrite(Row)
endfunction

function DamageTraceToggle()
    if DamageTraceEnabled = TRUE
        DamageTraceEnabled = FALSE
    else
        DamageTraceEnabled = TRUE
    endif
endfunction

function DamageTraceDraw()
    if DamageTraceEnabled = FALSE then exitfunction
    if DamageTraceText = 0
        DamageTraceText = CreateText("")
        SetTextSize(DamageTraceText,12)
        SetTextColor(DamageTraceText,255,255,255,255)
        SetTextPosition(DamageTraceText,8,100)
    endif
    SetTextString(DamageTraceText,"B01 CSV ON  #"+Str(DamageTraceSequence))
    DrawText(DamageTraceText)
endfunction
