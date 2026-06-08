
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

	Sonec.AnimationData.Frame = 0
		
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
	Sonec.ObjectData.Position.y = 0//Screen.Height/8
	
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
	
	SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
	
	Sonec.EnergyShield.StateMax = 250
	Sonec.EnergyShield.State = 0
	Sonec.EnergyShield.StateChange = 1
	
	Sonec.Energy.StateMax = 3500
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

function SonecFlameGunInput(Sonec ref as TSonec,FlameList ref as TFlameList,ProtoFlame ref as TProtoFlame,World ref as TWorld,Sound ref as TSound,Now as integer)
	
	local Position as TPosition
	local Angle as float
	local Radius as float
	
	if (GetRawKeyState(KEY_3) = 1 or GetRawJoystickButtonState(1,joystickButtonX) = 1 )and Sonec.Energy.State >= COSTFLAME
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
				PlaySound(Sound.MFlameSound)
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

function SonecPlasmaBlitzGunInput(Sonec ref as TSonec,FlashList ref as TFlashList,ProtoFlash ref as TProtoFlash,PlasmaBlitzList ref as TPlasmaBlitzList,ProtoPlasmaBlitz ref as TProtoPlasmaBlitz,World ref as TWorld,Now as integer)
	
	local Position as TPosition
	local Angle as float
	local Radius as float
	
	if (GetRawKeyState(KEY_1) = 1 or GetRawJoystickButtonState(1,joystickButtonY) = 1) and Sonec.Energy.State >= COSTPLASMABLITZ
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

function SonecMGunInput(Sonec ref as TSonec,FlashList ref as TFlashList,ProtoFlash ref as TProtoFlash,BulletList ref as TBulletList,ProtoBullet ref as TProtoBullet,World ref as TWorld,Sound ref as TSound,Now as integer)
	
	local Position as TPosition
	local Angle as float
	local Radius as float
	
	if (GetRawKeyState(KEY_2) = 1 or GetRawJoystickButtonState(1,joystickButtonA) = 1 or Sonec.MGun.FireBurst > 0) and Sonec.MGun.Ammo > 0
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
			PlaySound(Sound.MGunSound)
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

function SonecGrenadeLauncherInput(Sonec ref as TSonec,GrenadeList ref as TGrenadeList,ProtoGrenade ref as TProtoGrenade,World ref as TWorld,Sound ref as TSound,Now as integer)
	
	local Position as TPosition
	local Angle as float
	local Radius as float
	local Recoil as float
	
	if (GetRawKeyState(KEY_2) = 1 or GetRawJoystickButtonState(1,joystickButtonB) = 1) and Sonec.GrenadeLauncher.Ammo > 0
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
				
			PlaySound(Sound.GrenadeLauncherSound)
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

function SonecShieldInput(Sonec ref as TSonec,Shield ref as TShield,World ref as TWorld,Now as integer)

	local Position as TPosition
	
	if GetRawKeyPressed(KEY_5) = 1 or GetRawJoystickButtonPressed(1,joystickButtonRR) = 1
		if Shield.Enabled = FALSE
			if Sonec.Energy.State >= COSTSHIELD
				Shield.Enabled = TRUE
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
					// leben aufbauen
					if Sonec.EnergyShield.State + Sonec.EnergyShield.StateChange <= Sonec.EnergyShield.StateMax
						Sonec.EnergyShield.State = Sonec.EnergyShield.State + Sonec.EnergyShield.StateChange
					else
						Sonec.EnergyShield.State = Sonec.EnergyShield.StateMax
					endif
				else
					Shield.AnimationData.Initialize = FALSE
					Shield.AnimationData.Uninitialize = TRUE
				endif
			else
				// leben abbauen
				if Sonec.EnergyShield.State - Sonec.EnergyShield.StateChange >= 0
					Sonec.EnergyShield.State = Sonec.EnergyShield.State - Sonec.EnergyShield.StateChange
				else
					Sonec.EnergyShield.State = 0
				endif
			endif
			TimeReset(Sonec.EnergyShield.ShieldTimer,Now)
		endif
		
	else
		ShieldReset(Shield,Sonec.EnergyShield.StateMax,Now)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecInenergieInput(Sonec ref as TSonec,Inenergie ref as TInenergie,EnergieList ref as TEnergieList,World ref as TWorld,Now as integer)
	
	local Position as TPosition
	
	if GetRawKeyPressed(KEY_4) = 1 or GetRawJoystickButtonPressed(1,joystickButtonLR) = 1
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

