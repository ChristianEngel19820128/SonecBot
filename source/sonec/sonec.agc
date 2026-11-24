// Shared Sonec damage hitbox: two body circles, including the ducking pose.
// Keep these values aligned with the locally tested K1d enemy-bullet geometry.
#constant SONEC_DUCK_SECOND_CIRCLE_Y 10
#constant SONEC_CHEST_CONTACT_EPSILON 0.5
#constant SONEC_CHEST_SWEEP_EPSILON 0.01
#constant SONEC_CHEST_SWEEP_ITERATIONS 18
#constant SONEC_COUNTERSTEER_FACTOR 1.5
#constant SONEC_GROUND_COAST_FACTOR 0.75
#constant SONEC_AIR_COAST_FACTOR 0.1
#constant SONEC_COAST_ZERO_SPEED 0.25
#constant SONEC_BALANCE_X_STEP 0.5
#constant SONEC_HOVER_AIR_DAMPING 0.20
#constant SONEC_MAX_GROUND_SPEED 5
#constant SONEC_MAX_VERTICAL_SPEED 8
#constant SONEC_GROUND_ACCELERATION 0.005
#constant SONEC_VERTICAL_ACCELERATION 0.01
#constant SONEC_NORMAL_ACCELERATION_FACTOR 1.0
#constant SONEC_CAMERA_EDGE_MARGIN 10
#constant SONEC_CAMERA_UPPER_FRACTION 0.33
#constant SONEC_CAMERA_LOWER_FRACTION 0.66

function SonecHitCircleRadius(Sonec ref as TSonec)
    local Radius as float
    Radius = Sonec.ObjectData.Size.Width*0.30
    if Sonec.State.Stand = TRUE and Sonec.State.Duck = TRUE
        Radius = Sonec.ObjectData.Size.Width*0.32
    endif
endfunction Radius

function SonecHitCircleY(Sonec ref as TSonec,Index as integer)
    local CenterY as float
    local OffsetY as float
    CenterY = Sonec.ObjectData.Position.y
    if Sonec.State.Stand = TRUE and Sonec.State.Duck = TRUE
        if Index = 1 then CenterY = CenterY+SONEC_DUCK_SECOND_CIRCLE_Y
    else
        OffsetY = Sonec.ObjectData.Size.Height*0.18
        if Index = 0
            CenterY = CenterY-OffsetY
        else
            CenterY = CenterY+OffsetY
        endif
    endif
endfunction CenterY


//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoSonecAnimLoad(ProtoSonecAnim ref as TProtoSonecAnimation)
	
	local i as integer
	
	if ImageLoad(ProtoSonecAnim.Stand.Image) = TRUE
		SpriteLoad(ProtoSonecAnim.Stand)
	endif
	
	if ImageLoad(ProtoSonecAnim.Fly.Image) = TRUE
		SpriteLoad(ProtoSonecAnim.Fly)
	endif
	
	if ImageLoad(ProtoSonecAnim.Duck.Image) = TRUE
		SpriteLoad(ProtoSonecAnim.Duck)
	endif
	
	for i = 0 to ProtoSonecAnim.AnimWalk.Length
		if ImageLoad(ProtoSonecAnim.AnimWalk[i].Image) = TRUE
			SpriteLoad(ProtoSonecAnim.AnimWalk[i])
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoSonecLoad(ProtoSonec ref as TProtoSonec,File as TFilePath)
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoSonec.FromJson(ReadFileString(File))
		
		ProtoSonecAnimLoad(ProtoSonec.AnimRight)
		ProtoSonecAnimLoad(ProtoSonec.AnimLeft)
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

global SonecHitFlashUntil as integer

#constant SONEC_HIT_FLASH_MS 150

function SonecVisualUpdate(Sonec ref as TSonec,Now as integer)
	if Now < SonecHitFlashUntil
		ColorSet(Sonec.SpriteData.Color,255,0,0,255)
	else
		ColorSet(Sonec.SpriteData.Color,80,232,80,255)
	endif
endfunction

