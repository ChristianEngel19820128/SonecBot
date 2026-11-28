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

// B02c: resistance reduction active in the common HP path.
#constant DAMAGE_TYPE_UNKNOWN 0
#constant DAMAGE_TYPE_KINETIC 1
#constant DAMAGE_TYPE_ENERGY 2
#constant DAMAGE_TYPE_EXPLOSION 3
#constant DAMAGE_TYPE_FIRE 4
#constant DAMAGE_ARMOR_UNARMORED 0
#constant DAMAGE_ARMOR_MASSIVE 1
#constant DAMAGE_ARMOR_ENERGY 2
#constant DAMAGE_ARMOR_COMPOSITE 3
#constant DAMAGE_ARMOR_THERMAL 4
#constant DAMAGE_ARMOR_INDIVIDUAL 5

global DamageArmorConfig as TDamageArmorConfig
global DamageArmorConfigLoaded as integer

function DamageResistanceSet(Profile ref as TDamageResistance,Kinetic as integer,Energy as integer,Explosion as integer,Fire as integer)
    Profile.Kinetic = Kinetic
    Profile.Energy = Energy
    Profile.Explosion = Explosion
    Profile.Fire = Fire
endfunction

function DamageResistanceValid(Profile ref as TDamageResistance)
    local Valid as integer
    Valid = TRUE
    if Profile.Kinetic < 0 or Profile.Kinetic > 100 then Valid = FALSE
    if Profile.Energy < 0 or Profile.Energy > 100 then Valid = FALSE
    if Profile.Explosion < 0 or Profile.Explosion > 100 then Valid = FALSE
    if Profile.Fire < 0 or Profile.Fire > 100 then Valid = FALSE
endfunction Valid

function DamageArmorLoad()
    local File as TFilePath
    local Candidate as TDamageArmorConfig
    DamageArmorConfig.Version = 1
    DamageResistanceSet(DamageArmorConfig.Unarmored,0,0,0,0)
    DamageResistanceSet(DamageArmorConfig.Massive,75,0,50,25)
    DamageResistanceSet(DamageArmorConfig.Energy,25,75,0,50)
    DamageResistanceSet(DamageArmorConfig.Composite,50,25,75,0)
    DamageResistanceSet(DamageArmorConfig.Thermal,0,50,25,75)
    DamageArmorConfigLoaded = FALSE
    File.Path = "/media/data"
    File.Name = "damagearmor.json"
    if FilePathSetAndCheck(File) = FALSE then exitfunction
    // Missing fields must not silently become valid zero resistances.
    Candidate.Version = -1
    DamageResistanceSet(Candidate.Unarmored,-1,-1,-1,-1)
    DamageResistanceSet(Candidate.Massive,-1,-1,-1,-1)
    DamageResistanceSet(Candidate.Energy,-1,-1,-1,-1)
    DamageResistanceSet(Candidate.Composite,-1,-1,-1,-1)
    DamageResistanceSet(Candidate.Thermal,-1,-1,-1,-1)
    Candidate.FromJson(ReadFileString(File))
    if Candidate.Version <> 1 then exitfunction
    if DamageResistanceValid(Candidate.Unarmored) = FALSE then exitfunction
    if DamageResistanceValid(Candidate.Massive) = FALSE then exitfunction
    if DamageResistanceValid(Candidate.Energy) = FALSE then exitfunction
    if DamageResistanceValid(Candidate.Composite) = FALSE then exitfunction
    if DamageResistanceValid(Candidate.Thermal) = FALSE then exitfunction
    if Candidate.Unarmored.Kinetic <> 0 or Candidate.Unarmored.Energy <> 0 or Candidate.Unarmored.Explosion <> 0 or Candidate.Unarmored.Fire <> 0 then exitfunction
    DamageArmorConfig = Candidate
    DamageArmorConfigLoaded = TRUE
endfunction

