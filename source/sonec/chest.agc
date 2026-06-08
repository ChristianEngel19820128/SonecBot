
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoChestLoad(ProtoChest ref as TProtoChest,File as TFilePath)
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoChest.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoChest.AnimChest.Image) = TRUE
			SpriteLoad(ProtoChest.AnimChest)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestInit(ChestList ref as TChestList)
	
	TimeSet(ChestList.CreateTimer,1000,1)
	ChestList.Chest.Length = -1
	ChestList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestNew(ChestList ref as TChestList,Chest ref as TChest,ProtoChest ref as TProtoChest,World ref as TWorld,Plate ref as TPlate,PlateIndex as integer,Now as integer)
	
	local Value as integer
	local Position as TPosition
	local i as integer
	local imax as integer
	
	Chest.Enabled = TRUE

	Chest.SpriteData.Angle = 0
	Chest.SpriteData.Center = FALSE
	Chest.SpriteData.Scale = 0.20 * random(1,5)
	
	Chest.ObjectData.Size.Width = GetImageWidth(ProtoChest.AnimChest.Image.ID)*Chest.SpriteData.Scale
	Chest.ObjectData.Size.Height = GetImageHeight(ProtoChest.AnimChest.Image.ID)*Chest.SpriteData.Scale

	Chest.CollisionData.Index = PlateIndex
	
	Chest.CollisionData.Position.y = -Chest.ObjectData.Size.Height
	Chest.CollisionData.Position.x = random(0,Plate.ObjectData.Size.Width-Chest.ObjectData.Size.Width)
	
	Position.x = Plate.ObjectData.Position.x + Chest.CollisionData.Position.x
	Position.y = Plate.ObjectData.Position.y + Chest.CollisionData.Position.y
	
	Chest.Health.StateMax = 500 * Chest.SpriteData.Scale 
	Chest.Health.State = 500 * Chest.SpriteData.Scale 
	Chest.Health.RegRate = 500
	
	TimeSet(Chest.Health.RegenerationTimer,Chest.Health.RegRate,1)
	TimeReset(Chest.Health.RegenerationTimer,Now)
	
	ColorSet(Chest.SpriteData.Color,0,255,0,255)
	
	Chest.CollisionData.Position1.x = Chest.ObjectData.Position.x
	Chest.CollisionData.Position1.y = Chest.ObjectData.Position.y
	Chest.CollisionData.Position2.x = Chest.ObjectData.Position.x + Chest.ObjectData.Size.Width
	Chest.CollisionData.Position2.y = Chest.ObjectData.Position.y + Chest.ObjectData.Size.Height
	
	i = 0
	imax = 5
	while ChestExists(ChestList,World,Position,Chest.ObjectData.Size,PlateIndex) = TRUE and i <= imax
		Chest.CollisionData.Position.x = random(0,Plate.ObjectData.Size.Width-Chest.ObjectData.Size.Width)
		Position.x = Plate.ObjectData.Position.x + Chest.CollisionData.Position.x
		i = i +1
	endwhile

	Chest.ObjectData.Position = Position

	SpritePositionCalc(Chest.SpriteData.Position,Chest.ObjectData.Position,World.Position)
	
	if i > imax
		Value = FALSE
	else
		Value = TRUE
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestHealthRegenerate(ChestList ref as TChestList,Now as integer)
	
	local i as integer
	
	for i = 0 to ChestList.Chest.Length
		if ChestList.Chest[i].Enabled = TRUE
			if TimeGet(ChestList.Chest[i].Health.RegenerationTimer,Now) > 0
				if ChestList.Chest[i].Health.State + REGHEALTH <= ChestList.Chest[i].Health.StateMax
					ChestList.Chest[i].Health.State = ChestList.Chest[i].Health.State + REGHEALTH
					ColorSet(ChestList.Chest[i].SpriteData.Color,0,255,0,255)
				else
					if ChestList.Chest[i].Health.State < ChestList.Chest[i].Health.StateMax
						ChestList.Chest[i].Health.State = ChestList.Chest[i].Health.StateMax
					endif
				endif
				TimeReset(ChestList.Chest[i].Health.RegenerationTimer,Now)
			endif
			if ChestList.Chest[i].Health.State < 0 then ChestDelete(ChestList,i)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestAdd(ChestList ref as TChestList,ProtoChest ref as TProtoChest,World ref as TWorld,Plate ref as TPlate,PlateIndex as integer,Now as integer)
	
	local Found as integer
	local i as integer
	local Chest as TChest
	local max as integer
	
	max = floor(Plate.ObjectData.Size.Width / GetImageWidth(ProtoChest.AnimChest.Image.ID) * 0.25)
	
	for i = 1 to random(0,max)
			
		if ChestNew(ChestList,Chest,ProtoChest,World,Plate,PlateIndex,Now) = TRUE
			
			Found = FALSE
			i = ChestList.FirstFree
			while Found = FALSE and i <= ChestList.Chest.Length
				if ChestList.Chest[i].Enabled = FALSE
					Found = TRUE
				else
					i = i+1
				endif
			endwhile
			
			if Found = FALSE
				ChestList.Chest.Insert(Chest)
				ChestList.FirstFree = ChestList.Chest.Length
			else
				ChestList.Chest[i] = Chest
				ChestList.FirstFree = i+1
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestExists(ChestList ref as TChestList,World ref as TWorld,Position as TPosition,Size as TSize,PlateIndex as integer)
	
	local Value as integer
	local i as integer
	local Box1P1 as TPosition
	local Box1P2 as TPosition
	local Box2P1 as TPosition
	local Box2P2 as TPosition
	
	Value = FALSE
	
	for i = 0 to ChestList.Chest.Length
		if ChestList.Chest[i].Enabled = TRUE
			if ChestList.Chest[i].CollisionData.Index = PlateIndex
				
				Box1P1.x = ChestList.Chest[i].ObjectData.Position.x
				Box1P1.y = ChestList.Chest[i].ObjectData.Position.y
				
				Box1P2.x = ChestList.Chest[i].ObjectData.Position.x + ChestList.Chest[i].ObjectData.Size.Width
				Box1P2.y = ChestList.Chest[i].ObjectData.Position.y + ChestList.Chest[i].ObjectData.Size.Height
				
				Box2P1.x = Position.x
				Box2P1.y = Position.y
				
				Box2P2.x = Position.x + Size.Width
				Box2P2.y = Position.y + Size.Height
				
				if BoxInBox(Box1P1,Box1P2,Box2P1,Box2P2) = TRUE
					Value = TRUE
				endif
			endif
		endif
		
	next i
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestDelete(ChestList ref as TChestList,Index as integer)
	
	ChestList.Chest[Index].Enabled = FALSE
	if ChestList.FirstFree > Index
		ChestList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestCheckAll(ChestList ref as TChestList,ProtoChest ref as TProtoChest)
	
	local i as integer
	local px as float
	local pdx as float
	
	for i = 0 to ChestList.Chest.Length
		
		if ChestList.Chest[i].Enabled = TRUE
		
			px = ChestList.Chest[i].ObjectData.Position.x
			pdx = ChestList.Chest[i].ObjectData.Size.Width
				
			if px+pdx < 0
				ChestDelete(ChestList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestMove(Chest ref as TChest,PlateList ref as TPlateList,World ref as TWorld)

	local x as float
	local y as float
	local sx as float
	local sy as float
	local r as float
	
	if Chest.Enabled = TRUE
		
		Chest.ObjectData.Position.x = PlateList.Plate[Chest.CollisionData.Index].ObjectData.Position.x + Chest.CollisionData.Position.x
		Chest.ObjectData.Position.y = PlateList.Plate[Chest.CollisionData.Index].ObjectData.Position.y + Chest.CollisionData.Position.y
		
		SpritePositionCalc(Chest.SpriteData.Position,Chest.ObjectData.Position,World.Position)
		
		Chest.CollisionData.Position1.x = Chest.ObjectData.Position.x
		Chest.CollisionData.Position1.y = Chest.ObjectData.Position.y
		Chest.CollisionData.Position2.x = Chest.ObjectData.Position.x + (Chest.ObjectData.Size.Width * Chest.SpriteData.Scale)
		Chest.CollisionData.Position2.y = Chest.ObjectData.Position.y + (Chest.ObjectData.Size.Height * Chest.SpriteData.Scale)
				
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestMoveAll(ChestList ref as TChestList,PlateList ref as TPlateList,World ref as TWorld)
	
	local i as integer
	
	for i = 0 to ChestList.Chest.Length
		ChestMove(ChestList.Chest[i],PlateList,World)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestDraw(Chest ref as TChest,ProtoChest ref as TProtoChest)
	
	if Chest.Enabled = TRUE
		SpriteDraw(ProtoChest.AnimChest.Sprite,Chest.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestDrawAll(ChestList ref as TChestList,ProtoChest ref as TProtoChest)
	
	local i as integer
	
	for i = 0 to ChestList.Chest.Length
		ChestDraw(ChestList.Chest[i],ProtoChest)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ChestCountAll(ChestList ref as TChestList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to ChestList.Chest.Length
		if ChestList.Chest[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------