function SonecInit(Sonec ref as TSonec,ProtoSonec ref as TProtoSonec,World ref as TWorld,Screen as TSize,Now as integer)

	TimeSet(Sonec.AnimationData.AnimTimer,50,1)
	TimeReset(Sonec.AnimationData.AnimTimer,Now)
	TimeSet(Sonec.ObjectData.MoveTimer,10,10)
	TimeReset(Sonec.ObjectData.MoveTimer,Now)
	TimeSet(Sonec.InputTimer,15,1)
	TimeReset(Sonec.InputTimer,Now)
	TimeSet(Sonec.InputActionTimer,15,1)
	TimeReset(Sonec.InputActionTimer,Now)

	Sonec.IsLost = False
	Sonec.BalanceActive = FALSE
	Sonec.BalanceTargetX = 0

	Sonec.AnimationData.Frame = 0
	Sonec.AnimationData.RepeatAnimation = TRUE
	Sonec.AnimationData.Finished = FALSE
		
	Sonec.CollisionData.Index = -1
	Sonec.GroundContactActive = FALSE

	Sonec.State.Fall  = TRUE
	Sonec.State.Fly   = FALSE
	Sonec.State.Hover = FALSE
	Sonec.State.Duck  = FALSE
	Sonec.State.Move  = FALSE
	Sonec.State.Jump  = FALSE
	Sonec.State.LookAlignment = LOOKRIGHT
	Sonec.State.Alignment = MOVERIGHT
	
	Sonec.ObjectData.Position.x = Screen.Width/4
	// Start completely above the visible world; enter naturally after touchdown.
    Sonec.ObjectData.Position.y = -GetSpriteHeight(ProtoSonec.AnimRight.Stand.Sprite.ID)*0.5-8
    Sonec.SpawnEntering = TRUE
	Sonec.CollisionMoveStart = Sonec.ObjectData.Position
	Sonec.CollisionMoveEnd = Sonec.ObjectData.Position
	Sonec.PassThroughChestIndex = -1
	Sonec.LinkedPlateIndex = -1
	Sonec.BlockedChestIndex = -1
	Sonec.BlockedChestSide = 0
	Sonec.BlockedChestOffsetX = 0
	
	Sonec.ObjectData.MoveSpeedMax.x = SONEC_MAX_GROUND_SPEED
	Sonec.ObjectData.MoveSpeedMax.y = SONEC_MAX_VERTICAL_SPEED
	Sonec.ObjectData.MoveSpeed.x = 0
	Sonec.ObjectData.MoveSpeed.y = 0
	Sonec.ObjectData.MoveAcceleration.x = SONEC_GROUND_ACCELERATION
	Sonec.ObjectData.MoveAcceleration.y = SONEC_VERTICAL_ACCELERATION
	
	Sonec.ObjectData.AutoSpeed.x = 0
	Sonec.ObjectData.AutoSpeed.y = 0
	
	Sonec.ObjectData.Size.Width = GetSpriteWidth(ProtoSonec.AnimRight.Stand.Sprite.ID)
	Sonec.ObjectData.Size.Height = GetSpriteHeight(ProtoSonec.AnimRight.Stand.Sprite.ID)
	
	Sonec.ObjectData.Radius = Sonec.ObjectData.Size.Width * 0.5
	
	Sonec.SpriteData.Angle = 0
	Sonec.SpriteData.Scale = 1
	Sonec.SpriteData.Center = TRUE
	SonecHitFlashUntil = 0
	ColorSet(Sonec.SpriteData.Color,80,232,80,255)
	
	SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
	
	Sonec.EnergyShield.StateMax = 250
	Sonec.EnergyShield.State = 0
	Sonec.EnergyShield.DamageTrailAmount = 0
	Sonec.EnergyShield.DamageTrailStartMs = 0
	Sonec.EnergyShield.DamageTrailEndMs = 0
	Sonec.EnergyShield.StateChange = 1
	
	Sonec.Energy.StateMax = 4000
	// HUD overload smoke test: start 500 above the normal capacity.
	Sonec.Energy.State = 4500
	Sonec.Energy.RegRate = 500
	
	TimeSet(Sonec.Energy.AttractTimer,15,1)
	TimeReset(Sonec.Energy.AttractTimer,Now)
	TimeSet(Sonec.Energy.RegenerationTimer,Sonec.Energy.RegRate,1)
	TimeReset(Sonec.Energy.RegenerationTimer,Now)
	
	Sonec.Health.StateMax = 1000
	Sonec.Health.State = 1000
	Sonec.Health.RegRate = 500
	
	TimeSet(Sonec.Health.RegenerationTimer,Sonec.Health.RegRate,1)
	TimeReset(Sonec.Health.RegenerationTimer,Now)
	
	Sonec.MGun.FlashIndex = -1
	
	Sonec.MGun.FireRate = 800
	Sonec.MGun.FireBurstMax = 1
	Sonec.MGun.FireBurstLimit = 3
	Sonec.MGun.AmmoMax = 300
	Sonec.MGun.Ammo = 300
	Sonec.MGun.FireBurstRate = 200
	
	TimeSet(Sonec.MGun.FireTimer,Sonec.MGun.FireRate,1)
	TimeReset(Sonec.MGun.FireTimer,Now)
	TimeSet(Sonec.MGun.FireBurstTimer,Sonec.MGun.FireBurstRate,1)
	TimeReset(Sonec.MGun.FireBurstTimer,Now)
	
	Sonec.GrenadeLauncher.FireRate = 1000
	Sonec.GrenadeLauncher.AmmoMax = 50
	Sonec.GrenadeLauncher.Ammo = 50
	
	TimeSet(Sonec.GrenadeLauncher.FireTimer,Sonec.GrenadeLauncher.FireRate,1)
	TimeReset(Sonec.GrenadeLauncher.FireTimer,Now)
	
	TimeSet(Sonec.FlameGun.FireTimer,50,1)
	TimeReset(Sonec.FlameGun.FireTimer,Now)
	
	Sonec.PlasmaBlitzGun.FlashIndex = -1
	Sonec.PlasmaBlitzGun.PlasmaBlitzIndex = -1
	Sonec.PlasmaBlitzGun.UploadMax = 100

	TimeSet(Sonec.PlasmaBlitzGun.FireTimer,300,1)
	TimeReset(Sonec.PlasmaBlitzGun.FireTimer,Now)
	TimeSet(Sonec.PlasmaBlitzGun.UploadTimer,10,1)
	TimeReset(Sonec.PlasmaBlitzGun.UploadTimer,Now)
	
	SonecCollideReset(Sonec)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecHealthRegenerate(Sonec ref as TSonec,Now as integer)
	
	local Overload as integer
	
	if TimeGet(Sonec.Health.RegenerationTimer,Now) > 0
		if Sonec.Energy.State > Sonec.Energy.StateMax
			Overload = Sonec.Energy.State - Sonec.Energy.StateMax
			Overload = Overload / 100
			Sonec.Health.State = Sonec.Health.State - COSTOVERLOAD * Overload
		else
			if Sonec.Health.State + REGHEALTH <= Sonec.Health.StateMax
				Sonec.Health.State = Sonec.Health.State + REGHEALTH
			else
				if Sonec.Health.State < Sonec.Health.StateMax
					Sonec.Health.State = Sonec.Health.StateMax
				endif
			endif
		endif
		TimeReset(Sonec.Health.RegenerationTimer,Now)
	endif
	if Sonec.Health.State < 0 then Sonec.IsLost = TRUE
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecEnergyRegenerate(Sonec ref as TSonec,Now as integer)
	if TimeGet(Sonec.Energy.RegenerationTimer,Now) > 0
		if Sonec.Energy.State + REGENERGY <= Sonec.Energy.StateMax
			Sonec.Energy.State = Sonec.Energy.State + REGENERGY
		else
			if Sonec.Energy.State < Sonec.Energy.StateMax
				Sonec.Energy.State = Sonec.Energy.StateMax
			endif
		endif
		TimeReset(Sonec.Energy.RegenerationTimer,Now)
	endif
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecJetfireAdd(Sonec ref as TSonec,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Position as TPosition,Now as integer)

	if Sonec.Energy.State >= COSTJETFIRE
		if JetfireAdd(JetfireList,ProtoJetfire,World,Position,Now) = TRUE
			Sonec.Energy.State = Sonec.Energy.State - COSTJETFIRE
		endif
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecRefreshAnimations(Sonec ref as TSonec,PlasmaBlitzList ref as TPlasmaBlitzList,FlashList ref as TFlashList,World ref as TWorld)
	
	local Position as TPosition
	local Angle as float
	local Radius as float
	
	Position.x = Sonec.ObjectData.Position.x
	
	if Sonec.State.Duck = TRUE
		Position.y = Sonec.ObjectData.Position.y + 4
	else
		Position.y = Sonec.ObjectData.Position.y - 6
	endif
	
	if Sonec.State.LookAlignment = LOOKLEFT
		Angle = 270
	else
		Angle = 90
	endif
	
	FlashRefresh(FlashList,World,Sonec.MGun.FlashIndex,Position,Angle)
	FlashRefresh(FlashList,World,Sonec.PlasmaBlitzGun.FlashIndex,Position,Angle)
	PlasmaBlitzRefresh(PlasmaBlitzList,Sonec.PlasmaBlitzGun.PlasmaBlitzIndex,Position,Angle,World)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecFlameGunInput(Sonec ref as TSonec,FlameList ref as TFlameList,ProtoFlame ref as TProtoFlame,World ref as TWorld,Sound ref as TSound,Keys ref as TKeys,JoystickIndex as integer,Now as integer)
	
	local Position as TPosition
	local Angle as float
	local Radius as float
	
	if (InputActionState(Keys,JoystickIndex,ACTION_FIRE_FLAME) = 1 )and Sonec.Energy.State >= COSTFLAME
		if TimeGet(Sonec.FlameGun.FireTimer,Now) > 0
			
			if Sonec.State.LookAlignment = LOOKLEFT
				Angle = 270
			else
				Angle = 90
			endif
			
			Radius = 25
			
			Sonec.ObjectData.Angle = Angle
			Position.x = Sonec.ObjectData.Position.x
			
			if Sonec.State.Duck = TRUE
				Position.y = Sonec.ObjectData.Position.y + 4
			else
				Position.y = Sonec.ObjectData.Position.y - 6
			endif
			
			if GetSoundInstances(Sound.MFlameSound) = 0
				SoundPlay(Sound.MFlameSound)
			endif
			
			FlameAdd(FlameList,ProtoFlame,World,Sonec.ObjectData,Position,Angle,Radius,Now)
			Sonec.Energy.State = Sonec.Energy.State - COSTFLAME
			
			TimeReset(Sonec.FlameGun.FireTimer,Now)
			
		endif
	endif
			
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecPlasmaBlitzGunInput(Sonec ref as TSonec,FlashList ref as TFlashList,ProtoFlash ref as TProtoFlash,PlasmaBlitzList ref as TPlasmaBlitzList,ProtoPlasmaBlitz ref as TProtoPlasmaBlitz,World ref as TWorld,Keys ref as TKeys,JoystickIndex as integer,Now as integer)
	
	local Position as TPosition
	local Angle as float
	local Radius as float
	
	if (InputActionState(Keys,JoystickIndex,ACTION_FIRE_PLASMA) = 1) and Sonec.Energy.State >= COSTPLASMABLITZ
		if TimeGet(Sonec.PlasmaBlitzGun.FireTimer,Now) > 0
			
			if Sonec.State.LookAlignment = LOOKLEFT
				Angle = 270
			else
				Angle = 90
			endif
			
			Sonec.ObjectData.Angle = Angle
			Position.x = Sonec.ObjectData.Position.x
			
			if Sonec.State.Duck = TRUE
				Position.y = Sonec.ObjectData.Position.y + 4
			else
				Position.y = Sonec.ObjectData.Position.y - 6
			endif
			
			if Sonec.PlasmaBlitzGun.FlashIndex = -1
				TimeReset(Sonec.PlasmaBlitzGun.UploadTimer,Now)
				Radius = 25+18
				Sonec.PlasmaBlitzGun.FlashIndex = FlashAdd(FlashList,ProtoFlash,World,1,Sonec.PlasmaBlitzGun.UploadMax,Position,Angle,Radius,Now)
			endif
			
			if Sonec.PlasmaBlitzGun.FlashIndex >= 0 and Sonec.Energy.State >= COSTPLASMABLITZ
				if TimeGet(Sonec.PlasmaBlitzGun.UploadTimer,Now) > 0
					Sonec.PlasmaBlitzGun.Upload = Sonec.PlasmaBlitzGun.Upload +1
					Sonec.Energy.State = Sonec.Energy.State - COSTPLASMABLITZ
					TimeReset(Sonec.PlasmaBlitzGun.UploadTimer,Now)
					if Sonec.PlasmaBlitzGun.Upload >= Sonec.PlasmaBlitzGun.UploadMax
						Sonec.PlasmaBlitzGun.Upload = 0
						Sonec.PlasmaBlitzGun.FlashIndex = -1
						Radius = 25
						Sonec.PlasmaBlitzGun.PlasmaBlitzIndex = PlasmaBlitzAdd(PlasmaBlitzList,ProtoPlasmaBlitz,World,Position,Angle,Radius,Now)
						TimeReset(Sonec.PlasmaBlitzGun.FireTimer,Now)
					endif
				endif
			endif
			
		endif
	else
		Sonec.PlasmaBlitzGun.Upload = 0
		FlashDelete(FlashList,Sonec.PlasmaBlitzGun.FlashIndex)
		Sonec.PlasmaBlitzGun.FlashIndex = -1
		Sonec.PlasmaBlitzGun.PlasmaBlitzIndex = -1
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecMGunInput(Sonec ref as TSonec,FlashList ref as TFlashList,ProtoFlash ref as TProtoFlash,BulletList ref as TBulletList,ProtoBullet ref as TProtoBullet,World ref as TWorld,Sound ref as TSound,Keys ref as TKeys,JoystickIndex as integer,Now as integer)
	
	local Position as TPosition
	local Angle as float
	local Radius as float
	
	if (InputActionState(Keys,JoystickIndex,ACTION_FIRE_MG) = 1 or Sonec.MGun.FireBurst > 0) and Sonec.MGun.Ammo > 0
		if (Sonec.MGun.FireBurst = 0 and TimeGet(Sonec.MGun.FireTimer,Now) > 0)  or (Sonec.MGun.FireBurst > 0 and TimeGet(Sonec.MGun.FireBurstTimer,Now) > 0)
			
			if Sonec.MGun.FireBurst = 0 then Sonec.MGun.FireBurst = Sonec.MGun.FireBurstMax
			
			Position.x = Sonec.ObjectData.Position.x
			
			if Sonec.State.Duck = TRUE
				Position.y = Sonec.ObjectData.Position.y + 4
			else
				Position.y = Sonec.ObjectData.Position.y - 6
			endif
			
			if Sonec.State.LookAlignment = LOOKLEFT
				Angle = 270
			else
				Angle = 90
			endif
			
			Sonec.MGun.Ammo = Sonec.MGun.Ammo -1
			if Sonec.MGun.FireBurst > 0
				Sonec.MGun.FireBurst = Sonec.MGun.FireBurst-1
				if Sonec.MGun.Ammo = 0
					Sonec.MGun.FireBurst = 0
				endif
			endif
			
			Radius = 33
			if Sonec.MGun.FlashIndex >= 0
				FlashDelete(FlashList,Sonec.MGun.FlashIndex)
			endif
			SoundPlay(Sound.MGunSound)
			Sonec.MGun.FlashIndex = FlashAdd(FlashList,ProtoFlash,World,0,10,Position,Angle,Radius,Now)
			Radius = 25
			BulletAdd(BulletList,ProtoBullet,World,Position,Angle,Radius,TYPEPLAYERONE,Now)
			TimeReset(Sonec.MGun.FireTimer,Now)
			TimeReset(Sonec.MGun.FireBurstTimer,Now)
			
		endif
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecGrenadeLauncherInput(Sonec ref as TSonec,GrenadeList ref as TGrenadeList,ProtoGrenade ref as TProtoGrenade,World ref as TWorld,Sound ref as TSound,Keys ref as TKeys,JoystickIndex as integer,Now as integer)
	
	local Position as TPosition
	local Angle as float
	local Radius as float
	local Recoil as float
	
	if (InputActionState(Keys,JoystickIndex,ACTION_FIRE_GRENADE) = 1) and Sonec.GrenadeLauncher.Ammo > 0
		if TimeGet(Sonec.GrenadeLauncher.FireTimer,Now) > 0
			
			Position.x = Sonec.ObjectData.Position.x
			
			if Sonec.State.Duck = TRUE
				Position.y = Sonec.ObjectData.Position.y + 4
			else
				Position.y = Sonec.ObjectData.Position.y - 6
			endif
			
			if Sonec.State.LookAlignment = LOOKLEFT
				Angle = 270
			else
				Angle = 90
			endif
			
			Sonec.GrenadeLauncher.Ammo = Sonec.GrenadeLauncher.Ammo -1
				
			SoundPlay(Sound.GrenadeLauncherSound)
			Radius = 25
			GrenadeAdd(GrenadeList,ProtoGrenade,World,Position,Angle,Radius,Now)
			TimeReset(Sonec.GrenadeLauncher.FireTimer,Now)
			
			Recoil = 1
			
			if Sonec.State.LookAlignment = LOOKRIGHT
				
				if Sonec.State.Move = TRUE and Sonec.State.Alignment = MOVELEFT
					Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x - Recoil
				endif
				if Sonec.State.Move = FALSE
					Sonec.ObjectData.MoveSpeed.x = -Recoil
					Sonec.State.Alignment = MOVELEFT
					Sonec.State.Move = TRUE
					Sonec.State.Stand = FALSE
				endif
				
				if Sonec.State.Move = TRUE and Sonec.State.Alignment = MOVERIGHT
					Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x - Recoil
					if Sonec.ObjectData.MoveSpeed.x < 0
						Sonec.State.Alignment = MOVELEFT
					endif
				endif
							
			endif
			
			if Sonec.State.LookAlignment = LOOKLEFT
				
				if Sonec.State.Move = TRUE and Sonec.State.Alignment = MOVERIGHT
					Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x + Recoil
				endif
				if Sonec.State.Move = FALSE
					Sonec.ObjectData.MoveSpeed.x = Recoil
					Sonec.State.Alignment = MOVERIGHT
					Sonec.State.Move = TRUE
					Sonec.State.Stand = FALSE
				endif
				
				if Sonec.State.Move = TRUE and Sonec.State.Alignment = MOVELEFT
					Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x + Recoil
					if Sonec.ObjectData.MoveSpeed.x > 0
						Sonec.State.Alignment = MOVERIGHT
					endif
				endif
							
			endif
			
			if Sonec.ObjectData.MoveAcceleration.x > Sonec.ObjectData.MoveSpeedMax.x
				//Sonec.ObjectData.MoveAcceleration.x = Sonec.ObjectData.MoveSpeedMax.x
			endif
				
		endif
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecShieldInput(Sonec ref as TSonec,Shield ref as TShield,World ref as TWorld,Keys ref as TKeys,JoystickIndex as integer,Now as integer)

	local Position as TPosition
	
	if InputActionPressed(Keys,JoystickIndex,ACTION_SHIELD) = 1
		if Shield.Enabled = FALSE
			if Sonec.Energy.State >= COSTSHIELD
				Shield.Enabled = TRUE
				Shield.AnimationData.FrameAlignment = 0
				Shield.AnimationData.Initialize = TRUE
				Shield.AnimationData.Uninitialize = FALSE
			endif
		else
			if Shield.AnimationData.Uninitialize = TRUE
				// Reverse dismantling without resetting the current charge.
				if Sonec.Energy.State >= COSTSHIELD
					Shield.AnimationData.FrameAlignment = 0
					Shield.AnimationData.Initialize = TRUE
					Shield.AnimationData.Uninitialize = FALSE
				endif
			else
				Shield.AnimationData.FrameAlignment = 1
				Shield.AnimationData.Initialize = FALSE
				Shield.AnimationData.Uninitialize = TRUE
			endif
		endif
		
	endif

	if Shield.Enabled = TRUE
		
		Position.x = Sonec.ObjectData.Position.x
			
		if Sonec.State.Duck = TRUE
			Position.y = Sonec.ObjectData.Position.y + 4
		else
			Position.y = Sonec.ObjectData.Position.y
		endif
			
		ShieldRefresh(Shield,World,Position,Now)
		
		if TimeGet(Sonec.EnergyShield.ShieldTimer,Now) > 0
			if Shield.AnimationData.Uninitialize = FALSE
				if Sonec.Energy.State >= COSTSHIELD
					Sonec.Energy.State = Sonec.Energy.State - COSTSHIELD
				else
					Shield.AnimationData.FrameAlignment = 1
					Shield.AnimationData.Initialize = FALSE
					Shield.AnimationData.Uninitialize = TRUE
				endif
			endif
			TimeReset(Sonec.EnergyShield.ShieldTimer,Now)
		endif
		
	else
		ShieldReset(Shield,Sonec.EnergyShield.StateMax,Now)
		Sonec.EnergyShield.State = 0
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecInenergieInput(Sonec ref as TSonec,Inenergie ref as TInenergie,EnergieList ref as TEnergieList,World ref as TWorld,Keys ref as TKeys,JoystickIndex as integer,Now as integer)
	
	local Position as TPosition
	
	if InputActionPressed(Keys,JoystickIndex,ACTION_ATTRACT_ENERGY) = 1
		if Inenergie.Enabled = FALSE
			if Sonec.Energy.State >= COSTATTRACT
				Inenergie.Enabled = TRUE
				Sonec.Energy.State = Sonec.Energy.State - COSTATTRACT
			endif
		else
			Inenergie.Enabled = FALSE			
		endif
	endif
	
	if Inenergie.Enabled = TRUE 
	
		Position.x = Sonec.ObjectData.Position.x
			
		if Sonec.State.Duck = TRUE
			Position.y = Sonec.ObjectData.Position.y + 4
		else
			Position.y = Sonec.ObjectData.Position.y
		endif
		
		InenergieRefresh(Inenergie,World,Position,Now)
		
		if TimeGet(Sonec.Energy.AttractTimer,Now) > 0
			TimeReset(Sonec.Energy.AttractTimer,Now)
			EnergieAttract(EnergieList,Sonec.ObjectData.Position,Now)
		endif
		
		if Inenergie.AnimationData.Frame >= Inenergie.AnimationData.FrameMax
			if Sonec.Energy.State >= COSTATTRACT
				Sonec.Energy.State = Sonec.Energy.State - COSTATTRACT
			else
				Inenergie.Enabled = FALSE
				InenergieReset(Inenergie,Now)
			endif
		endif
		
	else
		InenergieReset(Inenergie,Now)
	endif
			
			
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Phase A2: Keep all Up-button flight/jump/fall transitions in one place.
// This extraction preserves the old branch priority and energy thresholds.
// It does not yet redefine the physical grounded/contact model.
function SonecInputVerticalState(Sonec ref as TSonec,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Position as TPosition,UpHeld as integer,Now as integer)
	if UpHeld and ((Sonec.State.Fly = FALSE and Sonec.Energy.State > COSTJETFIRE*10) or (Sonec.State.Fly = TRUE and Sonec.Energy.State >= COSTJETFIRE))
		if Sonec.State.Fly = FALSE
			Sonec.Energy.State = Sonec.Energy.State - COSTJETFIRE*10
		endif
		Sonec.State.Fly = TRUE
		Sonec.State.Fall = FALSE
		Sonec.State.Stand = FALSE
		Sonec.GroundContactActive = FALSE
		Sonec.AnimationData.Frame = 0
		SonecJetfireAdd(Sonec,JetfireList,ProtoJetfire,World,Position,Now)
	else
		if UpHeld and Sonec.State.Stand = TRUE
			Sonec.State.Jump = TRUE
			Sonec.GroundContactActive = FALSE
			Sonec.State.Stand = FALSE
			Sonec.State.Fly = FALSE
			Sonec.State.Fall = FALSE
			Sonec.AnimationData.Frame = 0
		else
			Sonec.State.Fly = FALSE
			if Sonec.State.Stand = FALSE
				Sonec.State.Fall = TRUE
			endif
		endif
	endif
	
