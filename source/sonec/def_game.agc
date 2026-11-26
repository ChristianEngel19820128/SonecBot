
#constant MOVELEFT 0
#constant MOVERIGHT 1

#constant LOOKLEFT 0
#constant LOOKRIGHT 1

#constant MOVEDOWN 0
#constant MOVEUP 1

#constant ELEMENTLEFT 0
#constant ELEMENTRIGHT 1

#constant FALLACCELERATION 0.01

#constant REGENERGY 1
#constant REGHEALTH 1
#constant COSTOVERLOAD 1
#constant COSTJETFIRE 2
#constant COSTSHIELD 2
#constant COSTATTRACT 1
#constant COSTFLAME 3
#constant COSTPLASMABLITZ 3

#constant TYPEPLATE 1
#constant TYPECHEST 2

#constant TYPEPLAYERONE 1
#constant TYPEPLAYERTWO 2
#constant TYPEENEMY 3


type TPosition
	x as float
	y as float
endtype

// Visual emitter state belongs to its owner; particles live independently.
// Session prevents old owners from resuming emission after GameInit.
type TSmokeEmitter
	Active as integer
	SessionID as integer
	StartMs as integer
	NextMs as integer
	ParticleCredit as float
endtype

type TSize
	Width as float
	Height as float
endtype

type TSpeed
	x as float
	y as float
endtype

type TAlignment
	x as integer
	y as integer
endtype

type TImage
	File as TFilePath
	ID as integer
endtype

type TSpriteData
	Position as TPosition
	Angle as float
	Scale as float
	Center as integer
	OffsetOn as integer
	Offset as TPosition
	Color as TColor
endtype

type TSprite
	ID as integer
	Data as TSpriteData
endtype

type TProtoData
	Image as TImage
	Sprite as TSprite
	Offset as TPosition
	Anchor as TPosition
	Angle as float
	Rotation as float
	Radius as float
endtype

type TEffectData
	LifeCycleTimer as TTime
	LifeCycleMax as integer
	LifeCycle as integer
endtype

type TYShift
	Enabled as integer
	Alignment as integer
	Min as float
	Max as float
endtype

type TObjectData
	MoveTimer as TTime
	Rotation as float
	RotationAlignment as integer
	Angle as float
	AngleAnimate as float
	AngleDelta as float
	Radius as float
	Position as TPosition
	AnchorPosition as TPosition
	AbsolutePosition as TPosition
	RelativePosition as TPosition
	Size as TSize
	MoveSpeedMax as TSpeed
	MoveSpeed as TSpeed
	AutoSpeed as TSpeed
	MoveAcceleration as TSpeed
	MoveAlignment as TAlignment
endtype

type TCollisionData
	ListType as integer
	Index as integer
	CollisionType as integer
	Position as TPosition
	Position1 as TPosition
	Position2 as TPosition
	CollisionTimer as TTime
endtype

type TAnimationData
	AnimTimer as TTime
	Initialize as integer
	Uninitialize as integer
	Animating as integer
	Frame as integer
	FrameStep as integer
	FrameMin as integer
	FrameMax as integer
	FrameAlignment as integer
	RepeatAnimation as integer
	Finished as integer
endtype

type TProtoJetfire
	AnimJetfire as TProtoData
endtype

type TJetfire
	Enabled as integer
	ObjectData as TObjectData
	SpriteData as TSpriteData
	EffectData as TEffectData
endtype

type TJetfireList
	FirstFree as integer
	Jetfire as TJetfire[-1]
	CreateTimer as TTime
endtype

type TProtoEnergie
	AnimEnergie as TProtoData[-1]
endtype

type TEnergie
	Enabled as integer
	ObjectData as TObjectData
	SpriteData as TSpriteData
	EffectData as TEffectData
	IsAttracted as integer
	Value as integer
	EnergieType as integer
endtype

type TEnergieList
	FirstFree as integer
	Energie as TEnergie[-1]
	CreateTimer as TTime
endtype

type TProtoShield
	AnimShield as TProtoData
endtype