function SonecInput(Sonec ref as TSonec,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Now as integer)
	
	local Position as TPosition
	
	if TimeGet(Sonec.InputTimer,Now) > 0
		
		Position.y = Sonec.ObjectData.Position.y -10
		if Sonec.State.LookAlignment = LOOKLEFT
			Position.x = Sonec.ObjectData.Position.x +12
		else
			Position.x = Sonec.ObjectData.Position.x -12
		endif
		
		if (GetRawKeyState(Key_W) = 1 or GetRawJoystickY(1) < -0.25 or GetRawJoystickButtonState(1,joystickButtonCrossUp) = 1) and ((Sonec.State.Fly = FALSE and Sonec.Energy.State > COSTJETFIRE*10) or (Sonec.State.Fly = TRUE and Sonec.Energy.State >= COSTJETFIRE))
			if Sonec.State.Fly = FALSE
				Sonec.Energy.State = Sonec.Energy.State - COSTJETFIRE*10
			endif
			Sonec.State.Fly = TRUE
			Sonec.State.Fall = FALSE
			Sonec.State.Stand = FALSE
			Sonec.AnimationData.Frame = 0
			SonecJetfireAdd(Sonec,JetfireList,ProtoJetfire,World,Position,Now)
		else
			if (GetRawKeyState(Key_W) = 1 or GetRawJoystickY(1) < -0.25 or GetRawJoystickButtonState(1,joystickButtonCrossUp) = 1) and Sonec.State.Stand = TRUE
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
		
		if GetRawKeyState(Key_S) = 1 or GetRawJoystickY(1) > 0.5 or GetRawJoystickButtonState(1,joystickButtonCrossDown) = 1
			Sonec.State.Duck = TRUE
			Sonec.AnimationData.Frame = 0
		else
			Sonec.State.Duck = FALSE
		endif
		
		Sonec.State.Move = FALSE
		
		if GetRawKeyState(Key_A) = 1 or GetRawKeyState(Key_Q) = 1 or GetRawJoystickX(1) < -0.5 or GetRawJoystickZ(1) > 0.5 or GetRawJoystickButtonState(1,joystickButtonCrossLeft) = 1
			if GetRawKeyState(Key_A) = 1 or GetRawJoystickX(1) < -0.5 or GetRawJoystickButtonState(1,joystickButtonCrossLeft) = 1
				if GetRawJoystickZ(1) = 0
					Sonec.State.LookAlignment = LOOKLEFT
				endif
			endif
			if GetRawKeyState(Key_Q) = 1 or GetRawJoystickZ(1) > 0.5
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
			if GetRawKeyState(Key_CONTROL) = 1 or GetRawJoystickButtonState(1,joystickButtonPadLeft) = 1
				//Sonec.State.LookAlignment = LOOKRIGHT
				Sonec.State.Hover = TRUE
			else	
				Sonec.State.Hover = FALSE
			endif
		endif
		
		if GetRawKeyState(Key_D) = 1 or GetRawKeyState(Key_E) = 1 or GetRawJoystickX(1) > 0.5 or GetRawJoystickRZ(1) > 0.5 or GetRawJoystickButtonState(1,joystickButtonCrossRight) = 1
			if GetRawKeyState(Key_D) = 1 or GetRawJoystickX(1) > 0.5 or GetRawJoystickButtonState(1,joystickButtonCrossRight) = 1
				if GetRawJoystickRZ(1) = 0
					Sonec.State.LookAlignment = LOOKRIGHT
				endif
			endif
			if GetRawKeyState(Key_E) = 1 or GetRawJoystickRZ(1) > 0.5
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
			if GetRawKeyState(Key_CONTROL) = 1 or GetRawJoystickButtonState(1,joystickButtonPadLeft) = 1
				//Sonec.State.LookAlignment = LOOKLEFT
				Sonec.State.Hover = TRUE
			else	
				Sonec.State.Hover = FALSE
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
	
