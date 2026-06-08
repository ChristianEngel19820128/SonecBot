
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoExplosionLoad(ProtoExplosion ref as TProtoExplosion)
	
	local File as TFilePath
	local Anim as TProtoData
	local i as integer
	local k as integer
	local ten as string
	local min as integer
	local max as integer
	
	ProtoExplosion.AnimExplosion.length = 2
	
	for k = 0 to ProtoExplosion.AnimExplosion.length
		select k
			case 0
				File.Path = "/media/gfx/explosions/BlueFlash"
				File.Name = "DebrisExplode00"
				min = 6
				max = 49
			endcase
			case 1
				File.Path = "/media/gfx/explosions/RedExplode"
				File.Name = "redexplode00"
				min = 4
				max = 35
			endcase
			case 2
				File.Path = "/media/gfx/explosions/WhiteExplode"
				File.Name = "explodewhite00"
				min = 3
				max = 46
			endcase
		endselect
		
		for i = min to max
			
			Anim.Image.File.Path = File.Path
			
			if i < 10
				ten = "0"
			else
				ten = ""
			endif
			
			Anim.Image.File.Name = File.Name + ten + str(i) + ".png"
			
			if FilePathSetAndCheck(Anim.Image.File) = TRUE
				if ImageLoad(Anim.Image) = TRUE
					SpriteLoad(Anim)
				endif
			endif
			
			ProtoExplosion.AnimExplosion[k].Insert(Anim)
		
		next i
	next k

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionInit(ExplosionList ref as TExplosionList)
	
	ExplosionList.Explosion.Length = -1
	ExplosionList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionNew(Explosion ref as TExplosion,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,ExplosionType as integer,Position ref as TPosition,Now as integer)

	Explosion.Enabled = TRUE
	
	TimeSet(Explosion.AnimationData.AnimTimer,random(20,30),1)
	TimeReset(Explosion.AnimationData.AnimTimer,Now)
	
	Explosion.AnimationData.Frame = 0
	
	Explosion.ExplosionType = ExplosionType
	
	Explosion.ObjectData.Size.Width = GetImageWidth(ProtoExplosion.AnimExplosion[Explosion.ExplosionType,0].Image.ID)
	Explosion.ObjectData.Size.Height = GetImageHeight(ProtoExplosion.AnimExplosion[Explosion.ExplosionType,0].Image.ID)
	
	if Explosion.ObjectData.Size.Width > Explosion.ObjectData.Size.Height
		Explosion.ObjectData.Radius = Explosion.ObjectData.Size.Width * 0.5
	else
		Explosion.ObjectData.Radius = Explosion.ObjectData.Size.Height * 0.5
	endif
	
	Explosion.ObjectData.Position = Position
	
	Explosion.SpriteData.Angle  = random(0,360)
	Explosion.SpriteData.Center = TRUE
	Explosion.SpriteData.Scale  = random(75,125)*0.01
	
	Explosion.ObjectData.Radius = Explosion.ObjectData.Radius * Explosion.SpriteData.Scale
	
	select Explosion.ExplosionType
		case 0
			ColorSet(Explosion.SpriteData.Color,0,255,55,200)
		endcase
		case 1
			ColorSet(Explosion.SpriteData.Color,255,155,0,200)
		endcase
		case 2
			ColorSet(Explosion.SpriteData.Color,0,255,0,200)
		endcase
	endselect
	
	SpritePositionCalc(Explosion.SpriteData.Position,Explosion.ObjectData.Position,Game.World.Position)

	Explosion.BulletData.BulletType = 1
	Explosion.BulletData.Damage = 5

	Explosion.CollisionData.Position1.x = Explosion.ObjectData.Position.x - Explosion.ObjectData.Size.Width  * 0.5
	Explosion.CollisionData.Position1.y = Explosion.ObjectData.Position.y - Explosion.ObjectData.Size.Height * 0.5
	Explosion.CollisionData.Position2.x = Explosion.ObjectData.Position.x + Explosion.ObjectData.Size.Width  * 0.5
	Explosion.CollisionData.Position2.y = Explosion.ObjectData.Position.y + Explosion.ObjectData.Size.Height * 0.5
	
	select Explosion.ExplosionType
		case 0
			PlaySound(Game.Sound.ImpactSound)
		endcase
		case 1
			PlaySound(Game.Sound.ExplodeSound)
		endcase
		case 2
			PlaySound(Game.Sound.ExplosionSound)
		endcase
	endselect
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionAdd(ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,ExplosionType as integer,Position ref as TPosition,Now as integer)
	
	local Found as integer
	local i as integer
	local Explosion as TExplosion
	
	ExplosionNew(Explosion,ProtoExplosion,Game,ExplosionType,Position,Now)
	
	Found = FALSE
	i = ExplosionList.FirstFree
	while Found = FALSE and i <= ExplosionList.Explosion.Length
		if ExplosionList.Explosion[i].Enabled = FALSE
			Found = TRUE
		else
			i = i+1
		endif
	endwhile
	
	if Found = FALSE
		ExplosionList.Explosion.Insert(Explosion)
		ExplosionList.FirstFree = ExplosionList.Explosion.Length
	else
		ExplosionList.Explosion[i] = Explosion
		ExplosionList.FirstFree = i+1
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionDelete(ExplosionList ref as TExplosionList,Index as integer)
	
	ExplosionList.Explosion[Index].Enabled = FALSE
	if ExplosionList.FirstFree > Index
		ExplosionList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionAnimateAll(ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Now as integer)

	local i as integer
	
	for i = 0 to ExplosionList.Explosion.Length
		if TimeGet(ExplosionList.Explosion[i].AnimationData.AnimTimer,Now) > 0
			ExplosionList.Explosion[i].AnimationData.Frame = ExplosionList.Explosion[i].AnimationData.Frame +1
			if ExplosionList.Explosion[i].AnimationData.Frame > ProtoExplosion.AnimExplosion[ExplosionList.Explosion[i].ExplosionType].Length
				ExplosionDelete(ExplosionList,i)
			endif
			if ExplosionList.Explosion[i].AnimationData.AnimTimer.Span > 15
				TimeSet(ExplosionList.Explosion[i].AnimationData.AnimTimer,floor(ExplosionList.Explosion[i].AnimationData.AnimTimer.Span*0.9),1)
			endif
			TimeReset(ExplosionList.Explosion[i].AnimationData.AnimTimer,Now)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionCollideSonec(ExplosionList ref as TExplosionList,Sonec ref as TSonec)
	
	local i as integer
	local Radius as float

	for i = 0 to ExplosionList.Explosion.Length
		if ExplosionList.Explosion[i].Enabled = TRUE
			Radius = CalcRadius(ExplosionList.Explosion[i].ObjectData.Position,Sonec.ObjectData.Position)
			if Radius < ExplosionList.Explosion[i].ObjectData.Radius
				Sonec.Health.State = Sonec.Health.State - ExplosionList.Explosion[i].BulletData.Damage
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionCollideChest(ExplosionList ref as TExplosionList,ChestList ref as TChestList)
	
	local i as integer
	local k as integer
	local Radius as float

	for i = 0 to ExplosionList.Explosion.Length
		if ExplosionList.Explosion[i].Enabled = TRUE
			for k = 0 to ChestList.Chest.Length
				if ChestList.Chest[k].Enabled = TRUE
					Radius = CalcRadius(ExplosionList.Explosion[i].ObjectData.Position,ChestList.Chest[k].ObjectData.Position)
					if Radius < ExplosionList.Explosion[i].ObjectData.Radius
						ChestList.Chest[k].Health.State = ChestList.Chest[k].Health.State - ExplosionList.Explosion[i].BulletData.Damage
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionCollideOrb(ExplosionList ref as TExplosionList,OrbList ref as TOrbList)
	
	local i as integer
	local k as integer
	local Radius as float

	for i = 0 to ExplosionList.Explosion.Length
		if ExplosionList.Explosion[i].Enabled = TRUE
			for k = 0 to OrbList.Orb.Length
				if OrbList.Orb[k].Enabled = TRUE
					Radius = CalcRadius(ExplosionList.Explosion[i].ObjectData.Position,OrbList.Orb[k].ObjectData.Position)
					if Radius < ExplosionList.Explosion[i].ObjectData.Radius
						OrbList.Orb[k].Health.State = OrbList.Orb[k].Health.State - ExplosionList.Explosion[i].BulletData.Damage
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionCollideMine(ExplosionList ref as TExplosionList,MineList ref as TMineList)
	
	local i as integer
	local k as integer
	local Radius as float

	for i = 0 to ExplosionList.Explosion.Length
		if ExplosionList.Explosion[i].Enabled = TRUE
			for k = 0 to MineList.Mine.Length
				if MineList.Mine[k].Enabled = TRUE
					Radius = CalcRadius(ExplosionList.Explosion[i].ObjectData.Position,MineList.Mine[k].ObjectData.Position)
					if Radius < ExplosionList.Explosion[i].ObjectData.Radius
						MineList.Mine[k].Health.State = MineList.Mine[k].Health.State - ExplosionList.Explosion[i].BulletData.Damage
					endif
				endif
			next k
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionMove(Explosion ref as TExplosion,World ref as TWorld,Now as integer)
	
	if Explosion.Enabled = TRUE
		if TimeGet(Explosion.ObjectData.MoveTimer,Now) > 0
			
			SpritePositionCalc(Explosion.SpriteData.Position,Explosion.ObjectData.Position,World.Position)
			
			Explosion.CollisionData.Position1.x = Explosion.ObjectData.Position.x - (Explosion.ObjectData.Size.Width  * 0.5)
			Explosion.CollisionData.Position1.y = Explosion.ObjectData.Position.y - (Explosion.ObjectData.Size.Height * 0.5)
			Explosion.CollisionData.Position2.x = Explosion.ObjectData.Position.x + (Explosion.ObjectData.Size.Width  * 0.5)
			Explosion.CollisionData.Position2.y = Explosion.ObjectData.Position.y + (Explosion.ObjectData.Size.Height * 0.5)
			
			TimeReset(Explosion.ObjectData.MoveTimer,Now)
			
		endif
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionMoveAll(ExplosionList ref as TExplosionList,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to ExplosionList.Explosion.Length
		ExplosionMove(ExplosionList.Explosion[i],World,Now)
		if ExplosionList.Explosion[i].ObjectData.Position.x + ExplosionList.Explosion[i].ObjectData.Size.Width < World.Position.x
			ExplosionDelete(ExplosionList,i)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionDraw(Explosion ref as TExplosion,ProtoExplosion ref as TProtoExplosion)
	
	if Explosion.Enabled = TRUE
		SpriteDraw(ProtoExplosion.AnimExplosion[Explosion.ExplosionType,Explosion.AnimationData.Frame].Sprite,Explosion.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ExplosionDrawAll(ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion)
	
	local i as integer
	
	for i = 0 to ExplosionList.Explosion.Length
		ExplosionDraw(ExplosionList.Explosion[i],ProtoExplosion)
	next i
	
endfunction
	
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

