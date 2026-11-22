
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoExplosionLoad(ProtoExplosion ref as TProtoExplosion)
	
	local File as TFilePath
	local Anim as TProtoData
	local i as integer
	local k as integer
	local ten as string
	local min as integer
	local max as integer
	
	ProtoExplosion.AnimExplosion.length = 2
	
	for k = 0 to ProtoExplosion.AnimExplosion.length
		select k
			case 0
				File.Path = "/media/gfx/explosions/BlueFlash"
				File.Name = "DebrisExplode00"
				min = 6
				max = 49
			endcase
			case 1
				File.Path = "/media/gfx/explosions/RedExplode"
				File.Name = "redexplode00"
				min = 4
				max = 35
			endcase
			case 2
				File.Path = "/media/gfx/explosions/WhiteExplode"
				File.Name = "explodewhite00"
				min = 3
				max = 46
			endcase
		endselect
		
		for i = min to max
			
			Anim.Image.File.Path = File.Path
			
			if i < 10
				ten = "0"
			else
				ten = ""
			endif
			
			Anim.Image.File.Name = File.Name + ten + str(i) + ".png"
			
			if FilePathSetAndCheck(Anim.Image.File) = TRUE
				if ImageLoad(Anim.Image) = TRUE
					SpriteLoad(Anim)
				endif
			endif
			
			ProtoExplosion.AnimExplosion[k].Insert(Anim)
		
		next i
	next k

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionInit(ExplosionList ref as TExplosionList)
	
	ExplosionList.Explosion.Length = -1
	ExplosionList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Measurement switch: only Windows, and only when explicitly enabled.
#constant EXPLOSION_MEASURE 1
#constant EXPLOSION_TIMED_DAMAGE 1
#constant EXPLOSION_DAMAGE_INTERVAL_MS 100
#constant EXPLOSION_TIMED_DAMAGE_AMOUNT 30

function ExplosionMeasureSave(Explosion ref as TExplosion)
	if EXPLOSION_MEASURE = 1 and Device$ = "windows"
		local fileID as integer
		local filename as string
		local isNew as integer
		SetFolder("/")
		filename = "explosion_measurements.csv"
		isNew = GetFileExists(filename) = 0
		fileID = 999
		OpenToWrite(fileID,filename,1)
		if isNew
			WriteLine(fileID,"StartMs,ExplosionType,DurationMs,CollisionChecks,HitCount,TotalDamage,ChestHits,OrbHits,MineHits")
		endif
		WriteLine(fileID,str(Explosion.MeasureStartMs)+","+str(Explosion.ExplosionType)+","+str(GetMilliseconds()-Explosion.MeasureStartMs)+","+str(Explosion.MeasureChecks)+","+str(Explosion.MeasureHits)+","+str(Explosion.MeasureDamage)+","+str(Explosion.MeasureChestHits)+","+str(Explosion.MeasureOrbHits)+","+str(Explosion.MeasureMineHits))
		CloseFile(fileID)
	endif
endfunction

