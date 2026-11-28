
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoFlameLoad(ProtoFlame ref as TProtoFlame,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoFlame.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoFlame.AnimFlame.Image) = TRUE
			SpriteLoad(ProtoFlame.AnimFlame)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// One damage interval per particle and live target identity, on virtual game time.
#constant FLAME_DAMAGE_INTERVAL_MS 100
global FlameTargetSerial as integer

function FlameNewTargetId()
	FlameTargetSerial = FlameTargetSerial+1
endfunction FlameTargetSerial

function FlameCanDamage(Flame ref as TFlame,TargetId as integer,Now as integer)
	local i as integer
	local Hit as TFlameHit
	if TargetId <= 0 then exitfunction FALSE
	for i = 0 to Flame.HitList.Length
		if Flame.HitList[i].TargetId = TargetId
			if Now < Flame.HitList[i].NextHitMs then exitfunction FALSE
			Flame.HitList[i].NextHitMs = Now+FLAME_DAMAGE_INTERVAL_MS
			exitfunction TRUE
		endif
	next i
	Hit.TargetId = TargetId
	Hit.NextHitMs = Now+FLAME_DAMAGE_INTERVAL_MS
	Flame.HitList.Insert(Hit)
endfunction TRUE

function FlameInit(FlameList ref as TFlameList)
	
	TimeSet(FlameList.CreateTimer,10,1)
	FlameList.Flame.Length = -1
	FlameTargetSerial = 0
	FlameList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameNew(Flame ref as TFlame,ProtoFlame ref as TProtoFlame,World ref as TWorld,InheritedSpeed as TSpeed,Position as TPosition,Angle as float,Radius as float,Now)
		
	Speed as TPosition
	
	Flame.Enabled = TRUE
    DamageOriginStart(Flame.BulletData.DamageOrigin,DAMAGE_OBJECT_SONEC,0,DAMAGE_SOURCE_FLAME)
	Flame.HitList.Length = -1
	TimeSet(Flame.ObjectData.MoveTimer,10,10)
	TimeReset(Flame.ObjectData.MoveTimer,Now)
	
	TimeSet(Flame.EffectData.LifeCycleTimer,10,1)
	TimeReset(Flame.EffectData.LifeCycleTimer,Now)
	
	Flame.EffectData.LifeCycle = 0
	Flame.EffectData.LifeCycleMax = 25
	
	Flame.ObjectData.Position = Position
	CalcPosition(Flame.ObjectData.Position,Angle,Radius)
	
	Flame.ObjectData.MoveSpeedMax.x = 0
	Flame.ObjectData.MoveSpeedMax.y = 0
	
	Speed.x = 0
	Speed.y = 0
	CalcPosition(Speed,Angle,1)

	// Capture world velocity once, already converted to flame timer units.
	Flame.ObjectData.MoveSpeed.x = Speed.x + InheritedSpeed.x
	Flame.ObjectData.MoveSpeed.y = Speed.y + InheritedSpeed.y
	
	Flame.ObjectData.MoveAcceleration.x = 0.01
	Flame.ObjectData.MoveAcceleration.y = 0.01
	
	Flame.ObjectData.MoveAlignment.x = 0
	Flame.ObjectData.MoveAlignment.y = 0
	
	Flame.SpriteData.Angle = random(0,359)
	Flame.SpriteData.Center = TRUE
	Flame.SpriteData.Scale = 0.15
		
	ColorSet(Flame.SpriteData.Color,0,255,0,255)
	
	Flame.ObjectData.Size.Width = GetImageWidth(ProtoFlame.AnimFlame.Image.ID)*Flame.SpriteData.Scale
	Flame.ObjectData.Size.Height = GetImageHeight(ProtoFlame.AnimFlame.Image.ID)*Flame.SpriteData.Scale

	if Flame.ObjectData.Size.Width > Flame.ObjectData.Size.Height
		Flame.ObjectData.Radius = Flame.ObjectData.Size.Width * 0.5
	else
		Flame.ObjectData.Radius = Flame.ObjectData.Size.Height * 0.5
	endif
	
	SpritePositionCalc(Flame.SpriteData.Position,Flame.ObjectData.Position,World.Position)
	
	Flame.BulletData.BulletType = 1
	Flame.BulletData.Damage = 5
	
	Flame.CollisionData.Position1.x = Flame.ObjectData.Position.x - Flame.ObjectData.Size.Width  * 0.5
	Flame.CollisionData.Position1.y = Flame.ObjectData.Position.y - Flame.ObjectData.Size.Height * 0.5
	Flame.CollisionData.Position2.x = Flame.ObjectData.Position.x + Flame.ObjectData.Size.Width  * 0.5
	Flame.CollisionData.Position2.y = Flame.ObjectData.Position.y + Flame.ObjectData.Size.Height * 0.5
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameAdd(FlameList ref as TFlameList,ProtoFlame ref as TProtoFlame,World ref as TWorld,InheritedSpeed as TSpeed,Position as TPosition,Angle as float,Radius as float,Now as integer,Depth ref as TWeaponDepth)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Flame as TFlame
	
	Value = FALSE
	
	if TimeGet(FlameList.CreateTimer,Now) > 0
		
		FlameNew(Flame,ProtoFlame,World,InheritedSpeed,Position,Angle,Radius,Now)
        Flame.WeaponDepth = Depth
		
		Found = FALSE
		i = FlameList.FirstFree
		while Found = FALSE and i <= FlameList.Flame.Length
			if FlameList.Flame[i].Enabled = FALSE
				Found = TRUE
			else
				i = i+1
			endif
		endwhile
		
		if Found = FALSE
			FlameList.Flame.Insert(Flame)
			FlameList.FirstFree = FlameList.Flame.Length
		else
			FlameList.Flame[i] = Flame
			FlameList.FirstFree = i+1
		endif
		
		Value = TRUE
		
		TimeReset(FlameList.CreateTimer,Now)
	
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameDelete(FlameList ref as TFlameList,Index as integer)
	
	FlameList.Flame[Index].Enabled = FALSE
	if FlameList.FirstFree > Index
		FlameList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Base flame radius is stored at initial scale 0.15; the sprite grows over its lifetime.
