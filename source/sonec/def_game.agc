
#constant MOVELEFT 0
#constant MOVERIGHT 1

#constant LOOKLEFT 0
#constant LOOKRIGHT 1

#constant MOVEDOWN 0
#constant MOVEUP 1

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
	ShieldTimer as TTime
	State as integer
	StateMax as integer
	StateChange as integer
endtype

type TShield
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
endtype

type TProtoWalker
	AnimRight as TProtoWalkerAnimation
	AnimLeft as TProtoWalkerAnimation
endtype

type TWalkerObjectData
	Tower as TObjectData
	Corpus as TObjectData
	Thigh as TObjectData
	Shank as TObjectData
	Socket as TObjectData
endtype

type TWalkerSpriteData
	Tower as TSpriteData
	Corpus as TSpriteData
	Thigh as TSpriteData
	Shank as TSpriteData
	Socket as TSpriteData
endtype

type TWalkerCollisionData
	Tower as TCollisionData
	Corpus as TCollisionData
	Thigh as TCollisionData
	Shank as TCollisionData
	Socket as TCollisionData
endtype

type TWalker
	Enabled as integer
	ObjectData as TObjectData
	CollisionData as TCollisionData
	WalkerObjectData as TWalkerObjectData
	WalkerSpriteData as TWalkerSpriteData
	WalkerCollisionData as TWalkerCollisionData
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

type TBullet
	Enabled as integer
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

type TFlame
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

type TSonec
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
	Enabled as integer
	ProtoIndex as integer
	ObjectData as TObjectData
	YShift as TYShift
	SpriteData as TSpriteData
	CollisionData as TCollisionData
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

type TGame
	
	Screen as TSize
	
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
	ProtoExplosion as TProtoExplosion
	
	WalkerList as TWalkerList
	OrbList as TOrbList
	MineList as TMineList
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
	
	Gui as TGui
	
endtype

type TIntro
	ProtoBackground as TProtoData
	Background as TBackground
	TextStart as integer
	TextOption as integer
	TextEnd as integer
	TextHelp as integer
	SelctionPos as integer
	IsOption as integer
	IsQuit as integer
	TimerHelp as TTime
endtype

