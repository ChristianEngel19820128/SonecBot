
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoMineLoad(ProtoMine ref as TProtoMine,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoMine.FromJson(ReadFileString(File))

		if ImageLoad(ProtoMine.AnimMine.Image) = TRUE
			SpriteLoad(ProtoMine.AnimMine)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineInit(MineList ref as TMineList)
	
	TimeSet(MineList.CreateTimer,1000,1)
	MineList.Mine.Length = -1
	MineList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineNew(Mine ref as TMine,ProtoMine ref as TProtoMine,World ref as TWorld,y as integer,Now as integer)
	
	Mine.Enabled = TRUE
	TimeSet(Mine.ObjectData.MoveTimer,10,10)
	TimeReset(Mine.ObjectData.MoveTimer,Now)
	
	Mine.ObjectData.MoveSpeed.x = random(35,100)*0.001
	Mine.ObjectData.MoveSpeed.y = 0
	
	Mine.ObjectData.Size.Width = GetImageWidth(ProtoMine.AnimMine.Image.ID)
	Mine.ObjectData.Size.Height = GetImageHeight(ProtoMine.AnimMine.Image.ID)
	
	if Mine.ObjectData.Size.Width > Mine.ObjectData.Size.Height
		Mine.ObjectData.Radius = Mine.ObjectData.Size.Width * 0.5
	else
		Mine.ObjectData.Radius = Mine.ObjectData.Size.Height * 0.5
	endif
	
	Mine.ObjectData.Position.x = World.Size.Width + Mine.ObjectData.Size.Width*0.5
	Mine.ObjectData.Position.y = y
	
	Mine.SpriteData.Angle  = 0
	Mine.SpriteData.Center = TRUE
	Mine.SpriteData.Scale  = 1
	
	ColorSet(Mine.SpriteData.Color,0,255,0,35)
	
	SpritePositionCalc(Mine.SpriteData.Position,Mine.ObjectData.Position,World.Position)
	
	Mine.Health.StateMax = 25
	Mine.Health.State = 25
	Mine.Health.RegRate = 1000
	
	TimeSet(Mine.Health.RegenerationTimer,Mine.Health.RegRate,1)
	TimeReset(Mine.Health.RegenerationTimer,Now)
	
	Mine.CollisionData.Position1.x = Mine.ObjectData.Position.x - Mine.ObjectData.Size.Width  * 0.5
	Mine.CollisionData.Position1.y = Mine.ObjectData.Position.y - Mine.ObjectData.Size.Height * 0.5
	Mine.CollisionData.Position2.x = Mine.ObjectData.Position.x + Mine.ObjectData.Size.Width  * 0.5
	Mine.CollisionData.Position2.y = Mine.ObjectData.Position.y + Mine.ObjectData.Size.Height * 0.5
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineAdd(MineList ref as TMineList,ProtoMine ref as TProtoMine,World ref as TWorld,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Mine as TMine
	local y as integer

	y = random(64,floor((World.Size.Height-64)/8))*8
	
	Value = -1
	
	if MineExists(MineList,World,y) = FALSE
	
		if TimeGet(MineList.CreateTimer,Now) > 0
			
			MineNew(Mine,ProtoMine,World,y,Now)
			
			Found = FALSE
			i = MineList.FirstFree
			while Found = FALSE and i <= MineList.Mine.Length
				if MineList.Mine[i].Enabled = FALSE
					Found = TRUE
				else
					i = i+1
				endif
			endwhile
			
			if Found = FALSE
				MineList.Mine.Insert(Mine)
				MineList.FirstFree = MineList.Mine.Length
				Value = MineList.Mine.Length
			else
				MineList.Mine[i] = Mine
				MineList.FirstFree = i+1
				Value = i
			endif
		
			TimeReset(MineList.CreateTimer,Now)
			
		endif
	endif
	
endfunction Value


//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineExists(MineList ref as TMineList,World ref as TWorld,y as integer)
	
	local Value as integer
	local i as integer
	
	Value = FALSE
	
	for i = 0 to MineList.Mine.Length
		if MineList.Mine[i].Enabled = TRUE
			if MineList.Mine[i].ObjectData.Position.y > y - MineList.Mine[i].ObjectData.Size.Height*4
				if MineList.Mine[i].ObjectData.Position.y < y + MineList.Mine[i].ObjectData.Size.Height*4
					Value = TRUE
				endif
			endif
		endif
		
	next i
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineDelete(MineList ref as TMineList,Index as integer)
	
	MineList.Mine[Index].Enabled = FALSE
	if MineList.FirstFree > Index
		MineList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineDestroy(MineList ref as TMineList,Index as integer,ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,Position ref as TPosition,Now as integer)

	ExplosionAdd(ExplosionList,ProtoExplosion,Game,1,Position,Now)
	MineDelete(MineList,Index)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineCheckAll(MineList ref as TMineList,ProtoMine ref as TProtoMine)
	
	local i as integer
	local px as float
	local pdx as float
	
	for i = 0 to MineList.Mine.Length
		
		if MineList.Mine[i].Enabled = TRUE
		
			px = MineList.Mine[i].ObjectData.Position.x
			pdx = MineList.Mine[i].ObjectData.Size.Width*0.5
				
			if px+pdx < 0
				MineDelete(MineList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineHealthRegenerate(MineList ref as TMineList,Game ref as TGame,Now as integer)
	
	local i as integer
	local k as integer
	local EnergieType as integer
	local Position as TPosition
	
	for i = 0 to MineList.Mine.Length
		if MineList.Mine[i].Enabled = TRUE
			if TimeGet(MineList.Mine[i].Health.RegenerationTimer,Now) > 0
				ColorSet(MineList.Mine[i].SpriteData.Color,0,255,0,35)
				if MineList.Mine[i].Health.State + REGHEALTH <= MineList.Mine[i].Health.StateMax
					MineList.Mine[i].Health.State = MineList.Mine[i].Health.State + REGHEALTH
				else
					if MineList.Mine[i].Health.State < MineList.Mine[i].Health.StateMax
						MineList.Mine[i].Health.State = MineList.Mine[i].Health.StateMax
					endif
				endif
				TimeReset(MineList.Mine[i].Health.RegenerationTimer,Now)
			endif
			if MineList.Mine[i].Health.State < 0
				for k = 0 to random(0,4)
					EnergieType = 0
					Position.x = MineList.Mine[i].ObjectData.Position.x + random(0,20) - 10
					Position.y = MineList.Mine[i].ObjectData.Position.y + random(0,20) - 10
					EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,EnergieType,Position,Now)
				next k
				MineDestroy(MineList,i,Game.ExplosionList,Game.ProtoExplosion,Game,MineList.Mine[i].ObjectData.Position,Now)
			endif
		endif
	next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineCollideSonec(MineList ref as TMineList,Sonec ref as TSonec,Game ref as TGame,Now as integer)
	
	local i as integer
	local Radius as float

	for i = 0 to MineList.Mine.Length
		if MineList.Mine[i].Enabled = TRUE
			Radius = CalcRadius(MineList.Mine[i].ObjectData.Position,Sonec.ObjectData.Position)
			if Radius < Sonec.ObjectData.Radius + MineList.Mine[i].ObjectData.Radius
				MineDestroy(MineList,i,Game.ExplosionList,Game.ProtoExplosion,Game,MineList.Mine[i].ObjectData.Position,Now)
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineMove(Mine ref as TMine,Sonec ref as TSonec,Inenergie ref as TInenergie,World ref as TWorld,Now as integer)

	local x as float
	local y as float
	local sx as float
	local sy as float
	local r as float
	local Radius as float
	local Angle as float
	
	if Mine.Enabled = TRUE
		if TimeGet(Mine.ObjectData.MoveTimer,Now) > 0
			
			x = Mine.ObjectData.Position.x
			y = Mine.ObjectData.Position.y
			sx = Mine.ObjectData.MoveSpeed.x
			sy = Mine.ObjectData.MoveSpeed.y
			r = Mine.ObjectData.MoveTimer.CalcRange
			
			Radius = CalcRadius(Mine.ObjectData.Position,Sonec.ObjectData.Position)
			if Radius < 250 or Inenergie.Enabled = TRUE 
				Angle = CalcAngle(Mine.ObjectData.Position,Sonec.ObjectData.Position)
				CalcPosition(Mine.ObjectData.Position,Angle,Mine.ObjectData.MoveTimer.CalcRange*0.15)
			else
				Mine.ObjectData.Position.x = x - sx*r
			endif
			
			SpritePositionCalc(Mine.SpriteData.Position,Mine.ObjectData.Position,World.Position)
			
			Mine.CollisionData.Position1.x = Mine.ObjectData.Position.x - (Mine.ObjectData.Size.Width  * 0.5)
			Mine.CollisionData.Position1.y = Mine.ObjectData.Position.y - (Mine.ObjectData.Size.Height * 0.5)
			Mine.CollisionData.Position2.x = Mine.ObjectData.Position.x + (Mine.ObjectData.Size.Width  * 0.5)
			Mine.CollisionData.Position2.y = Mine.ObjectData.Position.y + (Mine.ObjectData.Size.Height * 0.5)
			
			TimeReset(Mine.ObjectData.MoveTimer,Now)
			
		endif
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineMoveAll(MineList ref as TMineList,Sonec ref as TSonec,Inenergie ref as TInenergie,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to MineList.Mine.Length
		MineMove(MineList.Mine[i],Sonec,Inenergie,World,Now)
		if MineList.Mine[i].ObjectData.Position.x + MineList.Mine[i].ObjectData.Size.Width < World.Position.x
			MineDelete(MineList,i)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineDraw(Mine ref as TMine,ProtoMine ref as TProtoMine)
	
	if Mine.Enabled = TRUE
		SpriteDraw(ProtoMine.AnimMine.Sprite,Mine.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineDrawAll(MineList ref as TMineList,ProtoMine ref as TProtoMine)
	
	local i as integer
	
	for i = 0 to MineList.Mine.Length
		MineDraw(MineList.Mine[i],ProtoMine)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function MineCountAll(MineList ref as TMineList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to MineList.Mine.Length
		if MineList.Mine[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------







