
#constant TOUCHDOWN_COUNTDOWN_MS 3000

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameCreate(Game ref as TGame,vx as integer,vy as integer)
	
	Game.Screen.Width = vx
	Game.Screen.Height = vy
	
	GameProtoLoad(Game)
	FlarakVisualTestCreate()
	WarningCreate(Game.Warning,Game.Screen)
	
	SetJoystickIndex(Game)
	
	SoundLoad(Game.Sound)
	
	Game.DebugText.Length = 2
	Game.DebugText[0] = CreateText("")
	SetTextPosition(Game.DebugText[0],10,35)
	SetTextSize(Game.DebugText[0],16)
	SetTextColor(Game.DebugText[0],255,255,255,255)
	Game.DebugText[1] = CreateText("")
	SetTextPosition(Game.DebugText[1],10,55)
	SetTextSize(Game.DebugText[1],16)
	SetTextColor(Game.DebugText[1],255,255,255,255)
	Game.DebugText[2] = CreateText("")
	SetTextPosition(Game.DebugText[2],10,80)
	SetTextSize(Game.DebugText[2],16)
	SetTextColor(Game.DebugText[2],255,255,255,255)
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
	
	File.Name = "protosimplemine.json"
	ProtoMineLoad(Game.ProtoSimpleMine,File)
	
	// D1: three equally sized 46x30 px drone views, stored as colored art.
	DroneProtoLoad(Game.ProtoDrone)
	BomberProtoLoad(Game.ProtoBomber)
	
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
    Game.TouchdownUntilMs = Now+TOUCHDOWN_COUNTDOWN_MS
    Game.TouchdownNowMs = Now
    Game.TouchdownStarted = FALSE

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
	MineInit(Game.SimpleMineList)
	// S3: first automatic spawn attempt occurs after 18-30 seconds of active game time.
	SimpleMineSpawnInit(Game,Now)
	DroneInit(Game.Drone,Game.Screen,Game.World,Now)
	BomberInit(Game.Bomber,Now)
	WarningReset(Game.Warning)
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

// Initialize Sonec at the countdown boundary, before the first gameplay input.
function GameTouchdownStart(Game ref as TGame,Now as integer)
    if Game.TouchdownStarted = FALSE and Now >= Game.TouchdownUntilMs
        SonecInit(Game.Sonec,Game.ProtoSonec,Game.World,Game.Screen,Now)
        ShieldRefresh(Game.Shield,Game.World,Game.Sonec.ObjectData.Position,Now)
        InenergieRefresh(Game.Inenergie,Game.World,Game.Sonec.ObjectData.Position,Now)
        WarningReset(Game.Warning)
        Game.TouchdownStarted = TRUE
    endif
endfunction

function GameInput(Game ref as TGame,Keys ref as TKeys,Options ref as TGameOptions,Now as integer)

	if Now < Game.TouchdownUntilMs then exitfunction
    GameTouchdownStart(Game,Now)
	SonecInput(Game.Sonec,Game.JetfireList,Game.ProtoJetfire,Game.World,Keys,Options,Game.JoystickIndex,Now)
	// Back/Select is handled only while paused in main.agc.

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameActionInput(Game ref as TGame,Keys ref as TKeys,Now as integer)

	if Now < Game.TouchdownUntilMs then exitfunction
    GameTouchdownStart(Game,Now)
	SonecFlameGunInput(Game.Sonec,Game.FlameList,Game.ProtoFlame,Game.World,Game.Sound,Keys,Game.JoystickIndex,Now)
	SonecPlasmaBlitzGunInput(Game.Sonec,Game.FlashList,Game.ProtoFlash,Game.PlasmaBlitzList,Game.ProtoPlasmaBlitz,Game.World,Keys,Game.JoystickIndex,Now)
	SonecMGunInput(Game.Sonec,Game.FlashList,Game.ProtoFlash,Game.BulletList,Game.ProtoBullet,Game.World,Game.Sound,Keys,Game.JoystickIndex,Now)
	SonecGrenadeLauncherInput(Game.Sonec,Game.GrenadeList,Game.ProtoGrenade,Game.World,Game.Sound,Keys,Game.JoystickIndex,Now)
	SonecShieldInput(Game.Sonec,Game.Shield,Game.World,Keys,Game.JoystickIndex,Now)
	SonecInenergieInput(Game.Sonec,Game.Inenergie,Game.EnergieList,Game.World,Keys,Game.JoystickIndex,Now)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// D-R3 temporary diagnostic: append one simulation frame to the AGK app-local CSV.
