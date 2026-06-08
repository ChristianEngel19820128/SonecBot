
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoBulletLoad(ProtoBullet ref as TProtoBullet,File ref as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoBullet.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoBullet.AnimBullet.Image) = TRUE
			SpriteLoad(ProtoBullet.AnimBullet)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletInit(BulletList ref as TBulletList)
	
	BulletList.Bullet.Length = -1
	BulletList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletNew(Bullet ref as TBullet,ProtoBullet ref as TProtoBullet,World ref as TWorld,Position ref as TPosition,Angle as float,Radius as float,CollisionType as integer,Now as integer)
	
	Speed as TPosition
	
	Bullet.Enabled = TRUE
	TimeSet(Bullet.ObjectData.MoveTimer,10,10)
	TimeReset(Bullet.ObjectData.MoveTimer,Now)
	
	Bullet.ObjectData.Position = Position
	CalcPosition(Bullet.ObjectData.Position,Angle,Radius)
	
	Bullet.ObjectData.MoveSpeedMax.x = 0
	Bullet.ObjectData.MoveSpeedMax.y = 0
	
	Speed.x = 0
	Speed.y = 0
	CalcPosition(Speed,Angle,3)

	Bullet.ObjectData.MoveSpeed.x = Speed.x
	Bullet.ObjectData.MoveSpeed.y = Speed.y

	Bullet.ObjectData.MoveAcceleration.x = 0
	Bullet.ObjectData.MoveAcceleration.y = 0
	
	Bullet.ObjectData.MoveAlignment.x = 0
	Bullet.ObjectData.MoveAlignment.y = 0
	
	Bullet.SpriteData.Angle = Angle
	Bullet.SpriteData.Center = TRUE
	Bullet.SpriteData.Scale = 1
		
	ColorSet(Bullet.SpriteData.Color,255,255,255,255)
	
	Bullet.ObjectData.Size.Width = GetImageWidth(ProtoBullet.AnimBullet.Image.ID)*Bullet.SpriteData.Scale
	Bullet.ObjectData.Size.Height = GetImageHeight(ProtoBullet.AnimBullet.Image.ID)*Bullet.SpriteData.Scale

	if Bullet.ObjectData.Size.Width > Bullet.ObjectData.Size.Height
		Bullet.ObjectData.Radius = Bullet.ObjectData.Size.Width * 0.5
	else
		Bullet.ObjectData.Radius = Bullet.ObjectData.Size.Height * 0.5
	endif
	
	SpritePositionCalc(Bullet.SpriteData.Position,Bullet.ObjectData.Position,World.Position)
	
	Bullet.CollisionData.CollisionType = CollisionType
	Bullet.BulletData.BulletType = 1
	Bullet.BulletData.Damage = 25
	
	Bullet.CollisionData.Position1.x = Bullet.ObjectData.Position.x - Bullet.ObjectData.Size.Height * 0.5
	Bullet.CollisionData.Position1.y = Bullet.ObjectData.Position.y - Bullet.ObjectData.Size.Width  * 0.5
	Bullet.CollisionData.Position2.x = Bullet.ObjectData.Position.x + Bullet.ObjectData.Size.Height * 0.5
	Bullet.CollisionData.Position2.y = Bullet.ObjectData.Position.y + Bullet.ObjectData.Size.Width  * 0.5
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletAdd(BulletList ref as TBulletList,ProtoBullet ref as TProtoBullet,World ref as TWorld,Position ref as TPosition,Angle as float,Radius as float,CollisionType as integer,Now as integer)
	
	local Found as integer
	local i as integer
	local Bullet as TBullet
		
	BulletNew(Bullet,ProtoBullet,World,Position,Angle,Radius,CollisionType,Now)
	
	Found = FALSE
	i = BulletList.FirstFree
	while Found = FALSE and i <= BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = FALSE
			Found = TRUE
		else
			i = i+1
		endif
	endwhile
	
	if Found = FALSE
		BulletList.Bullet.Insert(Bullet)
		BulletList.FirstFree = BulletList.Bullet.Length
	else
		BulletList.Bullet[i] = Bullet
		BulletList.FirstFree = i+1
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletDelete(BulletList ref as TBulletList,Index as integer)
	
	BulletList.Bullet[Index].Enabled = FALSE
	if BulletList.FirstFree > Index
		BulletList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletCollide(BulletList ref as TBulletList,Sonec ref as TSonec)
	
	local i as integer
	local Radius as float
	
	for i = 0 to BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = TRUE
			if BulletList.Bullet[i].CollisionData.CollisionType = TYPEENEMY
				Radius = CalcRadius(BulletList.Bullet[i].ObjectData.Position,Sonec.ObjectData.Position)
				if Radius < Sonec.ObjectData.Radius
					Sonec.Health.State = Sonec.Health.State - BulletList.Bullet[i].BulletData.Damage
					BulletDelete(BulletList,i)
				endif
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletCollideOrbs(BulletList ref as TBulletList,OrbList ref as TOrbList)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = TRUE
			for k = 0 to OrbList.Orb.Length
				if OrbList.Orb[k].Enabled = TRUE
					if BoxInBox(BulletList.Bullet[i].CollisionData.Position1,BulletList.Bullet[i].CollisionData.Position2,OrbList.Orb[k].CollisionData.Position1,OrbList.Orb[k].CollisionData.Position2)
						OrbList.Orb[k].Health.State = OrbList.Orb[k].Health.State - BulletList.Bullet[i].BulletData.Damage
						BulletDelete(BulletList,i)
						ColorSet(OrbList.Orb[k].SpriteData.Color,255,0,0,255)
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletCollideMine(BulletList ref as TBulletList,MineList ref as TMineList)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = TRUE
			for k = 0 to MineList.Mine.Length
				if MineList.Mine[k].Enabled = TRUE
					Radius = CalcRadius(BulletList.Bullet[i].ObjectData.Position,MineList.Mine[k].ObjectData.Position)
					if Radius < BulletList.Bullet[i].ObjectData.Radius + MineList.Mine[k].ObjectData.Radius
						MineList.Mine[k].Health.State = MineList.Mine[k].Health.State - BulletList.Bullet[i].BulletData.Damage
						BulletDelete(BulletList,i)
						ColorSet(MineList.Mine[k].SpriteData.Color,255,0,0,255)
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletCollideChest(BulletList ref as TBulletList,ChestList ref as TChestList)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = TRUE
			for k = 0 to ChestList.Chest.Length
				if ChestList.Chest[k].Enabled = TRUE
					if BoxInBox(BulletList.Bullet[i].CollisionData.Position1,BulletList.Bullet[i].CollisionData.Position2,ChestList.Chest[k].CollisionData.Position1,ChestList.Chest[k].CollisionData.Position2)
						ChestList.Chest[k].Health.State = ChestList.Chest[k].Health.State - BulletList.Bullet[i].BulletData.Damage
						BulletDelete(BulletList,i)
						ColorSet(ChestList.Chest[k].SpriteData.Color,255,0,0,255)
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletMove(Bullet ref as TBullet,World ref as TWorld,Now as integer)

	if Bullet.Enabled = TRUE
		if TimeGet(Bullet.ObjectData.MoveTimer,Now) > 0
			
			Bullet.ObjectData.Position.x = Bullet.ObjectData.Position.x + Bullet.ObjectData.MoveSpeed.x * Bullet.ObjectData.MoveTimer.CalcRange
			Bullet.ObjectData.Position.y = Bullet.ObjectData.Position.y + Bullet.ObjectData.MoveSpeed.y * Bullet.ObjectData.MoveTimer.CalcRange
			
			SpritePositionCalc(Bullet.SpriteData.Position,Bullet.ObjectData.Position,World.Position)
			
			Bullet.CollisionData.Position1.x = Bullet.ObjectData.Position.x - Bullet.ObjectData.Size.Height * 0.5
			Bullet.CollisionData.Position1.y = Bullet.ObjectData.Position.y - Bullet.ObjectData.Size.Width  * 0.5
			Bullet.CollisionData.Position2.x = Bullet.ObjectData.Position.x + Bullet.ObjectData.Size.Height * 0.5
			Bullet.CollisionData.Position2.y = Bullet.ObjectData.Position.y + Bullet.ObjectData.Size.Width  * 0.5
			
			TimeReset(Bullet.ObjectData.MoveTimer,Now)
			
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletMoveAll(BulletList ref as TBulletList,World ref as TWorld,Now as integer)

	Local i as integer
	
	for i = 0 to BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = TRUE
			BulletMove(BulletList.Bullet[i],World,Now)
			if BulletList.Bullet[i].ObjectData.Position.y < -BulletList.Bullet[i].ObjectData.Size.Height
				BulletDelete(BulletList,i)
			else
				if BulletList.Bullet[i].ObjectData.Position.y > World.Size.Height+BulletList.Bullet[i].ObjectData.Size.Height
					BulletDelete(BulletList,i)
				else
					if BulletList.Bullet[i].ObjectData.Position.x > World.Size.Width+BulletList.Bullet[i].ObjectData.Size.Width
						BulletDelete(BulletList,i)
					else
						if BulletList.Bullet[i].ObjectData.Position.x < -BulletList.Bullet[i].ObjectData.Size.Width
							BulletDelete(BulletList,i)
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

function BulletDraw(Bullet ref as TBullet,ProtoBullet ref as TProtoBullet)

	if Bullet.Enabled = TRUE
		SpriteDraw(ProtoBullet.AnimBullet.Sprite,Bullet.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletDrawAll(BulletList ref as TBulletList,ProtoBullet ref as TProtoBullet)
	
	local i as integer
	
	for i = 0 to BulletList.Bullet.Length
		BulletDraw(BulletList.Bullet[i],ProtoBullet)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BulletCountAll(BulletList ref as TBulletList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to BulletList.Bullet.Length
		if BulletList.Bullet[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------