endfunction

// Phase A1: Input owns control intent and the existing Fly/Fall/Stand/Jump
// transitions. Do not treat these flags as a collision result without checking
// the actual support recorded in CollisionData. Keep ButtonDown energy behavior.
function SonecInput(Sonec ref as TSonec,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Keys ref as TKeys,Options ref as TGameOptions,JoystickIndex as integer,Now as integer)
	
	local Position as TPosition
	
	// Toggle on a fresh press, including short taps between movement timer ticks.
	// Hold mode follows the current key/button state, as in step 6c.
	if Options.HoverMode = HOVER_MODE_TOGGLE
		if InputActionPressed(Keys,JoystickIndex,ACTION_HOVER) = 1
			if Sonec.State.Hover = TRUE
				Sonec.State.Hover = FALSE
			else
				Sonec.State.Hover = TRUE
			endif
		endif
	else
		Sonec.State.Hover = InputActionState(Keys,JoystickIndex,ACTION_HOVER)
	endif

	if TimeGet(Sonec.InputTimer,Now) > 0
		
		Position.y = Sonec.ObjectData.Position.y -10
		if Sonec.State.LookAlignment = LOOKLEFT
			Position.x = Sonec.ObjectData.Position.x +12
		else
			Position.x = Sonec.ObjectData.Position.x -12
		endif
		
		SonecInputVerticalState(Sonec,JetfireList,ProtoJetfire,World,Position,(InputActionState(Keys,JoystickIndex,ACTION_MOVE_UP) = 1 or GetJoyY(JoystickIndex) < -0.5),Now)

		if InputActionState(Keys,JoystickIndex,ACTION_MOVE_DOWN) = 1 or GetJoyY(JoystickIndex) > 0.5
			Sonec.State.Duck = TRUE
			Sonec.AnimationData.Frame = 0
		else
			Sonec.State.Duck = FALSE
		endif
		
		Sonec.State.Move = FALSE
		
		if InputActionState(Keys,JoystickIndex,ACTION_MOVE_LEFT) = 1 or InputActionState(Keys,JoystickIndex,ACTION_MOVE_BACK_LEFT) = 1 or GetJoyX(JoystickIndex) < -0.5 or GetJoyZ(JoystickIndex) > 0.5
			if InputActionState(Keys,JoystickIndex,ACTION_MOVE_LEFT) = 1 or GetJoyX(JoystickIndex) < -0.5
				if GetJoyZ(JoystickIndex) = 0
					Sonec.State.LookAlignment = LOOKLEFT
				endif
			endif
			if InputActionState(Keys,JoystickIndex,ACTION_MOVE_BACK_LEFT) = 1 or GetJoyZ(1) > 0.5
				Sonec.State.LookAlignment = LOOKRIGHT
			endif
			if (Sonec.State.Fly = TRUE or Sonec.State.Fall = TRUE) and Sonec.Energy.State >= COSTJETFIRE
				Sonec.State.Move = TRUE
				Sonec.State.Alignment = MOVELEFT
				SonecJetfireAdd(Sonec,JetfireList,ProtoJetfire,World,Position,Now)
			endif
			if Sonec.State.Stand = TRUE and Sonec.State.Duck = FALSE
				Sonec.State.Move = TRUE
				Sonec.State.Alignment = MOVELEFT
			endif
		endif
		
		if InputActionState(Keys,JoystickIndex,ACTION_MOVE_RIGHT) = 1 or InputActionState(Keys,JoystickIndex,ACTION_MOVE_BACK_RIGHT) = 1 or GetJoyX(JoystickIndex) > 0.5 or GetJoyRZ(JoystickIndex) > 0.5
			if InputActionState(Keys,JoystickIndex,ACTION_MOVE_RIGHT) = 1 or GetJoyX(JoystickIndex) > 0.5
				if GetJoyRZ(1) = 0
					Sonec.State.LookAlignment = LOOKRIGHT
				endif
			endif
			if InputActionState(Keys,JoystickIndex,ACTION_MOVE_BACK_RIGHT) = 1 or GetJoyRZ(JoystickIndex) > 0.5
				Sonec.State.LookAlignment = LOOKLEFT
			endif
			if (Sonec.State.Fly = TRUE or Sonec.State.Fall = TRUE) and Sonec.Energy.State >= COSTJETFIRE
				Sonec.State.Move = TRUE
				Sonec.State.Alignment = MOVERIGHT
				SonecJetfireAdd(Sonec,JetfireList,ProtoJetfire,World,Position,Now)
			endif
			if Sonec.State.Stand = TRUE and Sonec.State.Duck = FALSE
				Sonec.State.Move = TRUE
				Sonec.State.Alignment = MOVERIGHT
			endif
		endif
		
		// Any deliberate input takes priority over an automatic balance step.
		if Sonec.BalanceActive = TRUE
			if Sonec.State.Move = TRUE or Sonec.State.Duck = TRUE or Sonec.State.Jump = TRUE or Sonec.State.Fly = TRUE or Sonec.State.Stand = FALSE
				Sonec.BalanceActive = FALSE
				Sonec.AnimationData.RepeatAnimation = TRUE
				Sonec.AnimationData.Finished = FALSE
			endif
		endif

		TimeReset(Sonec.InputTimer,Now)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Phase A1: Release the current supporting surface and enter falling.