// Use its current visual scale for collisions without changing object movement or sizes.
function FlameCollisionRadius(Flame ref as TFlame)

	local Radius as float

	Radius = Flame.ObjectData.Radius * (Flame.SpriteData.Scale / 0.15)

endfunction Radius

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameCollide(FlameList ref as TFlameList,Sonec ref as TSonec)
	
	local i as integer
	local Radius as float
	local FlameRadius as float
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			FlameRadius = FlameCollisionRadius(FlameList.Flame[i])
			Radius = CalcRadius(FlameList.Flame[i].ObjectData.Position,Sonec.ObjectData.Position)
			if Radius < FlameRadius + Sonec.ObjectData.Radius
				Sonec.Health.State = Sonec.Health.State - FlameList.Flame[i].BulletData.Damage
				FlameDelete(FlameList,i)
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameCollideOrbs(FlameList ref as TFlameList,OrbList ref as TOrbList,Now as integer)
	
	local i as integer
	local k as integer
	local Radius as float
	local FlameRadius as float
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			FlameRadius = FlameCollisionRadius(FlameList.Flame[i])
			for k = 0 to OrbList.Orb.Length
				if OrbList.Orb[k].Enabled = TRUE
					Radius = CalcRadius(FlameList.Flame[i].ObjectData.Position,OrbList.Orb[k].ObjectData.Position)
					if Radius < FlameRadius + OrbList.Orb[k].ObjectData.Radius
						if FlameCanDamage(FlameList.Flame[i],OrbList.Orb[k].FlameTargetId,Now) = TRUE
							OrbList.Orb[k].Health.State = OrbList.Orb[k].Health.State - FlameList.Flame[i].BulletData.Damage
							ColorSet(OrbList.Orb[k].SpriteData.Color,255,0,0,255)
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

function FlameCollideMine(FlameList ref as TFlameList,MineList ref as TMineList,Now as integer)
	
	local i as integer
	local k as integer
	local Radius as float
	local FlameRadius as float
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			FlameRadius = FlameCollisionRadius(FlameList.Flame[i])
			for k = 0 to MineList.Mine.Length
				if MineList.Mine[k].Enabled = TRUE
					Radius = CalcRadius(FlameList.Flame[i].ObjectData.Position,MineList.Mine[k].ObjectData.Position)
					if Radius < FlameRadius + MineList.Mine[k].ObjectData.Radius
						if FlameCanDamage(FlameList.Flame[i],MineList.Mine[k].FlameTargetId,Now) = TRUE
							MineList.Mine[k].Health.State = MineList.Mine[k].Health.State - FlameList.Flame[i].BulletData.Damage
							ColorSet(MineList.Mine[k].SpriteData.Color,255,0,0,255)
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

