
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

function ShieldAnimate(Shield ref as TShield,Now as integer)
	
	if Shield.Enabled = TRUE
		if TimeGet(Shield.AnimationData.AnimTimer,Now) > 0
			
			TimeReset(Shield.AnimationData.AnimTimer,Now)
			
			Shield.SpriteData.Angle = NormalizeAngle(Shield.SpriteData.Angle+1)
			
			if Shield.AnimationData.FrameAlignment = 0
				Shield.AnimationData.Frame = Shield.AnimationData.Frame + Shield.AnimationData.FrameStep
			endif
			
			if Shield.AnimationData.FrameAlignment = 1
				Shield.AnimationData.Frame = Shield.AnimationData.Frame - Shield.AnimationData.FrameStep
			endif
			
			
			//if Shield.AnimationData.Uninitialize = TRUE and Shield.AnimationData.Animating = TRUE
				//if Shield.AnimationData.Frame < Shield.AnimationData.FrameMax
					//Shield.AnimationData.Uninitialize = FALSE
				//else
					//Shield.AnimationData.Animating = FALSE
				//endif
			//endif
			
			
			if Shield.AnimationData.Frame >= Shield.AnimationData.FrameMax
				Shield.AnimationData.FrameAlignment = 1
				//if Shield.AnimationData.Animating = FALSE
					if Shield.AnimationData.Initialize = TRUE
						Shield.AnimationData.Initialize = FALSE
						//Shield.AnimationData.Animating = TRUE
					endif
				//endif
			endif
			
			if Shield.AnimationData.Frame <= Shield.AnimationData.FrameMin
				Shield.AnimationData.FrameAlignment = 0
				//if Shield.AnimationData.Animating = FALSE
					if Shield.AnimationData.Uninitialize = TRUE
						Shield.AnimationData.Uninitialize = FALSE
						Shield.Enabled = FALSE
					endif
				//endif
			endif
			
			ColorSet(Shield.SpriteData.Color,55,255,155,55+Shield.AnimationData.Frame*155/Shield.AnimationData.FrameMax)
			
			if (Shield.AnimationData.Initialize = TRUE or Shield.AnimationData.Uninitialize = TRUE) and Shield.AnimationData.Animating = FALSE
				Shield.SpriteData.Scale = 1.0*Shield.AnimationData.Frame/Shield.AnimationData.FrameMax
			else
				Shield.SpriteData.Scale = 0.75+(1.0*Shield.AnimationData.Frame/Shield.AnimationData.FrameMax)*0.25
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