// LinkedPlateIndex intentionally survives: it represents the depth plane,
// whereas CollisionData.ListType/Index identifies the current support.
function SonecCollideReset(Sonec ref as TSonec)
	
	Sonec.CollisionData.ListType = 0
	Sonec.CollisionData.Index = -1
	Sonec.GroundContactActive = FALSE
	Sonec.State.Fall = TRUE
	Sonec.State.Stand = FALSE
	Sonec.ObjectData.AutoSpeed.x = 0
	Sonec.ObjectData.AutoSpeed.y = 0
	Sonec.BalanceActive = FALSE
	Sonec.AnimationData.RepeatAnimation = TRUE
	Sonec.AnimationData.Finished = FALSE
	
endfunction
						
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Phase A3: A valid landing updates support and depth-plane association.
// Eligibility and timing remain with the existing collision callers.
function SonecSetGroundContact(Sonec ref as TSonec,SurfaceType as integer,SurfaceIndex as integer,PlateIndex as integer)
	Sonec.GroundContactActive = TRUE
	Sonec.State.Fall = FALSE
	Sonec.State.Stand = TRUE
	Sonec.CollisionData.ListType = SurfaceType
	Sonec.CollisionData.Index = SurfaceIndex
	Sonec.LinkedPlateIndex = PlateIndex
	Sonec.ObjectData.MoveSpeed.y = 0
endfunction

// Phase A4: Validate only whether the linked platform still exists.
// Do not clear linkage merely because Sonec is airborne or above a chest.
// Existing invalid-index/disabled-platform behavior is preserved.
function SonecValidateLinkedPlate(Sonec ref as TSonec,PlateList ref as TPlateList)
	if Sonec.LinkedPlateIndex >= 0
		if Sonec.LinkedPlateIndex > PlateList.Plate.Length
			Sonec.LinkedPlateIndex = -1
		else
			if PlateList.Plate[Sonec.LinkedPlateIndex].Enabled = FALSE
				Sonec.LinkedPlateIndex = -1
			endif
		endif
	endif
endfunction

// Phase A1: Legacy collision owner for platform support/landing and
// chest-contact dispatch. This routine currently updates Stand/Fall,
// CollisionData and LinkedPlateIndex; Phase E will unify those decisions.
function SonecCollidePlate(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,World ref as TWorld)
	
	local i as integer
	local PlateIndex as integer
	local SideHitIndex as integer
	local SideContactTime as float
	local PassPlateIndex as integer
	local PassIndex as integer
	local HalfWidth as float
	local HalfHeight as float
	local BestPlateIndex as integer
	local BestPlateY as float
	local StartFeetY as float
	local EndFeetY as float
	local PlateStartY as float
	local PlateEndY as float
	local RelativeStartY as float
	local RelativeEndY as float
	local ContactTime as float
	local BestContactTime as float
	
	
	// Preserve an established physical support across non-liftoff state
	// changes (e.g. grenade recoil); input jump/jetpack explicitly clears it.
	if Sonec.GroundContactActive = TRUE and Sonec.State.Fly = FALSE and Sonec.State.Jump = FALSE
		Sonec.State.Stand = TRUE
		Sonec.State.Fall = FALSE
	endif
	PlateIndex = -1
	// The association survives a jump and normal falling; only actual
	// jetpack flight ignores it when finding solid chests.
	SonecValidateLinkedPlate(Sonec,PlateList)
	PassPlateIndex = -1
	PassIndex = Sonec.PassThroughChestIndex
	if PassIndex >= 0
		if PassIndex > ChestList.Chest.Length
			Sonec.PassThroughChestIndex = -1
		else
			if ChestList.Chest[PassIndex].Enabled = FALSE
				Sonec.PassThroughChestIndex = -1
			else
				PassPlateIndex = ChestList.Chest[PassIndex].CollisionData.Index
			endif
		endif
	endif
	
	if Sonec.State.Stand = TRUE
		if Sonec.CollisionData.ListType = TYPEPLATE
			if Sonec.CollisionData.Index >= 0
				PlateIndex = Sonec.CollisionData.Index
			endif
		endif
	endif

	if Sonec.State.Stand = TRUE
		if Sonec.CollisionData.ListType = TYPEPLATE
			if Sonec.CollisionData.Index >= 0
				if PlateList.Plate.Length >= 0
					if PlateList.Plate[Sonec.CollisionData.Index].Enabled = FALSE
						SonecCollideReset(Sonec)
					else
	
						Sonec.ObjectData.AutoSpeed.y = PlateList.Plate[Sonec.CollisionData.Index].ObjectData.MoveSpeed.y
						Sonec.ObjectData.Position.y = PlateList.Plate[Sonec.CollisionData.Index].ObjectData.Position.y - Sonec.ObjectData.Size.Height*0.5
						
						if Sonec.ObjectData.Position.x > Sonec.ObjectData.Size.Width*0.5
							if Sonec.ObjectData.MoveSpeed.x <> 0
								Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - PlateList.Plate[Sonec.CollisionData.Index].ObjectData.Position.x
								Sonec.ObjectData.AutoSpeed.x = 0
							else
								Sonec.ObjectData.AutoSpeed.x = -PlateList.Plate[Sonec.CollisionData.Index].ObjectData.MoveSpeed.x
								Sonec.ObjectData.Position.x = PlateList.Plate[Sonec.CollisionData.Index].ObjectData.Position.x + Sonec.CollisionData.Position.x
							endif
						endif
						
						SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
						
						if Sonec.ObjectData.Position.x < PlateList.Plate[Sonec.CollisionData.Index].ObjectData.Position.x
							SonecCollideReset(Sonec)
						else
							if Sonec.ObjectData.Position.x > PlateList.Plate[Sonec.CollisionData.Index].ObjectData.Position.x + PlateList.Plate[Sonec.CollisionData.Index].ObjectData.Size.Width
								SonecCollideReset(Sonec)
							endif
						endif
			
					endif
				endif
			endif
		endif
	endif
	
	// Classify the first side/top/underside contact before chest landing.
	SideHitIndex = SonecCollideChestSideContacts(Sonec,ChestList,PlateList,PlateIndex,World,SideContactTime)
	SonecCollideChestHorizontal(Sonec,ChestList,World,SideHitIndex,SideContactTime)
	if Sonec.PassThroughChestIndex >= 0
		PassPlateIndex = ChestList.Chest[Sonec.PassThroughChestIndex].CollisionData.Index
	endif
		
	// B2: Sweep Sonec's feet against each platform's moving top edge.
	// Keep the legacy horizontal end-position test until a later step.
	if Sonec.State.Stand = FALSE and Sonec.State.Fall = TRUE
		BestPlateIndex = -1
		BestContactTime = 2
		StartFeetY = Sonec.CollisionMoveStart.y + Sonec.ObjectData.Size.Height*0.5
		EndFeetY = Sonec.CollisionMoveEnd.y + Sonec.ObjectData.Size.Height*0.5
		for i = 0 to PlateList.Plate.Length
			if i <> PassPlateIndex and PlateList.Plate[i].Enabled = TRUE
				if Sonec.ObjectData.Position.x > PlateList.Plate[i].ObjectData.Position.x
					if Sonec.ObjectData.Position.x < PlateList.Plate[i].ObjectData.Position.x + PlateList.Plate[i].ObjectData.Size.Width
						PlateStartY = PlateList.Plate[i].CollisionMoveStart.y
						PlateEndY = PlateList.Plate[i].ObjectData.Position.y
						RelativeStartY = StartFeetY - PlateStartY
						RelativeEndY = EndFeetY - PlateEndY
						if RelativeEndY > RelativeStartY and RelativeStartY <= 0 and RelativeEndY >= 0
							ContactTime = -RelativeStartY/(RelativeEndY-RelativeStartY)
							if ContactTime < BestContactTime
								BestPlateIndex = i
								BestContactTime = ContactTime
								BestPlateY = PlateEndY
							endif
						endif
					endif
				endif
			endif
		next i
		if BestPlateIndex >= 0
			Sonec.ObjectData.Position.y = BestPlateY - Sonec.ObjectData.Size.Height*0.5
			Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - PlateList.Plate[BestPlateIndex].ObjectData.Position.x
			Sonec.CollisionData.Position.y = Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5 - BestPlateY
			SonecSetGroundContact(Sonec,TYPEPLATE,BestPlateIndex,BestPlateIndex)
			SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
		endif
	endif

	// Retain the pass-through until after ALL landing checks, including
	// the frame in which Sonec has just exited through the bottom.
	PassIndex = Sonec.PassThroughChestIndex
	if PassIndex >= 0
		if PassIndex > ChestList.Chest.Length
			Sonec.PassThroughChestIndex = -1
		else
			if ChestList.Chest[PassIndex].Enabled = FALSE
				Sonec.PassThroughChestIndex = -1
			else
				HalfWidth = Sonec.ObjectData.Size.Width*0.5
				HalfHeight = Sonec.ObjectData.Size.Height*0.5
				if Sonec.ObjectData.Position.x + HalfWidth <= ChestList.Chest[PassIndex].ObjectData.Position.x or Sonec.ObjectData.Position.x - HalfWidth >= ChestList.Chest[PassIndex].ObjectData.Position.x + ChestList.Chest[PassIndex].ObjectData.Size.Width or Sonec.ObjectData.Position.y + HalfHeight <= ChestList.Chest[PassIndex].ObjectData.Position.y or Sonec.ObjectData.Position.y - HalfHeight >= ChestList.Chest[PassIndex].ObjectData.Position.y + ChestList.Chest[PassIndex].ObjectData.Size.Height
					Sonec.PassThroughChestIndex = -1
				endif
			endif
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecCollideChest(Sonec ref as TSonec,ChestList ref as TChestList,Index as integer,World ref as TWorld)
	
	local Value as integer
	local i as integer
	local Position as TPosition
	local Radius as float
	
	Value = FALSE
		
	for i = 0 to ChestList.Chest.Length
	
		if ChestList.Chest[i].Enabled = TRUE
			if ChestList.Chest[i].CollisionData.Index = Index
				if Sonec.ObjectData.Position.x + Sonec.ObjectData.Size.Width*0.5 > ChestList.Chest[i].ObjectData.Position.x
					if Sonec.ObjectData.Position.x - Sonec.ObjectData.Size.Width*0.5 < ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width
						
						Position.x = ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width*0.5
						Position.y = ChestList.Chest[i].ObjectData.Position.y + ChestList.Chest[i].ObjectData.Size.Height*0.5
						
						Radius = CalcRadius(Position,Sonec.ObjectData.Position)
						
						if Radius < 26 + ChestList.Chest[i].ObjectData.Size.Width*0.5
							Value = TRUE
						endif
						
					endif
				endif
			endif
		endif
	
	next i
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Keep the platform association after jumping or leaving an edge.
// Jetpack flight intentionally sees every active chest.
function SonecChestRelevant(Sonec ref as TSonec,ChestList ref as TChestList,ChestIndex as integer)
	local Relevant as integer
	Relevant = FALSE
	if ChestIndex >= 0 and ChestIndex <= ChestList.Chest.Length
		if ChestList.Chest[ChestIndex].Enabled = TRUE
			if Sonec.State.Fly = TRUE
				Relevant = TRUE
			else
				if Sonec.LinkedPlateIndex >= 0 and ChestList.Chest[ChestIndex].CollisionData.Index = Sonec.LinkedPlateIndex
					Relevant = TRUE
				else
					// A foreign chest can be reached while falling from above.
					// Keep it intangible when entering from underneath.
					if Sonec.State.Fall = TRUE
						if Sonec.CollisionMoveStart.y + Sonec.ObjectData.Size.Height*0.5 <= ChestList.Chest[ChestIndex].CollisionMoveStart.y
							Relevant = TRUE
						endif
					endif
				endif
			endif
		endif
	endif