function SonecEdgeCsvWrite(Game ref as TGame,Now as integer)
	local FileID as integer
	local CsvPath as TFilePath
	local EventCode as integer
	local ChestIndex as integer
	local ChestX as float
	local ChestVx as float
	local CsvRow as string
	local PlateX as float
	local PlateVx as float
	local PlateIndex as integer

	if GAME_DEBUG_ENABLED = 0
		exitfunction
	endif

	// FilePathSetAndCheck sets the app-local root even for a new file.
	CsvPath.Path = "/"
	CsvPath.Name = ""
	FilePathSetAndCheck(CsvPath)

	if SonecEdgeCsvStarted = FALSE
		FileID = OpenToWrite("sonec_edge_diagnostics.csv",0)
		if FileID = 0
			exitfunction
		endif
		WriteLine(FileID,"time_ms,event,x,y,vx,vy,carry_x,balance_active,balance_target_x,balance_dx,collision_start_x,collision_end_x,chest_index,chest_x,chest_vx,stand,fall,fly,move,ground_contact,linked_plate,support_type,support_index,hop_impulse_y,move_start_x,move_start_y,pre_collision_vx,pre_collision_vy,post_collision_vx,post_collision_vy,hop_pre_vx,hop_pre_vy,hop_post_vx,hop_post_vy,hop_chest_index,hop_chest_left,hop_chest_right,alignment,world_x,screen_x,plate_x,plate_vx,move_start_vx,after_horizontal_vx,normal_jump,air_thrust_direction,top_contact_trace")
		CloseFile(FileID)
		SonecEdgeCsvStarted = TRUE
	endif

	EventCode = 0
	if Game.Sonec.DebugEdgePending = TRUE
		EventCode = Game.Sonec.DebugEdgeEvent
	endif

	ChestIndex = -1
	ChestX = 0
	ChestVx = 0
	if Game.Sonec.CollisionData.ListType = TYPECHEST
		ChestIndex = Game.Sonec.CollisionData.Index
	endif
	if ChestIndex >= 0 and ChestIndex <= Game.ChestList.Chest.Length
		if Game.ChestList.Chest[ChestIndex].Enabled = TRUE
			ChestX = Game.ChestList.Chest[ChestIndex].ObjectData.Position.x
			ChestVx = Game.ChestList.Chest[ChestIndex].ObjectData.MoveSpeed.x
		endif
	else
		ChestIndex = -1
	endif

	PlateX = 0
	PlateVx = 0
	PlateIndex = Game.Sonec.LinkedPlateIndex
	if PlateIndex >= 0 and PlateIndex <= Game.PlateList.Plate.Length
		if Game.PlateList.Plate[PlateIndex].Enabled = TRUE
			PlateX = Game.PlateList.Plate[PlateIndex].ObjectData.Position.x
			PlateVx = Game.PlateList.Plate[PlateIndex].ObjectData.MoveSpeed.x
		endif
	endif

	CsvRow = Str(Now)+","+Str(EventCode)+","+Str(Game.Sonec.ObjectData.Position.x)+","+Str(Game.Sonec.ObjectData.Position.y)+","+Str(Game.Sonec.ObjectData.MoveSpeed.x)+","+Str(Game.Sonec.ObjectData.MoveSpeed.y)+","+Str(Game.Sonec.ObjectData.AutoSpeed.x)
	CsvRow = CsvRow+","+Str(Game.Sonec.BalanceActive)+","+Str(Game.Sonec.BalanceTargetX)+","+Str(Game.Sonec.DebugEdgeAfterBalanceX-Game.Sonec.DebugEdgeBeforeBalanceX)+","+Str(Game.Sonec.DebugEdgeCollisionStartX)+","+Str(Game.Sonec.DebugEdgeCollisionEndX)
	CsvRow = CsvRow+","+Str(ChestIndex)+","+Str(ChestX)+","+Str(ChestVx)+","+Str(Game.Sonec.State.Stand)+","+Str(Game.Sonec.State.Fall)+","+Str(Game.Sonec.State.Fly)+","+Str(Game.Sonec.State.Move)+","+Str(Game.Sonec.GroundContactActive)+","+Str(Game.Sonec.LinkedPlateIndex)
	CsvRow = CsvRow+","+Str(Game.Sonec.CollisionData.ListType)+","+Str(Game.Sonec.CollisionData.Index)
	if EventCode = 3 or EventCode = 4
		CsvRow = CsvRow+","+Str(-SONEC_MINI_HOP_IMPULSE_Y)
	else
		CsvRow = CsvRow+",0"
	endif

	CsvRow = CsvRow+","+Str(Game.Sonec.DebugCsvMoveStartX)+","+Str(Game.Sonec.DebugCsvMoveStartY)+","+Str(Game.Sonec.DebugCsvPreCollisionVX)+","+Str(Game.Sonec.DebugCsvPreCollisionVY)+","+Str(Game.Sonec.DebugCsvPostCollisionVX)+","+Str(Game.Sonec.DebugCsvPostCollisionVY)
	CsvRow = CsvRow+","+Str(Game.Sonec.DebugCsvHopPreVX)+","+Str(Game.Sonec.DebugCsvHopPreVY)+","+Str(Game.Sonec.DebugCsvHopPostVX)+","+Str(Game.Sonec.DebugCsvHopPostVY)+","+Str(Game.Sonec.DebugCsvHopChestIndex)+","+Str(Game.Sonec.DebugCsvHopChestLeft)+","+Str(Game.Sonec.DebugCsvHopChestRight)
	CsvRow = CsvRow+","+Str(Game.Sonec.State.Alignment)+","+Str(Game.World.Position.x)+","+Str(Game.Sonec.SpriteData.Position.x)+","+Str(PlateX)+","+Str(PlateVx)
	CsvRow = CsvRow+","+Str(Game.Sonec.DebugCsvMoveStartVX)+","+Str(Game.Sonec.DebugCsvMoveAfterHorizontalVX)+","+Str(Game.Sonec.NormalJumpActive)+","+Str(Game.Sonec.AirThrustDirection)+","+Game.Sonec.DebugTopTrace

	FileID = OpenToWrite("sonec_edge_diagnostics.csv",1)
	if FileID > 0
		WriteLine(FileID,CsvRow)
		CloseFile(FileID)
	endif