type TEnergyShield
	DamageTrailAmount as float
	DamageTrailStartMs as integer
	DamageTrailEndMs as integer
	ShieldTimer as TTime
	State as integer
	StateMax as integer
	StateChange as integer
endtype

type TShield
	SizeMultiplier as float
	LastDamageMs as integer
	DamageCooldownActive as integer
	ShapeTestChecks as integer
	ShapeTestHits as integer
	ShapeTestRadiusHits as integer
	ShapeTestOnlyHits as integer
	ShapeTestRadiusOnlyHits as integer
	Enabled as integer
	ObjectData as TObjectData
	SpriteData as TSpriteData
	AnimationData as TAnimationData
endtype

type TProtoInenergie
	AnimInEnergie as TProtoData
endtype

type TInenergie
	Enabled as integer
	ObjectData as TObjectData
	SpriteData as TSpriteData
	AnimationData as TAnimationData
endtype

type TObjectState
	Fly as integer
	Hover as integer
	Fall as integer
	Stand as integer
	Duck as integer
	Move as integer
	Jump as integer
	Alignment as integer
	LookAlignment as integer
endtype

type TProtoOrb
	AnimOrb as TProtoData
endtype
	
type TOrb
	FlameTargetId as integer
	Enabled as integer
	ObjectData as TObjectData
	YShift as TYShift
	SpriteData as TSpriteData
	Health as THealth
	CollisionData as TCollisionData
endtype

type TOrbList
	FirstFree as integer
	Orb as TOrb[-1]
	CreateTimer as TTime
endtype

type TProtoMine
	AnimMine as TProtoData
endtype
	
type TMine
	FlameTargetId as integer
	Enabled as integer
	ObjectData as TObjectData
	YShift as TYShift
	SpriteData as TSpriteData
	Health as THealth
	CollisionData as TCollisionData
endtype

type TMineList
	FirstFree as integer
	Mine as TMine[-1]
	CreateTimer as TTime
endtype

type TProtoWalkerAnimation
	Tower as TProtoData
	Corpus as TProtoData
	Thigh as TProtoData
	Shank as TProtoData
	Socket as TProtoData
	Barrel as TProtoData
endtype

type TProtoWalker
	AnimRight as TProtoWalkerAnimation
	AnimLeft as TProtoWalkerAnimation
endtype

type TWalkerObjectData
	Tower as TObjectData
	Corpus as TObjectData
	Thigh as TObjectData[1]
	Shank as TObjectData[1]
	Socket as TObjectData[1]
	Barrel as TObjectData[1]
endtype

type TWalkerSpriteData
	Tower as TSpriteData
	Corpus as TSpriteData
	Thigh as TSpriteData[1]
	Shank as TSpriteData[1]
	Socket as TSpriteData[1]
	Barrel as TSpriteData[1]
endtype

type TWalkerCollisionData
	Tower as TCollisionData
	Corpus as TCollisionData
	Thigh as TCollisionData[1]
	Shank as TCollisionData[1]
	Socket as TCollisionData[1]
	Barrel as TCollisionData[1]
endtype

type TWalker
	FlameTargetId as integer
	PlateIndex as integer
	PlateOffsetX as float
	PlateOffsetY as float
	WalkPhase as float
	TurnPending as integer
	SkeletonFootX as float[1]
	SkeletonFootY as float[1]
	SkeletonFootStartX as float[1]
	SkeletonFootTargetX as float[1]
	SkeletonSwing as integer[1]
	SkeletonDebugIK as float
	SkeletonDebugProto as float
	SkeletonDebugSprite as float
	SkeletonDebugShankIK as float
	SkeletonDebugShankSprite as float
	NextPauseMs as integer
	PauseUntilMs as integer
	FireTimer as TTime
	FireState as integer
	FireStateUntilMs as integer
	// One fixed aim angle per burst; improve slowly while the target stays in view.
	AimAngle as float
	AimActive as integer
	AimSalvos as integer
	// Independent projected turret swivel around the Corpus offset.
	TurretSwivelActive as integer
	TurretSwivelFrom as integer
	TurretSwivelTo as integer
	TurretSwivelStartMs as integer
	TurretWidthScale as float
	// Independent additive barrel recoil, leaving all neutral pivots intact.
	BarrelRecoilActive as integer[1]
	BarrelRecoilStartMs as integer[1]
	BarrelRecoilAngle as float[1]
	BarrelRecoilDistance as float[1]
	TowerRecoilActive as integer
	TowerRecoilStartMs as integer
	TowerRecoilAngle as float
	TowerRecoilDistance as float
	Enabled as integer
	ObjectData as TObjectData
	CollisionData as TCollisionData
	WalkerObjectData as TWalkerObjectData
	WalkerSpriteData as TWalkerSpriteData
	WalkerCollisionData as TWalkerCollisionData
	HitFlashUntil as integer
	AnimationData as TAnimationData
	Health as THealth	
	State as TObjectState