endfunction Relevant

// The wall remembered on the previous frame limits horizontal thrust before
// SonecMove integrates it. Reverse direction and vertical clearance remain free.
function SonecMoveLimitChestWall(Sonec ref as TSonec,ChestList ref as TChestList)
	local WallIndex as integer
	local Radius as float
	local CircleIndex as integer
	local CircleY as float
	local ChestTop as float
	local ChestBottom as float
	local HeightOverlap as integer
	local ContactValid as integer
	local WallX as float

	WallIndex = Sonec.BlockedChestIndex
	ContactValid = FALSE
	if WallIndex >= 0
		if SonecChestRelevant(Sonec,ChestList,WallIndex) = TRUE and Sonec.PassThroughChestIndex <> WallIndex
			ChestTop = ChestList.Chest[WallIndex].ObjectData.Position.y
			ChestBottom = ChestTop + ChestList.Chest[WallIndex].ObjectData.Size.Height
			HeightOverlap = FALSE
			// Match the B-K3 full-height grounded front line when
			// continuing a side contact across movement frames.
			if Sonec.GroundContactActive = TRUE
				if Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5 > ChestTop and Sonec.ObjectData.Position.y - Sonec.ObjectData.Size.Height*0.5 < ChestBottom
					HeightOverlap = TRUE
				endif
			else
				Radius = SonecHitCircleRadius(Sonec)
				for CircleIndex = 0 to 1
					CircleY = SonecHitCircleY(Sonec,CircleIndex)
					if CircleY + Radius > ChestTop and CircleY - Radius < ChestBottom
						HeightOverlap = TRUE
					endif
				next CircleIndex
			endif

			if HeightOverlap = TRUE
				if Sonec.BlockedChestSide = 1
					WallX = ChestList.Chest[WallIndex].ObjectData.Position.x + Sonec.BlockedChestOffsetX
					if Sonec.ObjectData.Position.x <= WallX + SONEC_CHEST_CONTACT_EPSILON and Sonec.ObjectData.Position.x >= WallX - SONEC_CHEST_CONTACT_EPSILON
						ContactValid = TRUE
						if Sonec.ObjectData.MoveSpeed.x > 0
							Sonec.ObjectData.MoveSpeed.x = 0
						endif
					endif
				endif
				if Sonec.BlockedChestSide = -1
					WallX = ChestList.Chest[WallIndex].ObjectData.Position.x + ChestList.Chest[WallIndex].ObjectData.Size.Width + Sonec.BlockedChestOffsetX
					if Sonec.ObjectData.Position.x <= WallX + SONEC_CHEST_CONTACT_EPSILON and Sonec.ObjectData.Position.x >= WallX - SONEC_CHEST_CONTACT_EPSILON
						ContactValid = TRUE
						if Sonec.ObjectData.MoveSpeed.x < 0
							Sonec.ObjectData.MoveSpeed.x = 0
						endif
					endif
				endif
			endif
		endif
	endif
	if ContactValid = FALSE
		Sonec.BlockedChestIndex = -1
		Sonec.BlockedChestSide = 0
		Sonec.BlockedChestOffsetX = 0
	endif
endfunction

// Squared distance from a moving body-circle center to a chest rectangle.
// No square root: used for both rounded corners and straight side faces.
function SonecChestCircleDistanceSq(CircleX as float,CircleY as float,Width as float,Height as float)
	local DistX as float
	local DistY as float
	local DistanceSq as float
	DistX = 0
	DistY = 0
	if CircleX < 0 then DistX = CircleX
	if CircleX > Width then DistX = CircleX - Width
	if CircleY < 0 then DistY = CircleY
	if CircleY > Height then DistY = CircleY - Height
	DistanceSq = DistX*DistX + DistY*DistY
endfunction DistanceSq

// Continuous sweep of a circle against a moving chest (in chest coordinates).
// Expanded AABB is only a broad phase; rounded corners use the actual circle.
// Returns the FIRST hit time in [0,1], or -1 for no contact.
function SonecChestCircleHitTime(StartX as float,StartY as float,DeltaX as float,DeltaY as float,Width as float,Height as float,Radius as float)
	local EnterX as float
	local ExitX as float
	local EnterY as float
	local ExitY as float
	local EnterTime as float
	local ExitTime as float
	local SearchLow as float
	local SearchHigh as float
	local Third as float
	local SweepMidTime as float
	local NearestTime as float
	local RadiusSq as float
	local DistanceLeft as float
	local DistanceRight as float
	local HitTime as float
	local i as integer

	HitTime = -1
	EnterX = -2
	ExitX = 2
	EnterY = -2
	ExitY = 2

	if DeltaX > 0
		EnterX = (-Radius - StartX) / DeltaX
		ExitX = (Width + Radius - StartX) / DeltaX
	else
		if DeltaX < 0
			EnterX = (Width + Radius - StartX) / DeltaX
			ExitX = (-Radius - StartX) / DeltaX
		else
			if StartX < -Radius or StartX > Width + Radius
				ExitX = -3
			endif
		endif
	endif

	if DeltaY > 0
		EnterY = (-Radius - StartY) / DeltaY
		ExitY = (Height + Radius - StartY) / DeltaY
	else
		if DeltaY < 0
			EnterY = (Height + Radius - StartY) / DeltaY
			ExitY = (-Radius - StartY) / DeltaY
		else
			if StartY < -Radius or StartY > Height + Radius
				ExitY = -3
			endif
		endif
	endif

	EnterTime = EnterX
	if EnterY > EnterTime then EnterTime = EnterY
	ExitTime = ExitX
	if ExitY < ExitTime then ExitTime = ExitY
	if EnterTime < 0 then EnterTime = 0
	if ExitTime > 1 then ExitTime = 1

	if EnterTime <= ExitTime
		RadiusSq = Radius*Radius + SONEC_CHEST_SWEEP_EPSILON
		SearchLow = EnterTime
		SearchHigh = ExitTime
		// Distance to a convex rectangle along a straight segment is convex.
		for i = 1 to SONEC_CHEST_SWEEP_ITERATIONS
			Third = (SearchHigh - SearchLow) / 3
			DistanceLeft = SonecChestCircleDistanceSq(StartX + DeltaX*(SearchLow + Third),StartY + DeltaY*(SearchLow + Third),Width,Height)
			DistanceRight = SonecChestCircleDistanceSq(StartX + DeltaX*(SearchHigh - Third),StartY + DeltaY*(SearchHigh - Third),Width,Height)
			if DistanceLeft <= DistanceRight
				SearchHigh = SearchHigh - Third
			else
				SearchLow = SearchLow + Third
			endif
		next i
		NearestTime = (SearchLow + SearchHigh)*0.5
		if SonecChestCircleDistanceSq(StartX + DeltaX*NearestTime,StartY + DeltaY*NearestTime,Width,Height) <= RadiusSq
			if SonecChestCircleDistanceSq(StartX + DeltaX*EnterTime,StartY + DeltaY*EnterTime,Width,Height) <= RadiusSq
				HitTime = EnterTime
			else
				SearchLow = EnterTime
				SearchHigh = NearestTime
				for i = 1 to SONEC_CHEST_SWEEP_ITERATIONS
					SweepMidTime = (SearchLow + SearchHigh)*0.5
					if SonecChestCircleDistanceSq(StartX + DeltaX*SweepMidTime,StartY + DeltaY*SweepMidTime,Width,Height) <= RadiusSq
						SearchHigh = SweepMidTime
					else
						SearchLow = SweepMidTime
					endif
				next i
				HitTime = SearchHigh
			endif
		endif
	endif
endfunction HitTime

