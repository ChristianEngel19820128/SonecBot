// Shared Sonec damage hitbox: two body circles, including the ducking pose.
// Keep these values aligned with the locally tested K1d enemy-bullet geometry.
#constant SONEC_DUCK_SECOND_CIRCLE_Y 10
#constant SONEC_MECHANICAL_FRONT_X 25
#constant SONEC_MECHANICAL_RELATIVE_EPSILON 0.0001
#constant SONEC_DEPTH_NEUTRAL 0
#constant SONEC_DEPTH_PASSAGE 1
#constant SONEC_DEPTH_CLEARED 2
#constant SONEC_DEPTH_EPSILON 0.0001
#constant SONEC_CHEST_SWEEP_EPSILON 0.01
#constant SONEC_CHEST_SWEEP_ITERATIONS 18
// === Sonec movement balancing (current movement-step units) ===
// Horizontal: speed limits, acceleration and passive braking.
#constant SONEC_MAX_GROUND_SPEED 5
#constant SONEC_MAX_AIR_THRUST_SPEED 8
#constant SONEC_GROUND_ACCELERATION 0.005
#constant SONEC_AIR_THRUST_ACCELERATION 0.005
// Unpowered jump steering: no energy cost, no passive braking.
#constant SONEC_JUMP_CORRECTION_ACCELERATION 0.001
#constant SONEC_JUMP_MAX_CORRECTION_X 1.5
#constant SONEC_NORMAL_ACCELERATION_FACTOR 1.0
#constant SONEC_COUNTERSTEER_FACTOR 1.5
#constant SONEC_GROUND_COAST_FACTOR 0.75
#constant SONEC_AIR_COAST_FACTOR 0.1
#constant SONEC_COAST_ZERO_SPEED 0.25

// Vertical: positive Y is down; accelerations use MoveTimer.CalcRange.
// Gross jet thrust minus gravity = net upward acceleration (0.03 initially).
#constant SONEC_FALL_ACCELERATION 0.01
#constant SONEC_JETPACK_THRUST_ACCELERATION 0.025
#constant SONEC_MAX_JETPACK_UP_SPEED 10
#constant SONEC_MAX_FALL_SPEED 16
// A zero fall-speed limit disables it. Positive limits cap downward acceleration.
#constant SONEC_JUMP_IMPULSE_Y 8
// Optional minimum launch speed in the requested direction, relative to support.
// Zero disables it; an opposite existing velocity is never redirected.
#constant SONEC_JUMP_MIN_RELATIVE_X 0.0
#constant SONEC_JETPACK_HOLD_MS 180
#constant SONEC_GRENADE_RECOIL_X 1.0
#constant SONEC_HOVER_AIR_DAMPING 0.20

// Kistenkante / balance and local depth eligibility (provisional values).
#constant SONEC_FOOT_HALF_X 8.0
#constant SONEC_GROUND_CLEARANCE_STEP_X 1.0
#constant SONEC_DEPTH_RELEVANCE_X 100.0
#constant SONEC_BALANCE_X_STEP 0.5
#constant SONEC_MINI_HOP_IMPULSE_Y 1.5
#constant SONEC_MINI_HOP_MIN_RELATIVE_X 1.0

// Jetstream visuals only: maximum total particles per accepted emission.
#constant SONEC_JETSTREAM_SPACING 4.0
#constant SONEC_JETSTREAM_MAX_PER_EMISSION 3
#constant SONEC_JETSTREAM_MAX_GAP_MS 100

// Diagnostics and camera (not movement balancing).
#constant SONEC_INTEGRATION_TRACE 1
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
	TimeSet(Sonec.InputTimer,10,1)
	TimeReset(Sonec.InputTimer,Now)
	TimeSet(Sonec.InputActionTimer,15,1)
	TimeReset(Sonec.InputActionTimer,Now)

	Sonec.IsLost = False
	Sonec.BalanceActive = FALSE
	Sonec.BalanceTargetX = 0
	Sonec.DebugEdgePending = FALSE
	Sonec.DebugEdgeEvent = 0
	Sonec.DebugEdgeChestX = 0
	Sonec.DebugEdgeChestSpeedX = 0
	Sonec.DebugEdgeBeforeBalanceX = 0
	Sonec.DebugEdgeAfterBalanceX = 0

	Sonec.AnimationData.Frame = 0
	Sonec.AnimationData.RepeatAnimation = TRUE
	Sonec.AnimationData.Finished = FALSE
		
	Sonec.CollisionData.Index = -1
	Sonec.GroundContactActive = FALSE
	Sonec.NormalJumpActive = FALSE
	Sonec.JumpCorrectionDirection = 0
	Sonec.UpInputHeld = FALSE
	Sonec.UpHoldStartMs = Now
	Sonec.UpJumpHoldPending = FALSE
	Sonec.AirThrustDirection = 0
	Sonec.JetstreamRequested = FALSE
	Sonec.JetstreamPreviousValid = FALSE
	Sonec.JetstreamPreviousMs = Now
	Sonec.JetstreamPreviousNozzleX = 0
	Sonec.DebugTopTrace = ""

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
	Sonec.ObjectData.MoveSpeedMax.y = SONEC_MAX_JETPACK_UP_SPEED
	Sonec.ObjectData.MoveSpeed.x = 0
	Sonec.ObjectData.MoveSpeed.y = 0
	Sonec.ObjectData.MoveAcceleration.x = SONEC_GROUND_ACCELERATION
	Sonec.ObjectData.MoveAcceleration.y = SONEC_JETPACK_THRUST_ACCELERATION
	
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
	local DeltaX as float
	local DeltaY as float
	local Distance as float
	local NozzleX as float
	local Count as integer
	local i as integer
	local Fraction as float
	local ExtraPosition as TPosition

	if Sonec.Energy.State >= COSTJETFIRE
		Sonec.JetstreamRequested = TRUE
		// Keep the existing gated particle and its exact energy charge.
		if JetfireAdd(JetfireList,ProtoJetfire,World,Position,Now) = TRUE
			Sonec.Energy.State = Sonec.Energy.State - COSTJETFIRE
			NozzleX = Position.x-Sonec.ObjectData.Position.x
			if Sonec.JetstreamPreviousValid = TRUE and Now-Sonec.JetstreamPreviousMs <= SONEC_JETSTREAM_MAX_GAP_MS
				// A facing change moves the nozzle; do not draw across the body.
				if abs(NozzleX-Sonec.JetstreamPreviousNozzleX) < 0.01 and SONEC_JETSTREAM_SPACING > 0 and SONEC_JETSTREAM_MAX_PER_EMISSION > 1
					DeltaX = Position.x-Sonec.JetstreamPreviousPosition.x
					DeltaY = Position.y-Sonec.JetstreamPreviousPosition.y
					Distance = sqrt(DeltaX*DeltaX+DeltaY*DeltaY)
					Count = ceil(Distance/SONEC_JETSTREAM_SPACING)
					if Count > SONEC_JETSTREAM_MAX_PER_EMISSION then Count = SONEC_JETSTREAM_MAX_PER_EMISSION
					// The regular particle is already at the endpoint. Fill
					// intermediate world positions, never emit duplicate endpoints.
					for i = 1 to Count-1
						Fraction = i*1.0/Count
						ExtraPosition.x = Sonec.JetstreamPreviousPosition.x+DeltaX*Fraction
						ExtraPosition.y = Sonec.JetstreamPreviousPosition.y+DeltaY*Fraction
						JetfireInsertParticle(JetfireList,ProtoJetfire,World,ExtraPosition,Now)
					next i
				endif
			endif
			Sonec.JetstreamPreviousPosition = Position
			Sonec.JetstreamPreviousMs = Now
			Sonec.JetstreamPreviousNozzleX = NozzleX
			Sonec.JetstreamPreviousValid = TRUE
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
			
			// Add recoil once in the opposite firing direction. MoveSpeed.x
			// is support-relative on the ground and world-relative in the air.
			// Do not overwrite input direction or create a false lift-off.
			Recoil = SONEC_GRENADE_RECOIL_X
			if Sonec.State.LookAlignment = LOOKRIGHT
				Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x - Recoil
			else
				Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x + Recoil
			endif
			if Recoil <> 0 and Sonec.BalanceActive = TRUE
				Sonec.BalanceActive = FALSE
				Sonec.AnimationData.RepeatAnimation = TRUE
				Sonec.AnimationData.Finished = FALSE
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

// Phase D: ground MoveSpeed is relative to the support, air MoveSpeed is
// world momentum. Transfer cached support motion exactly once on release.
function SonecReleaseSupportMotion(Sonec ref as TSonec)
	if Sonec.GroundContactActive = TRUE
		Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x + Sonec.ObjectData.AutoSpeed.x
		Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeed.y + Sonec.ObjectData.AutoSpeed.y
	endif
	Sonec.GroundContactActive = FALSE
	Sonec.ObjectData.AutoSpeed.x = 0
	Sonec.ObjectData.AutoSpeed.y = 0
endfunction

// Phase A2: Keep all Up-button flight/jump/fall transitions in one place.
// This extraction preserves the old branch priority and energy thresholds.
// It does not yet redefine the physical grounded/contact model.
// A fresh Up press at real support always starts a normal jump, even
// with full energy. Apply optional launch assistance before carrier release.
function SonecStartNormalJump(Sonec ref as TSonec,Direction as integer)
	local RelativeVX as float
	RelativeVX = Sonec.ObjectData.MoveSpeed.x
	if SONEC_JUMP_MIN_RELATIVE_X > 0 and Direction <> 0
		if RelativeVX*Direction >= 0 and RelativeVX*Direction < SONEC_JUMP_MIN_RELATIVE_X
			Sonec.ObjectData.MoveSpeed.x = Direction*SONEC_JUMP_MIN_RELATIVE_X
		endif
	endif
	Sonec.State.Jump = TRUE
	Sonec.NormalJumpActive = TRUE
	Sonec.AirThrustDirection = 0
	SonecReleaseSupportMotion(Sonec)
	Sonec.State.Stand = FALSE
	Sonec.State.Fly = FALSE
	Sonec.State.Fall = FALSE
	Sonec.BalanceActive = FALSE
	Sonec.AnimationData.RepeatAnimation = TRUE
	Sonec.AnimationData.Finished = FALSE
	Sonec.AnimationData.Frame = 0
endfunction

// Sample the combined logical action each active game frame, not just
// the slower input timer. The virtual game clock excludes paused time.
function SonecTrackUpInput(Sonec ref as TSonec,UpHeld as integer,UpPressed as integer,Direction as integer,Now as integer)
	if Sonec.UpInputHeld = FALSE and (UpHeld = TRUE or UpPressed = TRUE)
		Sonec.UpHoldStartMs = Now
		// Only the press which actually starts a jump needs the hold delay.
		Sonec.UpJumpHoldPending = FALSE
		if Sonec.GroundContactActive = TRUE
			Sonec.UpJumpHoldPending = TRUE
			SonecStartNormalJump(Sonec,Direction)
		endif
	endif
	Sonec.UpInputHeld = UpHeld
	if UpHeld = FALSE
		Sonec.UpJumpHoldPending = FALSE
		// Release thrust immediately; never cancel a queued jump impulse.
		Sonec.State.Fly = FALSE
		if Sonec.GroundContactActive = FALSE and Sonec.State.Jump = FALSE
			Sonec.State.Fall = TRUE
		endif
	endif
	// Once the original hold is long enough, no new delay is introduced
	// by energy depletion, pickup or a landing during that same hold.
	if Sonec.UpJumpHoldPending = TRUE and Now-Sonec.UpHoldStartMs >= SONEC_JETPACK_HOLD_MS
		Sonec.UpJumpHoldPending = FALSE
	endif
