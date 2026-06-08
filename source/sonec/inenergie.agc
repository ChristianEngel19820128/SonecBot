
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoInenergieLoad(ProtoInenergie ref as TProtoInenergie,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoInenergie.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoInenergie.AnimInenergie.Image) = TRUE
			SpriteLoad(ProtoInenergie.AnimInenergie)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function InenergieRefresh(Inenergie ref as TInenergie,World ref as TWorld,Position as TPosition,Now as integer)
	
	if Inenergie.Enabled = TRUE
		Inenergie.ObjectData.Position = Position
		SpritePositionCalc(Inenergie.SpriteData.Position,Inenergie.ObjectData.Position,World.Position)
		Inenergie.SpriteData.Scale = 1.0/Inenergie.AnimationData.Frame
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function InenergieReset(Inenergie ref as TInenergie,Now as integer)
	
	Inenergie.Enabled = FALSE
	TimeSet(Inenergie.AnimationData.AnimTimer,75,1)
	TimeReset(Inenergie.AnimationData.AnimTimer,Now)
	Inenergie.AnimationData.Frame = 0
	Inenergie.AnimationData.FrameStep = 1
	Inenergie.AnimationData.FrameMin = 1
	Inenergie.AnimationData.FrameMax = 10
	Inenergie.SpriteData.Center = TRUE
	Inenergie.SpriteData.Scale = 1
	ColorSet(Inenergie.SpriteData.Color,55,255,155,200)
	
endfunction
	
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function InenergieAnimate(Inenergie ref as TInenergie,Now as integer)
	
	if Inenergie.Enabled = TRUE
		if TimeGet(Inenergie.AnimationData.AnimTimer,Now) > 0
			Inenergie.AnimationData.Frame = Inenergie.AnimationData.Frame + Inenergie.AnimationData.FrameStep
			TimeReset(Inenergie.AnimationData.AnimTimer,Now)
			if Inenergie.AnimationData.Frame > Inenergie.AnimationData.FrameMax
				Inenergie.AnimationData.Frame = Inenergie.AnimationData.FrameMin
			endif
			ColorSet(Inenergie.SpriteData.Color,55,255,155,200-50*Inenergie.AnimationData.Frame/Inenergie.AnimationData.FrameMax)
		endif
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function InenergieDraw(Inenergie ref as TInenergie,ProtoInenergie ref as TProtoInenergie)
	
	if Inenergie.Enabled = TRUE
		SpriteDraw(ProtoInenergie.AnimInenergie.Sprite,Inenergie.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------


