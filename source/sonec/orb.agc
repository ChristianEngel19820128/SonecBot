
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoOrbLoad(ProtoOrb ref as TProtoOrb,File as TFilePath)
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoOrb.FromJson(ReadFileString(File))

		if ImageLoad(ProtoOrb.AnimOrb.Image) = TRUE
			SpriteLoad(ProtoOrb.AnimOrb)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbInit(OrbList ref as TOrbList)
	
	TimeSet(OrbList.CreateTimer,1000,1)
	OrbList.Orb.Length = -1
	OrbList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbNew(Orb ref as TOrb,ProtoOrb ref as TProtoOrb,World ref as TWorld,y as integer,Now as integer)
	
	Orb.Enabled = TRUE
	TimeSet(Orb.ObjectData.MoveTimer,10,10)
	TimeReset(Orb.ObjectData.MoveTimer,Now)
	
	Orb.ObjectData.MoveSpeed.x = random(35,100)*0.001
	Orb.ObjectData.MoveSpeed.y = random(25,50)*0.001
	
	Orb.ObjectData.Size.Width = GetImageWidth(ProtoOrb.AnimOrb.Image.ID)
	Orb.ObjectData.Size.Height = GetImageHeight(ProtoOrb.AnimOrb.Image.ID)
	
	if Orb.ObjectData.Size.Width > Orb.ObjectData.Size.Height
		Orb.ObjectData.Radius = Orb.ObjectData.Size.Width * 0.5
	else
		Orb.ObjectData.Radius = Orb.ObjectData.Size.Height * 0.5
	endif
	
	Orb.ObjectData.Position.x = World.Size.Width + Orb.ObjectData.Size.Width*0.5
	Orb.ObjectData.Position.y = y
	
	Orb.YShift.Enabled = random(0,1)
	Orb.YShift.Alignment = random(0,1)
	Orb.YShift.Min = random(Orb.ObjectData.Position.y-200,Orb.ObjectData.Position.y)
	if Orb.YShift.Min < 64
		Orb.YShift.Min = 64
	endif
	Orb.YShift.Max = random(Orb.ObjectData.Position.y,Orb.ObjectData.Position.y+200)
	if Orb.YShift.Max > World.Size.Height - 64
		Orb.YShift.Max = World.Size.Height - 64
	endif
	
	Orb.SpriteData.Angle  = 0
	Orb.SpriteData.Center = TRUE
	Orb.SpriteData.Scale  = 1
	
	ColorSet(Orb.SpriteData.Color,0,255,0,255)
	
	SpritePositionCalc(Orb.SpriteData.Position,Orb.ObjectData.Position,World.Position)
	
	Orb.Health.StateMax = 25
	Orb.Health.State = 25
	Orb.Health.RegRate = 1000
	
	TimeSet(Orb.Health.RegenerationTimer,Orb.Health.RegRate,1)
	TimeReset(Orb.Health.RegenerationTimer,Now)
	
	Orb.CollisionData.Position1.x = Orb.ObjectData.Position.x - Orb.ObjectData.Size.Width  * 0.5
	Orb.CollisionData.Position1.y = Orb.ObjectData.Position.y - Orb.ObjectData.Size.Height * 0.5
	Orb.CollisionData.Position2.x = Orb.ObjectData.Position.x + Orb.ObjectData.Size.Width  * 0.5
	Orb.CollisionData.Position2.y = Orb.ObjectData.Position.y + Orb.ObjectData.Size.Height * 0.5
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbAdd(OrbList ref as TOrbList,ProtoOrb ref as TProtoOrb,World ref as TWorld,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Orb as TOrb
	local y as integer

	y = random(64,floor((World.Size.Height-64)/8))*8
	
	Value = -1
	
	if OrbExists(OrbList,World,y) = FALSE
	
		if TimeGet(OrbList.CreateTimer,Now) > 0
			
			OrbNew(Orb,ProtoOrb,World,y,Now)
			
			Found = FALSE
			i = OrbList.FirstFree
			while Found = FALSE and i <= OrbList.Orb.Length
				if OrbList.Orb[i].Enabled = FALSE
					Found = TRUE
				else
					i = i+1
				endif
			endwhile
			
			if Found = FALSE
				OrbList.Orb.Insert(Orb)
				OrbList.FirstFree = OrbList.Orb.Length
				Value = OrbList.Orb.Length
			else
				OrbList.Orb[i] = Orb
				OrbList.FirstFree = i+1
				Value = i
			endif
		
			TimeReset(OrbList.CreateTimer,Now)
			
		endif
	endif
	
endfunction Value


//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbExists(OrbList ref as TOrbList,World ref as TWorld,y as integer)
	
	local Value as integer
	local i as integer
	
	Value = FALSE
	
	for i = 0 to OrbList.Orb.Length
		if OrbList.Orb[i].Enabled = TRUE
			if OrbList.Orb[i].ObjectData.Position.y > y - OrbList.Orb[i].ObjectData.Size.Height*4
				if OrbList.Orb[i].ObjectData.Position.y < y + OrbList.Orb[i].ObjectData.Size.Height*4
					Value = TRUE
				endif
			endif
		endif
		
	next i
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbDelete(OrbList ref as TOrbList,Index as integer)
	
	OrbList.Orb[Index].Enabled = FALSE
	if OrbList.FirstFree > Index
		OrbList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbDestroy(OrbList ref as TOrbList,Index as integer,ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,Position ref as TPosition,Now as integer)

	ExplosionAdd(ExplosionList,ProtoExplosion,Game,2,Position,Now)
	OrbDelete(OrbList,Index)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbCheckAll(OrbList ref as TOrbList,ProtoOrb ref as TProtoOrb)
	
	local i as integer
	local px as float
	local pdx as float
	
	for i = 0 to OrbList.Orb.Length
		
		if OrbList.Orb[i].Enabled = TRUE
		
			px = OrbList.Orb[i].ObjectData.Position.x
			pdx = OrbList.Orb[i].ObjectData.Size.Width*0.5
				
			if px+pdx < 0
				OrbDelete(OrbList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbHealthRegenerate(OrbList ref as TOrbList,Game ref as TGame,Now as integer)
	
	local i as integer
	local k as integer
	local EnergieType as integer
	local Position as TPosition
	
	for i = 0 to OrbList.Orb.Length
		if OrbList.Orb[i].Enabled = TRUE
			if TimeGet(OrbList.Orb[i].Health.RegenerationTimer,Now) > 0
				ColorSet(OrbList.Orb[i].SpriteData.Color,0,255,0,255)
				if OrbList.Orb[i].Health.State + REGHEALTH <= OrbList.Orb[i].Health.StateMax
					OrbList.Orb[i].Health.State = OrbList.Orb[i].Health.State + REGHEALTH
				else
					if OrbList.Orb[i].Health.State < OrbList.Orb[i].Health.StateMax
						OrbList.Orb[i].Health.State = OrbList.Orb[i].Health.StateMax
					endif
				endif
				TimeReset(OrbList.Orb[i].Health.RegenerationTimer,Now)
			endif
			if OrbList.Orb[i].Health.State < 0
				for k = 0 to random(0,12)
					EnergieType = 0
					if random(0,8) > 5
						EnergieType = random(0,Game.ProtoEnergie.AnimEnergie.Length)
					endif
					Position.x = OrbList.Orb[i].ObjectData.Position.x + random(0,20) - 10
					Position.y = OrbList.Orb[i].ObjectData.Position.y + random(0,20) - 10
					EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,EnergieType,Position,Now)
				next k
				OrbDestroy(OrbList,i,Game.ExplosionList,Game.ProtoExplosion,Game,OrbList.Orb[i].ObjectData.Position,Now)
			endif
		endif
	next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbMove(Orb ref as TOrb,World ref as TWorld,Now as integer)

	local x as float
	local y as float
	local sx as float
	local sy as float
	local r as float
	
	if Orb.Enabled = TRUE
		if TimeGet(Orb.ObjectData.MoveTimer,Now) > 0
			
			x = Orb.ObjectData.Position.x
			y = Orb.ObjectData.Position.y
			sx = Orb.ObjectData.MoveSpeed.x
			sy = Orb.ObjectData.MoveSpeed.y
			r = Orb.ObjectData.MoveTimer.CalcRange
			
			Orb.ObjectData.Position.x = x - sx*r
			
			if Orb.YShift.Enabled = TRUE
				if Orb.YShift.Alignment = MOVEUP
					Orb.ObjectData.Position.y = y - sy*r
					if Orb.ObjectData.Position.y < Orb.YShift.Min
						Orb.ObjectData.Position.y = Orb.YShift.Min
						Orb.YShift.Alignment = MOVEDOWN
					endif
				else
					Orb.ObjectData.Position.y = y + sy*r
					if Orb.ObjectData.Position.y > Orb.YShift.Max
						Orb.ObjectData.Position.y = Orb.YShift.Max
						Orb.YShift.Alignment = MOVEUP
					endif
				endif
			endif
			
			SpritePositionCalc(Orb.SpriteData.Position,Orb.ObjectData.Position,World.Position)
			
			Orb.CollisionData.Position1.x = Orb.ObjectData.Position.x - (Orb.ObjectData.Size.Width  * 0.5)
			Orb.CollisionData.Position1.y = Orb.ObjectData.Position.y - (Orb.ObjectData.Size.Height * 0.5)
			Orb.CollisionData.Position2.x = Orb.ObjectData.Position.x + (Orb.ObjectData.Size.Width  * 0.5)
			Orb.CollisionData.Position2.y = Orb.ObjectData.Position.y + (Orb.ObjectData.Size.Height * 0.5)
			
			TimeReset(Orb.ObjectData.MoveTimer,Now)
			
		endif
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbMoveAll(OrbList ref as TOrbList,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to OrbList.Orb.Length
		OrbMove(OrbList.Orb[i],World,Now)
		if OrbList.Orb[i].ObjectData.Position.x + OrbList.Orb[i].ObjectData.Size.Width < World.Position.x
			OrbDelete(OrbList,i)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbDraw(Orb ref as TOrb,ProtoOrb ref as TProtoOrb)
	
	if Orb.Enabled = TRUE
		SpriteDraw(ProtoOrb.AnimOrb.Sprite,Orb.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbDrawAll(OrbList ref as TOrbList,ProtoOrb ref as TProtoOrb)
	
	local i as integer
	
	for i = 0 to OrbList.Orb.Length
		OrbDraw(OrbList.Orb[i],ProtoOrb)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function OrbCountAll(OrbList ref as TOrbList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to OrbList.Orb.Length
		if OrbList.Orb[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------