endtype

type TWalkerList
	FirstFree as integer
	Walker as TWalker[-1]
	CreateTimer as TTime
endtype

type TProtoSonecAnimation
	AnimWalk as TProtoData[-1]
	Stand as TProtoData
	Fly as TProtoData
	Duck as TProtoData
endtype

type TProtoSonec
	AnimRight as TProtoSonecAnimation
	AnimLeft as TProtoSonecAnimation
endtype
	
type TEnergy
	State as integer
	StateMax as integer
	AttractTimer as TTime
	RegenerationTimer as TTime
	RegRate as integer
endtype

type THealth
	State as integer
	StateMax as integer
	RegenerationTimer as TTime
	RegRate as integer
endtype

type TBulletData
	BulletType as integer
	Damage as integer
endtype

type TProtoBullet
	AnimBullet as TProtoData
endtype

// Immutable launch snapshot for detached projectiles; live for attached plasma.
type TWeaponDepth
    ExcludedPlateIds as integer[-1]
    ExcludedBackgroundIds as integer[-1]
endtype

type TBullet
    WeaponDepth as TWeaponDepth
	OutsideWorld as integer
	SonecSweepStartMs as integer
	SonecSweepEndMs as integer
	SonecSweepReady as integer
	Enabled as integer
	Modification as integer
	ExplodeAtMs as integer
	// K1: starting position of the most recent movement step (world coordinates).
	PreviousPosition as TPosition
	ObjectData as TObjectData
	SpriteData as TSpriteData
	BulletData as TBulletData
	CollisionData as TCollisionData
endtype

type TBulletList
	FirstFree as integer
	Bullet as TBullet[-1]
endtype

type TProtoGrenade
	AnimGrenade as TProtoData
endtype

type TGrenade
    WeaponDepth as TWeaponDepth
	SweepStartMs as integer
	SweepEndMs as integer
	PreviousPosition as TPosition
	Enabled as integer
	ObjectData as TObjectData
	SpriteData as TSpriteData
	BulletData as TBulletData
	CollisionData as TCollisionData
endtype

type TGrenadeList
	FirstFree as integer
	Grenade as TGrenade[-1]
endtype

type TProtoFlash
	AnimFlash as TProtoData[-1]
endtype

type TFlash
	Enabled as integer
	ObjectData as TObjectData
	SpriteData as TSpriteData
	EffectData as TEffectData
	FlashAnimIndex as integer
	AttachedWalkerIndex as integer
	AttachedBarrelIndex as integer
endtype

type TFlashList
	FirstFree as integer
	Flash as TFlash[-1]
endtype

type TMGun
	FireTimer as TTime
	FlashIndex as integer
	Ammo as integer
	AmmoMax as integer
	FireRate as integer
	FireBurstTimer as TTime
	FireBurst as integer
	FireBurstMax as integer
	FireBurstLimit as integer
	FireBurstRate as integer
endtype

type TGrenadeLauncher
	FireTimer as TTime
	Ammo as integer
	AmmoMax as integer
	FireRate as integer
endtype

type TProtoPlasmaBlitz
	AnimPlasmaBlitz as TProtoData
endtype