endfunction

function GameDo(Game ref as TGame,Now as integer)

	local FlarakChance as integer
	local WalkerChance as integer
	local Index as integer
	local i as integer
    Game.TouchdownNowMs = Now
    // Display the countdown in the existing warning panel, replacing the same notice.
    if Now < Game.TouchdownUntilMs
        // Keep the sky positioned during countdown while gameplay stays frozen.
        BackgroundDo(Game.Background,Game.World,Now)
        Game.Warning.Now = Now
        Game.Warning.Count = 1
        Game.Warning.Notice[0].Kind = 0
        Game.Warning.Notice[0].MessageString = "Touchdown in "+Str((Game.TouchdownUntilMs-Now+999)/1000)+" Sekunden."
        Game.Warning.Notice[0].UntilMs = Game.TouchdownUntilMs
        Game.Warning.Notice[0].PreviewUntilMs = Game.TouchdownUntilMs
        exitfunction
    endif
    GameTouchdownStart(Game,Now)
	
	BackgroundDo(Game.Background,Game.World,Now)
	if CloudCountAll(Game.CloudList) < 50
		if random(0,10000) < 50
			CloudCreate(Game.CloudList,Game.ProtoCloud,Game.World,Now)
		endif
	endif
	CloudMoveAll(Game.CloudList,Game.World,Now)
	SonecMove(Game.Sonec,Game.ChestList,Game.World,Game.Screen,Now)
	
	
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
                // Smaller platforms favor Flak/Flarak; larger ones favor walkers.
                // Chance: 70% at 100px, 35% at 200px, 17.5% at 400px.
                FlarakChance = 700000 / (Game.PlateList.Plate[Index].ObjectData.Size.Width * 0.25)
                if FlarakChance > 7000 then FlarakChance = 7000
                if random(0,10000) < FlarakChance then FlarakSpawn(Game.PlateList,Game.ChestList,Index,Now)
				if WalkerCountAll(Game.WalkerList) < 5
					// Longer platforms provide more room for walkers (35% at 200 px).
					WalkerChance = 3500 * Game.PlateList.Plate[Index].ObjectData.Size.Width / 200
					if WalkerChance > 8500 then WalkerChance = 8500
					if random(0,10000) < WalkerChance
						WalkerAdd(Game.WalkerList,Game.ProtoWalker,Game.ChestList,Game.World,Game.PlateList.Plate[Index],Index,Now)
					endif
				endif
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
	
	// S3 simple formations run on the pause-aware virtual game clock.
	SimpleMineSpawnDo(Game,Now)
	// D4b temporary scheduler; remove this call when Chat B owns spawning.
	DroneAutoSpawnDo(Game.Drone,Game.Screen,Game.World,Game.Sonec,Now)
	DroneMove(Game.Drone,Game.Screen,Game.Sonec,Game.Shield,Game.Inenergie,Now)
	DroneJetfireDo(Game.Drone,Game.JetfireList,Game.ProtoJetfire,Game.World,Now)
	WarningUpdate(Game.Warning,Now)
	BomberDo(Game.Bomber,Game.ProtoBomber,Game.Warning,Game.JetfireList,Game.ProtoJetfire,Game.World,Game.Screen,Now)
    BomberBombDo(Game.Bomber,Game.ProtoBomber,Game.World,Game.Screen,Now)
	
	if MineCountAll(Game.MineList) < 15
		if random(0,10000) < 5
			for i = 0 to random(0,15)
				MineAdd(Game.MineList,Game.ProtoMine,Game.World,Now)
			next i
		endif
	endif
	

	OrbMoveAll(Game.OrbList,Game.World,Now)
	OrbHealthRegenerate(Game.OrbList,Game,Now)
	
	MineMoveAll(Game.MineList,Game.Sonec,Game.Inenergie,Game.World,Now)
	MineHealthRegenerate(Game.MineList,Game,Now)
	MineCollideSonec(Game.MineList,Game.Sonec,Game,Now)
	SimpleMineMoveAll(Game.SimpleMineList,Game.World,Now)
	SimpleMineHealthRegenerate(Game.SimpleMineList,Game,Now)
	MineCollideSonec(Game.SimpleMineList,Game.Sonec,Game,Now)
	
	
	// Flaraks follow platforms after PlateMoveAll below.
	JetfireLifeCycle(Game.JetfireList,Now)
	EnergieMoveAll(Game.EnergieList,Game.World,Now)
	EnergieLifeCycle(Game.EnergieList,Now)
	EnergieCollect(Game.EnergieList,Game.Sonec,Game.Warning,Now)
	
	ExplosionMoveAll(Game.ExplosionList,Game.World,Now)
	ShieldShapeTest(Game.Shield,Game.ProtoShield,Game.ExplosionList,Game.ProtoExplosion,Game.DebugText[0])
	ExplosionCollideSonec(Game.ExplosionList,Game.Sonec,Game.Shield,Now)
	ExplosionCollideChest(Game.ExplosionList,Game.ChestList)
	ExplosionCollideOrb(Game.ExplosionList,Game.OrbList)
	// E1b: independent cooldowns for intelligent and simple mine pools.
	ExplosionCollideMine(Game.ExplosionList,Game.MineList,0)
	ExplosionCollideMine(Game.ExplosionList,Game.SimpleMineList,1)
	ExplosionCollideWalkers(Game.ExplosionList,Game.WalkerList,Now)
	ExplosionCollideDrone(Game.ExplosionList,Game.Drone,Now)
	
	SonecEnergyRegenerate(Game.Sonec,Now)
	SonecHealthRegenerate(Game.Sonec,Now)
		
	PlateMoveAll(Game.PlateList,Game.World,Now)
    FlarakDoAll(Game,Game.JetfireList,Game.ProtoJetfire,Game.World,Game.PlateList,Now)
    ExplosionFollowPlates(Game.ExplosionList,Game.PlateList,Game.World)
    // Current platform and launcher pose is now available for explosion damage.
    ExplosionCollideFlaraks(Game.ExplosionList,Game,Now)
    BomberBombCollideSonec(Game.Bomber,Game,Now)
	WalkerMoveAll(Game.WalkerList,Game.ProtoWalker,Game.PlateList,Game.ChestList,Game.Sonec,Game.World,Now)
	WalkerHealthRegenerate(Game.WalkerList,Game,Now)
	// Select the turret side after walking/turning, before rebuilding its pose.
	WalkerTurretFaceTargetAll(Game.WalkerList,Game.Sonec,Game.Screen.Width,Now)
	WalkerAnimateAll(Game.WalkerList,Game.ProtoWalker,Game.World,Now)
	// Turret world positions are current; enemy bullets join the normal Bullet pipeline.
	WalkerFireAll(Game.WalkerList,Game.ProtoWalker,Game.BulletList,Game.ProtoBullet,Game.FlashList,Game.ProtoFlash,Game.World,Game.Sonec,Game.Screen.Width,Now)
	// Keep live Walker flashes on their barrels while platforms move vertically.
	WalkerFlashFollowAll(Game.WalkerList,Game.FlashList,Game.World)
	ChestMoveAll(Game.ChestList,Game.PlateList,Game.World)
    BomberBombCollideChest(Game.Bomber,Game,Now)
    BomberBombCollidePlate(Game.Bomber,Game.PlateList,Game,Now)
	ChestCheckAll(Game.ChestList,Game.ProtoChest)
	PlateCheckAll(Game.PlateList,Game.ProtoPlate)
	ChestHealthRegenerate(Game.ChestList,Game,Now)
	SonecCollidePlate(Game.Sonec,Game.PlateList,Game.ChestList,Game.World,Game.Screen)
	SonecEdgeCsvWrite(Game,Now)
	
	FlashLifeCycle(Game.FlashList,Now)
	
	FlameLifeCycle(Game.FlameList,Now)
	FlameMoveall(Game.FlameList,Game.World,Now)
    BomberBombCollideFlames(Game.Bomber,Game.FlameList,Game,Now)
    FlarakRocketCollideFlames(Game,Now)
	FlameCollideOrbs(Game.FlameList,Game.OrbList)
	FlameCollideMine(Game.FlameList,Game.MineList)
	FlameCollideMine(Game.FlameList,Game.SimpleMineList)
	FlameCollideChest(Game.FlameList,Game.ChestList)
	FlameCollideWalkers(Game.FlameList,Game.WalkerList,Now)
	FlameCollideDrone(Game.FlameList,Game.Drone)
    FlameCollideFlaraks(Game.FlameList,Game,Now)
	
	BulletMoveall(Game.BulletList,Game.World,Now)
    // Flak diagnostic: see whether a freshly added bullet survives world-bound checks.
    FlarakDebugAfterBulletMove(Game.BulletList,Now)
    BulletExplosiveFuses(Game.BulletList,Game,Now)
    BomberBombCollideBullets(Game.Bomber,Game.BulletList,Game.ExplosionList,Game.ProtoExplosion,Game,Now)
    FlarakRocketCollideBullets(Game,Now)
	BulletCollide(Game.BulletList,Game.Sonec,Game.Shield,Game,Now)
	// K1b: one nearest-hit sweep across all player-bullet target types.
	BulletCollidePlayerTargets(Game.BulletList,Game.OrbList,Game.WalkerList,Game.MineList,Game.SimpleMineList,Game.ChestList,Game.Drone,Game,Now)
	// Retain the established enemy-bullet interactions with mines and chests.
	BulletCollideMines(Game.BulletList,Game.MineList,Game.SimpleMineList)
	BulletCollideChest(Game.BulletList,Game.ChestList)
	
	GrenadeMoveall(Game.GrenadeList,Game.World,Now)
    BomberBombCollideGrenades(Game.Bomber,Game.GrenadeList,Game,Now)
    FlarakRocketCollideGrenades(Game,Now)
	GrenadeCollideOrbs(Game.GrenadeList,Game.OrbList,Game,Now)
	GrenadeCollideMine(Game.GrenadeList,Game.MineList,Game,Now)
	GrenadeCollideMine(Game.GrenadeList,Game.SimpleMineList,Game,Now)
	GrenadeCollideChest(Game.GrenadeList,Game.ChestList,Game,Now)
	GrenadeCollideWalkers(Game.GrenadeList,Game.WalkerList,Game,Now)
	GrenadeCollideDrone(Game.GrenadeList,Game.Drone,Game,Now)
    GrenadeCollideFlaraks(Game.GrenadeList,Game,Now)
	GrenadeCollidePlate(Game.GrenadeList,Game.PlateList,Game,Now)
	
	PlasmaBlitzLifeCycle(Game.PlasmaBlitzList,Now)
    BomberBombCollidePlasmaBlitz(Game.Bomber,Game.PlasmaBlitzList,Game,Now)
    FlarakRocketCollidePlasma(Game,Now)
    // B4: all four weapon pools have moved/updated before this check.
    BomberCollideWeapons(Game.Bomber,Game,Now)
	PlasmaBlitzCollideOrbs(Game.PlasmaBlitzList,Game.OrbList,Now)
	PlasmaBlitzCollideMine(Game.PlasmaBlitzList,Game.MineList,Now)
	PlasmaBlitzCollideMine(Game.PlasmaBlitzList,Game.SimpleMineList,Now)
	PlasmaBlitzCollideChest(Game.PlasmaBlitzList,Game.ChestList,Now)
	PlasmaBlitzCollideWalkers(Game.PlasmaBlitzList,Game.WalkerList,Now)
	PlasmaBlitzCollideDrone(Game.PlasmaBlitzList,Game.Drone,Now)
    PlasmaBlitzCollideFlaraks(Game.PlasmaBlitzList,Game,Now)
	PlasmaBlitzCollisionTimerReset(Game.PlasmaBlitzList,Now)
	// D5c: consume one destruction event after all weapon collisions.
	if DroneDeathEffectPending = TRUE
		ExplosionAdd(Game.ExplosionList,Game.ProtoExplosion,Game,0,DroneDeathPosition,Now)
		RewardDrop(Game,REWARD_OBJECT_DRONE,DroneDeathPosition,Now)
		DroneDeathEffectPending = FALSE
	endif
	
	// Attack hit flashes are triggered by bullet/explosion damage, not energy overload.
	SonecVisualUpdate(Game.Sonec,Now)

	SonecRefreshAnimations(Game.Sonec,Game.PlasmaBlitzList,Game.FlashList,Game.World)
	Game.IsLost = Game.Sonec.IsLost
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GameAnimate(Game ref as TGame,Now as integer)
	
	InenergieAnimate(Game.Inenergie,Now)
	SonecAnimate(Game.Sonec,Game.ProtoSonec,Now)
	ShieldAnimate(Game.Shield,Game.Sonec,Now)
	ExplosionAnimateAll(Game.ExplosionList,Game.ProtoExplosion,Now)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// K1d: lightweight manual outlines, not AGK sprite shape collision.