endfunction

function SonecInputVerticalState(Sonec ref as TSonec,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Position as TPosition,Now as integer)
	// A pending jump must be integrated before the jetpack may engage.
	// Only the original ground-jump press has an additional hold delay.
	if Sonec.State.Jump = TRUE then exitfunction
	if Sonec.UpInputHeld = TRUE and Sonec.UpJumpHoldPending = FALSE and ((Sonec.State.Fly = FALSE and Sonec.Energy.State > COSTJETFIRE*10) or (Sonec.State.Fly = TRUE and Sonec.Energy.State >= COSTJETFIRE))
		if Sonec.State.Fly = FALSE
			Sonec.Energy.State = Sonec.Energy.State - COSTJETFIRE*10
		endif
		Sonec.NormalJumpActive = FALSE
		Sonec.JumpCorrectionDirection = 0
		Sonec.State.Fly = TRUE
		Sonec.State.Fall = FALSE
		Sonec.State.Stand = FALSE
		SonecReleaseSupportMotion(Sonec)
		Sonec.AnimationData.Frame = 0
		SonecJetfireAdd(Sonec,JetfireList,ProtoJetfire,World,Position,Now)
	else
		Sonec.State.Fly = FALSE
		if Sonec.GroundContactActive = FALSE
			Sonec.State.Fall = TRUE
		endif
	endif
endfunction

// Phase A1: Input owns control intent and the existing Fly/Fall/Stand/Jump
// transitions. Do not treat these flags as a collision result without checking
// the actual support recorded in CollisionData. Keep ButtonDown energy behavior.
function SonecInput(Sonec ref as TSonec,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Keys ref as TKeys,Options ref as TGameOptions,JoystickIndex as integer,Now as integer)
	
	local Position as TPosition
	local UpHeld as integer
	local UpPressed as integer
	local LeftHeld as integer
	local RightHeld as integer
	local JumpDirection as integer

	UpHeld = (InputActionState(Keys,JoystickIndex,ACTION_MOVE_UP) = 1 or GetJoyY(JoystickIndex) < -0.5)
	UpPressed = InputActionPressed(Keys,JoystickIndex,ACTION_MOVE_UP)
	LeftHeld = (InputActionState(Keys,JoystickIndex,ACTION_MOVE_LEFT) = 1 or InputActionState(Keys,JoystickIndex,ACTION_MOVE_BACK_LEFT) = 1 or GetJoyX(JoystickIndex) < -0.5 or GetJoyZ(JoystickIndex) > 0.5)
	RightHeld = (InputActionState(Keys,JoystickIndex,ACTION_MOVE_RIGHT) = 1 or InputActionState(Keys,JoystickIndex,ACTION_MOVE_BACK_RIGHT) = 1 or GetJoyX(JoystickIndex) > 0.5 or GetJoyRZ(JoystickIndex) > 0.5)
	// Conflicting directions request no optional launch assistance.
	JumpDirection = RightHeld - LeftHeld
	SonecTrackUpInput(Sonec,UpHeld,UpPressed,JumpDirection,Now)
	// Sample weak unpowered steering every frame, including short taps.
	Sonec.JumpCorrectionDirection = 0
	if Sonec.NormalJumpActive = TRUE and Sonec.GroundContactActive = FALSE
		Sonec.JumpCorrectionDirection = JumpDirection
	endif
	
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
		Sonec.JetstreamRequested = FALSE
		
		Position.y = Sonec.ObjectData.Position.y -10
		if Sonec.State.LookAlignment = LOOKLEFT
			Position.x = Sonec.ObjectData.Position.x +12
		else
			Position.x = Sonec.ObjectData.Position.x -12
		endif
		
		SonecInputVerticalState(Sonec,JetfireList,ProtoJetfire,World,Position,Now)

		if InputActionState(Keys,JoystickIndex,ACTION_MOVE_DOWN) = 1 or GetJoyY(JoystickIndex) > 0.5
			Sonec.State.Duck = TRUE
			Sonec.AnimationData.Frame = 0
		else
			Sonec.State.Duck = FALSE
		endif
		
		Sonec.State.Move = FALSE
		Sonec.AirThrustDirection = 0
		
		if LeftHeld = TRUE
			if InputActionState(Keys,JoystickIndex,ACTION_MOVE_LEFT) = 1 or GetJoyX(JoystickIndex) < -0.5
				if GetJoyZ(JoystickIndex) = 0
					Sonec.State.LookAlignment = LOOKLEFT
				endif
			endif
			if InputActionState(Keys,JoystickIndex,ACTION_MOVE_BACK_LEFT) = 1 or GetJoyZ(1) > 0.5
				Sonec.State.LookAlignment = LOOKRIGHT
			endif
			if Sonec.GroundContactActive = FALSE and Sonec.NormalJumpActive = FALSE and (Sonec.State.Fly = TRUE or Sonec.State.Fall = TRUE) and Sonec.Energy.State >= COSTJETFIRE
				Sonec.AirThrustDirection = -1
				Sonec.State.Move = TRUE
				Sonec.State.Alignment = MOVELEFT
				SonecJetfireAdd(Sonec,JetfireList,ProtoJetfire,World,Position,Now)
			endif
			if Sonec.State.Stand = TRUE and Sonec.State.Duck = FALSE
				Sonec.State.Move = TRUE
				Sonec.State.Alignment = MOVELEFT
			endif
		endif
		
		if RightHeld = TRUE
			if InputActionState(Keys,JoystickIndex,ACTION_MOVE_RIGHT) = 1 or GetJoyX(JoystickIndex) > 0.5
				if GetJoyRZ(1) = 0
					Sonec.State.LookAlignment = LOOKRIGHT
				endif
			endif
			if InputActionState(Keys,JoystickIndex,ACTION_MOVE_BACK_RIGHT) = 1 or GetJoyRZ(JoystickIndex) > 0.5
				Sonec.State.LookAlignment = LOOKLEFT
			endif
			if Sonec.GroundContactActive = FALSE and Sonec.NormalJumpActive = FALSE and (Sonec.State.Fly = TRUE or Sonec.State.Fall = TRUE) and Sonec.Energy.State >= COSTJETFIRE
				Sonec.AirThrustDirection = 1
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

		// Never bridge a non-powered interval with new trail particles.
		if Sonec.JetstreamRequested = FALSE then Sonec.JetstreamPreviousValid = FALSE
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
	SonecReleaseSupportMotion(Sonec)
	
	Sonec.CollisionData.ListType = 0
	Sonec.CollisionData.Index = -1
	Sonec.State.Fall = TRUE
	Sonec.State.Stand = FALSE
	Sonec.BalanceActive = FALSE
	Sonec.AnimationData.RepeatAnimation = TRUE
	Sonec.AnimationData.Finished = FALSE
	
endfunction
						
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Phase A3: A valid landing updates support and depth-plane association.
// Eligibility and timing remain with the existing collision callers.
function SonecSetGroundContact(Sonec ref as TSonec,SurfaceType as integer,SurfaceIndex as integer,PlateIndex as integer,Carry as TSpeed)
	// Convert world momentum to support-relative momentum at the contact.
	// The current residual X path is already world space: do not add carry twice.
	if Sonec.GroundContactActive = FALSE
		Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x - Carry.x
	endif
	Sonec.ObjectData.AutoSpeed = Carry
	Sonec.GroundContactActive = TRUE
	Sonec.NormalJumpActive = FALSE
	Sonec.JumpCorrectionDirection = 0
	Sonec.AirThrustDirection = 0
	// A real landing ends the current flight. Held Up is evaluated again
	// by the existing input path, with its normal activation energy rule.
	Sonec.State.Fly = FALSE
	Sonec.State.Fall = FALSE
	Sonec.State.Stand = TRUE
	Sonec.CollisionData.ListType = SurfaceType
	Sonec.CollisionData.Index = SurfaceIndex
	// A valid landing alone assigns a new active depth plane.
	if Sonec.LinkedPlateIndex <> PlateIndex then Sonec.PassThroughChestIndex = -1
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

// Phase B: shared contact-time comparison; earlier wins, ties stay stable.
function SonecContactChooseEarlier(Best as TSonecContactCandidate,ContactTime as float,ListType as integer,Index as integer,Kind as integer)
	if ContactTime >= 0 and ContactTime <= 1
		if Best.Valid = FALSE or ContactTime < Best.ContactTime
			Best.Valid = TRUE
			Best.ContactTime = ContactTime
			Best.ListType = ListType
			Best.Index = Index
			Best.Kind = Kind
		endif
	endif
endfunction Best

function SonecPlateTopContactTime(Sonec ref as TSonec,PlateList ref as TPlateList,PlateIndex as integer)
	local StartFeetY as float
	local EndFeetY as float
	local RelativeStartY as float
	local RelativeEndY as float
	local ContactTime as float
	local ContactX as float
	local PlateContactX as float

	ContactTime = -1
	StartFeetY = Sonec.CollisionMoveStart.y + Sonec.ObjectData.Size.Height*0.5
	EndFeetY = Sonec.CollisionMoveEnd.y + Sonec.ObjectData.Size.Height*0.5
	RelativeStartY = StartFeetY - SonecCollisionAxisAt(PlateList.Plate[PlateIndex].CollisionMoveStart.y,PlateList.Plate[PlateIndex].ObjectData.Position.y,Sonec.CollisionSegmentStartTime)
	RelativeEndY = EndFeetY - PlateList.Plate[PlateIndex].ObjectData.Position.y
	if RelativeEndY > RelativeStartY and RelativeStartY <= 0 and RelativeEndY >= 0
		ContactTime = -RelativeStartY/(RelativeEndY-RelativeStartY)
		ContactX = Sonec.CollisionMoveStart.x + (Sonec.CollisionMoveEnd.x-Sonec.CollisionMoveStart.x)*ContactTime
		PlateContactX = SonecCollisionAxisAt(PlateList.Plate[PlateIndex].CollisionMoveStart.x,PlateList.Plate[PlateIndex].ObjectData.Position.x,Sonec.CollisionSegmentStartTime) + (PlateList.Plate[PlateIndex].ObjectData.Position.x-SonecCollisionAxisAt(PlateList.Plate[PlateIndex].CollisionMoveStart.x,PlateList.Plate[PlateIndex].ObjectData.Position.x,Sonec.CollisionSegmentStartTime))*ContactTime
		if ContactX <= PlateContactX + SonecFootMargin(PlateList.Plate[PlateIndex].ObjectData.Size.Width) or ContactX >= PlateContactX + PlateList.Plate[PlateIndex].ObjectData.Size.Width - SonecFootMargin(PlateList.Plate[PlateIndex].ObjectData.Size.Width)
			ContactTime = -1
		endif
	endif
endfunction ContactTime

// Obstacle snapshots stay immutable. Each residual sweep begins at the
// corresponding absolute time of the original frame.
function SonecCollisionAxisAt(StartValue as float,EndValue as float,FrameTime as float)
endfunction StartValue + (EndValue-StartValue)*FrameTime

