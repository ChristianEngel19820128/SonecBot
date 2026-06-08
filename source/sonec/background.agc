
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoBackgroundLoad(ProtoBackground ref as TProtoBackground,File as TFilePath)
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoBackground.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoBackground.AnimSky.Image) = TRUE
			SpriteLoad(ProtoBackground.AnimSky)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BackgroundInit(Background ref as TBackground,Screen as TSize)

	Background.ObjectData.Position.x = 0
	Background.ObjectData.Position.y = 0
	
	Background.SpriteData.Angle = 0
	Background.SpriteData.Scale = 1
	Background.SpriteData.Center = FALSE
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BackgroundDo(Background ref as TBackground,World ref as TWorld,Now as integer)
	
	SpritePositionCalc(Background.SpriteData.Position,Background.ObjectData.Position,World.Position)
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BackgroundDraw(Background ref as TBackground,ProtoBackground ref as TProtoBackground)

	SpriteDraw(ProtoBackground.AnimSky.Sprite,Background.SpriteData)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------
