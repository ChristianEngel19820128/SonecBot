
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoFlashLoad(ProtoFlash ref as TProtoFlash,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoFlash.FromJson(ReadFileString(File))
		
		for i = 0 to ProtoFlash.AnimFlash.Length
			if ImageLoad(ProtoFlash.AnimFlash[i].Image) = TRUE
				SpriteLoad(ProtoFlash.AnimFlash[i])
			endif
		next i
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlashInit(FlashList ref as TFlashList)
	
	FlashList.Flash.Length = -1
	FlashList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlashNew(Flash ref as TFlash,ProtoFlash ref as TProtoFlash,World ref as TWorld,FlashType as integer,FlashCycleMax as integer,Position as TPosition,Angle as float,Radius as float,Now)

	Flash.Enabled = TRUE
	
	Flash.FlashAnimIndex = FlashType
		
	Flash.SpriteData.Angle = Angle
	Flash.SpriteData.Center = TRUE
	Flash.SpriteData.Scale = Flash.EffectData.LifeCycle*(1.0/Flash.EffectData.LifeCycleMax)
	
	Flash.ObjectData.Size.Width = GetImageWidth(ProtoFlash.AnimFlash[FlashType].Image.ID)
	Flash.ObjectData.Size.Height = GetImageHeight(ProtoFlash.AnimFlash[FlashType].Image.ID)
	
	Flash.ObjectData.Angle = Angle
	
	Select Flash.FlashAnimIndex
		case 0
			Flash.ObjectData.Radius = Radius-Flash.ObjectData.Size.Height*0.5+Flash.ObjectData.Size.Height*0.5*Flash.SpriteData.Scale
		endcase
		case 1
			Flash.ObjectData.Radius = Radius+Flash.ObjectData.Size.Height*0.5
		endcase
	endselect
			
	Flash.ObjectData.Radius = Radius
	
	TimeSet(Flash.EffectData.LifeCycleTimer,10,1)
	TimeReset(Flash.EffectData.LifeCycleTimer,Now)
	
	select FlashType
		case 0
			ColorSet(Flash.SpriteData.Color,255,255,255,255)
			Flash.EffectData.LifeCycle = 1
			Flash.EffectData.LifeCycleMax = FlashCycleMax
		endcase
		case 1
			ColorSet(Flash.SpriteData.Color,55,255,200,200)
			Flash.EffectData.LifeCycle = 1
			Flash.EffectData.LifeCycleMax = FlashCycleMax
		endcase
	endselect
	
	Flash.ObjectData.Position = Position
	CalcPosition(Flash.ObjectData.Position,Flash.ObjectData.Angle,Flash.ObjectData.Radius)
	
	SpritePositionCalc(Flash.SpriteData.Position,Flash.ObjectData.Position,World.Position)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlashAdd(FlashList ref as TFlashList,ProtoFlash ref as TProtoFlash,World ref as TWorld,FlashType as integer,FlashCycleMax as integer,Position as TPosition,Angle as float,Radius as float,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Flash as TFlash
		
	FlashNew(Flash,ProtoFlash,World,FlashType,FlashCycleMax,Position,Angle,Radius,Now)

	Value = -1
	Found = FALSE
	i = FlashList.FirstFree
	while Found = FALSE and i <= FlashList.Flash.Length
		if FlashList.Flash[i].Enabled = FALSE
			Found = TRUE
		else
			i = i+1
		endif
	endwhile
	
	if Found = FALSE
		FlashList.Flash.Insert(Flash)
		FlashList.FirstFree = FlashList.Flash.Length
		Value = FlashList.Flash.Length
	else
		FlashList.Flash[i] = Flash
		FlashList.FirstFree = i+1
		Value = i
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlashDelete(FlashList ref as TFlashList,Index as integer)

	if Index >= 0 and Index <= FlashList.Flash.Length
		FlashList.Flash[Index].Enabled = FALSE
		if FlashList.FirstFree > Index
			FlashList.FirstFree = Index
		endif
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlashRefresh(FlashList ref as TFlashList,World ref as TWorld,FlashIndex as integer,Position as TPosition,Angle as float)
	
	if FlashIndex >= 0 and FlashIndex <= FlashList.Flash.Length
		if FlashList.Flash[FlashIndex].Enabled = TRUE
			FlashList.Flash[FlashIndex].ObjectData.Position = Position
			FlashList.Flash[FlashIndex].ObjectData.Angle = Angle			
			CalcPosition(FlashList.Flash[FlashIndex].ObjectData.Position,Angle,FlashList.Flash[FlashIndex].ObjectData.Radius)
			FlashList.Flash[FlashIndex].SpriteData.Angle = Angle
			SpritePositionCalc(FlashList.Flash[FlashIndex].SpriteData.Position,FlashList.Flash[FlashIndex].ObjectData.Position,World.Position)
		endif
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlashLifeCycle(FlashList ref as TFlashList,Now as integer)
	
	local i as integer
	
	for i = 0 to FlashList.Flash.Length
		
		if FlashList.Flash[i].Enabled = TRUE
			if FlashList.Flash[i].EffectData.LifeCycle < FlashList.Flash[i].EffectData.LifeCycleMax
				if TimeGet(FlashList.Flash[i].EffectData.LifeCycleTimer,Now) > 0
					FlashList.Flash[i].EffectData.LifeCycle = FlashList.Flash[i].EffectData.LifeCycle +1
					FlashList.Flash[i].SpriteData.Scale = FlashList.Flash[i].EffectData.LifeCycle*(1.0/FlashList.Flash[i].EffectData.LifeCycleMax)
					TimeReset(FlashList.Flash[i].EffectData.LifeCycleTimer,Now)
				endif
			else
				FlashDelete(FlashList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlashDraw(Flash ref as TFlash,ProtoFlash ref as TProtoFlash)
	
	if Flash.Enabled = TRUE
		SpriteDraw(ProtoFlash.AnimFlash[Flash.FlashAnimIndex].Sprite,Flash.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlashDrawAll(FlashList ref as TFlashList,ProtoFlash ref as TProtoFlash)
	
	local i as integer
	
	for i = 0 to FlashList.Flash.Length
		FlashDraw(FlashList.Flash[i],ProtoFlash)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlashCountAll(FlashList ref as TFlashList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to FlashList.Flash.Length
		if FlashList.Flash[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