function ExplosionNew(Explosion ref as TExplosion,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,ExplosionType as integer,Position ref as TPosition,Now as integer)

	Explosion.Enabled = TRUE
    Explosion.CompositeUpperVisual = FALSE
    Explosion.ImpactPlateIndex = -1
    Explosion.ImpactPlateLastX = 0
    Explosion.ImpactPlateLastY = 0
    Explosion.ImpactPlateLeftX = 0
    Explosion.ImpactPlateRightX = 0
    Explosion.LimitDamageBelowY = FALSE
    Explosion.DamageMaxY = 0
	Explosion.MeasureStartMs = GetMilliseconds()
	Explosion.LastSonecHitMs = 0
	Explosion.LastDroneHitMs = 0
	Explosion.LastChestHitMs.Length = -1
	Explosion.LastOrbHitMs.Length = -1
	Explosion.LastMineHitMs.Length = -1
	Explosion.LastSimpleMineHitMs.Length = -1
	Explosion.LastWalkerHitMs.Length = -1
	Explosion.MeasureChecks = 0
	Explosion.MeasureHits = 0
	Explosion.MeasureDamage = 0
	Explosion.MeasureChestHits = 0
	Explosion.MeasureOrbHits = 0
	Explosion.MeasureMineHits = 0
	
	TimeSet(Explosion.AnimationData.AnimTimer,random(20,30),1)
	TimeReset(Explosion.AnimationData.AnimTimer,Now)
	
	Explosion.AnimationData.Frame = 0
	
	Explosion.ExplosionType = ExplosionType
	
	Explosion.ObjectData.Size.Width = GetImageWidth(ProtoExplosion.AnimExplosion[Explosion.ExplosionType,0].Image.ID)
	Explosion.ObjectData.Size.Height = GetImageHeight(ProtoExplosion.AnimExplosion[Explosion.ExplosionType,0].Image.ID)
	
	if Explosion.ObjectData.Size.Width > Explosion.ObjectData.Size.Height
		Explosion.ObjectData.Radius = Explosion.ObjectData.Size.Width * 0.5
	else
		Explosion.ObjectData.Radius = Explosion.ObjectData.Size.Height * 0.5
	endif
	
	Explosion.ObjectData.Position = Position
	
	Explosion.SpriteData.Angle  = random(0,360)
	Explosion.SpriteData.Center = TRUE
	Explosion.SpriteData.Scale  = 1.0
	
	// The blast starts at zero and reaches the design radius halfway through the animation.
	Explosion.ObjectData.Radius = 0
	
	select Explosion.ExplosionType
		case 0
			ColorSet(Explosion.SpriteData.Color,0,255,0,200)//0,255,55,200)
		endcase
		case 1
			ColorSet(Explosion.SpriteData.Color,0,255,0,200)//255,155,0,200)
		endcase
		case 2
			ColorSet(Explosion.SpriteData.Color,0,255,0,200)
		endcase
	endselect
	
	SpritePositionCalc(Explosion.SpriteData.Position,Explosion.ObjectData.Position,Game.World.Position)

	Explosion.BulletData.BulletType = 1
	Explosion.BulletData.Damage = 5
	if EXPLOSION_TIMED_DAMAGE = 1
		Explosion.BulletData.Damage = EXPLOSION_TIMED_DAMAGE_AMOUNT
	endif

	Explosion.CollisionData.Position1.x = Explosion.ObjectData.Position.x - Explosion.ObjectData.Size.Width  * 0.5
	Explosion.CollisionData.Position1.y = Explosion.ObjectData.Position.y - Explosion.ObjectData.Size.Height * 0.5
	Explosion.CollisionData.Position2.x = Explosion.ObjectData.Position.x + Explosion.ObjectData.Size.Width  * 0.5
	Explosion.CollisionData.Position2.y = Explosion.ObjectData.Position.y + Explosion.ObjectData.Size.Height * 0.5
	
	select Explosion.ExplosionType
		case 0
			PlaySound(Game.Sound.ImpactSound)
		endcase
		case 1
			PlaySound(Game.Sound.ExplodeSound)
		endcase
		case 2
			PlaySound(Game.Sound.ExplosionSound)
		endcase
	endselect
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionInsert(ExplosionList ref as TExplosionList,Explosion ref as TExplosion)
    local Found as integer
    local i as integer
    Found = FALSE
    i = ExplosionList.FirstFree
    while Found = FALSE and i <= ExplosionList.Explosion.Length
        if ExplosionList.Explosion[i].Enabled = FALSE
            Found = TRUE
        else
            i = i+1
        endif
    endwhile
    if Found = FALSE
        ExplosionList.Explosion.Insert(Explosion)
        ExplosionList.FirstFree = ExplosionList.Explosion.Length
    else
        ExplosionList.Explosion[i] = Explosion
        ExplosionList.FirstFree = i+1
    endif
endfunction

function ExplosionAdd(ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,ExplosionType as integer,Position ref as TPosition,Now as integer)
    local Explosion as TExplosion
    ExplosionNew(Explosion,ProtoExplosion,Game,ExplosionType,Position,Now)
    ExplosionInsert(ExplosionList,Explosion)
endfunction