endfunction
						
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecCollidePlate(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,World ref as TWorld)
	
	local i as integer
	local PlateIndex as integer
	
	
	PlateIndex = -1
	
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
	
	SonecCollideChestVertical(Sonec,ChestList,PlateList,PlateIndex,World)
	SonecCollideChestHorizontal(Sonec,ChestList,World)
		
	if Sonec.State.Stand = FALSE and Sonec.State.Fall = TRUE
		if Sonec.ObjectData.MoveSpeed.y > 0
			for i = 0 to PlateList.Plate.Length
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
			next i
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
	local Position as TPosition
	local Radius as float
	local Box1P1 as TPosition
	local Box1P2 as TPosition
	local Box2P1 as TPosition
	local Box2P2 as TPosition
	
	if Sonec.ObjectData.Position.x > Sonec.ObjectData.Size.Width*0.5
	
	for i = 0 to ChestList.Chest.Length
			
		if ChestList.Chest[i].Enabled = TRUE
			if Sonec.State.Stand = FALSE or ChestList.Chest[i].CollisionData.Index = Index
			
				if Sonec.ObjectData.Position.x + Sonec.ObjectData.Size.Width*0.5 + Sonec.ObjectData.MoveSpeed.x > ChestList.Chest[i].ObjectData.Position.x
					if Sonec.ObjectData.Position.x - Sonec.ObjectData.Size.Width*0.5 + Sonec.ObjectData.MoveSpeed.x < ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width
							
						Box1P1.x = ChestList.Chest[i].ObjectData.Position.x
						Box1P1.y = ChestList.Chest[i].ObjectData.Position.y
						
						Box1P2.x = ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width
						Box1P2.y = ChestList.Chest[i].ObjectData.Position.y + ChestList.Chest[i].ObjectData.Size.Height
						
						Box2P1.x = Sonec.ObjectData.Position.x - Sonec.ObjectData.Size.Width*0.5
						Box2P1.y = Sonec.ObjectData.Position.y - Sonec.ObjectData.Size.Height*0.5
						
						Box2P2.x = Sonec.ObjectData.Position.x + Sonec.ObjectData.Size.Width*0.5
						Box2P2.y = Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5
				
						if BoxInBox(Box1P1,Box1P2,Box2P1,Box2P2) = TRUE
						
							if Sonec.ObjectData.Position.x > ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width
								if Sonec.ObjectData.Position.x - Sonec.ObjectData.Size.Width*0.5 < ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width
									Sonec.ObjectData.Position.x = ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width + Sonec.ObjectData.Size.Width*0.5
									if ChestList.Chest[i].CollisionData.Index = Index
										Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - PlateList.Plate[Index].ObjectData.Position.x
									endif
									if Sonec.ObjectData.MoveSpeed.x < 0
										Sonec.ObjectData.MoveSpeed.x = 0
										Sonec.State.Move = 0
									endif
									SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
								endif
							endif
								
							if Sonec.ObjectData.Position.x < ChestList.Chest[i].ObjectData.Position.x
								if Sonec.ObjectData.Position.x + Sonec.ObjectData.Size.Width*0.5 > ChestList.Chest[i].ObjectData.Position.x
									Sonec.ObjectData.Position.x = ChestList.Chest[i].ObjectData.Position.x - Sonec.ObjectData.Size.Width*0.5
									if ChestList.Chest[i].CollisionData.Index = Index
										Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - PlateList.Plate[Index].ObjectData.Position.x
									endif
									if Sonec.ObjectData.MoveSpeed.x > 0
										Sonec.ObjectData.MoveSpeed.x = 0
										Sonec.State.Move = 0
									endif
									SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
								endif
							endif
							
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