// Resolve a chest's FIRST body-circle contact, not its last-frame overlap.
// The resulting X is clamped to Sonec's intended step (never thrown backwards).
// Shared swept chest-top candidate: evaluate X at the actual Y crossing.
function SonecChestTopContactTime(Sonec ref as TSonec,ChestList ref as TChestList,ChestIndex as integer)
	local StartFeetY as float
	local EndFeetY as float
	local RelativeStartY as float
	local RelativeEndY as float
	local ContactTime as float
	local ContactX as float
	local ChestContactX as float
	local ChestWidth as float

	ContactTime = -1
	if Sonec.State.Stand = FALSE and Sonec.State.Fall = TRUE
		StartFeetY = Sonec.CollisionMoveStart.y + Sonec.ObjectData.Size.Height*0.5
		EndFeetY = Sonec.CollisionMoveEnd.y + Sonec.ObjectData.Size.Height*0.5
		RelativeStartY = StartFeetY - ChestList.Chest[ChestIndex].CollisionMoveStart.y
		RelativeEndY = EndFeetY - ChestList.Chest[ChestIndex].ObjectData.Position.y
		if RelativeEndY > RelativeStartY and RelativeStartY <= 0 and RelativeEndY >= 0
			ContactTime = -RelativeStartY/(RelativeEndY-RelativeStartY)
			ContactX = Sonec.CollisionMoveStart.x + (Sonec.CollisionMoveEnd.x-Sonec.CollisionMoveStart.x)*ContactTime
			ChestContactX = ChestList.Chest[ChestIndex].CollisionMoveStart.x + (ChestList.Chest[ChestIndex].ObjectData.Position.x-ChestList.Chest[ChestIndex].CollisionMoveStart.x)*ContactTime
			ChestWidth = ChestList.Chest[ChestIndex].ObjectData.Size.Width
			if ContactX <= ChestContactX or ContactX >= ChestContactX + ChestWidth
				ContactTime = -1
			endif
		endif
	endif
endfunction ContactTime

function SonecCollideChestSideContacts(Sonec ref as TSonec,ChestList ref as TChestList,PlateList ref as TPlateList,Index as integer,World ref as TWorld,SideContactTime ref as float)
	local i as integer
	local CircleIndex as integer
	local Radius as float
	local PlayerStepX as float
	local PlayerStepY as float
	local RelativeStepX as float
	local RelativeStepY as float
	local StartX as float
	local StartY as float
	local CircleYShift as float
	local HitTime as float
	local ContactX as float
	local ContactY as float
	local ClosestX as float
	local ClosestY as float
	local NormalX as float
	local NormalY as float
	local CandidateX as float
	local SideTime as float
	local BottomTime as float
	local HitPositionX as float
	local HitOffsetX as float
	local HitIndex as integer
	local HitSide as integer
	local BottomIndex as integer
	local StartFeetY as float
	local EndFeetY as float
	local RelativeStartY as float
	local RelativeEndY as float
	local TopTime as float
	local BestTopTime as float
	local FrontOffset as float
	local StartFrontX as float
	local EndFrontX as float
	local ChestStartEdge as float
	local ChestEndEdge as float
	local RelativeStartX as float
	local RelativeEndX as float
	local ContactCenterY as float
	local ContactChestTop as float

	Radius = SonecHitCircleRadius(Sonec)
	PlayerStepX = Sonec.CollisionMoveEnd.x - Sonec.CollisionMoveStart.x
	PlayerStepY = Sonec.CollisionMoveEnd.y - Sonec.CollisionMoveStart.y
	SideTime = 2
	BottomTime = 2
	HitIndex = -1
	HitSide = 0
	BottomIndex = -1

	for i = 0 to ChestList.Chest.Length
		if SonecChestRelevant(Sonec,ChestList,i) = TRUE and Sonec.PassThroughChestIndex <> i
			// Do not sweep against the chest Sonec is already standing on.
			if Sonec.State.Stand = FALSE or Sonec.CollisionData.ListType <> TYPECHEST or Sonec.CollisionData.Index <> i
				RelativeStepX = PlayerStepX - (ChestList.Chest[i].ObjectData.Position.x - ChestList.Chest[i].CollisionMoveStart.x)
				RelativeStepY = PlayerStepY - (ChestList.Chest[i].ObjectData.Position.y - ChestList.Chest[i].CollisionMoveStart.y)
				StartX = Sonec.CollisionMoveStart.x - ChestList.Chest[i].CollisionMoveStart.x
				// B-K3: grounded side contact uses a full-height front line,
				// swept against the moving chest side, not the airborne circles.
				if Sonec.GroundContactActive = TRUE
					FrontOffset = Sonec.ObjectData.Size.Width*0.5
					if PlayerStepX > 0 and RelativeStepX > 0
						StartFrontX = Sonec.CollisionMoveStart.x + FrontOffset
						EndFrontX = Sonec.CollisionMoveEnd.x + FrontOffset
						ChestStartEdge = ChestList.Chest[i].CollisionMoveStart.x
						ChestEndEdge = ChestList.Chest[i].ObjectData.Position.x
						RelativeStartX = StartFrontX - ChestStartEdge
						RelativeEndX = EndFrontX - ChestEndEdge
						if RelativeStartX <= 0 and RelativeEndX >= 0 and RelativeEndX > RelativeStartX
							HitTime = -RelativeStartX/(RelativeEndX-RelativeStartX)
							ContactCenterY = Sonec.CollisionMoveStart.y + PlayerStepY*HitTime
							ContactChestTop = ChestList.Chest[i].CollisionMoveStart.y + (ChestList.Chest[i].ObjectData.Position.y - ChestList.Chest[i].CollisionMoveStart.y)*HitTime
							if ContactCenterY + Sonec.ObjectData.Size.Height*0.5 > ContactChestTop and ContactCenterY - Sonec.ObjectData.Size.Height*0.5 < ContactChestTop + ChestList.Chest[i].ObjectData.Size.Height
							if HitTime < SideTime
								CandidateX = ChestEndEdge - FrontOffset
								if CandidateX >= FrontOffset
									if CandidateX < Sonec.CollisionMoveStart.x then CandidateX = Sonec.CollisionMoveStart.x
									if CandidateX <= Sonec.CollisionMoveEnd.x
										SideTime = HitTime
										HitIndex = i
										HitPositionX = CandidateX
										HitOffsetX = -FrontOffset
										HitSide = 1
									endif
								endif
							endif
							endif
						endif
					endif
					if PlayerStepX < 0 and RelativeStepX < 0
						StartFrontX = Sonec.CollisionMoveStart.x - FrontOffset
						EndFrontX = Sonec.CollisionMoveEnd.x - FrontOffset
						ChestStartEdge = ChestList.Chest[i].CollisionMoveStart.x + ChestList.Chest[i].ObjectData.Size.Width
						ChestEndEdge = ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width
						RelativeStartX = StartFrontX - ChestStartEdge
						RelativeEndX = EndFrontX - ChestEndEdge
						if RelativeStartX >= 0 and RelativeEndX <= 0 and RelativeEndX < RelativeStartX
							HitTime = -RelativeStartX/(RelativeEndX-RelativeStartX)
							ContactCenterY = Sonec.CollisionMoveStart.y + PlayerStepY*HitTime
							ContactChestTop = ChestList.Chest[i].CollisionMoveStart.y + (ChestList.Chest[i].ObjectData.Position.y - ChestList.Chest[i].CollisionMoveStart.y)*HitTime
							if ContactCenterY + Sonec.ObjectData.Size.Height*0.5 > ContactChestTop and ContactCenterY - Sonec.ObjectData.Size.Height*0.5 < ContactChestTop + ChestList.Chest[i].ObjectData.Size.Height
							if HitTime < SideTime
								CandidateX = ChestEndEdge + FrontOffset
								if CandidateX > Sonec.CollisionMoveStart.x then CandidateX = Sonec.CollisionMoveStart.x
								if CandidateX >= Sonec.CollisionMoveEnd.x
									SideTime = HitTime
									HitIndex = i
									HitPositionX = CandidateX
									HitOffsetX = FrontOffset
									HitSide = -1
								endif
							endif
							endif
						endif
					endif
				endif
				if Sonec.GroundContactActive = FALSE
				for CircleIndex = 0 to 1
					CircleYShift = SonecHitCircleY(Sonec,CircleIndex) - Sonec.ObjectData.Position.y
					StartY = Sonec.CollisionMoveStart.y + CircleYShift - ChestList.Chest[i].CollisionMoveStart.y
					HitTime = SonecChestCircleHitTime(StartX,StartY,RelativeStepX,RelativeStepY,ChestList.Chest[i].ObjectData.Size.Width,ChestList.Chest[i].ObjectData.Size.Height,Radius)
					if HitTime >= 0
						ContactX = StartX + RelativeStepX*HitTime
						ContactY = StartY + RelativeStepY*HitTime
						ClosestX = ContactX
						ClosestY = ContactY
						if ClosestX < 0 then ClosestX = 0
						if ClosestX > ChestList.Chest[i].ObjectData.Size.Width then ClosestX = ChestList.Chest[i].ObjectData.Size.Width
						if ClosestY < 0 then ClosestY = 0
						if ClosestY > ChestList.Chest[i].ObjectData.Size.Height then ClosestY = ChestList.Chest[i].ObjectData.Size.Height
						NormalX = ContactX - ClosestX
						NormalY = ContactY - ClosestY

						// The permitted underside entry wins over a later side
						// contact against the SAME chest during this frame.
						if NormalY > 0 and abs(NormalY) > abs(NormalX) and PlayerStepY < 0 and RelativeStepY < 0
							if HitTime < BottomTime
								BottomTime = HitTime
								BottomIndex = i
							endif
						endif

						// A horizontal collision requires Sonec to be moving
						// towards the wall himself, not merely a drifting chest.
						if abs(NormalX) >= abs(NormalY) and NormalX <> 0 and HitTime < SideTime
							if NormalX < 0 and PlayerStepX > 0 and RelativeStepX > 0
								CandidateX = ChestList.Chest[i].ObjectData.Position.x + NormalX
								// Existing world-left exception: a chest may drift
								// through Sonec there instead of shoving him outside.
								if CandidateX >= Sonec.ObjectData.Size.Width*0.5
									if CandidateX < Sonec.CollisionMoveStart.x
										CandidateX = Sonec.CollisionMoveStart.x
									endif
									if CandidateX <= Sonec.CollisionMoveEnd.x
										SideTime = HitTime
										HitIndex = i
										HitPositionX = CandidateX
										HitOffsetX = NormalX
										HitSide = 1
									endif
								endif
							endif
							if NormalX > 0 and PlayerStepX < 0 and RelativeStepX < 0
								CandidateX = ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width + NormalX
								if CandidateX > Sonec.CollisionMoveStart.x
									CandidateX = Sonec.CollisionMoveStart.x
								endif
								if CandidateX >= Sonec.CollisionMoveEnd.x
									SideTime = HitTime
									HitIndex = i
									HitPositionX = CandidateX
									HitOffsetX = NormalX
									HitSide = -1
								endif
							endif
						endif
					endif
				next CircleIndex
				endif
			endif
		endif
	next i

	// A bottom-first traversal must keep this particular chest and its
	// supporting plate nonsolid until Sonec has completely exited.
	if BottomIndex >= 0 and Sonec.PassThroughChestIndex < 0 and BottomTime <= SideTime
		Sonec.PassThroughChestIndex = BottomIndex
		if HitIndex = BottomIndex
			HitIndex = -1
		endif
	endif

	// Compare the earliest eligible top across ALL chests with the
	// earliest side, rather than prioritizing only the side-hit chest.
	BestTopTime = 2
	if Sonec.State.Stand = FALSE and Sonec.State.Fall = TRUE
		for i = 0 to ChestList.Chest.Length
			if SonecChestRelevant(Sonec,ChestList,i) = TRUE and Sonec.PassThroughChestIndex <> i
				TopTime = SonecChestTopContactTime(Sonec,ChestList,i)
				if TopTime >= 0 and TopTime < BestTopTime
					BestTopTime = TopTime
				endif
			endif
		next i
	endif
	SideContactTime = 2
	if HitIndex >= 0
		if BestTopTime <= SideTime
			HitIndex = -1
		else
			SideContactTime = SideTime
		endif
	endif

	if HitIndex >= 0
		Sonec.ObjectData.Position.x = HitPositionX
		Sonec.ObjectData.MoveSpeed.x = 0
		Sonec.BlockedChestIndex = HitIndex
		Sonec.BlockedChestSide = HitSide
		Sonec.BlockedChestOffsetX = HitOffsetX
		if Sonec.BalanceActive = TRUE
			Sonec.BalanceActive = FALSE
			Sonec.AnimationData.RepeatAnimation = TRUE
			Sonec.AnimationData.Finished = FALSE
		endif
		// The support offset is part of the position; without updating it,
		// a standing Sonec can be snapped back next frame.
		if Sonec.State.Stand = TRUE
			if Sonec.CollisionData.ListType = TYPEPLATE and Index >= 0
				Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - PlateList.Plate[Index].ObjectData.Position.x
			endif
			if Sonec.CollisionData.ListType = TYPECHEST and Sonec.CollisionData.Index >= 0
				Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x
			endif
		endif
		SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
	endif
