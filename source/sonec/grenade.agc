
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoGrenadeLoad(ProtoGrenade ref as TProtoGrenade,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoGrenade.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoGrenade.AnimGrenade.Image) = TRUE
			SpriteLoad(ProtoGrenade.AnimGrenade)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeInit(GrenadeList ref as TGrenadeList)
	
	GrenadeList.Grenade.Length = -1
	GrenadeList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeNew(Grenade ref as TGrenade,ProtoGrenade ref as TProtoGrenade,World ref as TWorld,Position as TPosition,Angle as float,Radius as float,Now)
	
	Speed as TPosition
	
	Grenade.Enabled = TRUE
	TimeSet(Grenade.ObjectData.MoveTimer,10,10)
	TimeReset(Grenade.ObjectData.MoveTimer,Now)
	
	Grenade.ObjectData.Position = Position
	CalcPosition(Grenade.ObjectData.Position,Angle,Radius)
	
	Grenade.ObjectData.MoveSpeedMax.x = 3
	Grenade.ObjectData.MoveSpeedMax.y = 3
	
	Speed.x = 0
	Speed.y = 0
	CalcPosition(Speed,Angle,3)

	Grenade.ObjectData.MoveSpeed.x = Speed.x
	Grenade.ObjectData.MoveSpeed.y = Speed.y

	Grenade.ObjectData.MoveAcceleration.x = 0
	Grenade.ObjectData.MoveAcceleration.y = 1.5
	
	Grenade.ObjectData.MoveAlignment.x = 0
	Grenade.ObjectData.MoveAlignment.y = 0
	
	Grenade.SpriteData.Angle = Angle
	Grenade.SpriteData.Center = TRUE
	Grenade.SpriteData.Scale = 1
		
	ColorSet(Grenade.SpriteData.Color,255,255,255,255)
	
	Grenade.ObjectData.Size.Width = GetImageWidth(ProtoGrenade.AnimGrenade.Image.ID)*Grenade.SpriteData.Scale
	Grenade.ObjectData.Size.Height = GetImageHeight(ProtoGrenade.AnimGrenade.Image.ID)*Grenade.SpriteData.Scale

	if Grenade.ObjectData.Size.Width > Grenade.ObjectData.Size.Height
		Grenade.ObjectData.Radius = Grenade.ObjectData.Size.Width * 0.5
	else
		Grenade.ObjectData.Radius = Grenade.ObjectData.Size.Height * 0.5
	endif
	
	SpritePositionCalc(Grenade.SpriteData.Position,Grenade.ObjectData.Position,World.Position)
	
	Grenade.BulletData.BulletType = 1
	Grenade.BulletData.Damage = 5
	
	Grenade.CollisionData.Position1.x = Grenade.ObjectData.Position.x - Grenade.ObjectData.Size.Height * 0.5
	Grenade.CollisionData.Position1.y = Grenade.ObjectData.Position.y - Grenade.ObjectData.Size.Width  * 0.5
	Grenade.CollisionData.Position2.x = Grenade.ObjectData.Position.x + Grenade.ObjectData.Size.Height * 0.5
	Grenade.CollisionData.Position2.y = Grenade.ObjectData.Position.y + Grenade.ObjectData.Size.Width  * 0.5
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeAdd(GrenadeList ref as TGrenadeList,ProtoGrenade ref as TProtoGrenade,World ref as TWorld,Position as TPosition,Angle as float,Radius as float,Now as integer)
	
	local Found as integer
	local i as integer
	local Grenade as TGrenade
		
	GrenadeNew(Grenade,ProtoGrenade,World,Position,Angle,Radius,Now)
	
	Found = FALSE
	i = GrenadeList.FirstFree
	while Found = FALSE and i <= GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = FALSE
			Found = TRUE
		else
			i = i+1
		endif
	endwhile
	
	if Found = FALSE
		GrenadeList.Grenade.Insert(Grenade)
		GrenadeList.FirstFree = GrenadeList.Grenade.Length
	else
		GrenadeList.Grenade[i] = Grenade
		GrenadeList.FirstFree = i+1
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeDelete(GrenadeList ref as TGrenadeList,Index as integer)
	
	GrenadeList.Grenade[Index].Enabled = FALSE
	if GrenadeList.FirstFree > Index
		GrenadeList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeDestroy(GrenadeList ref as TGrenadeList,Index as integer,ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,Position ref as TPosition,Now as integer)

	ExplosionAdd(ExplosionList,ProtoExplosion,Game,1,Position,Now)
	GrenadeDelete(GrenadeList,Index)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeCollideOrbs(GrenadeList ref as TGrenadeList,OrbList ref as TOrbList,Game ref as TGame,Now as integer)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = TRUE
			for k = 0 to OrbList.Orb.Length
				if OrbList.Orb[k].Enabled = TRUE
					if BoxInBox(GrenadeList.Grenade[i].CollisionData.Position1,GrenadeList.Grenade[i].CollisionData.Position2,OrbList.Orb[k].CollisionData.Position1,OrbList.Orb[k].CollisionData.Position2)
						OrbList.Orb[k].Health.State = OrbList.Orb[k].Health.State - GrenadeList.Grenade[i].BulletData.Damage
						ColorSet(OrbList.Orb[k].SpriteData.Color,255,0,0,255)
						GrenadeDestroy(GrenadeList,i,Game.ExplosionList,Game.ProtoExplosion,Game,GrenadeList.Grenade[i].ObjectData.Position,Now)
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeCollideMine(GrenadeList ref as TGrenadeList,MineList ref as TMineList,Game ref as TGame,Now as integer)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = TRUE
			for k = 0 to MineList.Mine.Length
				if MineList.Mine[k].Enabled = TRUE
					Radius = CalcRadius(GrenadeList.Grenade[i].ObjectData.Position,MineList.Mine[k].ObjectData.Position)
					if Radius < GrenadeList.Grenade[i].ObjectData.Radius + MineList.Mine[k].ObjectData.Radius
						MineList.Mine[k].Health.State = MineList.Mine[k].Health.State - GrenadeList.Grenade[i].BulletData.Damage
						ColorSet(MineList.Mine[k].SpriteData.Color,255,0,0,255)
						GrenadeDestroy(GrenadeList,i,Game.ExplosionList,Game.ProtoExplosion,Game,GrenadeList.Grenade[i].ObjectData.Position,Now)
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeCollideChest(GrenadeList ref as TGrenadeList,ChestList ref as TChestList,Game ref as TGame,Now as integer)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = TRUE
			for k = 0 to ChestList.Chest.Length
				if ChestList.Chest[k].Enabled = TRUE
					if BoxInBox(GrenadeList.Grenade[i].CollisionData.Position1,GrenadeList.Grenade[i].CollisionData.Position2,ChestList.Chest[k].CollisionData.Position1,ChestList.Chest[k].CollisionData.Position2)
						ChestList.Chest[k].Health.State = ChestList.Chest[k].Health.State - GrenadeList.Grenade[i].BulletData.Damage
						ColorSet(ChestList.Chest[k].SpriteData.Color,255,0,0,255)
						GrenadeDestroy(GrenadeList,i,Game.ExplosionList,Game.ProtoExplosion,Game,GrenadeList.Grenade[i].ObjectData.Position,Now)
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeCollidePlate(GrenadeList ref as TGrenadeList,PlateList ref as TPlateList,Game ref as TGame,Now as integer)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = TRUE
			for k = 0 to PlateList.Plate.Length
				if PlateList.Plate[k].Enabled = TRUE
					if BoxInBox(GrenadeList.Grenade[i].CollisionData.Position1,GrenadeList.Grenade[i].CollisionData.Position2,PlateList.Plate[k].CollisionData.Position1,PlateList.Plate[k].CollisionData.Position2)
						GrenadeDestroy(GrenadeList,i,Game.ExplosionList,Game.ProtoExplosion,Game,GrenadeList.Grenade[i].ObjectData.Position,Now)
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeMove(Grenade ref as TGrenade,World ref as TWorld,Now as integer)

	if Grenade.Enabled = TRUE
		if TimeGet(Grenade.ObjectData.MoveTimer,Now) > 0
			
			
			
			Grenade.ObjectData.MoveAcceleration.y = Grenade.ObjectData.MoveAcceleration.y^2
			
			if Grenade.ObjectData.MoveSpeed.y + Grenade.ObjectData.MoveAcceleration.y*0.00025 < Grenade.ObjectData.MoveSpeedMax.y
				Grenade.ObjectData.MoveSpeed.y = Grenade.ObjectData.MoveSpeed.y + Grenade.ObjectData.MoveAcceleration.y*0.00025
			endif
			
			Grenade.ObjectData.Position.x = Grenade.ObjectData.Position.x + Grenade.ObjectData.MoveSpeed.x * Grenade.ObjectData.MoveTimer.CalcRange
			Grenade.ObjectData.Position.y = Grenade.ObjectData.Position.y + Grenade.ObjectData.MoveSpeed.y * Grenade.ObjectData.MoveTimer.CalcRange
			
			SpritePositionCalc(Grenade.SpriteData.Position,Grenade.ObjectData.Position,World.Position)
			
			Grenade.CollisionData.Position1.x = Grenade.ObjectData.Position.x - Grenade.ObjectData.Size.Height * 0.5
			Grenade.CollisionData.Position1.y = Grenade.ObjectData.Position.y - Grenade.ObjectData.Size.Width  * 0.5
			Grenade.CollisionData.Position2.x = Grenade.ObjectData.Position.x + Grenade.ObjectData.Size.Height * 0.5
			Grenade.CollisionData.Position2.y = Grenade.ObjectData.Position.y + Grenade.ObjectData.Size.Width  * 0.5
			
			TimeReset(Grenade.ObjectData.MoveTimer,Now)
			
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeMoveAll(GrenadeList ref as TGrenadeList,World ref as TWorld,Now as integer)

	Local i as integer
	
	for i = 0 to GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = TRUE
			GrenadeMove(GrenadeList.Grenade[i],World,Now)
			if GrenadeList.Grenade[i].ObjectData.Position.y < -GrenadeList.Grenade[i].ObjectData.Size.Height
				GrenadeDelete(GrenadeList,i)
			else
				if GrenadeList.Grenade[i].ObjectData.Position.y > World.Size.Height+GrenadeList.Grenade[i].ObjectData.Size.Height
					GrenadeDelete(GrenadeList,i)
				else
					if GrenadeList.Grenade[i].ObjectData.Position.x > World.Size.Width+GrenadeList.Grenade[i].ObjectData.Size.Width
						GrenadeDelete(GrenadeList,i)
					else
						if GrenadeList.Grenade[i].ObjectData.Position.x < -GrenadeList.Grenade[i].ObjectData.Size.Width
							GrenadeDelete(GrenadeList,i)
						endif
					endif
				endif
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeDraw(Grenade ref as TGrenade,ProtoGrenade ref as TProtoGrenade)

	if Grenade.Enabled = TRUE
		SpriteDraw(ProtoGrenade.AnimGrenade.Sprite,Grenade.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeDrawAll(GrenadeList ref as TGrenadeList,ProtoGrenade ref as TProtoGrenade)
	
	local i as integer
	
	for i = 0 to GrenadeList.Grenade.Length
		GrenadeDraw(GrenadeList.Grenade[i],ProtoGrenade)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function GrenadeCountAll(GrenadeList ref as TGrenadeList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to GrenadeList.Grenade.Length
		if GrenadeList.Grenade[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------