// Use the same world-space parameters as the diagnostic sweep, converting Y for drawing.
global SonecCollisionDebugLineSprite as integer

function SonecCollisionDebugCircle(CenterX as float,CenterY as float,Radius as float)
    local i as integer
    local x1 as float
    local y1 as float
    local x2 as float
    local y2 as float
    local Angle1 as float
    local Angle2 as float
    local Dx as float
    local Dy as float
    local Length as float
    for i = 0 to 23
        Angle1 = i*15.0
        Angle2 = (i+1)*15.0
        x1 = CenterX+Cos(Angle1)*Radius
        y1 = CenterY+Sin(Angle1)*Radius
        x2 = CenterX+Cos(Angle2)*Radius
        y2 = CenterY+Sin(Angle2)*Radius
        Dx = x2-x1
        Dy = y2-y1
        Length = Sqrt(Dx*Dx+Dy*Dy)
        SetSpriteSize(SonecCollisionDebugLineSprite,Length,2)
        SetSpriteOffset(SonecCollisionDebugLineSprite,0,1)
        SetSpriteAngle(SonecCollisionDebugLineSprite,ATan2(Dy,Dx))
        SetSpritePositionByOffset(SonecCollisionDebugLineSprite,x1,y1)
        DrawSprite(SonecCollisionDebugLineSprite)
    next i