// Actual support displacement is sampled once per GameDo, including zero
// when the plate timer did not advance. AutoSpeed, in contrast, is the
// signed carrier momentum in units of the last Sonec movement update.
function SonecCarrierVelocity(Sonec ref as TSonec,PlateList ref as TPlateList,PlateIndex as integer)
	local Carry as TSpeed
	local StepRange as float
	Carry.x = 0
	Carry.y = 0
	if PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
		if PlateList.Plate[PlateIndex].Enabled = TRUE
			StepRange = Sonec.ObjectData.MoveTimer.CalcRange
			if StepRange <= 0 then StepRange = Sonec.ObjectData.MoveTimer.Range
			// PlateMove subtracts X speed; both timers use the same range units.
			Carry.x = -PlateList.Plate[PlateIndex].ObjectData.MoveSpeed.x*StepRange
			if PlateList.Plate[PlateIndex].YShift.Enabled = TRUE and PlateList.Plate[PlateIndex].YShift.Min < PlateList.Plate[PlateIndex].YShift.Max
				if PlateList.Plate[PlateIndex].YShift.Alignment = MOVEUP
					Carry.y = -PlateList.Plate[PlateIndex].ObjectData.MoveSpeed.y*StepRange
				else
					Carry.y = PlateList.Plate[PlateIndex].ObjectData.MoveSpeed.y*StepRange
				endif
			endif
		endif
	endif
endfunction Carry

// Bounded correction of an existing ground-side gap, swept like other motion.
function SonecGroundClearancePath(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList)
	local i as integer
	local ChestX as float
	local ChestY as float
	local Width as float
	local RelativeX as float
	local EndRelativeX as float
	local Gap as float
	local Direction as integer
	local Correction as float
	local BestCorrection as float
	local BestIndex as integer
	local TargetX as float
	local HalfHeight as float
	if Sonec.GroundContactActive = FALSE or SONEC_GROUND_CLEARANCE_STEP_X <= 0 then exitfunction
	HalfHeight = Sonec.ObjectData.Size.Height*0.5
	BestIndex = -1
	BestCorrection = 0
	for i = 0 to ChestList.Chest.Length
		if SonecChestRelevant(Sonec,PlateList,ChestList,i,FALSE) = TRUE
			if Sonec.CollisionData.ListType <> TYPECHEST or Sonec.CollisionData.Index <> i
				ChestX = ChestList.Chest[i].CollisionMoveStart.x
				ChestY = ChestList.Chest[i].CollisionMoveStart.y
				Width = ChestList.Chest[i].ObjectData.Size.Width
				if Sonec.CollisionMoveStart.y+HalfHeight > ChestY and Sonec.CollisionMoveStart.y-HalfHeight < ChestY+ChestList.Chest[i].ObjectData.Size.Height
					RelativeX = Sonec.CollisionMoveStart.x-ChestX
					Direction = 0
					Gap = 0
					if RelativeX <= 0 and RelativeX > -SONEC_MECHANICAL_FRONT_X
						Direction = -1
						Gap = -RelativeX
						if SonecMechanicalLeftPass(Sonec.CollisionMoveStart.x,ChestList.Chest[i].ObjectData.Position.x-ChestX,Sonec.ObjectData.Size.Width*0.5) = TRUE then Direction = 0
					endif
					if RelativeX >= Width and RelativeX < Width+SONEC_MECHANICAL_FRONT_X
						Direction = 1
						Gap = RelativeX-Width
					endif
					if Direction <> 0
						Correction = SONEC_MECHANICAL_FRONT_X-Gap
						if Correction > SONEC_GROUND_CLEARANCE_STEP_X then Correction = SONEC_GROUND_CLEARANCE_STEP_X
						EndRelativeX = Sonec.CollisionMoveEnd.x-ChestList.Chest[i].ObjectData.Position.x
						if (EndRelativeX-RelativeX)*Direction < Correction and Correction > abs(BestCorrection)
							BestCorrection = Direction*Correction
							BestIndex = i
							TargetX = ChestList.Chest[i].ObjectData.Position.x+RelativeX+BestCorrection
						endif
					endif
				endif
			endif
		endif
	next i
	if BestIndex >= 0
		Sonec.CollisionMoveEnd.x = TargetX
		if Sonec.ObjectData.MoveSpeed.x*BestCorrection < 0 then Sonec.ObjectData.MoveSpeed.x = 0
	endif
endfunction

function SonecPrepareSupportPath(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList)
	local i as integer
	local PlateIndex as integer
	local CarryX as float
	local SurfaceY as float
	if Sonec.GroundContactActive = FALSE then exitfunction
	i = Sonec.CollisionData.Index
	if Sonec.CollisionData.ListType = TYPEPLATE
		if i < 0 or i > PlateList.Plate.Length
			SonecCollideReset(Sonec)
			exitfunction
		endif
		if PlateList.Plate[i].Enabled = FALSE
			SonecCollideReset(Sonec)
			exitfunction
		endif
		PlateIndex = i
		CarryX = PlateList.Plate[i].ObjectData.Position.x - PlateList.Plate[i].CollisionMoveStart.x
		SurfaceY = PlateList.Plate[i].ObjectData.Position.y
	else
		if Sonec.CollisionData.ListType <> TYPECHEST
			SonecCollideReset(Sonec)
			exitfunction
		endif
		if i < 0 or i > ChestList.Chest.Length
			SonecCollideReset(Sonec)
			exitfunction
		endif
		if ChestList.Chest[i].Enabled = FALSE
			SonecCollideReset(Sonec)
			exitfunction
		endif
		PlateIndex = ChestList.Chest[i].CollisionData.Index
		CarryX = ChestList.Chest[i].ObjectData.Position.x - ChestList.Chest[i].CollisionMoveStart.x
		SurfaceY = ChestList.Chest[i].ObjectData.Position.y
	endif
	Sonec.ObjectData.AutoSpeed = SonecCarrierVelocity(Sonec,PlateList,PlateIndex)
	// The own path (including balance/recoil) is added to actual carry,
	// regardless of the sign or magnitude of the own movement.
	Sonec.CollisionMoveEnd.x = Sonec.CollisionMoveEnd.x + CarryX
	Sonec.CollisionMoveEnd.y = SurfaceY - Sonec.ObjectData.Size.Height*0.5
	if Sonec.BalanceActive = TRUE then Sonec.BalanceTargetX = Sonec.BalanceTargetX + CarryX
endfunction

// Clamp the combined proposal, not the own path before support carry.
// Do not erase an own velocity that already points away from the boundary.
function SonecClampCombinedPath(Sonec ref as TSonec,Screen as TSize)
	local HalfWidth as float
	HalfWidth = Sonec.ObjectData.Size.Width*0.5
	if Sonec.CollisionMoveEnd.x < HalfWidth
		Sonec.CollisionMoveEnd.x = HalfWidth
		if Sonec.ObjectData.MoveSpeed.x < 0 then Sonec.ObjectData.MoveSpeed.x = 0
	endif
	if Sonec.CollisionMoveEnd.x > Screen.Width - HalfWidth
		Sonec.CollisionMoveEnd.x = Screen.Width - HalfWidth
		if Sonec.ObjectData.MoveSpeed.x > 0 then Sonec.ObjectData.MoveSpeed.x = 0
	endif
endfunction

// Support departure is another timed event. No additional gravity/impulse
// integration is performed mid-frame: the existing movement update owns it.
function SonecSupportExitTime(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList)
	local i as integer
	local StartX as float
	local EndX as float
	local SurfaceWidth as float
	local RelativeStart as float
	local RelativeEnd as float
	local ContactTime as float
	local Margin as float
	local RightLimit as float
	ContactTime = -1
	if Sonec.GroundContactActive = TRUE
		i = Sonec.CollisionData.Index
		if Sonec.CollisionData.ListType = TYPEPLATE
			StartX = SonecCollisionAxisAt(PlateList.Plate[i].CollisionMoveStart.x,PlateList.Plate[i].ObjectData.Position.x,Sonec.CollisionSegmentStartTime)
			EndX = PlateList.Plate[i].ObjectData.Position.x
			SurfaceWidth = PlateList.Plate[i].ObjectData.Size.Width
		else
			StartX = SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.x,ChestList.Chest[i].ObjectData.Position.x,Sonec.CollisionSegmentStartTime)
			EndX = ChestList.Chest[i].ObjectData.Position.x
			SurfaceWidth = ChestList.Chest[i].ObjectData.Size.Width
		endif
		RelativeStart = Sonec.CollisionMoveStart.x - StartX
		RelativeEnd = Sonec.CollisionMoveEnd.x - EndX
		Margin = SonecFootMargin(SurfaceWidth)
		RightLimit = SurfaceWidth-Margin
		// A one-foot chest landing may move inward to regain stable support.
		if RelativeStart < Margin
			if Sonec.CollisionData.ListType <> TYPECHEST or RelativeEnd < RelativeStart-SONEC_MECHANICAL_RELATIVE_EPSILON
				ContactTime = 0
			endif
		endif
		if RelativeStart > RightLimit
			if Sonec.CollisionData.ListType <> TYPECHEST or RelativeEnd > RelativeStart+SONEC_MECHANICAL_RELATIVE_EPSILON
				ContactTime = 0
			endif
		endif
		if ContactTime < 0
			if RelativeStart >= Margin and RelativeEnd < Margin
				ContactTime = (Margin-RelativeStart)/(RelativeEnd-RelativeStart)
			endif
			if RelativeStart <= RightLimit and RelativeEnd > RightLimit
				ContactTime = (RightLimit-RelativeStart)/(RelativeEnd-RelativeStart)
			endif
		endif
	endif
endfunction ContactTime

// Highest active chest top at the original frame's start and end.
// Chests follow their carrier rigidly; the same minimum height is valid
// throughout the linear segment. Without a chest, use the plate top.
function SonecDepthLocalTop(PlateList ref as TPlateList,ChestList ref as TChestList,PlateIndex as integer,PlayerX as float,FrameTime as float)
	local HighestY as float
	local ChestX as float
	local ChestY as float
	local Reach as float
	local i as integer
	HighestY = SonecCollisionAxisAt(PlateList.Plate[PlateIndex].CollisionMoveStart.y,PlateList.Plate[PlateIndex].ObjectData.Position.y,FrameTime)
	Reach = SONEC_DEPTH_RELEVANCE_X
	if Reach < 0 then Reach = 0
	for i = 0 to ChestList.Chest.Length
		if ChestList.Chest[i].Enabled = TRUE and ChestList.Chest[i].CollisionData.Index = PlateIndex
			ChestX = SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.x,ChestList.Chest[i].ObjectData.Position.x,FrameTime)
			if PlayerX >= ChestX-Reach and PlayerX <= ChestX+ChestList.Chest[i].ObjectData.Size.Width+Reach
				ChestY = SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.y,ChestList.Chest[i].ObjectData.Position.y,FrameTime)
				if ChestY < HighestY then HighestY = ChestY
			endif
		endif
	next i
endfunction HighestY