// Only bomb impacts opt into this world-space damage boundary.
function ExplosionAddAboveY(ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,ExplosionType as integer,Position ref as TPosition,MaxY as float,PlateLeftX as float,PlateRightX as float,PlateIndex as integer,Now as integer)
    local Explosion as TExplosion
    ExplosionNew(Explosion,ProtoExplosion,Game,ExplosionType,Position,Now)
    Explosion.LimitDamageBelowY = TRUE
    Explosion.DamageMaxY = MaxY
    Explosion.CompositeUpperVisual = TRUE
    Explosion.ImpactPlateLeftX = PlateLeftX
    Explosion.ImpactPlateRightX = PlateRightX
    Explosion.ImpactPlateIndex = PlateIndex
    Explosion.ImpactPlateLastX = PlateLeftX
    Explosion.ImpactPlateLastY = MaxY
    Explosion.SpriteData.Angle = 0
    // Bomb-platform composite only: tint both existing layers green.
    ColorSet(Explosion.SpriteData.Color,0,255,0,200)
    ExplosionInsert(ExplosionList,Explosion)
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionDelete(ExplosionList ref as TExplosionList,Index as integer)
	
		if ExplosionList.Explosion[Index].Enabled = TRUE
		ExplosionMeasureSave(ExplosionList.Explosion[Index])
	endif
	ExplosionList.Explosion[Index].Enabled = FALSE
	if ExplosionList.FirstFree > Index
		ExplosionList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionAnimateAll(ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Now as integer)

	local i as integer
	local FrameCount as integer
	local Progress as float
	local RadiusFactor as float
	local MaxRadius as float
	
	for i = 0 to ExplosionList.Explosion.Length
		if TimeGet(ExplosionList.Explosion[i].AnimationData.AnimTimer,Now) > 0
			ExplosionList.Explosion[i].AnimationData.Frame = ExplosionList.Explosion[i].AnimationData.Frame +1
			FrameCount = ProtoExplosion.AnimExplosion[ExplosionList.Explosion[i].ExplosionType].Length + 1
			if ExplosionList.Explosion[i].AnimationData.Frame >= FrameCount
				ExplosionDelete(ExplosionList,i)
			else
				// One shared growth/shrink curve, with each type's own design radius.
				Progress = ExplosionList.Explosion[i].AnimationData.Frame * 1.0 / (FrameCount - 1)
				RadiusFactor = 1.0 - abs(2.0 * Progress - 1.0)
				MaxRadius = ExplosionList.Explosion[i].ObjectData.Size.Width * 0.5
				if ExplosionList.Explosion[i].ObjectData.Size.Height > ExplosionList.Explosion[i].ObjectData.Size.Width
					MaxRadius = ExplosionList.Explosion[i].ObjectData.Size.Height * 0.5
				endif
				ExplosionList.Explosion[i].ObjectData.Radius = MaxRadius * RadiusFactor
			endif
			if ExplosionList.Explosion[i].AnimationData.AnimTimer.Span > 15
				TimeSet(ExplosionList.Explosion[i].AnimationData.AnimTimer,floor(ExplosionList.Explosion[i].AnimationData.AnimTimer.Span*0.9),1)
			endif
			TimeReset(ExplosionList.Explosion[i].AnimationData.AnimTimer,Now)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionCollideSonec(ExplosionList ref as TExplosionList,Sonec ref as TSonec,Shield ref as TShield,Now as integer)

    local i as integer
    local CircleIndex as integer
    local Radius as float
    local DeltaX as float
    local DeltaY as float
    local Hit as integer

    for i = 0 to ExplosionList.Explosion.Length
        if ExplosionList.Explosion[i].Enabled = TRUE
            ExplosionList.Explosion[i].MeasureChecks = ExplosionList.Explosion[i].MeasureChecks + 1
            // S4: explosion radius reaches either shared Sonec body circle.
            // Keep the existing strict radius test (no extra Sonec-radius padding).
            Radius = ExplosionList.Explosion[i].ObjectData.Radius
            DeltaX = ExplosionList.Explosion[i].ObjectData.Position.x-Sonec.ObjectData.Position.x
            Hit = FALSE
            for CircleIndex = 0 to 1
                DeltaY = ExplosionList.Explosion[i].ObjectData.Position.y-SonecHitCircleY(Sonec,CircleIndex)
                if DeltaX*DeltaX+DeltaY*DeltaY < Radius*Radius then Hit = TRUE
            next CircleIndex
            // Preserve platform shielding against Sonec's original center position.
            // Do not let the upper circle bypass the existing platform boundary.
            if Hit = TRUE and ExplosionDamageAllowed(ExplosionList.Explosion[i],Sonec.ObjectData.Position)
                if EXPLOSION_TIMED_DAMAGE = 0 or ExplosionList.Explosion[i].LastSonecHitMs = 0 or GetMilliseconds()-ExplosionList.Explosion[i].LastSonecHitMs >= EXPLOSION_DAMAGE_INTERVAL_MS
                    ExplosionList.Explosion[i].LastSonecHitMs = GetMilliseconds()
                    ExplosionList.Explosion[i].MeasureHits = ExplosionList.Explosion[i].MeasureHits + 1
                    ExplosionList.Explosion[i].MeasureDamage = ExplosionList.Explosion[i].MeasureDamage + ExplosionList.Explosion[i].BulletData.Damage
                    local HealthBeforeHit as integer
                    HealthBeforeHit = Sonec.Health.State
                    Sonec.Health.State = Sonec.Health.State - (ExplosionList.Explosion[i].BulletData.Damage - ShieldAbsorbDamage(Shield,Sonec,ExplosionList.Explosion[i].BulletData.Damage,Now))
                    if Sonec.Health.State < HealthBeforeHit then SonecHitFlashUntil = Now + SONEC_HIT_FLASH_MS
                endif
            endif
        endif
    next i

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionCollideChest(ExplosionList ref as TExplosionList,ChestList ref as TChestList)
	
	local i as integer
	local k as integer
	local Radius as float

	for i = 0 to ExplosionList.Explosion.Length
		if ExplosionList.Explosion[i].Enabled = TRUE
			for k = 0 to ChestList.Chest.Length
				if ChestList.Chest[k].Enabled = TRUE
					Radius = CalcRadius(ExplosionList.Explosion[i].ObjectData.Position,ChestList.Chest[k].ObjectData.Position)
					if Radius < ExplosionList.Explosion[i].ObjectData.Radius and ExplosionDamageAllowed(ExplosionList.Explosion[i],ChestList.Chest[k].ObjectData.Position)
						if ExplosionList.Explosion[i].LastChestHitMs.Length < k
							ExplosionList.Explosion[i].LastChestHitMs.Length = k
						endif
						if EXPLOSION_TIMED_DAMAGE = 0 or ExplosionList.Explosion[i].LastChestHitMs[k] = 0 or GetMilliseconds()-ExplosionList.Explosion[i].LastChestHitMs[k] >= EXPLOSION_DAMAGE_INTERVAL_MS
							ExplosionList.Explosion[i].LastChestHitMs[k] = GetMilliseconds()
							ExplosionList.Explosion[i].MeasureChestHits = ExplosionList.Explosion[i].MeasureChestHits + 1
							ChestList.Chest[k].Health.State = ChestList.Chest[k].Health.State - ExplosionList.Explosion[i].BulletData.Damage
						endif
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionCollideOrb(ExplosionList ref as TExplosionList,OrbList ref as TOrbList)
	
	local i as integer
	local k as integer
	local Radius as float

	for i = 0 to ExplosionList.Explosion.Length
		if ExplosionList.Explosion[i].Enabled = TRUE
			for k = 0 to OrbList.Orb.Length
				if OrbList.Orb[k].Enabled = TRUE
					Radius = CalcRadius(ExplosionList.Explosion[i].ObjectData.Position,OrbList.Orb[k].ObjectData.Position)
					if Radius < ExplosionList.Explosion[i].ObjectData.Radius and ExplosionDamageAllowed(ExplosionList.Explosion[i],OrbList.Orb[k].ObjectData.Position)
						if ExplosionList.Explosion[i].LastOrbHitMs.Length < k
							ExplosionList.Explosion[i].LastOrbHitMs.Length = k
						endif
						if EXPLOSION_TIMED_DAMAGE = 0 or ExplosionList.Explosion[i].LastOrbHitMs[k] = 0 or GetMilliseconds()-ExplosionList.Explosion[i].LastOrbHitMs[k] >= EXPLOSION_DAMAGE_INTERVAL_MS
							ExplosionList.Explosion[i].LastOrbHitMs[k] = GetMilliseconds()
							ExplosionList.Explosion[i].MeasureOrbHits = ExplosionList.Explosion[i].MeasureOrbHits + 1
							OrbList.Orb[k].Health.State = OrbList.Orb[k].Health.State - ExplosionList.Explosion[i].BulletData.Damage
						endif
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// E1b: mine pools use independent per-explosion hit cooldowns.
// IsSimpleMine = 0 for intelligent mines, 1 for simple mine formations.
function ExplosionCollideMine(ExplosionList ref as TExplosionList,MineList ref as TMineList,IsSimpleMine as integer)

	local i as integer
	local k as integer
	local Radius as float
	local HitAllowed as integer
	local HitNow as integer

	for i = 0 to ExplosionList.Explosion.Length
		if ExplosionList.Explosion[i].Enabled = TRUE
			for k = 0 to MineList.Mine.Length
				if MineList.Mine[k].Enabled = TRUE
					Radius = CalcRadius(ExplosionList.Explosion[i].ObjectData.Position,MineList.Mine[k].ObjectData.Position)
					if Radius < ExplosionList.Explosion[i].ObjectData.Radius and ExplosionDamageAllowed(ExplosionList.Explosion[i],MineList.Mine[k].ObjectData.Position)
						HitNow = GetMilliseconds()
						HitAllowed = FALSE
						if IsSimpleMine = 1
							if ExplosionList.Explosion[i].LastSimpleMineHitMs.Length < k
								ExplosionList.Explosion[i].LastSimpleMineHitMs.Length = k
							endif
							if EXPLOSION_TIMED_DAMAGE = 0 or ExplosionList.Explosion[i].LastSimpleMineHitMs[k] = 0 or HitNow-ExplosionList.Explosion[i].LastSimpleMineHitMs[k] >= EXPLOSION_DAMAGE_INTERVAL_MS
								ExplosionList.Explosion[i].LastSimpleMineHitMs[k] = HitNow
								HitAllowed = TRUE
							endif
						else
							if ExplosionList.Explosion[i].LastMineHitMs.Length < k
								ExplosionList.Explosion[i].LastMineHitMs.Length = k
							endif
							if EXPLOSION_TIMED_DAMAGE = 0 or ExplosionList.Explosion[i].LastMineHitMs[k] = 0 or HitNow-ExplosionList.Explosion[i].LastMineHitMs[k] >= EXPLOSION_DAMAGE_INTERVAL_MS
								ExplosionList.Explosion[i].LastMineHitMs[k] = HitNow
								HitAllowed = TRUE
							endif
						endif
						if HitAllowed = TRUE
							ExplosionList.Explosion[i].MeasureMineHits = ExplosionList.Explosion[i].MeasureMineHits + 1
							MineList.Mine[k].Health.State = MineList.Mine[k].Health.State - ExplosionList.Explosion[i].BulletData.Damage
						endif
					endif
				endif
			next k
		endif
	next i

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Explosion circle against the established Walker turret hit box.
// Each Walker has its own damage interval for this explosion.
function ExplosionCollideWalkers(ExplosionList ref as TExplosionList,WalkerList ref as TWalkerList,Now as integer)

	local i as integer
	local k as integer
	local NearestPoint as TPosition

	for i = 0 to ExplosionList.Explosion.Length
		if ExplosionList.Explosion[i].Enabled = TRUE
			for k = 0 to WalkerList.Walker.Length
				if WalkerList.Walker[k].Enabled = TRUE
					NearestPoint = ExplosionList.Explosion[i].ObjectData.Position
					if NearestPoint.x < WalkerList.Walker[k].WalkerCollisionData.Tower.Position1.x then NearestPoint.x = WalkerList.Walker[k].WalkerCollisionData.Tower.Position1.x
					if NearestPoint.x > WalkerList.Walker[k].WalkerCollisionData.Tower.Position2.x then NearestPoint.x = WalkerList.Walker[k].WalkerCollisionData.Tower.Position2.x
					if NearestPoint.y < WalkerList.Walker[k].WalkerCollisionData.Tower.Position1.y then NearestPoint.y = WalkerList.Walker[k].WalkerCollisionData.Tower.Position1.y
					if NearestPoint.y > WalkerList.Walker[k].WalkerCollisionData.Tower.Position2.y then NearestPoint.y = WalkerList.Walker[k].WalkerCollisionData.Tower.Position2.y
					if CalcRadius(ExplosionList.Explosion[i].ObjectData.Position,NearestPoint) < ExplosionList.Explosion[i].ObjectData.Radius and ExplosionDamageAllowed(ExplosionList.Explosion[i],NearestPoint)
						if ExplosionList.Explosion[i].LastWalkerHitMs.Length < k
							ExplosionList.Explosion[i].LastWalkerHitMs.Length = k
						endif
						if EXPLOSION_TIMED_DAMAGE = 0 or ExplosionList.Explosion[i].LastWalkerHitMs[k] = 0 or GetMilliseconds()-ExplosionList.Explosion[i].LastWalkerHitMs[k] >= EXPLOSION_DAMAGE_INTERVAL_MS
							ExplosionList.Explosion[i].LastWalkerHitMs[k] = GetMilliseconds()
							WalkerList.Walker[k].Health.State = WalkerList.Walker[k].Health.State - ExplosionList.Explosion[i].BulletData.Damage
							WalkerList.Walker[k].HitFlashUntil = Now + 150
							ColorSet(WalkerList.Walker[k].WalkerSpriteData.Tower.Color,255,0,0,255)
						endif
					endif
				endif
			next k
		endif
	next i

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// D5b: each blast has its own cooldown for the single active drone.
function ExplosionCollideDrone(ExplosionList ref as TExplosionList,Drone ref as TDrone,Now as integer)
    local i as integer
    local NearestPoint as TPosition
    for i = 0 to ExplosionList.Explosion.Length
        if Drone.Enabled = TRUE and ExplosionList.Explosion[i].Enabled = TRUE
            NearestPoint = ExplosionList.Explosion[i].ObjectData.Position
            if NearestPoint.x < Drone.Position.x-23 then NearestPoint.x = Drone.Position.x-23
            if NearestPoint.x > Drone.Position.x+23 then NearestPoint.x = Drone.Position.x+23
            if NearestPoint.y < Drone.Position.y-15 then NearestPoint.y = Drone.Position.y-15
            if NearestPoint.y > Drone.Position.y+15 then NearestPoint.y = Drone.Position.y+15
            if CalcRadius(ExplosionList.Explosion[i].ObjectData.Position,NearestPoint) < ExplosionList.Explosion[i].ObjectData.Radius and ExplosionDamageAllowed(ExplosionList.Explosion[i],NearestPoint)
                if EXPLOSION_TIMED_DAMAGE = 0 or ExplosionList.Explosion[i].LastDroneHitMs = 0 or GetMilliseconds()-ExplosionList.Explosion[i].LastDroneHitMs >= EXPLOSION_DAMAGE_INTERVAL_MS
                    ExplosionList.Explosion[i].LastDroneHitMs = GetMilliseconds()
                    DroneTakeDamage(Drone,ExplosionList.Explosion[i].BulletData.Damage)
                endif
            endif
        endif
    next i