endfunction

function SonecCollisionDebugDraw(Sonec ref as TSonec,World ref as TWorld)
    local Radius as float
    if SONEC_TWO_CIRCLE_TEST = 1 and SonecCollisionDebugVisible = 1
        if SonecCollisionDebugLineSprite = 0
            SonecCollisionDebugLineSprite = CreateSprite(0)
        endif
        // Each circle independently shows whether its own sweep registered a hit.
        Radius = SonecHitCircleRadius(Sonec)
        if GetMilliseconds() < SonecCollisionDebugHitUntil0
            SetSpriteColor(SonecCollisionDebugLineSprite,255,0,0,255)
        else
            SetSpriteColor(SonecCollisionDebugLineSprite,0,255,255,255)
        endif
        SonecCollisionDebugCircle(Sonec.ObjectData.Position.x,SonecHitCircleY(Sonec,0)-World.Position.y,Radius)
        if GetMilliseconds() < SonecCollisionDebugHitUntil1
            SetSpriteColor(SonecCollisionDebugLineSprite,255,0,0,255)
        else
            SetSpriteColor(SonecCollisionDebugLineSprite,0,255,255,255)
        endif
        SonecCollisionDebugCircle(Sonec.ObjectData.Position.x,SonecHitCircleY(Sonec,1)-World.Position.y,Radius)
    endif