// Passage belongs to a foreign platform, not to a specific chest.
// Starting below its top makes it permeable; once in passage, the
// entire group stays permeable until the feet clear its highest top.
// Treat relative vertical alignment independently of horizontal overlap.
function SonecDepthRefresh(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,PlayerX as float,FeetY as float,FrameTime as float)
	local i as integer
	local PlateX as float
	local PlateY as float
	local HighestY as float
	local Overlap as integer
	local HalfWidth as float
	HalfWidth = Sonec.ObjectData.Size.Width*0.5
	for i = 0 to PlateList.Plate.Length
		if PlateList.Plate[i].Enabled = FALSE or i = Sonec.LinkedPlateIndex
			PlateList.Plate[i].SonecDepthState = SONEC_DEPTH_NEUTRAL
		else
			PlateX = SonecCollisionAxisAt(PlateList.Plate[i].CollisionMoveStart.x,PlateList.Plate[i].ObjectData.Position.x,FrameTime)
			PlateY = SonecCollisionAxisAt(PlateList.Plate[i].CollisionMoveStart.y,PlateList.Plate[i].ObjectData.Position.y,FrameTime)
			Overlap = (PlayerX+HalfWidth > PlateX and PlayerX-HalfWidth < PlateX+PlateList.Plate[i].ObjectData.Size.Width)
			HighestY = SonecDepthLocalTop(PlateList,ChestList,i,PlayerX,FrameTime)
			if Overlap = TRUE and FeetY > PlateY+SONEC_DEPTH_EPSILON
				PlateList.Plate[i].SonecDepthState = SONEC_DEPTH_PASSAGE
			else
				if FeetY <= HighestY+SONEC_DEPTH_EPSILON
					PlateList.Plate[i].SonecDepthState = SONEC_DEPTH_CLEARED
				else
					if Overlap = FALSE
						PlateList.Plate[i].SonecDepthState = SONEC_DEPTH_NEUTRAL
					endif
				endif
			endif
		endif
	next i
endfunction

// The clearance itself is a nonblocking event in the common time order.
// A later contact in the same frame therefore sees the newly solid group.
// Evaluate local clearance at the same interpolated absolute frame time.
function SonecDepthClearCandidate(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,PlateIndex as integer,Candidate as float,BestTime as float)
	local FrameTime as float
	local PlayerX as float
	local FeetY as float
	local HighestY as float
	if Candidate >= 0 and Candidate <= 1
		if BestTime < 0 or Candidate < BestTime
			FrameTime = SonecCollisionAxisAt(Sonec.CollisionSegmentStartTime,1.0,Candidate)
			PlayerX = SonecCollisionAxisAt(Sonec.CollisionMoveStart.x,Sonec.CollisionMoveEnd.x,Candidate)
			FeetY = SonecCollisionAxisAt(Sonec.CollisionMoveStart.y,Sonec.CollisionMoveEnd.y,Candidate)+Sonec.ObjectData.Size.Height*0.5
			HighestY = SonecDepthLocalTop(PlateList,ChestList,PlateIndex,PlayerX,FrameTime)
			if FeetY <= HighestY+SONEC_DEPTH_EPSILON then BestTime = Candidate
		endif
	endif
endfunction BestTime

function SonecDepthClearTime(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,PlateIndex as integer)
	local RelativeStart as float
	local RelativeEnd as float
	local ContactTime as float
	local Candidate as float
	local StartX as float
	local EndX as float
	local DeltaX as float
	local Reach as float
	local i as integer
	local FeetStart as float
	local FeetEnd as float
	ContactTime = -1
	FeetStart = Sonec.CollisionMoveStart.y+Sonec.ObjectData.Size.Height*0.5
	FeetEnd = Sonec.CollisionMoveEnd.y+Sonec.ObjectData.Size.Height*0.5
	RelativeStart = FeetStart-SonecCollisionAxisAt(PlateList.Plate[PlateIndex].CollisionMoveStart.y,PlateList.Plate[PlateIndex].ObjectData.Position.y,Sonec.CollisionSegmentStartTime)
	RelativeEnd = FeetEnd-PlateList.Plate[PlateIndex].ObjectData.Position.y
	if RelativeStart > 0 and RelativeEnd <= 0 and RelativeEnd < RelativeStart
		Candidate = RelativeStart/(RelativeStart-RelativeEnd)
		ContactTime = SonecDepthClearCandidate(Sonec,PlateList,ChestList,PlateIndex,Candidate,ContactTime)
	endif
	Reach = SONEC_DEPTH_RELEVANCE_X
	if Reach < 0 then Reach = 0
	for i = 0 to ChestList.Chest.Length
		if ChestList.Chest[i].Enabled = TRUE and ChestList.Chest[i].CollisionData.Index = PlateIndex
			RelativeStart = FeetStart-SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.y,ChestList.Chest[i].ObjectData.Position.y,Sonec.CollisionSegmentStartTime)
			RelativeEnd = FeetEnd-ChestList.Chest[i].ObjectData.Position.y
			if RelativeStart > 0 and RelativeEnd <= 0 and RelativeEnd < RelativeStart
				Candidate = RelativeStart/(RelativeStart-RelativeEnd)
				ContactTime = SonecDepthClearCandidate(Sonec,PlateList,ChestList,PlateIndex,Candidate,ContactTime)
			endif
			StartX = Sonec.CollisionMoveStart.x-SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.x,ChestList.Chest[i].ObjectData.Position.x,Sonec.CollisionSegmentStartTime)
			EndX = Sonec.CollisionMoveEnd.x-ChestList.Chest[i].ObjectData.Position.x
			DeltaX = EndX-StartX
			if DeltaX > SONEC_DEPTH_EPSILON and StartX <= ChestList.Chest[i].ObjectData.Size.Width+Reach and EndX > ChestList.Chest[i].ObjectData.Size.Width+Reach
				Candidate = (ChestList.Chest[i].ObjectData.Size.Width+Reach+SONEC_DEPTH_EPSILON-StartX)/DeltaX
				if Candidate > 1 then Candidate = 1
				ContactTime = SonecDepthClearCandidate(Sonec,PlateList,ChestList,PlateIndex,Candidate,ContactTime)
			endif
			if DeltaX < -SONEC_DEPTH_EPSILON and StartX >= -Reach and EndX < -Reach
				Candidate = (-Reach-SONEC_DEPTH_EPSILON-StartX)/DeltaX
				if Candidate > 1 then Candidate = 1
				ContactTime = SonecDepthClearCandidate(Sonec,PlateList,ChestList,PlateIndex,Candidate,ContactTime)
			endif
		endif
	next i
endfunction ContactTime

// G integration trace: record relative feet crossings near a possible
// top, even if the real eligibility or midpoint test rejects it.
// Only diagnostic output: never select or modify a contact here.
// Full body leaves the previous platform: release depth only, not momentum.
function SonecDepthLinkExitTime(Sonec ref as TSonec,PlateList ref as TPlateList)
	local i as integer
	local StartX as float
	local EndX as float
	local LeftLimit as float
	local RightLimit as float
	local ContactTime as float
	ContactTime = -1
	i = Sonec.LinkedPlateIndex
	if i >= 0 and i <= PlateList.Plate.Length and Sonec.GroundContactActive = FALSE
		if PlateList.Plate[i].Enabled = TRUE
			LeftLimit = -Sonec.ObjectData.Size.Width*0.5
			RightLimit = PlateList.Plate[i].ObjectData.Size.Width+Sonec.ObjectData.Size.Width*0.5
			StartX = Sonec.CollisionMoveStart.x-SonecCollisionAxisAt(PlateList.Plate[i].CollisionMoveStart.x,PlateList.Plate[i].ObjectData.Position.x,Sonec.CollisionSegmentStartTime)
			EndX = Sonec.CollisionMoveEnd.x-PlateList.Plate[i].ObjectData.Position.x
			if StartX <= LeftLimit or StartX >= RightLimit
				ContactTime = 0
			else
				if EndX <= LeftLimit then ContactTime = (LeftLimit-StartX)/(EndX-StartX)
				if EndX >= RightLimit then ContactTime = (RightLimit-StartX)/(EndX-StartX)
			endif
		endif
	endif
endfunction ContactTime

function SonecTraceTopContact(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,SurfaceType as integer,SurfaceIndex as integer,Eligible as integer,AcceptedTime as float)
	local PlateIndex as integer
	local SurfaceStart as TPosition
	local SurfaceEnd as TPosition
	local Width as float
	local StartY as float
	local StartX as float
	local RelativeStart as float
	local RelativeEnd as float
	local HitTime as float
	local FrameTime as float
	local RelativeX as float
	local FeetY as float
	local PlateY as float
	local HighestY as float
	if GAME_DEBUG_ENABLED = 0 or SONEC_INTEGRATION_TRACE = 0 then exitfunction
	if SurfaceType = TYPECHEST
		PlateIndex = ChestList.Chest[SurfaceIndex].CollisionData.Index
		SurfaceStart = ChestList.Chest[SurfaceIndex].CollisionMoveStart
		SurfaceEnd = ChestList.Chest[SurfaceIndex].ObjectData.Position
		Width = ChestList.Chest[SurfaceIndex].ObjectData.Size.Width
	else
		PlateIndex = SurfaceIndex
		SurfaceStart = PlateList.Plate[SurfaceIndex].CollisionMoveStart
		SurfaceEnd = PlateList.Plate[SurfaceIndex].ObjectData.Position
		Width = PlateList.Plate[SurfaceIndex].ObjectData.Size.Width
	endif
	if PlateIndex < 0 or PlateIndex > PlateList.Plate.Length then exitfunction
	if PlateList.Plate[PlateIndex].Enabled = FALSE then exitfunction
	StartY = SonecCollisionAxisAt(SurfaceStart.y,SurfaceEnd.y,Sonec.CollisionSegmentStartTime)
	RelativeStart = Sonec.CollisionMoveStart.y + Sonec.ObjectData.Size.Height*0.5 - StartY
	RelativeEnd = Sonec.CollisionMoveEnd.y + Sonec.ObjectData.Size.Height*0.5 - SurfaceEnd.y
	if RelativeStart > 0 or RelativeEnd < 0 or RelativeEnd <= RelativeStart then exitfunction
	HitTime = -RelativeStart/(RelativeEnd-RelativeStart)
	StartX = SonecCollisionAxisAt(SurfaceStart.x,SurfaceEnd.x,Sonec.CollisionSegmentStartTime)
	RelativeX = SonecCollisionAxisAt(Sonec.CollisionMoveStart.x,Sonec.CollisionMoveEnd.x,HitTime) - SonecCollisionAxisAt(StartX,SurfaceEnd.x,HitTime)
	if RelativeX < -Sonec.ObjectData.Size.Width*0.5 or RelativeX > Width + Sonec.ObjectData.Size.Width*0.5 then exitfunction
	FrameTime = SonecCollisionAxisAt(Sonec.CollisionSegmentStartTime,1.0,HitTime)
	FeetY = SonecCollisionAxisAt(Sonec.CollisionMoveStart.y,Sonec.CollisionMoveEnd.y,HitTime) + Sonec.ObjectData.Size.Height*0.5
	PlateY = SonecCollisionAxisAt(PlateList.Plate[PlateIndex].CollisionMoveStart.y,PlateList.Plate[PlateIndex].ObjectData.Position.y,FrameTime)
	HighestY = SonecDepthLocalTop(PlateList,ChestList,PlateIndex,SonecCollisionAxisAt(Sonec.CollisionMoveStart.x,Sonec.CollisionMoveEnd.x,HitTime),FrameTime)
	Sonec.DebugTopTrace = Sonec.DebugTopTrace+"|T;"+Str(SurfaceType)+";"+Str(SurfaceIndex)+";"+Str(PlateIndex)+";"+Str(Sonec.LinkedPlateIndex)+";"+Str(PlateList.Plate[PlateIndex].SonecDepthState)+";"+Str(Eligible)+";"+Str(AcceptedTime)+";"+Str(FrameTime)+";"+Str(RelativeX)+";"+Str(Width)+";"+Str(FeetY)+";"+Str(PlateY)+";"+Str(HighestY)+";"+Str(RelativeStart)+";"+Str(RelativeEnd)+";"+Str(PlateList.Plate[PlateIndex].ObjectData.Position.y-PlateList.Plate[PlateIndex].CollisionMoveStart.y)
