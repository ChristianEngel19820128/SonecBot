// Shared Sonec damage hitbox: two body circles, including the ducking pose.
// Keep these values aligned with the locally tested K1d enemy-bullet geometry.
#constant SONEC_DUCK_SECOND_CIRCLE_Y 10
#constant SONEC_CHEST_CONTACT_EPSILON 0.5

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
	
	Sonec.ObjectData.MoveSpeedMax.x = 5
	Sonec.ObjectData.MoveSpeedMax.y = 8
	Sonec.ObjectData.MoveSpeed.x = 0
	Sonec.ObjectData.MoveSpeed.y = 0
	Sonec.ObjectData.MoveAcceleration.x = 0.005
	Sonec.ObjectData.MoveAcceleration.y = 0.01
	
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
		
		if (InputActionState(Keys,JoystickIndex,ACTION_MOVE_UP) = 1 or GetJoyY(JoystickIndex) < -0.5) and ((Sonec.State.Fly = FALSE and Sonec.Energy.State > COSTJETFIRE*10) or (Sonec.State.Fly = TRUE and Sonec.Energy.State >= COSTJETFIRE))
			if Sonec.State.Fly = FALSE
				Sonec.Energy.State = Sonec.Energy.State - COSTJETFIRE*10
			endif
			Sonec.State.Fly = TRUE
			Sonec.State.Fall = FALSE
			Sonec.State.Stand = FALSE
			Sonec.AnimationData.Frame = 0
			SonecJetfireAdd(Sonec,JetfireList,ProtoJetfire,World,Position,Now)
		else
			if (InputActionState(Keys,JoystickIndex,ACTION_MOVE_UP) = 1 or GetJoyY(JoystickIndex) < -0.5) and Sonec.State.Stand = TRUE
				Sonec.State.Jump = TRUE
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

function SonecCollideReset(Sonec ref as TSonec)
	
	Sonec.CollisionData.ListType = 0
	Sonec.CollisionData.Index = -1
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

function SonecCollidePlate(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,World ref as TWorld)
	
	local i as integer
	local PlateIndex as integer
	local SideHitIndex as integer
	local PassPlateIndex as integer
	local PassIndex as integer
	local HalfWidth as float
	local HalfHeight as float
	
	
	PlateIndex = -1
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
	SideHitIndex = SonecCollideChestVertical(Sonec,ChestList,PlateList,PlateIndex,World)
	SonecCollideChestHorizontal(Sonec,ChestList,World,SideHitIndex)
	if Sonec.PassThroughChestIndex >= 0
		PassPlateIndex = ChestList.Chest[Sonec.PassThroughChestIndex].CollisionData.Index
	endif
		
	if Sonec.State.Stand = FALSE and Sonec.State.Fall = TRUE
		if Sonec.ObjectData.MoveSpeed.y > 0
			for i = 0 to PlateList.Plate.Length
				if i <> PassPlateIndex and PlateList.Plate[i].Enabled = TRUE
					if Sonec.ObjectData.Position.x > PlateList.Plate[i].ObjectData.Position.x
						if Sonec.ObjectData.Position.x < PlateList.Plate[i].ObjectData.Position.x + PlateList.Plate[i].ObjectData.Size.Width
							if Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5 > PlateList.Plate[i].ObjectData.Position.y
								if Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5 < PlateList.Plate[i].ObjectData.Position.y + PlateList.Plate[i].ObjectData.Size.Height + Sonec.ObjectData.MoveSpeed.y
									Sonec.ObjectData.Position.y = PlateList.Plate[i].ObjectData.Position.y - Sonec.ObjectData.Size.Height*0.5
									Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - PlateList.Plate[i].ObjectData.Position.x
									Sonec.CollisionData.Position.y = Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5 - PlateList.Plate[i].ObjectData.Position.y
									Sonec.State.Fall = FALSE
									Sonec.State.Stand = TRUE
									Sonec.CollisionData.ListType = TYPEPLATE
									Sonec.CollisionData.Index = i
									Sonec.ObjectData.MoveSpeed.y = 0
									SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
								endif
							endif
						endif
					endif
				endif
			next i
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