function DamageTargetArmor(TargetKind as integer)
    local Armor as integer
    Armor = DAMAGE_ARMOR_UNARMORED
    if TargetKind = DAMAGE_OBJECT_SONEC then Armor = DAMAGE_ARMOR_INDIVIDUAL
    if TargetKind = DAMAGE_OBJECT_WALKER or TargetKind = DAMAGE_OBJECT_FLARAK then Armor = DAMAGE_ARMOR_MASSIVE
    if TargetKind = DAMAGE_OBJECT_ORB or TargetKind = DAMAGE_OBJECT_DRONE then Armor = DAMAGE_ARMOR_ENERGY
    if TargetKind = DAMAGE_OBJECT_SMART_MINE or TargetKind = DAMAGE_OBJECT_BOMBER then Armor = DAMAGE_ARMOR_COMPOSITE
endfunction Armor

function DamageProfileResistance(Profile ref as TDamageResistance,DamageType as integer)
    local Resistance as integer
    Resistance = 0
    if DamageType = DAMAGE_TYPE_KINETIC then Resistance = Profile.Kinetic
    if DamageType = DAMAGE_TYPE_ENERGY then Resistance = Profile.Energy
    if DamageType = DAMAGE_TYPE_EXPLOSION then Resistance = Profile.Explosion
    if DamageType = DAMAGE_TYPE_FIRE then Resistance = Profile.Fire
endfunction Resistance

function DamageArmorResistance(Armor as integer,DamageType as integer)
    local Resistance as integer
    Resistance = 0
    if Armor = DAMAGE_ARMOR_MASSIVE then Resistance = DamageProfileResistance(DamageArmorConfig.Massive,DamageType)
    if Armor = DAMAGE_ARMOR_ENERGY then Resistance = DamageProfileResistance(DamageArmorConfig.Energy,DamageType)
    if Armor = DAMAGE_ARMOR_COMPOSITE then Resistance = DamageProfileResistance(DamageArmorConfig.Composite,DamageType)
    if Armor = DAMAGE_ARMOR_THERMAL then Resistance = DamageProfileResistance(DamageArmorConfig.Thermal,DamageType)
endfunction Resistance

function DamageDefaultType(SourceKind as integer)
    local DamageType as integer
    DamageType = DAMAGE_TYPE_UNKNOWN
    if SourceKind = DAMAGE_SOURCE_BULLET or SourceKind = DAMAGE_SOURCE_GRENADE then DamageType = DAMAGE_TYPE_KINETIC
    if SourceKind = DAMAGE_SOURCE_PLASMA or SourceKind = DAMAGE_SOURCE_LASER then DamageType = DAMAGE_TYPE_ENERGY
    if SourceKind = DAMAGE_SOURCE_EXPLOSION or SourceKind = DAMAGE_SOURCE_BOMB or SourceKind = DAMAGE_SOURCE_ROCKET then DamageType = DAMAGE_TYPE_EXPLOSION
    if SourceKind = DAMAGE_SOURCE_FLAME then DamageType = DAMAGE_TYPE_FIRE
endfunction DamageType

function DamageEffectiveResistance(Resistance as integer,Penetration as integer)
    local Effective as float
    if Resistance < 0 then Resistance = 0
    if Resistance > 100 then Resistance = 100
    if Penetration < 0 then Penetration = 0
    if Penetration > 100 then Penetration = 100
    Effective = Resistance*(100-Penetration)/100.0
    if Resistance = 100 then Effective = 100
endfunction Effective

// Integer HP, nearest integer (half up), minimum one except zero/immunity.
function DamageReducedHP(Damage as integer,Resistance as integer,Penetration as integer)
    local Reduced as integer
    local Effective as float
    Reduced = 0
    if Damage > 0 and Resistance < 100
        Effective = DamageEffectiveResistance(Resistance,Penetration)
        Reduced = Floor(Damage*(100.0-Effective)/100.0+0.5)
        if Reduced < 1 then Reduced = 1
        if Reduced > Damage then Reduced = Damage
    endif