endfunction

function SonecFindContact(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList)
	local Best as TSonecContactCandidate
	local Side as TSonecContactCandidate
	local i as integer
	local PassPlateIndex as integer
	local ContactTime as float
	local Eligible as integer
	Best.Valid = FALSE
	PassPlateIndex = -1
	if Sonec.PassThroughChestIndex >= 0
		PassPlateIndex = ChestList.Chest[Sonec.PassThroughChestIndex].CollisionData.Index
	endif
	// Deterministic tie order: chest top, plate top, side/underside, support exit.
	// Update all platform groups at the actual start of this residual sweep.
	SonecDepthRefresh(Sonec,PlateList,ChestList,Sonec.CollisionMoveStart.x,Sonec.CollisionMoveStart.y + Sonec.ObjectData.Size.Height*0.5,Sonec.CollisionSegmentStartTime)
	// Thrust intent is not the direction of travel: the relative feet sweep
	// decides whether an unsupported Sonec crosses a surface from above.
	if Sonec.GroundContactActive = FALSE
		for i = 0 to ChestList.Chest.Length
			Eligible = SonecChestRelevant(Sonec,PlateList,ChestList,i,TRUE)
			ContactTime = -1
			if Eligible = TRUE
				ContactTime = SonecChestTopContactTime(Sonec,ChestList,i)
				Best = SonecContactChooseEarlier(Best,ContactTime,TYPECHEST,i,1)
			endif
			if GAME_DEBUG_ENABLED = 1 and SONEC_INTEGRATION_TRACE = 1 and ChestList.Chest[i].Enabled = TRUE
				SonecTraceTopContact(Sonec,PlateList,ChestList,TYPECHEST,i,Eligible,ContactTime)
			endif
		next i
		for i = 0 to PlateList.Plate.Length
			Eligible = FALSE
			ContactTime = -1
			if i <> PassPlateIndex and PlateList.Plate[i].Enabled = TRUE and PlateList.Plate[i].SonecDepthState <> SONEC_DEPTH_PASSAGE
				Eligible = TRUE
				ContactTime = SonecPlateTopContactTime(Sonec,PlateList,i)
				Best = SonecContactChooseEarlier(Best,ContactTime,TYPEPLATE,i,1)
			endif
			if GAME_DEBUG_ENABLED = 1 and SONEC_INTEGRATION_TRACE = 1 and PlateList.Plate[i].Enabled = TRUE
				SonecTraceTopContact(Sonec,PlateList,ChestList,TYPEPLATE,i,Eligible,ContactTime)
			endif
		next i
	endif
	Side = SonecFindChestContact(Sonec,PlateList,ChestList)
	if Side.Valid = TRUE
		if Best.Valid = FALSE or Side.ContactTime < Best.ContactTime
			Best = Side
		endif
	endif
	ContactTime = SonecSupportExitTime(Sonec,PlateList,ChestList)
	Best = SonecContactChooseEarlier(Best,ContactTime,Sonec.CollisionData.ListType,Sonec.CollisionData.Index,4)
	ContactTime = SonecDepthLinkExitTime(Sonec,PlateList)
	Best = SonecContactChooseEarlier(Best,ContactTime,TYPEPLATE,Sonec.LinkedPlateIndex,6)
	if Sonec.GroundContactActive = FALSE
		for i = 0 to PlateList.Plate.Length
			if PlateList.Plate[i].Enabled = TRUE and i <> Sonec.LinkedPlateIndex and PlateList.Plate[i].SonecDepthState <> SONEC_DEPTH_CLEARED
				ContactTime = SonecDepthClearTime(Sonec,PlateList,ChestList,i)
				Best = SonecContactChooseEarlier(Best,ContactTime,TYPEPLATE,i,5)
			endif
		next i
	endif
endfunction Best

// Exactly one selected contact modifies the path and its affected component.
// X stays free after a top; Y stays free after a side. The next sweep uses
// this modified segment and the remaining fraction of obstacle motion.
function SonecResolveContact(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,Best as TSonecContactCandidate,Screen as TSize)
	local i as integer
	local SurfaceY as float
	local SurfaceEndY as float
	local ContactX as float
	local Carry as TSpeed
	local WallSpeed as TSpeed
	local TargetVX as float
	i = Best.Index
	Sonec.CollisionMoveStart.x = SonecCollisionAxisAt(Sonec.CollisionMoveStart.x,Sonec.CollisionMoveEnd.x,Best.ContactTime)
	Sonec.CollisionMoveStart.y = SonecCollisionAxisAt(Sonec.CollisionMoveStart.y,Sonec.CollisionMoveEnd.y,Best.ContactTime)
	Sonec.CollisionSegmentStartTime = SonecCollisionAxisAt(Sonec.CollisionSegmentStartTime,1.0,Best.ContactTime)
	if Best.Kind = 1
		if Best.ListType = TYPECHEST
			SurfaceY = SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.y,ChestList.Chest[i].ObjectData.Position.y,Sonec.CollisionSegmentStartTime)
			SurfaceEndY = ChestList.Chest[i].ObjectData.Position.y
			Carry = SonecCarrierVelocity(Sonec,PlateList,ChestList.Chest[i].CollisionData.Index)
			SonecSetGroundContact(Sonec,TYPECHEST,i,ChestList.Chest[i].CollisionData.Index,Carry)
		else
			SurfaceY = SonecCollisionAxisAt(PlateList.Plate[i].CollisionMoveStart.y,PlateList.Plate[i].ObjectData.Position.y,Sonec.CollisionSegmentStartTime)
			SurfaceEndY = PlateList.Plate[i].ObjectData.Position.y
			Carry = SonecCarrierVelocity(Sonec,PlateList,i)
			SonecSetGroundContact(Sonec,TYPEPLATE,i,i,Carry)
		endif
		Sonec.CollisionMoveStart.y = SurfaceY - Sonec.ObjectData.Size.Height*0.5
		Sonec.CollisionMoveEnd.y = SurfaceEndY - Sonec.ObjectData.Size.Height*0.5
		if Best.ListType = TYPECHEST
			if JumppodTryLaunch(i) = TRUE
				// Land first, then release carrier momentum once, as for a normal jump.
				// Apply the pod impulse to the remaining swept path, not a second full tick.
				SonecStartNormalJump(Sonec,0)
				Sonec.State.Jump = FALSE
				Sonec.State.Duck = FALSE
				Sonec.State.Fall = TRUE
				Sonec.CollisionData.ListType = 0
				Sonec.CollisionData.Index = -1
				Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeed.y-SONEC_JUMP_IMPULSE_Y*JUMPPOD_JUMP_FACTOR
				Sonec.CollisionMoveEnd.y = Sonec.CollisionMoveEnd.y-SONEC_JUMP_IMPULSE_Y*JUMPPOD_JUMP_FACTOR*(1.0-Sonec.CollisionSegmentStartTime)
				if Sonec.SpawnEntering = FALSE and Sonec.CollisionMoveEnd.y < Sonec.ObjectData.Size.Height*0.5
					Sonec.CollisionMoveEnd.y = Sonec.ObjectData.Size.Height*0.5
					if Sonec.ObjectData.MoveSpeed.y < 0 then Sonec.ObjectData.MoveSpeed.y = 0
				endif
			else
				SonecChestLandingEffects(Sonec,ChestList,i,Screen)
			endif
		endif
	endif
	if Best.Kind = 2
		// ContactX includes only the wall's remaining displacement, so
		// following a moving wall cannot create a backward impulse.
		ContactX = Best.HitPositionX
		if ContactX < Sonec.ObjectData.Size.Width*0.5 then ContactX = Sonec.ObjectData.Size.Width*0.5
		Sonec.CollisionMoveEnd.x = ContactX
		// Limit only the velocity entering the wall, in the same reference
		// frame as MoveSpeed. Same-platform wall and carrier velocities cancel.
		WallSpeed = SonecCarrierVelocity(Sonec,PlateList,ChestList.Chest[i].CollisionData.Index)
		TargetVX = WallSpeed.x - Sonec.ObjectData.AutoSpeed.x
		if (Sonec.ObjectData.MoveSpeed.x-TargetVX)*Best.HitSide > 0 then Sonec.ObjectData.MoveSpeed.x = TargetVX
		Sonec.BlockedChestIndex = i
		Sonec.BlockedChestSide = Best.HitSide
		Sonec.BlockedChestOffsetX = Best.HitOffsetX
		if Sonec.BalanceActive = TRUE
			Sonec.BalanceActive = FALSE
			Sonec.AnimationData.RepeatAnimation = TRUE
			Sonec.AnimationData.Finished = FALSE
		endif
	endif
	if Best.Kind = 3
		Sonec.PassThroughChestIndex = i
	endif
	if Best.Kind = 5
		PlateList.Plate[i].SonecDepthState = SONEC_DEPTH_CLEARED
		SonecDepthRefresh(Sonec,PlateList,ChestList,Sonec.CollisionMoveStart.x,Sonec.CollisionMoveStart.y + Sonec.ObjectData.Size.Height*0.5,Sonec.CollisionSegmentStartTime)
	endif
	if Best.Kind = 6
		Sonec.LinkedPlateIndex = -1
		Sonec.PassThroughChestIndex = -1
		PlateList.Plate[i].SonecDepthState = SONEC_DEPTH_NEUTRAL
	endif
	if Best.Kind = 4
		Sonec.ObjectData.Position = Sonec.CollisionMoveStart
		if Best.ListType = TYPECHEST
			SonecFinishChestEdge(Sonec,ChestList,Screen)
		else
			SonecCollideReset(Sonec)
		endif
	endif
endfunction