endfunction HitIndex HitIndex

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecCollideChestHorizontal(Sonec ref as TSonec,ChestList ref as TChestList,World ref as TWorld,SideHitIndex as integer,SideContactTime as float)
	
	local i as integer
	local BestChestIndex as integer
	local BestContactTime as float
	local ContactTime as float
	local RelativeStartY as float
	local RelativeEndY as float
	local StartFeetY as float
	local EndFeetY as float
	
	if Sonec.State.Stand = TRUE
		if Sonec.CollisionData.ListType = TYPECHEST
			if Sonec.CollisionData.Index >= 0
				if ChestList.Chest.Length >= 0
					if ChestList.Chest[Sonec.CollisionData.Index].Enabled = FALSE
						SonecCollideReset(Sonec)
					else
	
						Sonec.ObjectData.AutoSpeed.y = ChestList.Chest[Sonec.CollisionData.Index].ObjectData.MoveSpeed.y
						Sonec.ObjectData.Position.y = ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.y - Sonec.ObjectData.Size.Height*0.5
						
						if Sonec.ObjectData.Position.x > 0
							Sonec.ObjectData.AutoSpeed.x = -ChestList.Chest[Sonec.CollisionData.Index].ObjectData.MoveSpeed.x
							if Sonec.ObjectData.MoveSpeed.x <> 0 or Sonec.BalanceActive = TRUE
								Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x
							else
								Sonec.ObjectData.Position.x = ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x + Sonec.CollisionData.Position.x
							endif
						endif
						// Keep the world boundary valid when a moving chest restores the standing offset.
						if Sonec.ObjectData.Position.x < Sonec.ObjectData.Size.Width*0.5
							Sonec.ObjectData.Position.x = Sonec.ObjectData.Size.Width*0.5
							Sonec.ObjectData.MoveSpeed.x = 0
							Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x
						endif
						
						SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
						
						// Trigger the active edge hop before the body crosses the edge, allowing for this frame's speed.
						// Passive departures still use the exact edge, without a hop.
						if Sonec.State.Move = TRUE and Sonec.State.Alignment = MOVELEFT and Sonec.ObjectData.MoveSpeed.x < 0 and Sonec.State.Duck = FALSE and Sonec.ObjectData.Position.x <= ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x + Sonec.ObjectData.Size.Width*0.5 + abs(Sonec.ObjectData.MoveSpeed.x)
							SonecCollideReset(Sonec)
							Sonec.ObjectData.MoveSpeed.y = -1.5
						else
							if Sonec.State.Move = TRUE and Sonec.State.Alignment = MOVERIGHT and Sonec.ObjectData.MoveSpeed.x > 0 and Sonec.State.Duck = FALSE and Sonec.ObjectData.Position.x >= ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x + ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Size.Width - Sonec.ObjectData.Size.Width*0.5 - abs(Sonec.ObjectData.MoveSpeed.x)
								SonecCollideReset(Sonec)
								Sonec.ObjectData.MoveSpeed.y = -1.5
							else
								if Sonec.ObjectData.Position.x < ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x or Sonec.ObjectData.Position.x > ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x + ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Size.Width
									SonecCollideReset(Sonec)
								endif
							endif
						endif
			
					endif
				endif
			endif
		endif
	endif
		
	// Relative swept chest-top contact, including X at contact time.
	if Sonec.State.Stand = FALSE and Sonec.State.Fall = TRUE
		BestChestIndex = -1
		BestContactTime = 2
		for i = 0 to ChestList.Chest.Length
			if SonecChestRelevant(Sonec,ChestList,i) = TRUE and Sonec.PassThroughChestIndex <> i and SideHitIndex <> i
				ContactTime = SonecChestTopContactTime(Sonec,ChestList,i)
				if ContactTime >= 0 and ContactTime <= SideContactTime and ContactTime < BestContactTime
					BestContactTime = ContactTime
					BestChestIndex = i
				endif
			endif
		next i
		if BestChestIndex >= 0
			i = BestChestIndex
							Sonec.ObjectData.Position.y = ChestList.Chest[i].ObjectData.Position.y - Sonec.ObjectData.Size.Height*0.5
							Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - ChestList.Chest[i].ObjectData.Position.x
							Sonec.CollisionData.Position.y = Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5 - ChestList.Chest[i].ObjectData.Position.y
							SonecSetGroundContact(Sonec,TYPECHEST,i,ChestList.Chest[i].CollisionData.Index)
							// Only a slow landing close to an edge needs a short balancing step.
							Sonec.BalanceActive = FALSE
							if abs(Sonec.ObjectData.MoveSpeed.x) <= 0.75 and Sonec.State.Move = FALSE and Sonec.State.Duck = FALSE
								if Sonec.ObjectData.Position.x < ChestList.Chest[i].ObjectData.Position.x + Sonec.ObjectData.Size.Width*0.35
									Sonec.BalanceTargetX = ChestList.Chest[i].ObjectData.Position.x + Sonec.ObjectData.Size.Width*0.35
									Sonec.State.Alignment = MOVERIGHT
									Sonec.State.LookAlignment = LOOKRIGHT
									Sonec.BalanceActive = TRUE
								endif
								if Sonec.ObjectData.Position.x > ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width - Sonec.ObjectData.Size.Width*0.35
									Sonec.BalanceTargetX = ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width - Sonec.ObjectData.Size.Width*0.35
									Sonec.State.Alignment = MOVELEFT
									Sonec.State.LookAlignment = LOOKLEFT
									Sonec.BalanceActive = TRUE
								endif
								if Sonec.BalanceActive = TRUE
									Sonec.AnimationData.Frame = 0
									Sonec.AnimationData.RepeatAnimation = FALSE
									Sonec.AnimationData.Finished = FALSE
								endif
							endif
							SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Keep movement forces independent from collision resolution and input binding.
// Phase A1: Jump is a one-shot request consumed here, while Fly/Fall
// select the current vertical acceleration. This function does not establish
// ground contact or change the depth-plane association.
function SonecMoveVerticalSpeed(Sonec ref as TSonec)
	local a as float
	if Sonec.State.Jump = TRUE
		
		Sonec.State.Jump = FALSE
		Sonec.ObjectData.MoveSpeed.y = -Sonec.ObjectData.MoveSpeedMax.y
		
	endif
	
	if Sonec.State.Fly = TRUE
		Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeed.y - Sonec.ObjectData.MoveAcceleration.y * Sonec.ObjectData.MoveTimer.CalcRange
		if Sonec.ObjectData.MoveSpeed.y <> 0
			a = Sonec.ObjectData.MoveSpeed.y/abs(Sonec.ObjectData.MoveSpeed.y)	
			if abs(Sonec.ObjectData.MoveSpeed.y) > Sonec.ObjectData.MoveSpeedMax.y
				Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeedMax.y * a
			endif
		endif
	else
		if Sonec.State.Fall = TRUE
			Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeed.y + FALLACCELERATION * Sonec.ObjectData.MoveTimer.CalcRange
		endif
	endif
	
endfunction

// Phase A1: Move/Alignment express the active movement request; MoveSpeed.x
// stores momentum. Stand currently selects ground acceleration/coasting.
// Keep these existing decisions unchanged until their planned redesign.
function SonecMoveHorizontalSpeed(Sonec ref as TSonec)
	local acc as float
	if Sonec.State.Move = TRUE
		// Countersteering on a chest brakes harder than releasing the direction.
		// Keep airborne movement and normal acceleration unchanged.
		acc = SONEC_NORMAL_ACCELERATION_FACTOR
		if Sonec.State.Stand = TRUE and Sonec.CollisionData.ListType = TYPECHEST
			if Sonec.State.Alignment = MOVELEFT and Sonec.ObjectData.MoveSpeed.x > 0
				acc = SONEC_COUNTERSTEER_FACTOR
			endif
			if Sonec.State.Alignment = MOVERIGHT and Sonec.ObjectData.MoveSpeed.x < 0
				acc = SONEC_COUNTERSTEER_FACTOR
			endif
		endif
		if Sonec.State.Alignment = MOVELEFT
			Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x - acc * Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
		else
			Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x + acc * Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
		endif
		// Limit powered ground running only; leave airborne thrust and recoil untouched.
		if Sonec.State.Stand = TRUE
			if Sonec.ObjectData.MoveSpeed.x > Sonec.ObjectData.MoveSpeedMax.x
				Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeedMax.x
			endif
			if Sonec.ObjectData.MoveSpeed.x < -Sonec.ObjectData.MoveSpeedMax.x
				Sonec.ObjectData.MoveSpeed.x = -Sonec.ObjectData.MoveSpeedMax.x
			endif
		endif
	else
		if Sonec.State.Stand = TRUE
			acc = SONEC_GROUND_COAST_FACTOR
		else
			acc = SONEC_AIR_COAST_FACTOR
		endif
		if abs(Sonec.ObjectData.MoveSpeed.x) > SONEC_COAST_ZERO_SPEED
			if Sonec.ObjectData.MoveSpeed.x < 0
				Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x + acc * Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
				if Sonec.State.Stand = TRUE and Sonec.ObjectData.MoveSpeed.x > 0
					Sonec.ObjectData.MoveSpeed.x = 0
				endif
			else
				Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x - acc * Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
				if Sonec.State.Stand = TRUE and Sonec.ObjectData.MoveSpeed.x < 0
					Sonec.ObjectData.MoveSpeed.x = 0
				endif
			endif
		else
			Sonec.ObjectData.MoveSpeed.x = 0
		endif
	endif
		