function SonecCollideChestHorizontal(Sonec ref as TSonec,ChestList ref as TChestList,World ref as TWorld)
	
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
							if Sonec.ObjectData.MoveSpeed.x <> 0
								Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x
							else
								Sonec.ObjectData.Position.x = ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x + Sonec.CollisionData.Position.x
							endif
						endif
						
						SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
						
						if Sonec.ObjectData.Position.x < ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x
							SonecCollideReset(Sonec)
						else
							if Sonec.ObjectData.Position.x > ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Position.x + ChestList.Chest[Sonec.CollisionData.Index].ObjectData.Size.Width
								SonecCollideReset(Sonec)
							endif
						endif
			
					endif
				endif
			endif
		endif
	endif
		
	if Sonec.State.Stand = FALSE and Sonec.State.Fall = TRUE
		for i = 0 to ChestList.Chest.Length
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
							SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
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
			if Sonec.State.Alignment = MOVELEFT
				Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x - Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
			else
				Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x + Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
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
				else					
					Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x - acc * Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
				endif
			else
				Sonec.ObjectData.MoveSpeed.x = 0
			endif
		endif
			
		Sonec.ObjectData.Position.x = Sonec.ObjectData.Position.x + Sonec.ObjectData.MoveSpeed.x
		Sonec.ObjectData.Position.y = Sonec.ObjectData.Position.y + Sonec.ObjectData.MoveSpeed.y
		
		if Sonec.State.Hover = TRUE
			Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeed.y * 0.20
		endif
		
		if Sonec.ObjectData.Position.y < Sonec.ObjectData.Size.Height*0.5
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
		
endfunction
	
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SonecAnimate(Sonec ref as TSonec,ProtoSonec ref as TProtoSonec,Now as integer)
	
	if TimeGet(Sonec.AnimationData.AnimTimer,Now) > 0
		if Sonec.State.Stand = TRUE and Sonec.State.Duck = FALSE and Sonec.ObjectData.MoveSpeed.x <> 0
			if Sonec.State.Alignment = MOVELEFT and Sonec.State.LookAlignment = LOOKLEFT
				Sonec.AnimationData.Frame = Sonec.AnimationData.Frame +1
				if Sonec.AnimationData.Frame > ProtoSonec.AnimLeft.AnimWalk.Length
					Sonec.AnimationData.Frame = 0
				endif
			endif
			if Sonec.State.Alignment = MOVELEFT and Sonec.State.LookAlignment = LOOKRIGHT
				Sonec.AnimationData.Frame = Sonec.AnimationData.Frame -1
				if Sonec.AnimationData.Frame < 0
					Sonec.AnimationData.Frame = ProtoSonec.AnimRight.AnimWalk.Length
				endif
			endif
			if Sonec.State.Alignment = MOVERIGHT and Sonec.State.LookAlignment = LOOKLEFT
				Sonec.AnimationData.Frame = Sonec.AnimationData.Frame -1
				if Sonec.AnimationData.Frame < 0
					Sonec.AnimationData.Frame = ProtoSonec.AnimLeft.AnimWalk.Length
				endif
			endif
			if Sonec.State.Alignment = MOVERIGHT and Sonec.State.LookAlignment = LOOKRIGHT
				Sonec.AnimationData.Frame = Sonec.AnimationData.Frame +1
				if Sonec.AnimationData.Frame > ProtoSonec.AnimRight.AnimWalk.Length
					Sonec.AnimationData.Frame = 0
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
			if Sonec.ObjectData.MoveSpeed.x <> 0
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