function SonecCollidePlate(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,World ref as TWorld,Screen as TSize)
	local OriginalStart as TPosition
	local OriginalEnd as TPosition
	local Best as TSonecContactCandidate
	local i as integer
	local Iteration as integer
	local MechanicalCount as integer
	local Done as integer
	local PassIndex as integer
	local HalfWidth as float
	local HalfHeight as float

	Sonec.DebugEdgePending = FALSE
	Sonec.DebugTopTrace = ""
	Sonec.DebugCsvHopPreVX = 0
	Sonec.DebugCsvHopPreVY = 0
	Sonec.DebugCsvHopPostVX = 0
	Sonec.DebugCsvHopPostVY = 0
	Sonec.DebugCsvHopChestLeft = 0
	Sonec.DebugCsvHopChestRight = 0
	Sonec.DebugCsvHopChestIndex = -1
	Sonec.DebugEdgeCollisionStartX = Sonec.ObjectData.Position.x
	// Preserve an established physical support across non-liftoff state
	// changes (e.g. grenade recoil); input jump/jetpack explicitly clears it.
	if Sonec.GroundContactActive = TRUE and Sonec.State.Fly = FALSE and Sonec.State.Jump = FALSE
		Sonec.State.Stand = TRUE
		Sonec.State.Fall = FALSE
	endif
	SonecValidateLinkedPlate(Sonec,PlateList)
	PassIndex = Sonec.PassThroughChestIndex
	if PassIndex >= 0
		if PassIndex > ChestList.Chest.Length
			Sonec.PassThroughChestIndex = -1
		else
			if ChestList.Chest[PassIndex].Enabled = FALSE or ChestList.Chest[PassIndex].CollisionData.Index <> Sonec.LinkedPlateIndex
				Sonec.PassThroughChestIndex = -1
			endif
		endif
	endif
	
	OriginalStart = Sonec.CollisionMoveStart
	OriginalEnd = Sonec.CollisionMoveEnd
	Sonec.CollisionSegmentStartTime = 0
	SonecPrepareSupportPath(Sonec,PlateList,ChestList)
	SonecGroundClearancePath(Sonec,PlateList,ChestList)
	SonecClampCombinedPath(Sonec,Screen)
	// Contact memory is diagnostic only; all blocking is resolved in the sweep.
	Sonec.BlockedChestIndex = -1
	Sonec.BlockedChestSide = 0
	Sonec.BlockedChestOffsetX = 0
	Done = FALSE
	MechanicalCount = 0
	// Eight mechanical contacts plus room for local clearance and link exits.
	for Iteration = 1 to 8 + 2*(PlateList.Plate.Length + 1) + 2
		if Done = FALSE and MechanicalCount < 8
			Best = SonecFindContact(Sonec,PlateList,ChestList)
			if Best.Valid = FALSE
				Sonec.CollisionMoveStart = Sonec.CollisionMoveEnd
				Sonec.CollisionSegmentStartTime = 1
				Done = TRUE
			else
				if GAME_DEBUG_ENABLED = 1 and SONEC_INTEGRATION_TRACE = 1 and Sonec.DebugTopTrace <> ""
					Sonec.DebugTopTrace = Sonec.DebugTopTrace+"|W;"+Str(Best.Kind)+";"+Str(Best.ListType)+";"+Str(Best.Index)+";"+Str(SonecCollisionAxisAt(Sonec.CollisionSegmentStartTime,1.0,Best.ContactTime))
				endif
				SonecResolveContact(Sonec,PlateList,ChestList,Best,Screen)
				if Best.Kind <> 5 and Best.Kind <> 6 then MechanicalCount = MechanicalCount + 1
				if Sonec.CollisionSegmentStartTime >= 1
					Done = TRUE
				endif
			endif
		endif
	next Iteration
	Sonec.ObjectData.Position = Sonec.CollisionMoveStart
	if Done = FALSE and Sonec.GroundContactActive = TRUE then SonecCollideReset(Sonec)
	// Final support bookkeeping uses the resolved position, not the proposal.
	if Sonec.GroundContactActive = TRUE
		i = Sonec.CollisionData.Index
		if Sonec.CollisionData.ListType = TYPEPLATE
			Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - PlateList.Plate[i].ObjectData.Position.x
		else
			Sonec.CollisionData.Position.x = Sonec.ObjectData.Position.x - ChestList.Chest[i].ObjectData.Position.x
		endif
		Sonec.CollisionData.Position.y = 0
	endif
	// Release input only at the resolved position, not the pre-collision proposal.
	if Sonec.SpawnEntering = TRUE and Sonec.ObjectData.Position.y >= Sonec.ObjectData.Size.Height*0.5
		Sonec.SpawnEntering = FALSE
	endif
	// Persist group state at the reached time, before restoring debug snapshots.
	SonecDepthRefresh(Sonec,PlateList,ChestList,Sonec.ObjectData.Position.x,Sonec.ObjectData.Position.y + Sonec.ObjectData.Size.Height*0.5,Sonec.CollisionSegmentStartTime)
	Sonec.CollisionMoveStart = OriginalStart
	Sonec.CollisionMoveEnd = OriginalEnd
	Sonec.CollisionSegmentStartTime = 0
	SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)

	// Legacy underside exception is now ONLY for a chest of the own plane.
	// Foreign passages are retained by the platform state above.
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

	Sonec.DebugEdgeCollisionEndX = Sonec.ObjectData.Position.x

	Sonec.DebugCsvPostCollisionVX = Sonec.ObjectData.MoveSpeed.x
	Sonec.DebugCsvPostCollisionVY = Sonec.ObjectData.MoveSpeed.y

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

// Phase E: mechanical relevance depends on actual depth and passage,
// not on the jetpack action flag.
function SonecChestRelevant(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList,ChestIndex as integer,TopQuery as integer)
	local Relevant as integer
	local PlateIndex as integer
	Relevant = FALSE
	if ChestIndex >= 0 and ChestIndex <= ChestList.Chest.Length
		if ChestList.Chest[ChestIndex].Enabled = TRUE and Sonec.PassThroughChestIndex <> ChestIndex
			PlateIndex = ChestList.Chest[ChestIndex].CollisionData.Index
			if PlateIndex >= 0 and PlateIndex <= PlateList.Plate.Length
				if PlateList.Plate[PlateIndex].Enabled = TRUE
					if PlateIndex = Sonec.LinkedPlateIndex
						Relevant = TRUE
					else
						if Sonec.GroundContactActive = FALSE and PlateList.Plate[PlateIndex].SonecDepthState <> SONEC_DEPTH_PASSAGE
							// Non-passing foreign tops may be landed on from above.
							// Side contacts need an approach from the cleared region.
							if TopQuery = TRUE or PlateList.Plate[PlateIndex].SonecDepthState = SONEC_DEPTH_CLEARED
								Relevant = TRUE
							endif
						endif
					endif
				endif
			endif
		endif
	endif
endfunction Relevant

// Mechanical ground geometry is independent of damage and ducking pose.
// Initial muzzle distance matches the existing MG projectile spawn (25).
function SonecMechanicalFrontOffset()
endfunction SONEC_MECHANICAL_FRONT_X

// Only waive a left-side hit when the world boundary actually prevents
// following a left-moving wall. Before reaching it, stop at the boundary.
function SonecMechanicalLeftPass(StartX as float,WallStepX as float,WorldMinX as float)
	local Allowed as integer
	Allowed = FALSE
	if WallStepX < 0 and StartX <= WorldMinX + SONEC_MECHANICAL_RELATIVE_EPSILON
		Allowed = TRUE
	endif
endfunction Allowed

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

// Shared swept chest-top candidate: evaluate X at the actual Y crossing.
// Keep a stable center region even for narrow surfaces.
function SonecFootMargin(Width as float)
	local Margin as float
	Margin = SONEC_FOOT_HALF_X
	if Margin < 0 then Margin = 0
	if Margin > Width*0.45 then Margin = Width*0.45
endfunction Margin

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
	if Sonec.GroundContactActive = FALSE
		StartFeetY = Sonec.CollisionMoveStart.y + Sonec.ObjectData.Size.Height*0.5
		EndFeetY = Sonec.CollisionMoveEnd.y + Sonec.ObjectData.Size.Height*0.5
		RelativeStartY = StartFeetY - SonecCollisionAxisAt(ChestList.Chest[ChestIndex].CollisionMoveStart.y,ChestList.Chest[ChestIndex].ObjectData.Position.y,Sonec.CollisionSegmentStartTime)
		RelativeEndY = EndFeetY - ChestList.Chest[ChestIndex].ObjectData.Position.y
		if RelativeEndY > RelativeStartY and RelativeStartY <= 0 and RelativeEndY >= 0
			ContactTime = -RelativeStartY/(RelativeEndY-RelativeStartY)
			ContactX = Sonec.CollisionMoveStart.x + (Sonec.CollisionMoveEnd.x-Sonec.CollisionMoveStart.x)*ContactTime
			ChestContactX = SonecCollisionAxisAt(ChestList.Chest[ChestIndex].CollisionMoveStart.x,ChestList.Chest[ChestIndex].ObjectData.Position.x,Sonec.CollisionSegmentStartTime) + (ChestList.Chest[ChestIndex].ObjectData.Position.x-SonecCollisionAxisAt(ChestList.Chest[ChestIndex].CollisionMoveStart.x,ChestList.Chest[ChestIndex].ObjectData.Position.x,Sonec.CollisionSegmentStartTime))*ContactTime
			ChestWidth = ChestList.Chest[ChestIndex].ObjectData.Size.Width
			if ContactX <= ChestContactX - SonecFootMargin(ChestWidth) or ContactX >= ChestContactX + ChestWidth + SonecFootMargin(ChestWidth)
				ContactTime = -1
			endif
		endif
	endif
endfunction ContactTime