type TPlasmaBlitz
    WeaponDepth as TWeaponDepth
	CreatedMs as integer
	Enabled as integer
	ObjectData as TObjectData
	SpriteData as TSpriteData
	BulletData as TBulletData
	EffectData as TEffectData
	CollisionData as TCollisionData
endtype

type TPlasmaBlitzList
	FirstFree as integer
	PlasmaBlitz as TPlasmaBlitz[-1]
endtype

type TPlasmaBlitzGun
	FireTimer as TTime
	UploadTimer as TTime
	FlashIndex as integer
	FireRate as float
	UploadRate as float
	UploadMax as integer
	Upload as integer
	PlasmaBlitzIndex as integer
endtype

type TProtoFlame
	AnimFlame as TProtoData
endtype

type TFlameHit
	TargetId as integer
	NextHitMs as integer
endtype

type TFlame
    WeaponDepth as TWeaponDepth
	PreviousPosition as TPosition
	SweepStartMs as integer
	SweepEndMs as integer
	HitList as TFlameHit[-1]
	Enabled as integer
	ObjectData as TObjectData
	SpriteData as TSpriteData
	EffectData as TEffectData
	BulletData as TBulletData
	CollisionData as TCollisionData
endtype

type TFlameList
	FirstFree as integer
	Flame as TFlame[-1]
	CreateTimer as TTime
endtype

type TFlameGun
	FireTimer as TTime
endtype

// Phase B: shared candidate, Kind: 1 top, 2 side, 3 pass entry, 4 support exit.
type TSonecContactCandidate
	Kind as integer
	HitSide as integer
	HitOffsetX as float
	HitPositionX as float
	Valid as integer
	ContactTime as float
	ListType as integer
	Index as integer
endtype

type TSonec
	DebugCsvMoveStartVX as float
	DebugCsvMoveAfterHorizontalVX as float
	DebugCsvMoveStartX as float
	DebugCsvMoveStartY as float
	DebugCsvPreCollisionVX as float
	DebugCsvPreCollisionVY as float
	DebugCsvPostCollisionVX as float
	DebugCsvPostCollisionVY as float
	DebugCsvHopPreVX as float
	DebugCsvHopPreVY as float
	DebugCsvHopPostVX as float
	DebugCsvHopPostVY as float
	DebugCsvHopChestLeft as float
	DebugCsvHopChestRight as float
	DebugCsvHopChestIndex as integer
	DebugEdgePending as integer
	DebugEdgeCollisionStartX as float
	DebugEdgeCollisionEndX as float
	DebugEdgeEvent as integer
	DebugEdgeChestX as float
	DebugEdgeChestSpeedX as float
	DebugEdgeBeforeBalanceX as float
	DebugEdgeAfterBalanceX as float
	CollisionSegmentStartTime as float
	GroundContactActive as integer
	NormalJumpActive as integer
	JumpCorrectionDirection as integer
	UpInputHeld as integer
	UpHoldStartMs as integer
	UpJumpHoldPending as integer
	AirThrustDirection as integer
	JetstreamRequested as integer
	JetstreamPreviousValid as integer
	JetstreamPreviousPosition as TPosition
	JetstreamPreviousMs as integer
	JetstreamPreviousNozzleX as float
	DebugTopTrace as string
	PassThroughChestIndex as integer
	LinkedPlateIndex as integer
	// Last valid linked deck height, retained after horizontal unlink.
	LandingReferenceValid as integer
	LandingReferenceY as float
	BlockedChestIndex as integer
	BlockedChestSide as integer
	BlockedChestOffsetX as float
	CollisionMoveStart as TPosition
	CollisionMoveEnd as TPosition
    SpawnEntering as integer
	BalanceActive as integer
	BalanceTargetX as float
	ObjectData as TObjectData
	SpriteData as TSpriteData
	State as TObjectState
	CollisionData as TCollisionData
	AnimationData as TAnimationData
	InputTimer as TTime
	InputActionTimer as TTime
	IsLost as integer
	EnergyShield as TEnergyShield
	Energy as TEnergy
	Health as THealth
	MGun as TMGun
	GrenadeLauncher as TGrenadeLauncher
	PlasmaBlitzGun as TPlasmaBlitzGun
	FlameGun as TFlameGun
