
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoPlateLoad(ProtoPlate ref as TProtoPlate,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoPlate.FromJson(ReadFileString(File))
		
		for i = 0 to ProtoPlate.AnimPlate.Length
			if ImageLoad(ProtoPlate.AnimPlate[i].Image) = TRUE
				SpriteLoad(ProtoPlate.AnimPlate[i])
			endif
		next i
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateInit(PlateList ref as TPlateList)
	
	TimeSet(PlateList.CreateTimer,1000,1)
	PlateList.Plate.Length = -1
	PlateList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateNew(Plate ref as TPlate,ProtoPlate ref as TProtoPlate,World ref as TWorld,y as integer,Now as integer)
	
	Plate.Enabled = TRUE
	TimeSet(Plate.ObjectData.MoveTimer,10,10)
	TimeReset(Plate.ObjectData.MoveTimer,Now)
	Plate.ProtoIndex = random(0,ProtoPlate.AnimPlate.Length)
	Plate.ObjectData.MoveSpeed.x = random(35,100)*0.001
	Plate.ObjectData.MoveSpeed.y = random(0,50)*0.001
	
	Plate.ObjectData.Position.x = World.Size.Width
	Plate.ObjectData.Position.y = y
	Plate.ObjectData.Size.Width = GetImageWidth(ProtoPlate.AnimPlate[Plate.ProtoIndex].Image.ID)
	Plate.ObjectData.Size.Height = GetImageHeight(ProtoPlate.AnimPlate[Plate.ProtoIndex].Image.ID)
	
	if random(0,ProtoPlate.AnimPlate.Length) >= Plate.ProtoIndex
		Plate.YShift.Enabled = random(0,1)
		Plate.YShift.Alignment = random(0,1)
		Plate.YShift.Min = random(Plate.ObjectData.Position.y-200,Plate.ObjectData.Position.y)
		if Plate.YShift.Min < 64
			Plate.YShift.Min = 64
		endif
		Plate.YShift.Max = random(Plate.ObjectData.Position.y,Plate.ObjectData.Position.y+200)
		if Plate.YShift.Max > World.Size.Height - 64
			Plate.YShift.Max = World.Size.Height - 64
		endif
	endif
	
	Plate.SpriteData.Angle = 0
	Plate.SpriteData.Center = FALSE
	Plate.SpriteData.Scale = 1
	
	Plate.CollisionData.Position1.x = Plate.ObjectData.Position.x
	Plate.CollisionData.Position1.y = Plate.ObjectData.Position.y
	Plate.CollisionData.Position2.x = Plate.ObjectData.Position.x + Plate.ObjectData.Size.Width
	Plate.CollisionData.Position2.y = Plate.ObjectData.Position.y + Plate.ObjectData.Size.Height
	
	SpritePositionCalc(Plate.SpriteData.Position,Plate.ObjectData.Position,World.Position)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateAdd(PlateList ref as TPlateList,ProtoPlate ref as TProtoPlate,World ref as TWorld,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Plate as TPlate
	local y as integer

	y = random(64,floor((World.Size.Height-64)/8))*8
	
	Value = -1
	
	if PlateExists(PlateList,World,y) = FALSE
	
		if TimeGet(PlateList.CreateTimer,Now) > 0
			
			PlateNew(Plate,ProtoPlate,World,y,Now)
			
			Found = FALSE
			i = PlateList.FirstFree
			while Found = FALSE and i <= PlateList.Plate.Length
				if PlateList.Plate[i].Enabled = FALSE
					Found = TRUE
				else
					i = i+1
				endif
			endwhile
			
			if Found = FALSE
				PlateList.Plate.Insert(Plate)
				PlateList.FirstFree = PlateList.Plate.Length
				Value = PlateList.Plate.Length
			else
				PlateList.Plate[i] = Plate
				PlateList.FirstFree = i+1
				Value = i
			endif
		
			TimeReset(PlateList.CreateTimer,Now)
			
		endif
	endif
	
endfunction Value


//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateExists(PlateList ref as TPlateList,World ref as TWorld,y as integer)
	
	local Value as integer
	local i as integer
	
	Value = FALSE
	
	for i = 0 to PlateList.Plate.Length
		if PlateList.Plate[i].Enabled = TRUE
			if PlateList.Plate[i].ObjectData.Position.y > y - PlateList.Plate[i].ObjectData.Size.Height*4
				if PlateList.Plate[i].ObjectData.Position.y < y + PlateList.Plate[i].ObjectData.Size.Height*4
					Value = TRUE
				endif
			endif
		endif
		
	next i
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateDelete(PlateList ref as TPlateList,Index as integer)
	
	PlateList.Plate[Index].Enabled = FALSE
	if PlateList.FirstFree > Index
		PlateList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateCheckAll(PlateList ref as TPlateList,ProtoPlate ref as TProtoPlate)
	
	local i as integer
	local px as float
	local pdx as float
	
	for i = 0 to PlateList.Plate.Length
		
		if PlateList.Plate[i].Enabled = TRUE
		
			px = PlateList.Plate[i].ObjectData.Position.x
			pdx = PlateList.Plate[i].ObjectData.Size.Width
				
			if px+pdx < 0
				PlateDelete(PlateList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateMove(Plate ref as TPlate,World ref as TWorld,Now as integer)

	local x as float
	local y as float
	local sx as float
	local sy as float
	local r as float
	
	if Plate.Enabled = TRUE
		if TimeGet(Plate.ObjectData.MoveTimer,Now) > 0
			
			x = Plate.ObjectData.Position.x
			y = Plate.ObjectData.Position.y
			sx = Plate.ObjectData.MoveSpeed.x
			sy = Plate.ObjectData.MoveSpeed.y
			r = Plate.ObjectData.MoveTimer.CalcRange
			
			Plate.ObjectData.Position.x = x - sx*r
			
			if Plate.YShift.Enabled = TRUE
				if Plate.YShift.Alignment = MOVEUP
					Plate.ObjectData.Position.y = y - sy*r
					if Plate.ObjectData.Position.y < Plate.YShift.Min
						Plate.ObjectData.Position.y = Plate.YShift.Min
						Plate.YShift.Alignment = MOVEDOWN
					endif
				else
					Plate.ObjectData.Position.y = y + sy*r
					if Plate.ObjectData.Position.y > Plate.YShift.Max
						Plate.ObjectData.Position.y = Plate.YShift.Max
						Plate.YShift.Alignment = MOVEUP
					endif
				endif
			endif
			
			SpritePositionCalc(Plate.SpriteData.Position,Plate.ObjectData.Position,World.Position)
			
			Plate.CollisionData.Position1.x = Plate.ObjectData.Position.x
			Plate.CollisionData.Position1.y = Plate.ObjectData.Position.y
			Plate.CollisionData.Position2.x = Plate.ObjectData.Position.x + Plate.ObjectData.Size.Width
			Plate.CollisionData.Position2.y = Plate.ObjectData.Position.y + Plate.ObjectData.Size.Height
			
			TimeReset(Plate.ObjectData.MoveTimer,Now)
			
		endif
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateMoveAll(PlateList ref as TPlateList,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to PlateList.Plate.Length
		PlateMove(PlateList.Plate[i],World,Now)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateDraw(Plate ref as TPlate,ProtoPlate ref as TProtoPlate)
	
	if Plate.Enabled = TRUE
		SpriteDraw(ProtoPlate.AnimPlate[Plate.ProtoIndex].Sprite,Plate.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateDrawAll(PlateList ref as TPlateList,ProtoPlate ref as TProtoPlate)
	
	local i as integer
	
	for i = 0 to PlateList.Plate.Length
		PlateDraw(PlateList.Plate[i],ProtoPlate)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateAndChestDrawAll(PlateList ref as TPlateList,ProtoPlate ref as TProtoPlate,ChestList ref as TChestList,ProtoChest ref as TProtoChest)
	
	local i as integer
	local k as integer
	
	for i = 0 to PlateList.Plate.Length
		PlateDraw(PlateList.Plate[i],ProtoPlate)
		for k = 0 to ChestList.Chest.Length
			if ChestList.Chest[k].CollisionData.Index = i
				ChestDraw(ChestList.Chest[k],ProtoChest)
			endif
		next k
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateCountAll(PlateList ref as TPlateList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to PlateList.Plate.Length
		if PlateList.Plate[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------