endfunction

// Movement phase extracted without changing its original order or conditions.
function SonecMoveIntegratePosition(Sonec ref as TSonec)
	Sonec.ObjectData.Position.x = Sonec.ObjectData.Position.x + Sonec.ObjectData.MoveSpeed.x
	Sonec.ObjectData.Position.y = Sonec.ObjectData.Position.y + Sonec.ObjectData.MoveSpeed.y


endfunction

// Movement phase extracted without changing its original order or conditions.
function SonecMoveBalanceStep(Sonec ref as TSonec)
	// A balance step uses a small independent displacement, not running momentum.
	if Sonec.BalanceActive = TRUE
		if Sonec.State.Stand = FALSE or Sonec.State.Move = TRUE or Sonec.State.Duck = TRUE
			Sonec.BalanceActive = FALSE
			Sonec.AnimationData.RepeatAnimation = TRUE
			Sonec.AnimationData.Finished = FALSE
		else
			if Sonec.ObjectData.Position.x < Sonec.BalanceTargetX
				Sonec.ObjectData.Position.x = Sonec.ObjectData.Position.x + SONEC_BALANCE_X_STEP
				if Sonec.ObjectData.Position.x > Sonec.BalanceTargetX
					Sonec.ObjectData.Position.x = Sonec.BalanceTargetX
				endif
			endif
			if Sonec.ObjectData.Position.x > Sonec.BalanceTargetX
				Sonec.ObjectData.Position.x = Sonec.ObjectData.Position.x - SONEC_BALANCE_X_STEP
				if Sonec.ObjectData.Position.x < Sonec.BalanceTargetX
					Sonec.ObjectData.Position.x = Sonec.BalanceTargetX
				endif
			endif
			if Sonec.ObjectData.Position.x = Sonec.BalanceTargetX and Sonec.AnimationData.Finished = TRUE
				Sonec.BalanceActive = FALSE
				Sonec.AnimationData.RepeatAnimation = TRUE
				Sonec.AnimationData.Finished = FALSE
			endif
		endif
	endif
	

endfunction

// Movement phase extracted without changing its original order or conditions.
function SonecMoveHoverBrake(Sonec ref as TSonec)
	// Active jetpack flight takes priority over the Hover air brake.
	if Sonec.State.Hover = TRUE and Sonec.State.Fly = FALSE
		Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeed.y * SONEC_HOVER_AIR_DAMPING
	endif
	

endfunction

// Movement phase extracted without changing its original order or conditions.
function SonecMoveWorldBounds(Sonec ref as TSonec,World ref as TWorld,Screen as TSize)
	// Allow the first descent from off-screen; restore the top boundary afterwards.
        if Sonec.SpawnEntering = TRUE and Sonec.ObjectData.Position.y >= Sonec.ObjectData.Size.Height*0.5
            Sonec.SpawnEntering = FALSE
        endif
        if Sonec.SpawnEntering = FALSE and Sonec.ObjectData.Position.y < Sonec.ObjectData.Size.Height*0.5
            Sonec.ObjectData.Position.y = Sonec.ObjectData.Size.Height*0.5
            Sonec.ObjectData.MoveSpeed.y = 0
        endif
	
	if Sonec.ObjectData.Position.y > World.Size.Height + Sonec.ObjectData.Size.Height*0.5
		Sonec.IsLost = TRUE
	endif
	
	if Sonec.ObjectData.Position.x < Sonec.ObjectData.Size.Width*0.5
		Sonec.ObjectData.Position.x =  Sonec.ObjectData.Size.Width*0.5
		Sonec.ObjectData.MoveSpeed.x = 0
	endif
	
	if Sonec.ObjectData.Position.x > Screen.Width - Sonec.ObjectData.Size.Width*0.5
		Sonec.ObjectData.Position.x = Screen.Width - Sonec.ObjectData.Size.Width*0.5
		Sonec.ObjectData.MoveSpeed.x = 0
	endif


endfunction

// Movement phase extracted without changing its original order or conditions.
function SonecMoveCamera(Sonec ref as TSonec,World ref as TWorld,Screen as TSize)
	if World.Position.y > SONEC_CAMERA_EDGE_MARGIN
		if Sonec.SpriteData.Position.y < Screen.Height * SONEC_CAMERA_UPPER_FRACTION
			World.Position.y = World.Position.y + (Sonec.SpriteData.Position.y - Screen.Height * SONEC_CAMERA_UPPER_FRACTION)
		endif
	endif
	
	if World.Position.y < World.Size.Height - Screen.Height - SONEC_CAMERA_EDGE_MARGIN
		if Sonec.SpriteData.Position.y > Screen.Height * SONEC_CAMERA_LOWER_FRACTION
			World.Position.y = World.Position.y + (Sonec.SpriteData.Position.y - Screen.Height * SONEC_CAMERA_LOWER_FRACTION)
		endif
	endif
	
	SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
	

endfunction

// Phase A1: Movement computes the intended path in CollisionMoveStart/End.
// The later collision pass may resolve that path and update support state.
// AutoSpeed is platform carry, not a synonym for MoveSpeed or LinkedPlateIndex.
function SonecMove(Sonec ref as TSonec,ChestList ref as TChestList,World ref as TWorld,Screen as TSize,Now as integer)
	
	Sonec.CollisionMoveStart = Sonec.ObjectData.Position

	if TimeGet(Sonec.ObjectData.MoveTimer,Now) > 0
		
		SonecMoveVerticalSpeed(Sonec)
		SonecMoveHorizontalSpeed(Sonec)
		SonecMoveLimitChestWall(Sonec,ChestList)
		SonecMoveIntegratePosition(Sonec)
		SonecMoveBalanceStep(Sonec)
		SonecMoveHoverBrake(Sonec)
		SonecMoveWorldBounds(Sonec,World,Screen)
		SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
		SonecMoveCamera(Sonec,World,Screen)
		TimeReset(Sonec.ObjectData.MoveTimer,Now)
		
	endif
		
	Sonec.CollisionMoveEnd = Sonec.ObjectData.Position
	
endfunction
	
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecAnimate(Sonec ref as TSonec,ProtoSonec ref as TProtoSonec,Now as integer)

	local FrameIncrement as integer
	local LastFrame as integer

	if TimeGet(Sonec.AnimationData.AnimTimer,Now) > 0
		if Sonec.State.Stand = TRUE and Sonec.State.Duck = FALSE and (Sonec.ObjectData.MoveSpeed.x <> 0 or Sonec.BalanceActive = TRUE)
			if Sonec.AnimationData.RepeatAnimation = TRUE or Sonec.AnimationData.Finished = FALSE
				FrameIncrement = 1
				if Sonec.State.Alignment = MOVELEFT and Sonec.State.LookAlignment = LOOKRIGHT
					FrameIncrement = -1
				endif
				if Sonec.State.Alignment = MOVERIGHT and Sonec.State.LookAlignment = LOOKLEFT
					FrameIncrement = -1
				endif
				if Sonec.State.LookAlignment = LOOKLEFT
					LastFrame = ProtoSonec.AnimLeft.AnimWalk.Length
				else
					LastFrame = ProtoSonec.AnimRight.AnimWalk.Length
				endif
				Sonec.AnimationData.Frame = Sonec.AnimationData.Frame + FrameIncrement
				if Sonec.AnimationData.Frame > LastFrame
					if Sonec.AnimationData.RepeatAnimation = TRUE
						Sonec.AnimationData.Frame = 0
					else
						Sonec.AnimationData.Frame = LastFrame
						Sonec.AnimationData.Finished = TRUE
					endif
				endif
				if Sonec.AnimationData.Frame < 0
					if Sonec.AnimationData.RepeatAnimation = TRUE
						Sonec.AnimationData.Frame = LastFrame
					else
						Sonec.AnimationData.Frame = 0
						Sonec.AnimationData.Finished = TRUE
					endif
				endif
			endif
		endif

		TimeSet(Sonec.AnimationData.AnimTimer,1000/(abs(Sonec.ObjectData.MoveSpeed.x)+10),1)
		TimeReset(Sonec.AnimationData.AnimTimer,Now)
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecDraw(Sonec ref as TSonec,ProtoSonec ref as TProtoSonec)
	
	if Sonec.State.Fall = TRUE or Sonec.State.Fly = TRUE
		if Sonec.State.LookAlignment = LOOKLEFT
			SpriteDraw(ProtoSonec.AnimLeft.Fly.Sprite,Sonec.SpriteData)
		else
			SpriteDraw(ProtoSonec.AnimRight.Fly.Sprite,Sonec.SpriteData)
		endif
	endif
	
	if Sonec.State.Stand = TRUE
		if Sonec.State.Duck = TRUE
			if Sonec.State.LookAlignment = LOOKLEFT
				SpriteDraw(ProtoSonec.AnimLeft.Duck.Sprite,Sonec.SpriteData)
			else
				SpriteDraw(ProtoSonec.AnimRight.Duck.Sprite,Sonec.SpriteData)
			endif
		else
			if Sonec.ObjectData.MoveSpeed.x <> 0 or Sonec.BalanceActive = TRUE
				if Sonec.State.LookAlignment = LOOKLEFT
					SpriteDraw(ProtoSonec.AnimLeft.AnimWalk[Sonec.AnimationData.Frame].Sprite,Sonec.SpriteData)
				else
					SpriteDraw(ProtoSonec.AnimRight.AnimWalk[Sonec.AnimationData.Frame].Sprite,Sonec.SpriteData)
				endif
			else
				if Sonec.State.LookAlignment = LOOKLEFT
					SpriteDraw(ProtoSonec.AnimLeft.Stand.Sprite,Sonec.SpriteData)
				else
					SpriteDraw(ProtoSonec.AnimRight.Stand.Sprite,Sonec.SpriteData)
				endif
			endif
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