endtype

type TProtoPlate
	AnimPlate as TProtoData[-1]
endtype
	
type TPlate
    WeaponDepthId as integer
	// Mechanical depth state for the single player: 0 neutral, 1 passage, 2 cleared.
	SonecDepthState as integer
	CollisionMoveStart as TPosition
	Enabled as integer
	ProtoIndex as integer
	ObjectData as TObjectData
	YShift as TYShift
	SpriteData as TSpriteData
	CollisionData as TCollisionData
	// F1 platform diagnostics only. These fields never affect movement.
	DebugDeltaX as float
	DebugDeltaY as float
	DebugCalcRange as float
	DebugElapsedMs as integer
	DebugUpdated as integer
	// Rolling history of the last 60 GameDo frames (including frames with no timer step).
	DebugFrameMs as integer
	DebugLastNow as integer
	DebugHistoryDX as float[59]
	DebugHistoryFrameMs as integer[59]
	DebugHistoryStep as integer[59]
	DebugHistoryCount as integer
	DebugHistoryNext as integer
endtype

type TPlateList
	FirstFree as integer
	Plate as TPlate[-1]
	CreateTimer as TTime
endtype

type TProtoChest
	AnimChest as TProtoData
endtype

type TChest
	FlameTargetId as integer
	// Background chests retain damage geometry but are not Sonec supports.
	IsBackground as integer
	// Resolver-only: 0 ordinary chest, 1 lower base step, 2 upper base step.
	MechanicalStepLevel as integer
	CollisionMoveStart as TPosition
	Enabled as integer
	CollisionData as TCollisionData
	ObjectData as TObjectData
	SpriteData as TSpriteData
	Health as THealth
endtype

type TChestList
	FirstFree as integer
	Chest as TChest[-1]
	CreateTimer as TTime
endtype

type TProtoExplosion
	AnimExplosion as TProtoData[-1,-1]
endtype

type TExplosion
    CompositeUpperVisual as integer
    ImpactPlateIndex as integer
    ImpactPlateLastX as float
    ImpactPlateLastY as float
    ImpactPlateLeftX as float
    ImpactPlateRightX as float
    LimitDamageBelowY as integer
    DamageMaxY as float
	LastDroneHitMs as integer
	LastSonecHitMs as integer
	LastChestHitMs as integer[-1]
	LastOrbHitMs as integer[-1]
	LastMineHitMs as integer[-1]
	// E1b: simple mine pool uses independent indices and a separate cooldown.
	LastSimpleMineHitMs as integer[-1]
	LastWalkerHitMs as integer[-1]
    LastFlarakHitMs as integer[-1]
    LastFlarakTargetId as integer[-1]
    LastJumppodHitMs as integer[-1]
	MeasureStartMs as integer
	MeasureChecks as integer
	MeasureHits as integer
	MeasureDamage as integer
	MeasureChestHits as integer
	MeasureOrbHits as integer
	MeasureMineHits as integer
	Enabled as integer
	ExplosionType as integer
	ObjectData as TObjectData
	SpriteData as TSpriteData
	CollisionData as TCollisionData
	AnimationData as TAnimationData
	BulletData as TBulletData
endtype

type TExplosionList
	FirstFree as integer
	Explosion as TExplosion[-1]
endtype

type TProtoTower
	AnimSmallTower as TProtoData[-1]
	AnimTower as TProtoData[-1]
endtype

type TTowerPart
	ObjectData as TObjectData
	SpriteData as TSpriteData
	TowerType as integer
	TowerIndex as integer
endtype

type TTower
	Enabled as integer
	TowerType as integer
	TowerPart as TTowerPart[-1]
	ObjectData as TObjectData
	// F2 measurements only; never used in tower movement or rendering.
	DebugDeltaX as float
	DebugCalcRange as float
	DebugElapsedMs as integer
	DebugUpdated as integer
	DebugFrameMs as integer
	DebugLastNow as integer
	DebugHistoryDX as float[59]
	DebugHistoryFrameMs as integer[59]
	DebugHistoryStep as integer[59]
	DebugHistoryCount as integer
	DebugHistoryNext as integer
