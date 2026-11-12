
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoShieldLoad(ProtoShield ref as TProtoShield,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoShield.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoShield.AnimShield.Image) = TRUE
			SpriteLoad(ProtoShield.AnimShield)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ShieldRefresh(Shield ref as TShield,World ref as TWorld,Position as TPosition,Now as integer)
	
	if Shield.Enabled = TRUE
		Shield.ObjectData.Position = Position
		SpritePositionCalc(Shield.SpriteData.Position,Shield.ObjectData.Position,World.Position)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ShieldReset(Shield ref as TShield,AFrameMax as integer,Now as integer)
	
	Shield.Enabled = FALSE
	Shield.LastDamageMs = 0
	Shield.DamageCooldownActive = FALSE
	Shield.ShapeTestChecks = 0
	Shield.ShapeTestHits = 0
	Shield.ShapeTestRadiusHits = 0
	Shield.ShapeTestOnlyHits = 0
	Shield.ShapeTestRadiusOnlyHits = 0
	TimeSet(Shield.AnimationData.AnimTimer,25,1)
	TimeReset(Shield.AnimationData.AnimTimer,Now)
	Shield.AnimationData.Frame = 1
	Shield.AnimationData.FrameStep = 1
	Shield.AnimationData.FrameMin = 1
	Shield.AnimationData.FrameMax = AFrameMax * 0.5
	Shield.AnimationData.Initialize = FALSE
	Shield.AnimationData.Uninitialize = FALSE
	Shield.AnimationData.Animating = FALSE
	Shield.SpriteData.Center = TRUE
	Shield.SpriteData.Scale = 1
	Shield.SpriteData.Angle = 0
	ColorSet(Shield.SpriteData.Color,55,255,155,110)
	Shield.SpriteData.Scale = 1.0*Shield.AnimationData.Frame/Shield.AnimationData.FrameMax
	
