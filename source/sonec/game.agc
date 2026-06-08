
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameCreate(Game ref as TGame,vx as integer,vy as integer)
	
	Game.Screen.Width = vx
	Game.Screen.Height = vy
	
	GameProtoLoad(Game)
	
	SoundLoad(Game.Sound)
	
	Game.IsLost = TRUE
	Game.IsPause = FALSE
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameProtoLoad(Game ref as TGame)

	local File as TFilePath

	File.Path = "/media/data"
	
	File.Name = "protobackground.json"
	ProtoBackgroundLoad(Game.ProtoBackground,File)
	
	File.Name = "protocloud.json"
	ProtoCloudLoad(Game.ProtoCloud,File)
	
	File.Name = "prototower.json"
	ProtoTowerLoad(Game.ProtoTower,File)
	
	File.Name = "protoplate.json"
	ProtoPlateLoad(Game.ProtoPlate,File)
	
	File.Name = "protochest.json"
	ProtoChestLoad(Game.ProtoChest,File)
	
	File.Name = "protosonec.json"
	ProtoSonecLoad(Game.ProtoSonec,File)

	File.Name = "protojetfire.json"
	ProtoJetfireLoad(Game.ProtoJetfire,File)
	
	File.Name = "protoenergie.json"
	ProtoEnergieLoad(Game.ProtoEnergie,File)
	
	File.Name = "protoflame.json"
	ProtoFlameLoad(Game.ProtoFlame,File)
	
	File.Name = "protobullet.json"
	ProtoBulletLoad(Game.ProtoBullet,File)
	
	File.Name = "protogrenade.json"
	ProtoGrenadeLoad(Game.ProtoGrenade,File)
	
	File.Name = "protoplasmablitz.json"
	ProtoPlasmaBlitzLoad(Game.ProtoPlasmaBlitz,File)
	
	File.Name = "protoflash.json"
	ProtoFlashLoad(Game.ProtoFlash,File)
	
	File.Name = "protoshield.json"
	ProtoShieldLoad(Game.ProtoShield,File)
	
	File.Name = "protoinenergie.json"
	ProtoInenergieLoad(Game.ProtoInenergie,File)
	
	File.Name = "protoorb.json"
	ProtoOrbLoad(Game.ProtoOrb,File)
	
	File.Name = "protomine.json"
	ProtoMineLoad(Game.ProtoMine,File)
	
	File.Name = "protowalker.json"
	ProtoWalkerLoad(Game.ProtoWalker,File)
	
	GuiImagesLoad(Game.Gui)
	
	ProtoExplosionLoad(Game.ProtoExplosion)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameInit(Game ref as TGame,Now as integer)

	local Position as TPosition

	Game.IsPause = FALSE
	Game.IsLost = FALSE

	WorldInit(Game.World,Game.ProtoBackground,Game.Screen)
	TowerInit(Game.TowerList)
	BackgroundInit(Game.Background,Game.Screen)
	CloudInit(Game.CloudList,Game.ProtoCloud,Game.World,Now)
	PlateInit(Game.PlateList)
	ChestInit(Game.ChestList)
	JetfireInit(Game.JetfireList)
	EnergieInit(Game.EnergieList)
	SonecInit(Game.Sonec,Game.ProtoSonec,Game.World,Game.Screen,Now)
	ShieldReset(Game.Shield,250,Now)
	ShieldRefresh(Game.Shield,Game.World,Game.Sonec.ObjectData.Position,Now)
	InenergieReset(Game.Inenergie,Now)
	InenergieRefresh(Game.Inenergie,Game.World,Game.Sonec.ObjectData.Position,Now)
	OrbInit(Game.OrbList)
	MineInit(Game.MineList)
	WalkerInit(Game.WalkerList)
	ExplosionInit(Game.ExplosionList)
	FlashInit(Game.FlashList)
	BulletInit(Game.BulletList)
	GrenadeInit(Game.GrenadeList)
	FlameInit(Game.FlameList)
	PlasmaBlitzInit(Game.PlasmaBlitzList)
	
	//Position.x = 200
	//Position.y = 200
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameInput(Game ref as TGame,Now as integer)

	SonecInput(Game.Sonec,Game.JetfireList,Game.ProtoJetfire,Game.World,Now)
	
	if GetRawJoystickButtonPressed(1,joystickButtonBack) = 1
		Game.IsLost = TRUE
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameActionInput(Game ref as TGame,Now as integer)

	SonecFlameGunInput(Game.Sonec,Game.FlameList,Game.ProtoFlame,Game.World,Game.Sound,Now)
	SonecPlasmaBlitzGunInput(Game.Sonec,Game.FlashList,Game.ProtoFlash,Game.PlasmaBlitzList,Game.ProtoPlasmaBlitz,Game.World,Now)
	SonecMGunInput(Game.Sonec,Game.FlashList,Game.ProtoFlash,Game.BulletList,Game.ProtoBullet,Game.World,Game.Sound,Now)
	SonecGrenadeLauncherInput(Game.Sonec,Game.GrenadeList,Game.ProtoGrenade,Game.World,Game.Sound,Now)
	SonecShieldInput(Game.Sonec,Game.Shield,Game.World,Now)
	SonecInenergieInput(Game.Sonec,Game.Inenergie,Game.EnergieList,Game.World,Now)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameDo(Game ref as TGame,Now as integer)

	local Index as integer
	local i as integer
	
	BackgroundDo(Game.Background,Game.World,Now)
	if CloudCountAll(Game.CloudList) < 50
		if random(0,10000) < 50
			CloudCreate(Game.CloudList,Game.ProtoCloud,Game.World,Now)
		endif
	endif
	CloudMoveAll(Game.CloudList,Game.World,Now)
	SonecMove(Game.Sonec,Game.World,Game.Screen,Now)
	
	
	if TowerCountAll(Game.TowerList) < 15
		if random(0,10000) < 75
			TowerAdd(Game.TowerList,Game.ProtoTower,Game.World,Now)
		endif
	endif
	
	TowerMoveAll(Game.TowerList,Game.World,Now)
	TowerCheckAll(Game.TowerList,Game.ProtoTower)
		
	if PlateCountAll(Game.PlateList) < 10
		if random(0,10000) < 35
			Index = PlateAdd(Game.PlateList,Game.ProtoPlate,Game.World,Now)
			if Index >= 0
				ChestAdd(Game.ChestList,Game.ProtoChest,Game.World,Game.PlateList.Plate[Index],Index,Now)
			endif
		endif
	endif
	
	if EnergieCountAll(Game.EnergieList) < 15
		if random(0,10000) < 15
			EnergieCreate(Game.EnergieList,Game.ProtoEnergie,Game.World,Now)
		endif
	endif
	
	if OrbCountAll(Game.OrbList) < 5
		if random(0,10000) < 15
			OrbAdd(Game.OrbList,Game.ProtoOrb,Game.World,Now)
		endif
	endif
	
	if MineCountAll(Game.MineList) < 15
		if random(0,10000) < 5
			for i = 0 to random(0,15)
				MineAdd(Game.MineList,Game.ProtoMine,Game.World,Now)
			next i
		endif
	endif
	
	if WalkerCountAll(Game.WalkerList) < 5
		if random(0,10000) < 35
			//WalkerAdd(Game.WalkerList,Game.ProtoWalker,Game.World,Now)
		endif
	endif
	
	OrbMoveAll(Game.OrbList,Game.World,Now)
	OrbHealthRegenerate(Game.OrbList,Game,Now)
	
	MineMoveAll(Game.MineList,Game.Sonec,Game.Inenergie,Game.World,Now)
	MineHealthRegenerate(Game.MineList,Game,Now)
	MineCollideSonec(Game.MineList,Game.Sonec,Game,Now)

	WalkerMoveAll(Game.WalkerList,Game.ProtoWalker,Game.World,Now)
	WalkerHealthRegenerate(Game.WalkerList,Game,Now)
		
	JetfireLifeCycle(Game.JetfireList,Now)
	EnergieMoveAll(Game.EnergieList,Game.World,Now)
	EnergieLifeCycle(Game.EnergieList,Now)
	EnergieCollect(Game.EnergieList,Game.Sonec)
	
	ExplosionMoveAll(Game.ExplosionList,Game.World,Now)
	ExplosionCollideSonec(Game.ExplosionList,Game.Sonec)
	ExplosionCollideChest(Game.ExplosionList,Game.ChestList)
	ExplosionCollideOrb(Game.ExplosionList,Game.OrbList)
	ExplosionCollideMine(Game.ExplosionList,Game.MineList)
	
	SonecEnergyRegenerate(Game.Sonec,Now)
	SonecHealthRegenerate(Game.Sonec,Now)
		
	PlateMoveAll(Game.PlateList,Game.World,Now)
	ChestMoveAll(Game.ChestList,Game.PlateList,Game.World)
	ChestCheckAll(Game.ChestList,Game.ProtoChest)
	PlateCheckAll(Game.PlateList,Game.ProtoPlate)
	ChestHealthRegenerate(Game.ChestList,Now)
	SonecCollidePlate(Game.Sonec,Game.PlateList,Game.ChestList,Game.World)
	
	FlashLifeCycle(Game.FlashList,Now)
	
	FlameLifeCycle(Game.FlameList,Now)
	FlameMoveall(Game.FlameList,Game.World,Now)
	FlameCollideOrbs(Game.FlameList,Game.OrbList)
	FlameCollideMine(Game.FlameList,Game.MineList)
	FlameCollideChest(Game.FlameList,Game.ChestList)
	
	BulletMoveall(Game.BulletList,Game.World,Now)
	BulletCollide(Game.BulletList,Game.Sonec)
	BulletCollideOrbs(Game.BulletList,Game.OrbList)
	BulletCollideMine(Game.BulletList,Game.MineList)
	BulletCollideChest(Game.BulletList,Game.ChestList)
	
	GrenadeMoveall(Game.GrenadeList,Game.World,Now)
	GrenadeCollideOrbs(Game.GrenadeList,Game.OrbList,Game,Now)
	GrenadeCollideMine(Game.GrenadeList,Game.MineList,Game,Now)
	GrenadeCollideChest(Game.GrenadeList,Game.ChestList,Game,Now)
	GrenadeCollidePlate(Game.GrenadeList,Game.PlateList,Game,Now)
	
	PlasmaBlitzLifeCycle(Game.PlasmaBlitzList,Now)
	PlasmaBlitzCollideOrbs(Game.PlasmaBlitzList,Game.OrbList,Now)
	PlasmaBlitzCollideMine(Game.PlasmaBlitzList,Game.MineList)
	PlasmaBlitzCollideChest(Game.PlasmaBlitzList,Game.ChestList)
	
	SonecRefreshAnimations(Game.Sonec,Game.PlasmaBlitzList,Game.FlashList,Game.World)
	Game.IsLost = Game.Sonec.IsLost
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameAnimate(Game ref as TGame,Now as integer)
	
	InenergieAnimate(Game.Inenergie,Now)
	SonecAnimate(Game.Sonec,Game.ProtoSonec,Now)
	ShieldAnimate(Game.Shield,Now)
	ExplosionAnimateAll(Game.ExplosionList,Game.ProtoExplosion,Now)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameDraw(Game ref as TGame)

	BackgroundDraw(Game.Background,Game.ProtoBackground)
	CloudDrawAll(Game.CloudList,Game.ProtoCloud,0.25,1)
	TowerDrawAll(Game.TowerList,Game.ProtoTower)
	
	
	
	//PlateDrawAll(Game.PlateList,Game.ProtoPlate)
	//ChestDrawAll(Game.ChestList,Game.ProtoChest)
	PlateAndChestDrawAll(Game.PlateList,Game.ProtoPlate,Game.ChestList,Game.ProtoChest)
	
	EnergieDrawAll(Game.EnergieList,Game.ProtoEnergie)
	
	OrbDrawAll(Game.OrbList,Game.ProtoOrb)
	MineDrawAll(Game.MineList,Game.ProtoMine)
	WalkerDrawAll(Game.WalkerList,Game.ProtoWalker)
	
	InenergieDraw(Game.Inenergie,Game.ProtoInenergie)
	JetfireDrawAll(Game.JetfireList,Game.ProtoJetfire)
	FlameDrawAll(Game.FlameList,Game.ProtoFlame)
	BulletDrawAll(Game.BulletList,Game.ProtoBullet)
	GrenadeDrawAll(Game.GrenadeList,Game.ProtoGrenade)
	PlasmaBlitzDrawAll(Game.PlasmaBlitzList,Game.ProtoPlasmaBlitz)
	FlashDrawAll(Game.FlashList,Game.ProtoFlash)
	SonecDraw(Game.Sonec,Game.ProtoSonec)
	ShieldDraw(Game.Shield,Game.ProtoShield)

	ExplosionDrawAll(Game.ExplosionList,Game.ProtoExplosion)

	CloudDrawAll(Game.CloudList,Game.ProtoCloud,1,1.75)

	GuiEnergyDraw(Game.Gui,Game.Sonec,Game.Screen)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------