endtype

type TTowerList
	FirstFree as integer
	Tower as TTower[-1]
	CreateTimer as TTime
endtype

type TProtoBackground
	AnimSky as TProtoData
endtype

type TBackground
	SpriteData as TSpriteData
	ObjectData as TObjectData
endtype

type TProtoCloud
	AnimCloud as TProtoData[-1]
endtype

type TCloud
	Enabled as integer
	CloudType as integer
	SpriteData as TSpriteData
	ObjectData as TObjectData
endtype

type TCloudList
	FirstFree as integer
	Cloud as TCloud[-1]
	CreateTimer as TTime
endtype

type TWorldObjects
	Position as TPosition
	ListType as integer
	ListIndex as integer
endtype

type TWorld
	Position as TPosition
	Size as TSize
	Objects as TWorldObjects[40,32]
endtype

type TGui

	bar_horizontal as TProtoData
	bar_horizontal_small as TProtoData
	bar_horizontal_grenade_small as TProtoData
	bar_vertical as TProtoData
	bar_vertical_small as TProtoData
	
endtype

type TSound
	MGunSound as integer
	GrenadeLauncherSound as integer
	MFlameSound as integer
	MenuSound as integer
	SelectSound as integer
	ImpactSound as integer
	ExplodeSound as integer
	ExplosionSound as integer
endtype

type TNotice
    MessageString as string
    Kind as integer
    UntilMs as integer
    PreviewUntilMs as integer
    DurationMs as integer
    RepeatCount as integer
    TextID as integer
    BarSpriteID as integer
endtype

type TWarning
    Count as integer
    OverflowCount as integer
    Notice as TNotice[63]
    Icon as TProtoData
    IconData as TSpriteData
    StarIcon as TProtoData
    StarData as TSpriteData
    CenterX as float
    Now as integer
    PickupStarStartMs as integer
    PickupStarUntilMs as integer
    SlideStartMs as integer
    RepeatStartMs as integer
    OutUntilMs as integer
    OutMessage as string
    OutKind as integer
    OutBarSpriteID as integer
    OutTextID as integer
    RepeatSpriteID as integer
endtype

// D1: one persistent unarmed hover drone; no collisions or attack logic yet.
type TProtoDrone
    Left as TProtoData
    Center as TProtoData
    Right as TProtoData
    Torso as TProtoData
    SensorLeft as TProtoData
    SensorCenter as TProtoData
    SensorRight as TProtoData
    ScanLeft as TProtoData
    ScanRight as TProtoData
    ChargeLeft as TProtoData
    ChargeRight as TProtoData
    Laser as TProtoData
endtype

type TDrone
	FlameTargetId as integer
    Health as THealth
    Enabled as integer
    Direction as integer
    IsTurning as integer
    TurnUntilMs as integer
    LastMoveMs as integer
    Position as TPosition
    SpriteData as TSpriteData
endtype

// B1: a single spacejet, with a temporary one-pass test scheduler.
type TProtoBomber
    Body as TProtoData
    Bomb as TProtoData
endtype

type TBomberBomb
    SweepStartMs as integer
    Enabled as integer
    Position as TPosition
    PreviousPosition as TPosition
    Velocity as TPosition
    LastMoveMs as integer
    SpriteData as TSpriteData
endtype

type TBomber
	FlameTargetId as integer
    Enabled as integer
    Health as integer
    HitFlashUntil as integer
    LastPlasmaHitMs as integer
    Phase as integer
    NextWarningMs as integer
    SpawnAtMs as integer
    LastMoveMs as integer
    NextJetMs as integer
    LastJetX as float
    Position as TPosition
    SpriteData as TSpriteData
    BombCount as integer
    NextBombAtMs as integer
    Bomb as TBomberBomb[4]
endtype