function FlameCollideChest(FlameList ref as TFlameList,ChestList ref as TChestList,Now as integer,PlateList ref as TPlateList)
	
	local i as integer
	local k as integer
	local Radius as float
	local NearestPoint as TPosition
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			// ObjectData.Radius was calculated at spawn with SpriteData.Scale = 0.15.
			// Follow the current visual growth without changing other flame collision rules.
			Radius = FlameCollisionRadius(FlameList.Flame[i])
			for k = 0 to ChestList.Chest.Length
				if ChestList.Chest[k].Enabled = TRUE and WeaponDepthAllows(FlameList.Flame[i].WeaponDepth,PlateList,ChestList.Chest[k].CollisionData.Index,ChestList.Chest[k].IsBackground) = TRUE
					// Closest point on the chest AABB to the flame-circle center.
					NearestPoint = FlameList.Flame[i].ObjectData.Position
					if NearestPoint.x < ChestList.Chest[k].CollisionData.Position1.x then NearestPoint.x = ChestList.Chest[k].CollisionData.Position1.x
					if NearestPoint.x > ChestList.Chest[k].CollisionData.Position2.x then NearestPoint.x = ChestList.Chest[k].CollisionData.Position2.x
					if NearestPoint.y < ChestList.Chest[k].CollisionData.Position1.y then NearestPoint.y = ChestList.Chest[k].CollisionData.Position1.y
					if NearestPoint.y > ChestList.Chest[k].CollisionData.Position2.y then NearestPoint.y = ChestList.Chest[k].CollisionData.Position2.y
					if CalcRadius(FlameList.Flame[i].ObjectData.Position,NearestPoint) <= Radius
						if FlameCanDamage(FlameList.Flame[i],ChestList.Chest[k].FlameTargetId,Now) = TRUE
							ChestList.Chest[k].Health.State = ChestList.Chest[k].Health.State - FlameList.Flame[i].BulletData.Damage
							ColorSet(ChestList.Chest[k].SpriteData.Color,255,0,0,255)
						endif
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// Player flame vs. the existing Walker turret hit zone.
// Use the same growing flame circle as chest collisions, without changing
// the Walker's accepted pose, animation or projectile damage values.
//----------------------------------------------------------------------

function FlameCollideWalkers(FlameList ref as TFlameList,WalkerList ref as TWalkerList,Now as integer,PlateList ref as TPlateList)

	local i as integer
	local k as integer
	local Radius as float
	local NearestPoint as TPosition

	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			Radius = FlameCollisionRadius(FlameList.Flame[i])
			for k = 0 to WalkerList.Walker.Length
				if WalkerList.Walker[k].Enabled = TRUE and FlameList.Flame[i].Enabled = TRUE and WeaponDepthAllows(FlameList.Flame[i].WeaponDepth,PlateList,WalkerList.Walker[k].PlateIndex,FALSE) = TRUE
					NearestPoint = FlameList.Flame[i].ObjectData.Position
					if NearestPoint.x < WalkerList.Walker[k].WalkerCollisionData.Tower.Position1.x then NearestPoint.x = WalkerList.Walker[k].WalkerCollisionData.Tower.Position1.x
					if NearestPoint.x > WalkerList.Walker[k].WalkerCollisionData.Tower.Position2.x then NearestPoint.x = WalkerList.Walker[k].WalkerCollisionData.Tower.Position2.x
					if NearestPoint.y < WalkerList.Walker[k].WalkerCollisionData.Tower.Position1.y then NearestPoint.y = WalkerList.Walker[k].WalkerCollisionData.Tower.Position1.y
					if NearestPoint.y > WalkerList.Walker[k].WalkerCollisionData.Tower.Position2.y then NearestPoint.y = WalkerList.Walker[k].WalkerCollisionData.Tower.Position2.y
					if CalcRadius(FlameList.Flame[i].ObjectData.Position,NearestPoint) <= Radius
						if FlameCanDamage(FlameList.Flame[i],WalkerList.Walker[k].FlameTargetId,Now) = TRUE
							WalkerList.Walker[k].Health.State = WalkerList.Walker[k].Health.State - FlameList.Flame[i].BulletData.Damage
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