endfunction

function ExplosionMove(Explosion ref as TExplosion,World ref as TWorld,Now as integer)
	
	if Explosion.Enabled = TRUE
		if TimeGet(Explosion.ObjectData.MoveTimer,Now) > 0
			
			SpritePositionCalc(Explosion.SpriteData.Position,Explosion.ObjectData.Position,World.Position)
			
			Explosion.CollisionData.Position1.x = Explosion.ObjectData.Position.x - (Explosion.ObjectData.Size.Width  * 0.5)
			Explosion.CollisionData.Position1.y = Explosion.ObjectData.Position.y - (Explosion.ObjectData.Size.Height * 0.5)
			Explosion.CollisionData.Position2.x = Explosion.ObjectData.Position.x + (Explosion.ObjectData.Size.Width  * 0.5)
			Explosion.CollisionData.Position2.y = Explosion.ObjectData.Position.y + (Explosion.ObjectData.Size.Height * 0.5)
			
			TimeReset(Explosion.ObjectData.MoveTimer,Now)
			
		endif
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// B2f: keep a platform bomb blast attached to its moving impact platform.
// If the platform disappears, retain the last position rather than follow a reused slot.
function ExplosionFollowPlates(ExplosionList ref as TExplosionList,PlateList ref as TPlateList,World ref as TWorld)
    local i as integer
    local k as integer
    local DeltaX as float
    local DeltaY as float

    for i = 0 to ExplosionList.Explosion.Length
        if ExplosionList.Explosion[i].Enabled = TRUE and ExplosionList.Explosion[i].ImpactPlateIndex >= 0
            k = ExplosionList.Explosion[i].ImpactPlateIndex
            if k <= PlateList.Plate.Length and PlateList.Plate[k].Enabled = TRUE
                DeltaX = PlateList.Plate[k].CollisionData.Position1.x-ExplosionList.Explosion[i].ImpactPlateLastX
                DeltaY = PlateList.Plate[k].CollisionData.Position1.y-ExplosionList.Explosion[i].ImpactPlateLastY
                ExplosionList.Explosion[i].ObjectData.Position.x = ExplosionList.Explosion[i].ObjectData.Position.x+DeltaX
                ExplosionList.Explosion[i].ObjectData.Position.y = ExplosionList.Explosion[i].ObjectData.Position.y+DeltaY
                ExplosionList.Explosion[i].ImpactPlateLeftX = ExplosionList.Explosion[i].ImpactPlateLeftX+DeltaX
                ExplosionList.Explosion[i].ImpactPlateRightX = ExplosionList.Explosion[i].ImpactPlateRightX+DeltaX
                ExplosionList.Explosion[i].DamageMaxY = ExplosionList.Explosion[i].DamageMaxY+DeltaY
                ExplosionList.Explosion[i].ImpactPlateLastX = PlateList.Plate[k].CollisionData.Position1.x
                ExplosionList.Explosion[i].ImpactPlateLastY = PlateList.Plate[k].CollisionData.Position1.y
                SpritePositionCalc(ExplosionList.Explosion[i].SpriteData.Position,ExplosionList.Explosion[i].ObjectData.Position,World.Position)
            else
                ExplosionList.Explosion[i].ImpactPlateIndex = -1
            endif
        endif
    next i