endfunction Reduced

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
global DamageTestSummary as string
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
function DamageApplyHP(BeforeHP as integer,RequestedDamage as integer,ShieldAbsorbed as integer,Origin ref as TDamageOrigin,TargetKind as integer,TargetId as integer,BaseResistance as integer,Result ref as TDamageResult)
    Result.Origin = Origin
    Result.TargetKind = TargetKind
    Result.TargetId = TargetId
    Result.RequestedDamage = RequestedDamage
    Result.ShieldAbsorbed = ShieldAbsorbed
    Result.ArmorType = DamageTargetArmor(TargetKind)
    Result.BaseResistance = BaseResistance
    Result.EffectiveResistance = DamageEffectiveResistance(Result.BaseResistance,Origin.ArmorPenetration)
    Result.HPDamage = DamageReducedHP(RequestedDamage-ShieldAbsorbed,Result.BaseResistance,Origin.ArmorPenetration)
    Result.ResistancePrevented = RequestedDamage-ShieldAbsorbed-Result.HPDamage
    Result.HealthBefore = BeforeHP
    Result.HealthAfter = BeforeHP-Result.HPDamage
    Result.EffectiveHealthLoss = DamageEffectiveHealthLoss(BeforeHP,Result.HealthAfter)
endfunction Result.HealthAfter

// Explicit opt-in for existing shield-aware attack paths only.
function DamageApplySonec(Sonec ref as TSonec,Shield ref as TShield,RequestedDamage as integer,Origin ref as TDamageOrigin,TargetId as integer,Now as integer,Result ref as TDamageResult)
    local Absorbed as integer
    Absorbed = ShieldAbsorbDamage(Shield,Sonec,RequestedDamage,Now)
    local Resistance as integer
    local AfterHP as integer
    Resistance = DamageProfileResistance(Sonec.DamageResistance,Origin.DamageType)
    if Resistance < 0 then Resistance = 0
    if Resistance > 75 then Resistance = 75
    AfterHP = DamageApplyHP(Sonec.Health.State,RequestedDamage,Absorbed,Origin,DAMAGE_OBJECT_SONEC,TargetId,Resistance,Result)
    DamagePrepareDelayedOrigin(Sonec.Health,Result.HPDamage,Origin)
    Sonec.Health.State = AfterHP
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
    Origin.DamageType = DamageDefaultType(SourceKind)
    Origin.ArmorPenetration = 0
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
    AfterHP = DamageApplyHP(BeforeHP,Damage,0,Origin,TargetKind,TargetId,DamageArmorResistance(DamageTargetArmor(TargetKind),Origin.DamageType),Result)
    DamagePublishHit(Result)
endfunction AfterHP

function DamageApplyDelayedHealth(Health ref as THealth,Damage as integer,Origin ref as TDamageOrigin,TargetKind as integer,TargetId as integer)
    local Result as TDamageResult
    local AfterHP as integer
    AfterHP = DamageApplyHP(Health.State,Damage,0,Origin,TargetKind,TargetId,DamageArmorResistance(DamageTargetArmor(TargetKind),Origin.DamageType),Result)
    DamagePrepareDelayedOrigin(Health,Result.HPDamage,Origin)
    Health.State = AfterHP
    DamagePublishHit(Result)
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
        WriteLine(FileID,"round,sequence,event,owner_kind,owner_id,source_kind,source_id,target_kind,target_id,requested,shield_absorbed,hp_before,hp_after,effective_hp,damage_type,armor_type,resistance_base,armor_penetration,resistance_effective,resistance_prevented,hp_damage,armor_config_loaded")
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
    Row = Row+","+Str(Result.Origin.DamageType)+","+Str(Result.ArmorType)+","+Str(Result.BaseResistance)+","+Str(Result.Origin.ArmorPenetration)+","+Str(Result.EffectiveResistance)+","+Str(Result.ResistancePrevented)+","+Str(Result.HPDamage)+","+Str(DamageArmorConfigLoaded)
    DamageTraceWrite(Row)
endfunction

function DamageTraceDestruction(Event ref as TDamageDestruction)
    local Row as string
    Row = "destroy,"+DamageTraceOrigin(Event.Origin)+","+Str(Event.TargetKind)+","+Str(Event.TargetId)+",,,,,"+Str(Event.EffectiveHealthLoss)+","+Str(Event.Origin.DamageType)+",,,"+Str(Event.Origin.ArmorPenetration)+",,,,"+Str(DamageArmorConfigLoaded)
    DamageTraceWrite(Row)