// D5b: player flames damage the drone using the existing growing flame radius.
function FlameCollideFlaraks(FlameList ref as TFlameList,Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local R as float
    for i = 0 to FlameList.Flame.Length
        if FlameList.Flame[i].Enabled = TRUE
            R = FlameCollisionRadius(FlameList.Flame[i])
            for k = 0 to FlarakList.Length
                if FlameList.Flame[i].Enabled = TRUE and FlarakList[k].Enabled = TRUE and FlarakList[k].Destroyed = FALSE and WeaponDepthAllows(FlameList.Flame[i].WeaponDepth,Game.PlateList,FlarakList[k].PlateIndex,FALSE) = TRUE
                    if FlarakAreaHits(FlarakList[k],Game.World,FlameList.Flame[i].ObjectData.Position.x,FlameList.Flame[i].ObjectData.Position.y,R,R,TRUE)
                        if FlameCanDamage(FlameList.Flame[i],FlarakList[k].FlameTargetId,Now) = TRUE
                            FlarakApplyDamage(FlarakList[k],Game,FlameList.Flame[i].BulletData.Damage,Now)
                        endif
                    endif
                endif
            next k
        endif
    next i
endfunction

function FlameCollideDrone(FlameList ref as TFlameList,Drone ref as TDrone,Now as integer)
    local i as integer
    local NearestPoint as TPosition
    local Radius as float
    for i = 0 to FlameList.Flame.Length
        if Drone.Enabled = TRUE and FlameList.Flame[i].Enabled = TRUE
            NearestPoint = FlameList.Flame[i].ObjectData.Position
            if NearestPoint.x < Drone.Position.x-23 then NearestPoint.x = Drone.Position.x-23
            if NearestPoint.x > Drone.Position.x+23 then NearestPoint.x = Drone.Position.x+23
            if NearestPoint.y < Drone.Position.y-15 then NearestPoint.y = Drone.Position.y-15
            if NearestPoint.y > Drone.Position.y+15 then NearestPoint.y = Drone.Position.y+15
            Radius = FlameCollisionRadius(FlameList.Flame[i])
            if CalcRadius(FlameList.Flame[i].ObjectData.Position,NearestPoint) <= Radius
                if FlameCanDamage(FlameList.Flame[i],Drone.FlameTargetId,Now) = TRUE
                    DroneTakeDamage(Drone,FlameList.Flame[i].BulletData.Damage)
                endif
            endif
        endif
    next i
endfunction

// The legacy drag is 0.01 per update at the 60 Hz reference.
function FlameBrakeSpeed(Speed as float,Brake as float)
	if Speed > 0
		if Speed <= Brake then exitfunction 0.0
		exitfunction Speed-Brake
	endif
	if Speed < 0
		if -Speed <= Brake then exitfunction 0.0
		exitfunction Speed+Brake
	endif
endfunction 0.0

// Integrate linear drag over the actual elapsed range; stop at zero,
// including when a long update would otherwise overshoot the stopping time.
function FlameAxisDistance(OldSpeed as float,NewSpeed as float,Brake as float,StepRange as float)
	if Brake > 0 and abs(OldSpeed) < Brake
		StepRange = StepRange*abs(OldSpeed)/Brake
	endif
endfunction (OldSpeed+NewSpeed)*0.5*StepRange

function FlameMove(Flame ref as TFlame,World ref as TWorld,Now as integer)

	local OldSpeed as TSpeed
	local Brake as TSpeed
	local StepRange as float
	local ReferenceSteps as float

	if Flame.Enabled = TRUE
		Flame.PreviousPosition = Flame.ObjectData.Position
		// On a closed gate the displayed projectile remains at its current pose.
		Flame.SweepStartMs = SonecDamageFrameStartMs
		if Flame.ObjectData.MoveTimer.Stamp > Flame.SweepStartMs then Flame.SweepStartMs = Flame.ObjectData.MoveTimer.Stamp
		Flame.SweepEndMs = Now
		if TimeGet(Flame.ObjectData.MoveTimer,Now) > 0
			Flame.SweepStartMs = Flame.ObjectData.MoveTimer.Stamp
			
			StepRange = Flame.ObjectData.MoveTimer.CalcRange
			ReferenceSteps = Flame.ObjectData.MoveTimer.FullDifference*0.06
			OldSpeed = Flame.ObjectData.MoveSpeed
			Brake.x = Flame.ObjectData.MoveAcceleration.x*ReferenceSteps
			Brake.y = Flame.ObjectData.MoveAcceleration.y*ReferenceSteps
			Flame.ObjectData.MoveSpeed.x = FlameBrakeSpeed(OldSpeed.x,Brake.x)
			Flame.ObjectData.MoveSpeed.y = FlameBrakeSpeed(OldSpeed.y,Brake.y)
			Flame.ObjectData.Position.x = Flame.ObjectData.Position.x + FlameAxisDistance(OldSpeed.x,Flame.ObjectData.MoveSpeed.x,Brake.x,StepRange)
			Flame.ObjectData.Position.y = Flame.ObjectData.Position.y + FlameAxisDistance(OldSpeed.y,Flame.ObjectData.MoveSpeed.y,Brake.y,StepRange)
			
			SpritePositionCalc(Flame.SpriteData.Position,Flame.ObjectData.Position,World.Position)
			
			Flame.CollisionData.Position1.x = Flame.ObjectData.Position.x - Flame.ObjectData.Size.Width  * 0.5
			Flame.CollisionData.Position1.y = Flame.ObjectData.Position.y - Flame.ObjectData.Size.Height * 0.5
			Flame.CollisionData.Position2.x = Flame.ObjectData.Position.x + Flame.ObjectData.Size.Width  * 0.5
			Flame.CollisionData.Position2.y = Flame.ObjectData.Position.y + Flame.ObjectData.Size.Height * 0.5
			
			TimeReset(Flame.ObjectData.MoveTimer,Now)
			
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameMoveAll(FlameList ref as TFlameList,World ref as TWorld,Now as integer)
	local i as integer
	for i = 0 to FlameList.Flame.Length
		FlameMove(FlameList.Flame[i],World,Now)
	next i
endfunction

function FlameCullAll(FlameList ref as TFlameList,World ref as TWorld)

	Local i as integer
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			if FlameList.Flame[i].ObjectData.Position.y < -FlameList.Flame[i].ObjectData.Size.Height
				FlameDelete(FlameList,i)
			else
				if FlameList.Flame[i].ObjectData.Position.y > World.Size.Height+FlameList.Flame[i].ObjectData.Size.Height
					FlameDelete(FlameList,i)
				else
					if FlameList.Flame[i].ObjectData.Position.x > World.Size.Width+FlameList.Flame[i].ObjectData.Size.Width
						FlameDelete(FlameList,i)
					else
						if FlameList.Flame[i].ObjectData.Position.x < -FlameList.Flame[i].ObjectData.Size.Width
							FlameDelete(FlameList,i)
						endif
					endif
				endif
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameLifeCycle(FlameList ref as TFlameList,Now as integer)
	
	local i as integer
	
	for i = 0 to FlameList.Flame.Length
		
		if FlameList.Flame[i].Enabled = TRUE
			if FlameList.Flame[i].EffectData.LifeCycle < FlameList.Flame[i].EffectData.LifeCycleMax
				if TimeGet(FlameList.Flame[i].EffectData.LifeCycleTimer,Now) > 0
					FlameList.Flame[i].EffectData.LifeCycle = FlameList.Flame[i].EffectData.LifeCycle +1
					
					FlameList.Flame[i].SpriteData.Scale = 0.15+0.85*sqrt(FlameList.Flame[i].EffectData.LifeCycle)/sqrt(FlameList.Flame[i].EffectData.LifeCycleMax)
					
					ColorSet(FlameList.Flame[i].SpriteData.Color,0,255,0,255-200*FlameList.Flame[i].EffectData.LifeCycle/FlameList.Flame[i].EffectData.LifeCycleMax)
					TimeReset(FlameList.Flame[i].EffectData.LifeCycleTimer,Now)
				endif
			else
				FlameDelete(FlameList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameDraw(Flame ref as TFlame,ProtoFlame ref as TProtoFlame)
	
	if Flame.Enabled = TRUE
		SpriteDraw(ProtoFlame.AnimFlame.Sprite,Flame.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameDrawAll(FlameList ref as TFlameList,ProtoFlame ref as TProtoFlame)
	
	local i as integer
	
	for i = 0 to FlameList.Flame.Length
		FlameDraw(FlameList.Flame[i],ProtoFlame)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameCountAll(FlameList ref as TFlameList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------