// Phase C: one relative side sweep for both directions. Ground uses a
// mirrored vertical front line; air uses the existing two body circles.
// A geometry change can start overlapped: prevent deeper entry without
// snapping the center to a newly expanded shape.
function SonecFindChestContact(Sonec ref as TSonec,PlateList ref as TPlateList,ChestList ref as TChestList)
	local i as integer
	local Direction as integer
	local CircleIndex as integer
	local Best as TSonecContactCandidate
	local Bottom as TSonecContactCandidate
	local PlayerStepX as float
	local PlayerStepY as float
	local ChestStartX as float
	local ChestStartY as float
	local ChestStepX as float
	local ChestStepY as float
	local RelativeStepX as float
	local RelativeStepY as float
	local StartX as float
	local StartY as float
	local Width as float
	local Height as float
	local Radius as float
	local FrontOffset as float
	local EdgeX as float
	local SideOffset as float
	local ContactX as float
	local ContactY as float
	local ClosestX as float
	local ClosestY as float
	local NormalX as float
	local NormalY as float
	local HitTime as float
	local SideValid as integer
	local WorldMinX as float
	local HalfLineHeight as float
	local LineHit as integer
	local LineHitTime as float

	Best.Valid = FALSE
	Bottom.Valid = FALSE
	PlayerStepX = Sonec.CollisionMoveEnd.x - Sonec.CollisionMoveStart.x
	PlayerStepY = Sonec.CollisionMoveEnd.y - Sonec.CollisionMoveStart.y
	FrontOffset = SonecMechanicalFrontOffset()
	Radius = SonecHitCircleRadius(Sonec)
	WorldMinX = Sonec.ObjectData.Size.Width*0.5
	for i = 0 to ChestList.Chest.Length
		if SonecChestRelevant(Sonec,PlateList,ChestList,i,FALSE) = TRUE
			if Sonec.GroundContactActive = FALSE or Sonec.CollisionData.ListType <> TYPECHEST or Sonec.CollisionData.Index <> i
				ChestStartX = SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.x,ChestList.Chest[i].ObjectData.Position.x,Sonec.CollisionSegmentStartTime)
				ChestStartY = SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.y,ChestList.Chest[i].ObjectData.Position.y,Sonec.CollisionSegmentStartTime)
				ChestStepX = ChestList.Chest[i].ObjectData.Position.x - ChestStartX
				ChestStepY = ChestList.Chest[i].ObjectData.Position.y - ChestStartY
				RelativeStepX = PlayerStepX - ChestStepX
				RelativeStepY = PlayerStepY - ChestStepY
				StartX = Sonec.CollisionMoveStart.x - ChestStartX
				Width = ChestList.Chest[i].ObjectData.Size.Width
				Height = ChestList.Chest[i].ObjectData.Size.Height
				Direction = 0
				EdgeX = 0
				if RelativeStepX > SONEC_MECHANICAL_RELATIVE_EPSILON and StartX <= 0
					if SonecMechanicalLeftPass(Sonec.CollisionMoveStart.x,ChestStepX,WorldMinX) = FALSE
						Direction = 1
						// The prior event already stopped X at the world edge.
						if Sonec.BlockedChestIndex = i and Sonec.BlockedChestSide = 1 and Sonec.CollisionMoveEnd.x <= WorldMinX and ChestStepX < 0 then Direction = 0
					endif
				endif
				if RelativeStepX < -SONEC_MECHANICAL_RELATIVE_EPSILON and StartX >= Width
					Direction = -1
					EdgeX = Width
				endif
				LineHit = FALSE
				LineHitTime = -1
				HalfLineHeight = Sonec.ObjectData.Size.Height*0.5
				if Sonec.GroundContactActive = FALSE then HalfLineHeight = Sonec.ObjectData.Size.Height*0.18
				if Direction <> 0
						// Direction is the sign of relative entry, not sprite facing.
						SideOffset = -Direction*FrontOffset
						HitTime = (EdgeX + SideOffset - StartX)/RelativeStepX
						if HitTime < 0
							// Existing corner overlap: block deeper entry here.
							// Ground clearance is corrected gradually before the sweep.
							HitTime = 0
							SideOffset = StartX - EdgeX
						endif
						if HitTime <= 1
							ContactY = Sonec.CollisionMoveStart.y - ChestStartY + RelativeStepY*HitTime
							if ContactY + HalfLineHeight > 0 and ContactY - HalfLineHeight < Height
								LineHit = TRUE
								LineHitTime = HitTime
								if Best.Valid = FALSE or HitTime < Best.ContactTime
									Best = SonecContactChooseEarlier(Best,HitTime,TYPECHEST,i,2)
									Best.HitSide = Direction
									Best.HitOffsetX = SideOffset
									Best.HitPositionX = ChestList.Chest[i].ObjectData.Position.x + EdgeX + SideOffset
								endif
							endif
						endif
				endif
				if Sonec.GroundContactActive = FALSE
					for CircleIndex = 0 to 1
						StartY = Sonec.CollisionMoveStart.y + SonecHitCircleY(Sonec,CircleIndex) - Sonec.ObjectData.Position.y - ChestStartY
						HitTime = SonecChestCircleHitTime(StartX,StartY,RelativeStepX,RelativeStepY,Width,Height,Radius)
						if HitTime >= 0
							ContactX = StartX + RelativeStepX*HitTime
							ContactY = StartY + RelativeStepY*HitTime
							ClosestX = ContactX
							ClosestY = ContactY
							if ClosestX < 0 then ClosestX = 0
							if ClosestX > Width then ClosestX = Width
							if ClosestY < 0 then ClosestY = 0
							if ClosestY > Height then ClosestY = Height
							NormalX = ContactX - ClosestX
							NormalY = ContactY - ClosestY
							// Preserve the own-plane underside rule only. Foreign
							// passages are managed as whole platform groups.
							if ChestList.Chest[i].CollisionData.Index = Sonec.LinkedPlateIndex and NormalY > 0 and abs(NormalY) > abs(NormalX) and PlayerStepY < 0 and RelativeStepY < 0
								Bottom = SonecContactChooseEarlier(Bottom,HitTime,TYPECHEST,i,3)
							endif
							SideValid = FALSE
							// A falling circle can first touch an upper corner with
							// a predominantly vertical normal. If it also enters
							// horizontally, keep that side candidate. The global
							// feet/top candidate still wins earlier or equal times.
							if Direction <> 0 and NormalX*Direction < 0 and (LineHit = FALSE or (HitTime < LineHitTime and abs(NormalY) > SONEC_MECHANICAL_RELATIVE_EPSILON))
								if abs(NormalX) >= abs(NormalY) or (NormalY < 0 and RelativeStepY > 0)
									SideValid = TRUE
								endif
							endif
							// A previously reached side plane can have a zero
							// horizontal normal at t=0. Block deeper X entry,
							// but never snap the existing center away from it.
							if LineHit = FALSE and Direction <> 0 and HitTime = 0 and StartX = EdgeX and StartY >= 0 and StartY <= Height
								SideValid = TRUE
							endif
							if SideValid = TRUE
								if Best.Valid = FALSE or HitTime < Best.ContactTime
									Best = SonecContactChooseEarlier(Best,HitTime,TYPECHEST,i,2)
									Best.HitSide = Direction
									Best.HitOffsetX = ContactX - EdgeX
									Best.HitPositionX = ChestList.Chest[i].ObjectData.Position.x + ContactX
								endif
							endif
						endif
					next CircleIndex
				endif
			endif
		endif
	next i
	if Bottom.Valid = TRUE and Sonec.PassThroughChestIndex < 0
		if Best.Valid = FALSE or Bottom.ContactTime <= Best.ContactTime
			Best = Bottom
		endif
	endif
endfunction Best

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Legacy edge animation and impulse are retained; Phase F owns redesign.
function SonecFinishChestEdge(Sonec ref as TSonec,ChestList ref as TChestList,Screen as TSize)
	local i as integer
	local HopEvent as integer
	local Direction as integer
	local ChestX as float
	local ChestEndX as float
	local RelativeX as float
	local RelativeEndX as float
	local Remaining as float
	local RelativeVX as float
	local ExtraVX as float
	local HalfHeight as float

	// Only the selected support-exit event can trigger a mini-hop.
	if Sonec.GroundContactActive = FALSE or Sonec.CollisionData.ListType <> TYPECHEST then exitfunction
	i = Sonec.CollisionData.Index
	ChestEndX = ChestList.Chest[i].ObjectData.Position.x
	ChestX = SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.x,ChestEndX,Sonec.CollisionSegmentStartTime)
	RelativeX = Sonec.CollisionMoveStart.x - ChestX
	RelativeEndX = Sonec.CollisionMoveEnd.x - ChestEndX
	// Actual departure side, independent of input, facing or world VX.
	Direction = 1
	HopEvent = 4
	if RelativeX <= SonecFootMargin(ChestList.Chest[i].ObjectData.Size.Width)+SONEC_MECHANICAL_RELATIVE_EPSILON
		Direction = -1
		HopEvent = 3
	endif

	Sonec.DebugEdgeEvent = HopEvent
	Sonec.DebugEdgePending = TRUE
	Sonec.DebugEdgeChestX = ChestX
	Sonec.DebugEdgeChestSpeedX = ChestList.Chest[i].ObjectData.MoveSpeed.x
	Sonec.DebugCsvHopChestIndex = i
	Sonec.DebugCsvHopChestLeft = ChestX
	Sonec.DebugCsvHopChestRight = ChestX + ChestList.Chest[i].ObjectData.Size.Width
	Sonec.DebugCsvHopPreVX = Sonec.ObjectData.MoveSpeed.x
	Sonec.DebugCsvHopPreVY = Sonec.ObjectData.MoveSpeed.y

	// Grounded MoveSpeed.x is carrier-relative. Keep faster exits.
	RelativeVX = Sonec.ObjectData.MoveSpeed.x
	ExtraVX = 0
	if RelativeVX*Direction < SONEC_MINI_HOP_MIN_RELATIVE_X
		ExtraVX = Direction*SONEC_MINI_HOP_MIN_RELATIVE_X - RelativeVX
	endif
	Sonec.ObjectData.MoveSpeed.x = RelativeVX + ExtraVX
	// Clears support and transfers carrier momentum exactly once.
	SonecCollideReset(Sonec)
	Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeed.y - SONEC_MINI_HOP_IMPULSE_Y

	// Residual world path already includes carry. Apply only new impulse
	// over the unconsumed part of this frame, not a second full step.
	Remaining = 1.0 - Sonec.CollisionSegmentStartTime
	Sonec.CollisionMoveEnd.x = Sonec.CollisionMoveEnd.x + ExtraVX*Remaining
	Sonec.CollisionMoveEnd.y = Sonec.CollisionMoveEnd.y - SONEC_MINI_HOP_IMPULSE_Y*Remaining
	SonecClampCombinedPath(Sonec,Screen)
	HalfHeight = Sonec.ObjectData.Size.Height*0.5
	if Sonec.SpawnEntering = FALSE and Sonec.CollisionMoveEnd.y < HalfHeight
		Sonec.CollisionMoveEnd.y = HalfHeight
		if Sonec.ObjectData.MoveSpeed.y < 0 then Sonec.ObjectData.MoveSpeed.y = 0
	endif
	Sonec.DebugCsvHopPostVX = Sonec.ObjectData.MoveSpeed.x
	Sonec.DebugCsvHopPostVY = Sonec.ObjectData.MoveSpeed.y
endfunction

// Called at the selected top event, before resolving residual motion.
function SonecChestLandingEffects(Sonec ref as TSonec,ChestList ref as TChestList,i as integer,Screen as TSize)
	local ChestX as float
	local Width as float
	local Margin as float
	local RelativeX as float
	local RelativeEnd as float
	local Direction as integer
	local TargetRelative as float
	local StepX as float
	local Remaining as float
	ChestX = SonecCollisionAxisAt(ChestList.Chest[i].CollisionMoveStart.x,ChestList.Chest[i].ObjectData.Position.x,Sonec.CollisionSegmentStartTime)
	Width = ChestList.Chest[i].ObjectData.Size.Width
	Margin = SonecFootMargin(Width)
	RelativeX = Sonec.CollisionMoveStart.x-ChestX
	RelativeEnd = Sonec.CollisionMoveEnd.x-ChestList.Chest[i].ObjectData.Position.x
	Direction = 0
	if RelativeX < Margin then Direction = 1
	if RelativeX > Width-Margin then Direction = -1
	if RelativeX <= Sonec.ObjectData.Size.Width*0.5
		Sonec.DebugEdgeEvent = 1
		Sonec.DebugEdgePending = TRUE
	else
		if RelativeX >= Width-Sonec.ObjectData.Size.Width*0.5
			Sonec.DebugEdgeEvent = 2
			Sonec.DebugEdgePending = TRUE
		endif
	endif
	if Sonec.DebugEdgePending = TRUE
		Sonec.DebugEdgeChestX = ChestX
		Sonec.DebugEdgeChestSpeedX = ChestList.Chest[i].ObjectData.MoveSpeed.x
	endif
	Sonec.BalanceActive = FALSE
	if Direction <> 0
		if (RelativeEnd-RelativeX)*Direction < -SONEC_MECHANICAL_RELATIVE_EPSILON or (abs(RelativeEnd-RelativeX) <= SONEC_MECHANICAL_RELATIVE_EPSILON and Sonec.ObjectData.MoveSpeed.x*Direction < -SONEC_MECHANICAL_RELATIVE_EPSILON)
			Sonec.ObjectData.Position = Sonec.CollisionMoveStart
			SonecFinishChestEdge(Sonec,ChestList,Screen)
			exitfunction
		endif
	else
		if abs(Sonec.ObjectData.MoveSpeed.x) <= 0.75 and Sonec.State.Move = FALSE and Sonec.State.Duck = FALSE
			if RelativeX < Width*0.35 then Direction = 1
			if RelativeX > Width*0.65 then Direction = -1
		endif
	endif
	if Direction <> 0
		TargetRelative = Width*0.35
		if TargetRelative < Margin then TargetRelative = Margin
		if Direction < 0 then TargetRelative = Width-TargetRelative
		Sonec.BalanceTargetX = ChestList.Chest[i].ObjectData.Position.x+TargetRelative
		Sonec.BalanceActive = TRUE
		Remaining = 1.0-Sonec.CollisionSegmentStartTime
		StepX = SONEC_BALANCE_X_STEP*Remaining
		if (TargetRelative-RelativeX)*Direction < StepX then StepX = (TargetRelative-RelativeX)*Direction
		if StepX > 0 and (RelativeEnd-RelativeX)*Direction < StepX
			Sonec.CollisionMoveEnd.x = ChestList.Chest[i].ObjectData.Position.x+RelativeX+Direction*StepX
		endif
		if Direction > 0
			Sonec.State.Alignment = MOVERIGHT
			Sonec.State.LookAlignment = LOOKRIGHT
		else
			Sonec.State.Alignment = MOVELEFT
			Sonec.State.LookAlignment = LOOKLEFT
		endif
		Sonec.AnimationData.Frame = 0
		Sonec.AnimationData.RepeatAnimation = FALSE
		Sonec.AnimationData.Finished = FALSE
		SonecClampCombinedPath(Sonec,Screen)
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
	local PreviousY as float
	local NetAcceleration as float
	local FallLimit as float
	if Sonec.State.Jump = TRUE
		// Independent one-shot jump impulse; retain transferred carrier Y.
		Sonec.State.Jump = FALSE
		Sonec.ObjectData.MoveSpeed.y = Sonec.ObjectData.MoveSpeed.y - SONEC_JUMP_IMPULSE_Y
		Sonec.State.Fall = TRUE
		exitfunction
	endif
	if Sonec.GroundContactActive = TRUE then exitfunction
	if Sonec.State.Fly = FALSE and Sonec.State.Fall = FALSE then exitfunction
	PreviousY = Sonec.ObjectData.MoveSpeed.y
	// Gravity acts during both free fall and powered flight.
	NetAcceleration = SONEC_FALL_ACCELERATION
	if Sonec.State.Fly = TRUE
		NetAcceleration = NetAcceleration - Sonec.ObjectData.MoveAcceleration.y
	endif
	Sonec.ObjectData.MoveSpeed.y = PreviousY + NetAcceleration*Sonec.ObjectData.MoveTimer.CalcRange
	// Limit the powered acceleration, never cut existing inherited momentum.
	if Sonec.State.Fly = TRUE and NetAcceleration < 0
		if Sonec.ObjectData.MoveSpeed.y < -Sonec.ObjectData.MoveSpeedMax.y
			if PreviousY < -Sonec.ObjectData.MoveSpeedMax.y
				Sonec.ObjectData.MoveSpeed.y = PreviousY
			else
				Sonec.ObjectData.MoveSpeed.y = -Sonec.ObjectData.MoveSpeedMax.y
			endif
		endif
	endif
	// Optional terminal fall speed. Do not turn a downward overspeed into
	// an artificial brake impulse when switching on the jetpack.
	FallLimit = SONEC_MAX_FALL_SPEED
	if FallLimit > 0 and NetAcceleration > 0
		if Sonec.ObjectData.MoveSpeed.y > FallLimit
			if PreviousY > FallLimit
				Sonec.ObjectData.MoveSpeed.y = PreviousY
			else
				Sonec.ObjectData.MoveSpeed.y = FallLimit
			endif
		endif
	endif