endfunction

// B02c developer self-test: local value snapshots only, no combat events or HP changes.
function DamageTestCase(Requested as integer,Absorbed as integer,Resistance as integer,AP as integer,Expected as integer)
    local Origin as TDamageOrigin
    local Result as TDamageResult
    local AfterHP as integer
    local Passed as integer
    Origin.DamageType = DAMAGE_TYPE_KINETIC
    Origin.ArmorPenetration = AP
    AfterHP = DamageApplyHP(10,Requested,Absorbed,Origin,DAMAGE_OBJECT_WALKER,0,Resistance,Result)
    Passed = FALSE
    if Result.HPDamage = Expected and AfterHP = 10-Expected and Result.ResistancePrevented = Requested-Absorbed-Expected and Result.EffectiveHealthLoss = DamageEffectiveHealthLoss(10,10-Expected) then Passed = TRUE
endfunction Passed

function DamageRunSelfTest()
    local Passed as integer
    local Armor as integer
    local Kind as integer
    local Resistance as integer
    local Expected as integer
    local Profile as TDamageResistance
    local Health as THealth
    local Origin as TDamageOrigin
    local Result as TDamageResult
    local AfterHP as integer
    Passed = 0
    // Test all 20 loaded matrix cells with an exact 100-point input.
    for Armor = 0 to 4
        for Kind = 1 to 4
            Resistance = DamageArmorResistance(Armor,Kind)
            Expected = 100-Resistance
            Passed = Passed+DamageTestCase(100,0,Resistance,0,Expected)
        next Kind
    next Armor
    Passed = Passed+DamageTestCase(20,0,75,50,13)
    Passed = Passed+DamageTestCase(20,0,75,100,20)
    Passed = Passed+DamageTestCase(20,0,100,0,0)
    Passed = Passed+DamageTestCase(20,0,100,100,0)
    Passed = Passed+DamageTestCase(1,0,75,0,1)
    Passed = Passed+DamageTestCase(0,0,75,0,0)
    Passed = Passed+DamageTestCase(20,20,75,0,0)
    Passed = Passed+DamageTestCase(100,40,50,0,30)
    DamageResistanceSet(Profile,10,20,30,40)
    if DamageProfileResistance(Profile,DAMAGE_TYPE_KINETIC) = 10 and DamageProfileResistance(Profile,DAMAGE_TYPE_ENERGY) = 20 and DamageProfileResistance(Profile,DAMAGE_TYPE_EXPLOSION) = 30 and DamageProfileResistance(Profile,DAMAGE_TYPE_FIRE) = 40 then Passed = Passed+1
    // The first hit must not record a false destruction crossing.
    Health.State = 15
    Origin.OwnerId = 123
    Origin.DamageType = DAMAGE_TYPE_KINETIC
    AfterHP = DamageApplyHP(Health.State,20,0,Origin,DAMAGE_OBJECT_WALKER,0,50,Result)
    DamagePrepareDelayedOrigin(Health,Result.HPDamage,Origin)
    if AfterHP = 5 and Health.PendingDamageOrigin.OwnerId = 0 then Passed = Passed+1
    Health.State = AfterHP
    AfterHP = DamageApplyHP(Health.State,20,0,Origin,DAMAGE_OBJECT_WALKER,0,50,Result)
    DamagePrepareDelayedOrigin(Health,Result.HPDamage,Origin)
    if AfterHP = -5 and Health.PendingDamageOrigin.OwnerId = 123 then Passed = Passed+1
    DamageTestSummary = " | selftest "+Str(Passed)+"/31 | JSON "+Str(DamageArmorConfigLoaded)
endfunction

function DamageTraceToggle()
    if DamageTraceEnabled = TRUE
        DamageTraceEnabled = FALSE
    else
        DamageRunSelfTest()
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
    SetTextString(DamageTraceText,"B02 CSV ON  #"+Str(DamageTraceSequence)+DamageTestSummary)
    DrawText(DamageTraceText)
endfunction
