
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SpriteLoad(ProtoData ref as TProtoData)
	
	local Value as integer
	
	Value = FALSE
	
	if ProtoData.Image.ID > 0
		ProtoData.Sprite.ID = CreateSprite(ProtoData.Image.ID)
		if ProtoData.Sprite.ID > 0
			Value = TRUE
		endif
	endif

endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SpriteAngleCalc(Sprite ref as TSpriteData,Object ref as TObjectData)

	Sprite.Angle = NormalizeAngle(Object.Rotation)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SpritePositionCalc(Sprite ref as TPosition,Object ref as TPosition,World ref as TPosition)

	Sprite.x = Object.x
	Sprite.y = Object.y - World.y

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SpriteRadiusCalc(ProtoData ref as TProtoData)
	
	ProtoData.Angle  = CalcAngle(ProtoData.Offset,ProtoData.Anchor)
	ProtoData.Radius = CalcRadius(ProtoData.Offset,ProtoData.Anchor)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SpriteDraw(Sprite ref as TSprite,Data ref as TSpriteData)
	
	if Sprite.ID > 0
		if Data.OffsetOn = TRUE
			SetSpriteOffset(Sprite.ID,Data.Offset.x,Data.Offset.y)
		else
			SetSpriteOffset(Sprite.ID,GetSpriteWidth(Sprite.ID)/2,GetSpriteHeight(Sprite.ID)/2)
		endif
		if Sprite.Data.Scale <> Data.Scale
			SetSpriteScaleByOffset(Sprite.ID,Data.Scale,Data.Scale)
			if Data.OffsetOn = TRUE
				SetSpriteOffset(Sprite.ID,Data.Offset.x*Data.Scale,Data.Offset.y*Data.Scale)
			else
				SetSpriteOffset(Sprite.ID,GetSpriteWidth(Sprite.ID)/2,GetSpriteHeight(Sprite.ID)/2)
			endif
		endif
		if Sprite.Data.Angle <> Data.Angle
			SetSpriteAngle(Sprite.ID,Data.Angle)
		endif
		if Data.Center = TRUE
			SetSpritePositionByOffset(Sprite.ID,Floor(Data.Position.x),Floor(Data.Position.y))
		else
			SetSpritePosition(Sprite.ID,Floor(Data.Position.x),Floor(Data.Position.y))
		endif
		if Sprite.Data.Color.Value <> Data.Color.Value
			SetSpriteColor(Sprite.ID,Data.Color.Red,Data.Color.Green,Data.Color.Blue,Data.Color.Alpha)
		endif
		
		DrawSprite(Sprite.ID)
		Sprite.Data = Data
		
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------