endfunction

// Phase A1: Move/Alignment express the active movement request; MoveSpeed.x
// stores momentum. Stand currently selects ground acceleration/coasting.
// Keep these existing decisions unchanged until their planned redesign.
function SonecMoveHorizontalSpeed(Sonec ref as TSonec)
	local acc as float
	local VX as float
	local StepX as float
	// Unpowered jump: preserve momentum without input; allow only weak
	// directional correction. The cap limits added acceleration, not
	// existing faster launch, carrier or recoil momentum.
	if Sonec.GroundContactActive = FALSE
		if Sonec.NormalJumpActive = TRUE
			if SONEC_JUMP_CORRECTION_ACCELERATION > 0 and SONEC_JUMP_MAX_CORRECTION_X > 0
				VX = Sonec.ObjectData.MoveSpeed.x
				StepX = SONEC_JUMP_CORRECTION_ACCELERATION*Sonec.ObjectData.MoveTimer.CalcRange
				if Sonec.JumpCorrectionDirection < 0 and VX > -SONEC_JUMP_MAX_CORRECTION_X
					VX = VX - StepX
					if VX < -SONEC_JUMP_MAX_CORRECTION_X then VX = -SONEC_JUMP_MAX_CORRECTION_X
				endif
				if Sonec.JumpCorrectionDirection > 0 and VX < SONEC_JUMP_MAX_CORRECTION_X
					VX = VX + StepX
					if VX > SONEC_JUMP_MAX_CORRECTION_X then VX = SONEC_JUMP_MAX_CORRECTION_X
				endif
				Sonec.ObjectData.MoveSpeed.x = VX
			endif
			exitfunction
		endif
		VX = Sonec.ObjectData.MoveSpeed.x
		StepX = Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
		if Sonec.AirThrustDirection <> 0 then StepX = SONEC_AIR_THRUST_ACCELERATION * Sonec.ObjectData.MoveTimer.CalcRange
		if Sonec.AirThrustDirection < 0
			// Limit the added thrust, not inherited momentum above the limit.
			if VX > -SONEC_MAX_AIR_THRUST_SPEED
				VX = VX - StepX
				if VX < -SONEC_MAX_AIR_THRUST_SPEED then VX = -SONEC_MAX_AIR_THRUST_SPEED
			endif
		else
			if Sonec.AirThrustDirection > 0
				if VX < SONEC_MAX_AIR_THRUST_SPEED
					VX = VX + StepX
					if VX > SONEC_MAX_AIR_THRUST_SPEED then VX = SONEC_MAX_AIR_THRUST_SPEED
				endif
			else
				// Preserve passive air coast without crossing zero.
				if abs(VX) <= SONEC_COAST_ZERO_SPEED
					VX = 0
				else
					if VX < 0
						VX = VX + SONEC_AIR_COAST_FACTOR*StepX
						if VX > 0 then VX = 0
					else
						VX = VX - SONEC_AIR_COAST_FACTOR*StepX
						if VX < 0 then VX = 0
					endif
				endif
			endif
		endif
		Sonec.ObjectData.MoveSpeed.x = VX
		exitfunction
	endif
	// Ground control still uses the original acceleration and coast.
	if Sonec.State.Move = TRUE
		// Countersteering on a chest brakes harder than releasing the direction.
		// Keep normal ground acceleration unchanged.
		acc = SONEC_NORMAL_ACCELERATION_FACTOR
		if Sonec.CollisionData.ListType = TYPECHEST
			if Sonec.State.Alignment = MOVELEFT and Sonec.ObjectData.MoveSpeed.x > 0
				acc = SONEC_COUNTERSTEER_FACTOR
			endif
			if Sonec.State.Alignment = MOVERIGHT and Sonec.ObjectData.MoveSpeed.x < 0
				acc = SONEC_COUNTERSTEER_FACTOR
			endif
		endif
		VX = Sonec.ObjectData.MoveSpeed.x
		StepX = acc * Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
		if Sonec.State.Alignment = MOVELEFT
			if VX > -Sonec.ObjectData.MoveSpeedMax.x
				VX = VX - StepX
				if VX < -Sonec.ObjectData.MoveSpeedMax.x then VX = -Sonec.ObjectData.MoveSpeedMax.x
			endif
		else
			if VX < Sonec.ObjectData.MoveSpeedMax.x
				VX = VX + StepX
				if VX > Sonec.ObjectData.MoveSpeedMax.x then VX = Sonec.ObjectData.MoveSpeedMax.x
			endif
		endif
		Sonec.ObjectData.MoveSpeed.x = VX
	else
		acc = SONEC_GROUND_COAST_FACTOR
		if abs(Sonec.ObjectData.MoveSpeed.x) > SONEC_COAST_ZERO_SPEED
			if Sonec.ObjectData.MoveSpeed.x < 0
				Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x + acc * Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
				if Sonec.GroundContactActive = TRUE and Sonec.ObjectData.MoveSpeed.x > 0
					Sonec.ObjectData.MoveSpeed.x = 0
				endif
			else
				Sonec.ObjectData.MoveSpeed.x = Sonec.ObjectData.MoveSpeed.x - acc * Sonec.ObjectData.MoveAcceleration.x * Sonec.ObjectData.MoveTimer.CalcRange
				if Sonec.GroundContactActive = TRUE and Sonec.ObjectData.MoveSpeed.x < 0
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
	// Initial off-world descent is allowed; the resolved contact path
	// releases SpawnEntering after the whole body has entered the world.
        if Sonec.SpawnEntering = FALSE and Sonec.ObjectData.Position.y < Sonec.ObjectData.Size.Height*0.5
            Sonec.ObjectData.Position.y = Sonec.ObjectData.Size.Height*0.5
            Sonec.ObjectData.MoveSpeed.y = 0
        endif
	
	if Sonec.ObjectData.Position.y > World.Size.Height + Sonec.ObjectData.Size.Height*0.5
		Sonec.IsLost = TRUE
	endif
	
	if Sonec.ObjectData.Position.x < Sonec.ObjectData.Size.Width*0.5
		Sonec.ObjectData.Position.x =  Sonec.ObjectData.Size.Width*0.5
		if Sonec.GroundContactActive = FALSE then Sonec.ObjectData.MoveSpeed.x = 0
	endif
	
	if Sonec.ObjectData.Position.x > Screen.Width - Sonec.ObjectData.Size.Width*0.5
		Sonec.ObjectData.Position.x = Screen.Width - Sonec.ObjectData.Size.Width*0.5
		if Sonec.GroundContactActive = FALSE then Sonec.ObjectData.MoveSpeed.x = 0
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
// Phase D: ground MoveSpeed is support-relative, air MoveSpeed is world momentum.
// AutoSpeed is signed carrier momentum; actual carry uses position snapshots.
function SonecMove(Sonec ref as TSonec,ChestList ref as TChestList,World ref as TWorld,Screen as TSize,Now as integer)
	local OwnProposalX as float
	
	Sonec.CollisionSegmentStartTime = 0
	Sonec.CollisionMoveStart = Sonec.ObjectData.Position
	Sonec.DebugCsvMoveStartVX = Sonec.ObjectData.MoveSpeed.x
	Sonec.DebugCsvMoveStartX = Sonec.ObjectData.Position.x
	Sonec.DebugCsvMoveStartY = Sonec.ObjectData.Position.y
	OwnProposalX = Sonec.ObjectData.Position.x

	if TimeGet(Sonec.ObjectData.MoveTimer,Now) > 0
		
		SonecMoveVerticalSpeed(Sonec)
		SonecMoveHorizontalSpeed(Sonec)
		Sonec.DebugCsvMoveAfterHorizontalVX = Sonec.ObjectData.MoveSpeed.x
		SonecMoveIntegratePosition(Sonec)
		Sonec.DebugEdgeBeforeBalanceX = Sonec.ObjectData.Position.x
		SonecMoveBalanceStep(Sonec)
		Sonec.DebugEdgeAfterBalanceX = Sonec.ObjectData.Position.x
		SonecMoveHoverBrake(Sonec)
		OwnProposalX = Sonec.ObjectData.Position.x
		SonecMoveWorldBounds(Sonec,World,Screen)
		SpritePositionCalc(Sonec.SpriteData.Position,Sonec.ObjectData.Position,World.Position)
		SonecMoveCamera(Sonec,World,Screen)
		TimeReset(Sonec.ObjectData.MoveTimer,Now)
		
	endif
		
	Sonec.CollisionMoveEnd = Sonec.ObjectData.Position
	if Sonec.GroundContactActive = TRUE then Sonec.CollisionMoveEnd.x = OwnProposalX
	Sonec.DebugCsvPreCollisionVX = Sonec.ObjectData.MoveSpeed.x
	Sonec.DebugCsvPreCollisionVY = Sonec.ObjectData.MoveSpeed.y

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

