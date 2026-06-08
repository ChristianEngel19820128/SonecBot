
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoTowerLoad(ProtoTower ref as TProtoTower,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoTower.FromJson(ReadFileString(File))
		
		for i = 0 to ProtoTower.AnimSmallTower.Length
			if ImageLoad(ProtoTower.AnimSmallTower[i].Image) = TRUE
				SpriteLoad(ProtoTower.AnimSmallTower[i])
			endif
		next i
		
		for i = 0 to ProtoTower.AnimTower.Length
			if ImageLoad(ProtoTower.AnimTower[i].Image) = TRUE
				SpriteLoad(ProtoTower.AnimTower[i])
			endif
		next i
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerInit(TowerList ref as TTowerList)

	TimeSet(TowerList.CreateTimer,1000,1)
	TowerList.Tower.Length = -1
	TowerList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerPartNew(TowerPart ref as TTowerPart,ProtoTower ref as TProtoTower,ObjectData ref as TObjectData,World ref as TWorld,TowerType as integer,Height as integer)
	
	TowerPart.TowerIndex = random(0,ProtoTower.AnimTower.Length)
	TowerPart.TowerType = TowerType
	
	TowerPart.ObjectData.Size.Width = ObjectData.Size.Width
	TowerPart.ObjectData.Size.Height = ObjectData.Size.Height
	
	TowerPart.ObjectData.Position.x = ObjectData.Position.x
	TowerPart.ObjectData.Position.y = ObjectData.Position.y - ObjectData.Size.Height*0.5 - ObjectData.Size.Height*Height
	
	TowerPart.SpriteData.Angle = 0
	TowerPart.SpriteData.Center = TRUE
	TowerPart.SpriteData.Scale = 1
	
	SpritePositionCalc(TowerPart.SpriteData.Position,TowerPart.ObjectData.Position,World.Position)
	
	
endfunction
	
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerNew(Tower ref as TTower,ProtoTower ref as TProtoTower,World ref as TWorld,Now)
	
	local Height as integer
	local TowerPart as TTowerPart
	local i as integer
	
	Tower.Enabled = TRUE
	
	TimeSet(Tower.ObjectData.MoveTimer,10,10)
	TimeReset(Tower.ObjectData.MoveTimer,Now)
	
	Tower.TowerType = random(0,1)
	
	select Tower.TowerType
		case 0
			Tower.ObjectData.Size.Height = GetImageHeight(ProtoTower.AnimSmallTower[0].Image.ID)
			Tower.ObjectData.Size.Width = GetImageWidth(ProtoTower.AnimSmallTower[0].Image.ID)
			Tower.ObjectData.MoveSpeed.x = 0.05
		endcase
		case 1
			Tower.ObjectData.Size.Height = GetImageHeight(ProtoTower.AnimTower[0].Image.ID)
			Tower.ObjectData.Size.Width = GetImageWidth(ProtoTower.AnimTower[0].Image.ID)
			Tower.ObjectData.MoveSpeed.x = 0.1
		endcase
	endselect

	Tower.ObjectData.MoveSpeed.y = 0
	
	Tower.ObjectData.Position.x = World.Size.Width + Tower.ObjectData.Size.Width*0.5
	Tower.ObjectData.Position.y = World.Size.Height
	
	Height = random(1,4)
	
	for i = 0 to Height
		TowerPartNew(TowerPart,ProtoTower,Tower.ObjectData,World,Tower.TowerType,i)
		Tower.TowerPart.Insert(TowerPart)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerAdd(TowerList ref as TTowerList,ProtoTower ref as TProtoTower,World ref as TWorld,Now as integer)
	
	local Found as integer
	local i as integer
	local Tower as TTower
	
	if TowerExists(TowerList,World) = FALSE
		
		if TimeGet(TowerList.CreateTimer,Now) > 0
			
			TowerNew(Tower,ProtoTower,World,Now)
			
			Found = FALSE
			i = TowerList.FirstFree
			while Found = FALSE and i <= TowerList.Tower.Length
				if TowerList.Tower[i].Enabled = FALSE
					Found = TRUE
				else
					i = i+1
				endif
			endwhile
			
			if Found = FALSE
				TowerList.Tower.Insert(Tower)
				TowerList.FirstFree = TowerList.Tower.Length
			else
				TowerList.Tower[i] = Tower
				TowerList.FirstFree = i+1
			endif
		
			TimeReset(TowerList.CreateTimer,Now)
		
		endif
	
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerExists(TowerList ref as TTowerList,World ref as TWorld)
	
	local Value as integer
	local i as integer
	
	Value = FALSE
	
	for i = 0 to TowerList.Tower.Length
		if TowerList.Tower[i].Enabled = TRUE
			if TowerList.Tower[i].ObjectData.Position.x > World.Size.Width - TowerList.Tower[i].ObjectData.Size.Width*0.5 - TowerList.Tower[i].ObjectData.Size.Width/4 
				Value = TRUE
			endif
		endif
		
	next i
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerDelete(TowerList ref as TTowerList,Index as integer)
		
	TowerList.Tower[Index].TowerPart.Length = -1
	TowerList.Tower[Index].Enabled = FALSE
	if TowerList.FirstFree > Index
		TowerList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerCheckAll(TowerList ref as TTowerList,ProtoTower ref as TProtoTower)
	
	local i as integer
	local px as float
	local pdx as float
	
	for i = 0 to TowerList.Tower.Length
		
		if TowerList.Tower[i].Enabled = TRUE
		
			px = TowerList.Tower[i].ObjectData.Position.x
			pdx = TowerList.Tower[i].ObjectData.Size.Width*0.5
				
			if px+pdx < 0
				TowerDelete(TowerList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerMove(Tower ref as TTower,World ref as TWorld,Now as integer)

	local x as float
	local sx as float
	local r as float
	local i as integer
	
	if Tower.Enabled = TRUE
		if TimeGet(Tower.ObjectData.MoveTimer,Now) > 0
			
			x = Tower.ObjectData.Position.x
			sx = Tower.ObjectData.MoveSpeed.x
			r = Tower.ObjectData.MoveTimer.CalcRange
			
			Tower.ObjectData.Position.x = x - sx*r
			
			for i = 0 to Tower.TowerPart.Length
				Tower.TowerPart[i].ObjectData.Position.x = Tower.ObjectData.Position.x
				SpritePositionCalc(Tower.TowerPart[i].SpriteData.Position,Tower.TowerPart[i].ObjectData.Position,World.Position)
			next i
			
			TimeReset(Tower.ObjectData.MoveTimer,Now)
			
		endif
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerMoveAll(TowerList ref as TTowerList,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to TowerList.Tower.Length
		TowerMove(TowerList.Tower[i],World,Now)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerPartDraw(TowerPart ref as TTowerPart,ProtoTower ref as TProtoTower)
	
	select TowerPart.TowerType
		case 0
			SpriteDraw(ProtoTower.AnimSmallTower[TowerPart.TowerIndex].Sprite,TowerPart.SpriteData)
		endcase
		case 1
			SpriteDraw(ProtoTower.AnimTower[TowerPart.TowerIndex].Sprite,TowerPart.SpriteData)
		endcase
	endselect
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerDrawAll(TowerList ref as TTowerList,ProtoTower ref as TProtoTower)
	
	local i as integer
	local k as integer
	
	for i = 0 to TowerList.Tower.Length
		if TowerList.Tower[i].Enabled = TRUE
			if TowerList.Tower[i].TowerType = 0
				for k = 0 to TowerList.Tower[i].TowerPart.Length
					TowerPartDraw(TowerList.Tower[i].TowerPart[k],ProtoTower)
				next k
			endif
		endif
	next i
	
	for i = 0 to TowerList.Tower.Length
		if TowerList.Tower[i].Enabled = TRUE
			if TowerList.Tower[i].TowerType = 1
				for k = 0 to TowerList.Tower[i].TowerPart.Length
					TowerPartDraw(TowerList.Tower[i].TowerPart[k],ProtoTower)
				next k
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function TowerCountAll(TowerList ref as TTowerList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to TowerList.Tower.Length
		if TowerList.Tower[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------