endfunction
	
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ShieldAnimate(Shield ref as TShield,Sonec ref as TSonec,Now as integer)
	
	if Shield.Enabled = TRUE
		if TimeGet(Shield.AnimationData.AnimTimer,Now) > 0
			
			TimeReset(Shield.AnimationData.AnimTimer,Now)
			
			Shield.SpriteData.Angle = NormalizeAngle(Shield.SpriteData.Angle+1)
			
			if Shield.AnimationData.FrameAlignment = 0
				if Shield.DamageCooldownActive = TRUE
					if Now-Shield.LastDamageMs >= SHIELD_REGEN_DELAY_MS
						Shield.DamageCooldownActive = FALSE
					endif
				endif
				if Shield.DamageCooldownActive = FALSE and Sonec.Energy.State >= COSTSHIELD
					Shield.AnimationData.Frame = Shield.AnimationData.Frame + Shield.AnimationData.FrameStep
				endif
			endif
			
			if Shield.AnimationData.FrameAlignment = 1
				Shield.AnimationData.Frame = Shield.AnimationData.Frame - Shield.AnimationData.FrameStep*2
			endif
			
			
			//if Shield.AnimationData.Uninitialize = TRUE and Shield.AnimationData.Animating = TRUE
				//if Shield.AnimationData.Frame < Shield.AnimationData.FrameMax
					//Shield.AnimationData.Uninitialize = FALSE
				//else
					//Shield.AnimationData.Animating = FALSE
				//endif
			//endif
			
			
			if Shield.AnimationData.Frame >= Shield.AnimationData.FrameMax
				Shield.AnimationData.Frame = Shield.AnimationData.FrameMax
				//if Shield.AnimationData.Animating = FALSE
					if Shield.AnimationData.Initialize = TRUE
						Shield.AnimationData.Initialize = FALSE
						//Shield.AnimationData.Animating = TRUE
					endif
				//endif
			endif
			
			if Shield.AnimationData.Frame <= Shield.AnimationData.FrameMin
				Shield.AnimationData.Frame = Shield.AnimationData.FrameMin
				//if Shield.AnimationData.Animating = FALSE
					if Shield.AnimationData.Uninitialize = TRUE
						Shield.AnimationData.Uninitialize = FALSE
						Shield.Enabled = FALSE
					endif
				//endif
			endif
			
			ColorSet(Shield.SpriteData.Color,55,255,155,55+Shield.AnimationData.Frame*155/Shield.AnimationData.FrameMax)
			
			// Ein einheitlicher Größenverlauf für Auf- und Abbau.
			Shield.SpriteData.Scale = 1.0*Shield.AnimationData.Frame/Shield.AnimationData.FrameMax
			// HUD-Wert folgt denselben Keyframes wie die sichtbare Größe.
			if Shield.Enabled = TRUE
				Sonec.EnergyShield.State = (Shield.AnimationData.Frame-Shield.AnimationData.FrameMin)*Sonec.EnergyShield.StateMax/(Shield.AnimationData.FrameMax-Shield.AnimationData.FrameMin)
			else
				Sonec.EnergyShield.State = 0
			endif

		endif
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ShieldDraw(Shield ref as TShield,ProtoShield ref as TProtoShield)
	
	if Shield.Enabled = TRUE
		SpriteDraw(ProtoShield.AnimShield.Sprite,Shield.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------



// Read-only collision prototype: the existing damage routines remain unchanged.
#constant SHIELD_SHAPE_TEST 1
#constant SHIELD_MAX_PROTECTION_PERCENT 80
#constant SHIELD_REGEN_DELAY_MS 500
#constant SHIELD_DAMAGE_TRAIL_MS 1000

function ShieldShapeTest(Shield ref as TShield,ProtoShield ref as TProtoShield,ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,DebugTextID as integer)
	if SHIELD_SHAPE_TEST = 1 and Device$ = "windows" and Shield.Enabled = TRUE
		local shieldID as integer
		local explosionID as integer
		local i as integer
		local radius as float
		shieldID = ProtoShield.AnimShield.Sprite.ID
		if shieldID > 0
			SetSpriteShape(shieldID,1)
			SetSpriteScaleByOffset(shieldID,Shield.SpriteData.Scale,Shield.SpriteData.Scale)
			SetSpritePositionByOffset(shieldID,Shield.SpriteData.Position.x,Shield.SpriteData.Position.y)
			for i = 0 to ExplosionList.Explosion.Length
				if ExplosionList.Explosion[i].Enabled = TRUE
					explosionID = ProtoExplosion.AnimExplosion[ExplosionList.Explosion[i].ExplosionType,0].Sprite.ID
					if explosionID > 0
						SetSpriteShape(explosionID,1)
						SetSpriteScaleByOffset(explosionID,ExplosionList.Explosion[i].SpriteData.Scale,ExplosionList.Explosion[i].SpriteData.Scale)
						SetSpritePositionByOffset(explosionID,ExplosionList.Explosion[i].SpriteData.Position.x,ExplosionList.Explosion[i].SpriteData.Position.y)
						Shield.ShapeTestChecks = Shield.ShapeTestChecks + 1
						local shapeHit as integer
						local radiusHit as integer
						shapeHit = GetSpriteCollision(shieldID,explosionID)
						radius = CalcRadius(Shield.ObjectData.Position,ExplosionList.Explosion[i].ObjectData.Position)
						radiusHit = radius < ExplosionList.Explosion[i].ObjectData.Radius
						if shapeHit = 1
							Shield.ShapeTestHits = Shield.ShapeTestHits + 1
						endif
						if radiusHit = 1
							Shield.ShapeTestRadiusHits = Shield.ShapeTestRadiusHits + 1
						endif
						if shapeHit = 1 and radiusHit = 0
							Shield.ShapeTestOnlyHits = Shield.ShapeTestOnlyHits + 1
						endif
						if shapeHit = 0 and radiusHit = 1
							Shield.ShapeTestRadiusOnlyHits = Shield.ShapeTestRadiusOnlyHits + 1
						endif
					endif
				endif
			next i
		endif
		SetTextString(DebugTextID,"Shield shape: "+str(Shield.ShapeTestHits)+" / "+str(Shield.ShapeTestChecks)+"  radius: "+str(Shield.ShapeTestRadiusHits)+"  only shape/radius: "+str(Shield.ShapeTestOnlyHits)+"/"+str(Shield.ShapeTestRadiusOnlyHits))
	endif
endfunction

// Apply proportional absorption and reduce visible shield charge.
// The caller handles the remaining damage to Sonec's health.
function ShieldAbsorbDamage(Shield ref as TShield,Sonec ref as TSonec,Damage as integer,Now as integer)
	local absorbed as integer
	local charge as integer
	local frameRange as integer
	absorbed = 0
	if Shield.Enabled = TRUE and Shield.AnimationData.Uninitialize = FALSE and Damage > 0
		charge = Sonec.EnergyShield.State
		if charge > Sonec.EnergyShield.StateMax then charge = Sonec.EnergyShield.StateMax
		if charge < 0 then charge = 0
		if charge > 0
			absorbed = Damage * SHIELD_MAX_PROTECTION_PERCENT * charge / (100*Sonec.EnergyShield.StateMax)
			if absorbed > charge then absorbed = charge
			// Add new damage to the remaining visible trail and extend its lifetime.
			local trailRemaining as float
			trailRemaining = 0
			if Sonec.EnergyShield.DamageTrailEndMs > Now and Sonec.EnergyShield.DamageTrailEndMs > Sonec.EnergyShield.DamageTrailStartMs
				trailRemaining = Sonec.EnergyShield.DamageTrailAmount * (Sonec.EnergyShield.DamageTrailEndMs-Now) / (Sonec.EnergyShield.DamageTrailEndMs-Sonec.EnergyShield.DamageTrailStartMs)
			endif
			Sonec.EnergyShield.DamageTrailAmount = trailRemaining + absorbed
			Sonec.EnergyShield.DamageTrailStartMs = Now
			if Sonec.EnergyShield.DamageTrailEndMs > Now
				Sonec.EnergyShield.DamageTrailEndMs = Sonec.EnergyShield.DamageTrailEndMs + SHIELD_DAMAGE_TRAIL_MS
			else
				Sonec.EnergyShield.DamageTrailEndMs = Now + SHIELD_DAMAGE_TRAIL_MS
			endif
			Sonec.EnergyShield.State = charge - absorbed
			frameRange = Shield.AnimationData.FrameMax-Shield.AnimationData.FrameMin
			Shield.AnimationData.Frame = Shield.AnimationData.FrameMin + Sonec.EnergyShield.State*frameRange/Sonec.EnergyShield.StateMax
			Shield.SpriteData.Scale = 1.0*Shield.AnimationData.Frame/Shield.AnimationData.FrameMax
			Shield.LastDamageMs = Now
			Shield.DamageCooldownActive = TRUE
		endif
	endif
endfunction absorbed