function SonecCollideChestVertical(Sonec ref as TSonec,ChestList ref as TChestList,PlateList ref as TPlateList,Index as integer,World ref as TWorld)
	local i as integer
	local HalfWidth as float
	local HalfHeight as float
	local PlayerStepX as float
	local PlayerStepY as float
	local RelativeStepX as float
	local RelativeStepY as float
	local StartLeft as float
	local StartRight as float
	local StartTop as float
	local StartBottom as float
	local EnterX as float
	local ExitX as float
	local EnterY as float
	local ExitY as float
	local EnterTime as float
	local ExitTime as float
	local SideTime as float
	local BottomTime as float
	local CandidateX as float
	local HitPositionX as float
	local ContactSide as integer
	local ContactFace as integer
	local HitIndex as integer
	local BottomIndex as integer
	local HitCandidate as integer

	HalfWidth = Sonec.ObjectData.Size.Width*0.5
	HalfHeight = Sonec.ObjectData.Size.Height*0.5
	PlayerStepX = Sonec.CollisionMoveEnd.x - Sonec.CollisionMoveStart.x
	PlayerStepY = Sonec.CollisionMoveEnd.y - Sonec.CollisionMoveStart.y
	SideTime = 2.0
	BottomTime = 2.0
	HitIndex = -1
	BottomIndex = -1

	for i = 0 to ChestList.Chest.Length
		if ChestList.Chest[i].Enabled = TRUE
			// The supporting chest and an active passage from underneath
			// never act as new side obstacles.
			if (Sonec.State.Stand = FALSE or Sonec.CollisionData.ListType <> TYPECHEST or Sonec.CollisionData.Index <> i) and Sonec.PassThroughChestIndex <> i
				RelativeStepX = PlayerStepX - (ChestList.Chest[i].ObjectData.Position.x - ChestList.Chest[i].CollisionMoveStart.x)
				RelativeStepY = PlayerStepY - (ChestList.Chest[i].ObjectData.Position.y - ChestList.Chest[i].CollisionMoveStart.y)
				StartLeft = Sonec.CollisionMoveStart.x - HalfWidth - ChestList.Chest[i].CollisionMoveStart.x
				StartRight = Sonec.CollisionMoveStart.x + HalfWidth - ChestList.Chest[i].CollisionMoveStart.x
				StartTop = Sonec.CollisionMoveStart.y - HalfHeight - ChestList.Chest[i].CollisionMoveStart.y
				StartBottom = Sonec.CollisionMoveStart.y + HalfHeight - ChestList.Chest[i].CollisionMoveStart.y

				// Swept AABBs. Later entry axis identifies whether the first
				// contact was a side, the top, or the passable underside.
				EnterX = -2.0
				ExitX = 2.0
				ContactSide = 0
				if RelativeStepX > 0
					EnterX = -StartRight / RelativeStepX
					ExitX = (ChestList.Chest[i].ObjectData.Size.Width - StartLeft) / RelativeStepX
					ContactSide = 1
				else
					if RelativeStepX < 0
						EnterX = (ChestList.Chest[i].ObjectData.Size.Width - StartLeft) / RelativeStepX
						ExitX = -StartRight / RelativeStepX
						ContactSide = -1
					else
						if StartRight <= 0 or StartLeft >= ChestList.Chest[i].ObjectData.Size.Width
							ExitX = -3.0
						endif
					endif
				endif

				EnterY = -2.0
				ExitY = 2.0
				ContactFace = 0
				if RelativeStepY > 0
					EnterY = -StartBottom / RelativeStepY
					ExitY = (ChestList.Chest[i].ObjectData.Size.Height - StartTop) / RelativeStepY
					ContactFace = 1
				else
					if RelativeStepY < 0
						EnterY = (ChestList.Chest[i].ObjectData.Size.Height - StartTop) / RelativeStepY
						ExitY = -StartBottom / RelativeStepY
						ContactFace = -1
					else
						if StartBottom <= 0 or StartTop >= ChestList.Chest[i].ObjectData.Size.Height
							ExitY = -3.0
						endif
					endif
				endif

				EnterTime = EnterX
				if EnterY > EnterTime
					EnterTime = EnterY
				endif
				ExitTime = ExitX
				if ExitY < ExitTime
					ExitTime = ExitY
				endif

				if EnterTime <= ExitTime and ExitTime >= 0 and EnterTime <= 1
					// A tiny existing wall overlap can be corrected, but never
					// eject Sonec from a deeply overlapping moving chest.
					if EnterTime < 0 and EnterY < 0 and ContactSide <> 0
						if ContactSide = 1 and StartRight > 0 and StartRight <= SONEC_CHEST_CONTACT_EPSILON
							EnterTime = 0
							EnterX = 0
						endif
						if ContactSide = -1 and StartLeft < ChestList.Chest[i].ObjectData.Size.Width and StartLeft >= ChestList.Chest[i].ObjectData.Size.Width - SONEC_CHEST_CONTACT_EPSILON
							EnterTime = 0
							EnterX = 0
						endif
					endif

					// Only Sonec's upward movement initiates an underside pass.
					if ContactFace = -1 and EnterY > EnterX and EnterY >= 0 and EnterY <= 1 and PlayerStepY < 0
						if EnterY < BottomTime
							BottomTime = EnterY
							BottomIndex = i
						endif
					endif

					HitCandidate = FALSE
					if EnterTime >= 0 and EnterX >= EnterY and EnterX <= 1
						if ContactSide = 1 and PlayerStepX > 0 and RelativeStepX > 0
							CandidateX = ChestList.Chest[i].ObjectData.Position.x - HalfWidth
							// Preserve the left world boundary and do not force
							// Sonec backwards merely because a chest moves.
							if CandidateX >= HalfWidth
								if CandidateX < Sonec.CollisionMoveStart.x
									CandidateX = Sonec.CollisionMoveStart.x
								endif
								if CandidateX <= Sonec.CollisionMoveEnd.x
									HitCandidate = TRUE
								endif
							endif
						endif
						if ContactSide = -1 and PlayerStepX < 0 and RelativeStepX < 0
							CandidateX = ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width + HalfWidth
							if CandidateX > Sonec.CollisionMoveStart.x
								CandidateX = Sonec.CollisionMoveStart.x
							endif
							if CandidateX >= Sonec.CollisionMoveEnd.x
								HitCandidate = TRUE
							endif
						endif
					endif

					if HitCandidate = TRUE and EnterTime < SideTime
						SideTime = EnterTime
						HitIndex = i
						HitPositionX = CandidateX
					endif
				endif
			endif
		endif
	next i

	// Retain the permission while Sonec rises and falls within the chest;
	// its supporting plate must not catch him on the way back down.
	if BottomIndex >= 0 and Sonec.PassThroughChestIndex < 0 and BottomTime <= SideTime
		Sonec.PassThroughChestIndex = BottomIndex
	endif

	if HitIndex >= 0
		Sonec.ObjectData.Position.x = HitPositionX
		Sonec.ObjectData.MoveSpeed.x = 0
		Sonec.State.Move = FALSE
		if Sonec.BalanceActive = TRUE
			Sonec.BalanceActive = FALSE
			Sonec.AnimationData.RepeatAnimation = TRUE
			Sonec.AnimationData.Finished = FALSE
		endif
		// Keep standing offsets in sync with the corrected X.
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
endfunction HitIndex

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecCollideChestHorizontal(Sonec ref as TSonec,ChestList ref as TChestList,World ref as TWorld,SideHitIndex as integer)
	
	local i as integer
	
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
		
	// Only the chest hit from the side is excluded from landing.
	if Sonec.State.Stand = FALSE and Sonec.State.Fall = TRUE
		for i = 0 to ChestList.Chest.Length
            if ChestList.Chest[i].Enabled = TRUE and Sonec.PassThroughChestIndex <> i and SideHitIndex <> i
			if Sonec.ObjectData.Position.x > ChestList.Chest[i].ObjectData.Position.x
				if Sonec.ObjectData.Position.x < ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width
					if Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5 > ChestList.Chest[i].ObjectData.Position.y
						if Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5 < ChestList.Chest[i].ObjectData.Position.y + Sonec.ObjectData.MoveSpeed.y
							Sonec.ObjectData.Position.y = ChestList.Chest[i].ObjectData.Position.y - Sonec.ObjectData.Size.Height*0.5
							Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - ChestList.Chest[i].ObjectData.Position.x
							Sonec.CollisionData.Position.y = Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5 - ChestList.Chest[i].ObjectData.Position.y
							Sonec.State.Fall = FALSE
							Sonec.State.Stand = TRUE
							Sonec.CollisionData.ListType = TYPECHEST
							Sonec.CollisionData.Index = i
							Sonec.ObjectData.MoveSpeed.y = 0
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
				endif
			endif
            endif
		next i
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecMove(Sonec ref as TSonec,World ref as TWorld,Screen as TSize,Now as integer)
	
	local a as float
	local acc as float
	
	Sonec.CollisionMoveStart = Sonec.ObjectData.Position

	if TimeGet(Sonec.ObjectData.MoveTimer,Now) > 0
		
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
		
		if Sonec.State.Move = TRUE
			// Countersteering on a chest brakes harder than releasing the direction.
			// Keep airborne movement and normal acceleration unchanged.
			acc = 1.0
			if Sonec.State.Stand = TRUE and Sonec.CollisionData.ListType = TYPECHEST
				if Sonec.State.Alignment = MOVELEFT and Sonec.ObjectData.MoveSpeed.x > 0
					acc = 1.5
				endif
				if Sonec.State.Alignment = MOVERIGHT and Sonec.ObjectData.MoveSpeed.x < 0
					acc = 1.5
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
				acc = 0.75
			else
				acc = 0.1
			endif
			if abs(Sonec.ObjectData.MoveSpeed.x) > 0.25
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
			
		Sonec.ObjectData.Position.x = Sonec.ObjectData.Position.x + Sonec.ObjectData.MoveSpeed.x
		Sonec.ObjectData.Position.y = Sonec.ObjectData.Position.y + Sonec.ObjectData.MoveSpeed.y

		// A balance step uses a small independent displacement, not running momentum.
		if Sonec.BalanceActive = TRUE
			if Sonec.State.Stand = FALSE or Sonec.State.Move = TRUE or Sonec.State.Duck = TRUE
				Sonec.BalanceActive = FALSE
				Sonec.AnimationData.RepeatAnimation = TRUE
				Sonec.AnimationData.Finished = FALSE
			else
				if Sonec.ObjectData.Position.x < Sonec.BalanceTargetX
					Sonec.ObjectData.Position.x = Sonec.ObjectData.Position.x + 0.5
					if Sonec.ObjectData.Position.x > Sonec.BalanceTargetX
						Sonec.ObjectData.Position.x = Sonec.BalanceTargetX
					endif
				endif
				if Sonec.ObjectData.Position.x > Sonec.BalanceTargetX
					Sonec.ObjectData.Position.x = Sonec.ObjectData.Position.x - 0.5
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
		
		// Active jetpack flight takes priority over the Hover air brake.
		if Sonec.State.Hover = TRUE and Sonec.State.Fly = FALSE
			Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeed.y * 0.20
		endif
		
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

		SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
		
		if World.Position.y > 10
			if Sonec.SpriteData.Position.y < Screen.Height * 0.33
				World.Position.y = World.Position.y + (Sonec.SpriteData.Position.y - Screen.Height * 0.33)
			endif
		endif
		
		if World.Position.y < World.Size.Height - Screen.Height - 10
			if Sonec.SpriteData.Position.y > Screen.Height * 0.66
				World.Position.y = World.Position.y + (Sonec.SpriteData.Position.y - Screen.Height * 0.66)
			endif
		endif
		
		SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
		
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