endfunction

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
	MineDrawAll(Game.SimpleMineList,Game.ProtoSimpleMine)
	FlarakDrawAll(Game.World)
	DroneDraw(Game.Drone,Game.ProtoDrone,Game.World)
    BomberBombDraw(Game.Bomber,Game.ProtoBomber,Game.World)
	BomberDraw(Game.Bomber,Game.ProtoBomber,Game.World)
	WalkerDrawAll(Game.WalkerList,Game.ProtoWalker,Game.World)
	
	InenergieDraw(Game.Inenergie,Game.ProtoInenergie)
	JetfireDrawAll(Game.JetfireList,Game.ProtoJetfire,Game.World)
	FlameDrawAll(Game.FlameList,Game.ProtoFlame)
	BulletDrawAll(Game.BulletList,Game.ProtoBullet)
	GrenadeDrawAll(Game.GrenadeList,Game.ProtoGrenade)
	PlasmaBlitzDrawAll(Game.PlasmaBlitzList,Game.ProtoPlasmaBlitz)
	// Muzzle flashes are foreground effects: rendered after Walker and bullet sprites.
	FlashDrawAll(Game.FlashList,Game.ProtoFlash)
	// Debug muzzle markers remain visible above bullets and flashes.
	WalkerMuzzleDebugDrawAll(Game.WalkerList,Game.ProtoWalker,Game.World)
	if Game.TouchdownNowMs >= Game.TouchdownUntilMs
        SonecDraw(Game.Sonec,Game.ProtoSonec)
        SonecCollisionDebugDraw(Game.Sonec,Game.World)
        ShieldDraw(Game.Shield,Game.ProtoShield)
    endif


	ExplosionDrawAll(Game.ExplosionList,Game.ProtoExplosion)

	CloudDrawAll(Game.CloudList,Game.ProtoCloud,1,1.75)
	// Local feedback for successful upgrades, independent of the FIFO notice queue.
	WarningPickupStarDraw(Game.Warning,Game.Sonec)

	GuiEnergyDraw(Game.Gui,Game.Sonec,Game.Screen,GetMilliseconds())
	// S4: top warning overlay draws above gameplay and before main.agc Swap().
	WarningDraw(Game.Warning)
	// F2 compares one platform and one visible skyscraper without affecting movement.
	PlateDebugDrawAll(Game.PlateList,Game.TowerList)
	// Keep the existing shield debug in slot 0; K1d uses slot 1.
	if SHIELD_SHAPE_TEST = 1 and Device$ = "windows" and SonecCollisionDebugVisible = 1
		DrawText(Game.DebugText[0])
	endif
	if SONEC_TWO_CIRCLE_TEST = 1 and SonecCollisionDebugVisible = 1
		SetTextString(Game.DebugText[1],"K1d checks "+Str(SonecTwoCircleChecks)+" both "+Str(SonecTwoCircleBoth)+" old-only "+Str(SonecTwoCircleOldOnly)+" new-only "+Str(SonecTwoCircleNewOnly))
		DrawText(Game.DebugText[1])
	endif
	// D-R2: frozen diagnostic remains visible until another edge/hop event.
	if Game.Sonec.DebugEdgeVisible = TRUE
		SetTextString(Game.DebugText[2],Game.Sonec.DebugEdgeSnapshot)
		DrawText(Game.DebugText[2])
	endif
	// Temporary developer HUD for Flak firing from either side.
    FlarakDebugDrawAll(Game.World)
    FlarakCollisionDebugDrawAll(Game.World)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------