endfunction

// Platform-shaped shielding: below the top only targets beyond either side
// can be hit. Other explosion types keep their original radius behavior.
function ExplosionDamageAllowed(Explosion ref as TExplosion,Target ref as TPosition)
    local Allowed as integer
    Allowed = TRUE
    if Explosion.LimitDamageBelowY = TRUE and Target.y > Explosion.DamageMaxY
        Allowed = FALSE
        if Target.x < Explosion.ImpactPlateLeftX or Target.x > Explosion.ImpactPlateRightX
            Allowed = TRUE
        endif
    endif
endfunction Allowed

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionMoveAll(ExplosionList ref as TExplosionList,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to ExplosionList.Explosion.Length
		ExplosionMove(ExplosionList.Explosion[i],World,Now)
		if ExplosionList.Explosion[i].ObjectData.Position.x + ExplosionList.Explosion[i].ObjectData.Size.Width < World.Position.x
			ExplosionDelete(ExplosionList,i)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// B2e/4: red base, white foreground. Draw the upper blast normally,
// and allow lower portions only beyond the impacted platform's two edges.
// Platform edges are stored in world coordinates; convert to screen each frame.
function ExplosionDraw(Explosion ref as TExplosion,ProtoExplosion ref as TProtoExplosion)
    local WhiteFrame as integer
    local WhiteSpriteID as integer
    local RedSpriteID as integer
    local CutY as integer
    local LeftX as integer
    local RightX as integer
    local ScreenWidth as integer
    local ScreenHeight as integer
    local WhiteFrames as integer
    local RedFrames as integer

    if Explosion.Enabled = TRUE
        if Explosion.CompositeUpperVisual = TRUE
            WhiteFrames = ProtoExplosion.AnimExplosion[2].Length+1
            RedFrames = ProtoExplosion.AnimExplosion[1].Length+1
            WhiteFrame = floor(Explosion.AnimationData.Frame*WhiteFrames*1.0/RedFrames)
            if WhiteFrame >= WhiteFrames then WhiteFrame = WhiteFrames-1
            WhiteSpriteID = ProtoExplosion.AnimExplosion[2,WhiteFrame].Sprite.ID
            RedSpriteID = ProtoExplosion.AnimExplosion[1,Explosion.AnimationData.Frame].Sprite.ID

            ScreenWidth = GetVirtualWidth()
            ScreenHeight = GetVirtualHeight()
            // Clip at the impacted platform top, not at the bomb/chest impact center.
            CutY = floor(Explosion.DamageMaxY+Explosion.SpriteData.Position.y-Explosion.ObjectData.Position.y)
            LeftX = floor(Explosion.ImpactPlateLeftX+Explosion.SpriteData.Position.x-Explosion.ObjectData.Position.x)
            RightX = floor(Explosion.ImpactPlateRightX+Explosion.SpriteData.Position.x-Explosion.ObjectData.Position.x)
            if CutY < 0 then CutY = 0
            if CutY > ScreenHeight then CutY = ScreenHeight
            if LeftX < 0 then LeftX = 0
            if LeftX > ScreenWidth then LeftX = ScreenWidth
            if RightX < 0 then RightX = 0
            if RightX > ScreenWidth then RightX = ScreenWidth

            // Layer 1: red. The scissors never overlap, so alpha isn't doubled.
            if CutY > 0
                SetSpriteScissor(RedSpriteID,0,0,ScreenWidth,CutY)
                SpriteDraw(ProtoExplosion.AnimExplosion[1,Explosion.AnimationData.Frame].Sprite,Explosion.SpriteData)
            endif
            if CutY < ScreenHeight
                if LeftX > 0
                    SetSpriteScissor(RedSpriteID,0,CutY,LeftX,ScreenHeight)
                    SpriteDraw(ProtoExplosion.AnimExplosion[1,Explosion.AnimationData.Frame].Sprite,Explosion.SpriteData)
                endif
                if RightX < ScreenWidth
                    SetSpriteScissor(RedSpriteID,RightX,CutY,ScreenWidth,ScreenHeight)
                    SpriteDraw(ProtoExplosion.AnimExplosion[1,Explosion.AnimationData.Frame].Sprite,Explosion.SpriteData)
                endif
            endif
            SetSpriteScissor(RedSpriteID,0,0,0,0)

            // Layer 2: white, with the identical platform-shaped mask.
            if CutY > 0
                SetSpriteScissor(WhiteSpriteID,0,0,ScreenWidth,CutY)
                SpriteDraw(ProtoExplosion.AnimExplosion[2,WhiteFrame].Sprite,Explosion.SpriteData)
            endif
            if CutY < ScreenHeight
                if LeftX > 0
                    SetSpriteScissor(WhiteSpriteID,0,CutY,LeftX,ScreenHeight)
                    SpriteDraw(ProtoExplosion.AnimExplosion[2,WhiteFrame].Sprite,Explosion.SpriteData)
                endif
                if RightX < ScreenWidth
                    SetSpriteScissor(WhiteSpriteID,RightX,CutY,ScreenWidth,ScreenHeight)
                    SpriteDraw(ProtoExplosion.AnimExplosion[2,WhiteFrame].Sprite,Explosion.SpriteData)
                endif
            endif
            SetSpriteScissor(WhiteSpriteID,0,0,0,0)
        else
            SpriteDraw(ProtoExplosion.AnimExplosion[Explosion.ExplosionType,Explosion.AnimationData.Frame].Sprite,Explosion.SpriteData)
        endif
    endif
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionDrawAll(ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion)
	
	local i as integer
	
	for i = 0 to ExplosionList.Explosion.Length
		ExplosionDraw(ExplosionList.Explosion[i],ProtoExplosion)
	next i
	
endfunction
	
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