type TGame
	DebugText as integer[-1]
	
	Screen as TSize
	
	JoystickIndex as integer
	
	Sound as TSound
	
	ProtoJetfire as TProtoJetfire
	ProtoSonec as TProtoSonec
	ProtoWalker as TProtoWalker
	ProtoPlate as TProtoPlate
	ProtoChest as TProtoChest
	ProtoTower as TProtoTower
	ProtoBackground as TProtoBackground
	ProtoCloud as TProtoCloud
	ProtoInenergie as TProtoInenergie
	ProtoEnergie as TProtoEnergie
	ProtoShield as TProtoShield
	ProtoFlame as TProtoFlame
	ProtoBullet as TProtoBullet
	ProtoGrenade as TProtoGrenade
	ProtoFlash as TProtoFlash
	ProtoPlasmaBlitz as TProtoPlasmaBlitz
	ProtoOrb as TProtoOrb
	ProtoMine as TProtoMine
	ProtoSimpleMine as TProtoMine
	ProtoDrone as TProtoDrone
	ProtoBomber as TProtoBomber
	ProtoExplosion as TProtoExplosion
	
	WalkerList as TWalkerList
	OrbList as TOrbList
	MineList as TMineList
	SimpleMineList as TMineList
	SimpleMineNextSpawnMs as integer
	Drone as TDrone
	Bomber as TBomber
	Shield as TShield
	Inenergie as TInenergie
	Sonec as TSonec
	FlameList as TFlameList
	BulletList as TBulletList
	GrenadeList as TGrenadeList
	PlasmaBlitzList as TPlasmaBlitzList
	FlashList as TFlashList
	JetfireList as TJetfireList
	EnergieList as TEnergieList
	PlateList as TPlateList
	ChestList as TChestList
	TowerList as TTowerList
	Background as TBackground
	CloudList as TCloudList
	ExplosionList as TExplosionList
	
	World as TWorld
	
	IsPause as integer
	IsLost as integer
    TouchdownUntilMs as integer
    TouchdownNowMs as integer
    TouchdownStarted as integer
	
	Gui as TGui
	Warning as TWarning
	
endtype

type TMenuOrb
    Red as integer
    Green as integer
    Blue as integer
    Enabled as integer
    X as float
    Y as float
    Speed as float
    Size as float
    SpeedX as float
    NextSteerMs as integer
endtype

type TMenuPaint
    Frame as integer
    X as float
    Y as float
    Size as float
    Red as integer
    Green as integer
    Blue as integer
    Drip1Length as float
    Drip2Length as float
    Drip1Max as float
    Drip2Max as float
    Drip1X as float
    Drip2X as float
    DripY as float
    Drip1Width as float
    Drip2Width as float
endtype

type TIntro
    PaintSpriteID as integer
    PaintDripSpriteID as integer
    PaintTipSpriteID as integer
    PaintImageID as integer
    OrbImageID as integer
    OrbSpriteID as integer
    Paint as TMenuPaint[-1]
    Orbs as TMenuOrb[7]
    NextOrbMs as integer
    LastPaintFrame as integer
    MenuWidth as integer
    MenuHeight as integer
	ProtoBackground as TProtoData
	Background as TBackground
	TextStart as integer
	TextOption as integer
	TextEnd as integer
	TextHelp as integer
	TextOptionsTitle as integer
	TextOptionsEntry1 as integer
	TextOptionsEntry2 as integer
	TextOptionsEntry3 as integer
	TextOptionsEntry4 as integer
	TextKeyboardLabel as integer[10]
	TextKeyboardKey as integer[10]
	TextCapturePrompt as integer
	TextCaptureCancel as integer
	KeyboardCapture as integer
	KeyboardCaptureArmed as integer
	KeyboardCaptureAction as integer
	KeyboardCenterX as integer
	KeyboardCenterY as integer
	SelctionPos as integer
	OptionSelectionPos as integer
	OptionPage as integer
	AnalogMenuHeld as integer
	IsOption as integer
	IsQuit as integer
	TimerHelp as TTime
endtype

