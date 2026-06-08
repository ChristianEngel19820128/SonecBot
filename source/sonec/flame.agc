
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoFlameLoad(ProtoFlame ref as TProtoFlame,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoFlame.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoFlame.AnimFlame.Image) = TRUE
			SpriteLoad(ProtoFlame.AnimFlame)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameInit(FlameList ref as TFlameList)
	
	TimeSet(FlameList.CreateTimer,10,1)
	FlameList.Flame.Length = -1
	FlameList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameNew(Flame ref as TFlame,ProtoFlame ref as TProtoFlame,World ref as TWorld,ObjectData as TObjectData,Position as TPosition,Angle as float,Radius as float,Now)
		
	Speed as TPosition
	
	Flame.Enabled = TRUE
	TimeSet(Flame.ObjectData.MoveTimer,10,10)
	TimeReset(Flame.ObjectData.MoveTimer,Now)
	
	TimeSet(Flame.EffectData.LifeCycleTimer,10,1)
	TimeReset(Flame.EffectData.LifeCycleTimer,Now)
	
	Flame.EffectData.LifeCycle = 0
	Flame.EffectData.LifeCycleMax = 25
	
	Flame.ObjectData.Position = Position
	CalcPosition(Flame.ObjectData.Position,Angle,Radius)
	
	Flame.ObjectData.MoveSpeedMax.x = 0
	Flame.ObjectData.MoveSpeedMax.y = 0
	
	Speed.x = 0
	Speed.y = 0
	CalcPosition(Speed,Angle,1)

	Flame.ObjectData.MoveSpeed.x = Speed.x + ObjectData.AutoSpeed.x
	Flame.ObjectData.MoveSpeed.y = Speed.y + ObjectData.AutoSpeed.y
	
	Flame.ObjectData.MoveAcceleration.x = 0.01
	Flame.ObjectData.MoveAcceleration.y = 0.01
	
	Flame.ObjectData.MoveAlignment.x = 0
	Flame.ObjectData.MoveAlignment.y = 0
	
	Flame.SpriteData.Angle = random(0,359)
	Flame.SpriteData.Center = TRUE
	Flame.SpriteData.Scale = 0.15
		
	ColorSet(Flame.SpriteData.Color,0,255,0,255)
	
	Flame.ObjectData.Size.Width = GetImageWidth(ProtoFlame.AnimFlame.Image.ID)*Flame.SpriteData.Scale
	Flame.ObjectData.Size.Height = GetImageHeight(ProtoFlame.AnimFlame.Image.ID)*Flame.SpriteData.Scale

	if Flame.ObjectData.Size.Width > Flame.ObjectData.Size.Height
		Flame.ObjectData.Radius = Flame.ObjectData.Size.Width * 0.5
	else
		Flame.ObjectData.Radius = Flame.ObjectData.Size.Height * 0.5
	endif
	
	SpritePositionCalc(Flame.SpriteData.Position,Flame.ObjectData.Position,World.Position)
	
	Flame.BulletData.BulletType = 1
	Flame.BulletData.Damage = 5
	
	Flame.CollisionData.Position1.x = Flame.ObjectData.Position.x - Flame.ObjectData.Size.Width  * 0.5
	Flame.CollisionData.Position1.y = Flame.ObjectData.Position.y - Flame.ObjectData.Size.Height * 0.5
	Flame.CollisionData.Position2.x = Flame.ObjectData.Position.x + Flame.ObjectData.Size.Width  * 0.5
	Flame.CollisionData.Position2.y = Flame.ObjectData.Position.y + Flame.ObjectData.Size.Height * 0.5
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameAdd(FlameList ref as TFlameList,ProtoFlame ref as TProtoFlame,World ref as TWorld,ObjectData as TObjectData,Position as TPosition,Angle as float,Radius as float,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Flame as TFlame
	
	Value = FALSE
	
	if TimeGet(FlameList.CreateTimer,Now) > 0
		
		FlameNew(Flame,ProtoFlame,World,ObjectData,Position,Angle,Radius,Now)
		
		Found = FALSE
		i = FlameList.FirstFree
		while Found = FALSE and i <= FlameList.Flame.Length
			if FlameList.Flame[i].Enabled = FALSE
				Found = TRUE
			else
				i = i+1
			endif
		endwhile
		
		if Found = FALSE
			FlameList.Flame.Insert(Flame)
			FlameList.FirstFree = FlameList.Flame.Length
		else
			FlameList.Flame[i] = Flame
			FlameList.FirstFree = i+1
		endif
		
		Value = TRUE
		
		TimeReset(FlameList.CreateTimer,Now)
	
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameDelete(FlameList ref as TFlameList,Index as integer)
	
	FlameList.Flame[Index].Enabled = FALSE
	if FlameList.FirstFree > Index
		FlameList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameCollide(FlameList ref as TFlameList,Sonec ref as TSonec)
	
	local i as integer
	local Radius as float
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			Radius = CalcRadius(FlameList.Flame[i].ObjectData.Position,Sonec.ObjectData.Position)
			if Radius < Sonec.ObjectData.Radius
				Sonec.Health.State = Sonec.Health.State - FlameList.Flame[i].BulletData.Damage
				FlameDelete(FlameList,i)
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameCollideOrbs(FlameList ref as TFlameList,OrbList ref as TOrbList)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			for k = 0 to OrbList.Orb.Length
				if OrbList.Orb[k].Enabled = TRUE
					Radius = CalcRadius(FlameList.Flame[i].ObjectData.Position,OrbList.Orb[k].ObjectData.Position)
					if Radius < FlameList.Flame[i].ObjectData.Radius + OrbList.Orb[k].ObjectData.Radius
						OrbList.Orb[k].Health.State = OrbList.Orb[k].Health.State - FlameList.Flame[i].BulletData.Damage
						FlameDelete(FlameList,i)
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

function FlameCollideMine(FlameList ref as TFlameList,MineList ref as TMineList)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			for k = 0 to MineList.Mine.Length
				if MineList.Mine[k].Enabled = TRUE
					Radius = CalcRadius(FlameList.Flame[i].ObjectData.Position,MineList.Mine[k].ObjectData.Position)
					if Radius < FlameList.Flame[i].ObjectData.Radius + MineList.Mine[k].ObjectData.Radius
						MineList.Mine[k].Health.State = MineList.Mine[k].Health.State - FlameList.Flame[i].BulletData.Damage
						FlameDelete(FlameList,i)
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

function FlameCollideChest(FlameList ref as TFlameList,ChestList ref as TChestList)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			for k = 0 to ChestList.Chest.Length
				if ChestList.Chest[k].Enabled = TRUE
					if BoxInBox(FlameList.Flame[i].CollisionData.Position1,FlameList.Flame[i].CollisionData.Position2,ChestList.Chest[k].CollisionData.Position1,ChestList.Chest[k].CollisionData.Position2)
						ChestList.Chest[k].Health.State = ChestList.Chest[k].Health.State - FlameList.Flame[i].BulletData.Damage
						if random(0,7*FlameList.Flame[i].SpriteData.Scale) = 0 then FlameDelete(FlameList,i)
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

function FlameMove(Flame ref as TFlame,World ref as TWorld,Now as integer)

	if Flame.Enabled = TRUE
		if TimeGet(Flame.ObjectData.MoveTimer,Now) > 0
			
			Flame.ObjectData.Position.x = Flame.ObjectData.Position.x + Flame.ObjectData.MoveSpeed.x * Flame.ObjectData.MoveTimer.CalcRange
			Flame.ObjectData.Position.y = Flame.ObjectData.Position.y + Flame.ObjectData.MoveSpeed.y * Flame.ObjectData.MoveTimer.CalcRange
			
			if Flame.ObjectData.MoveSpeed.x > 0
				if Flame.ObjectData.MoveSpeed.x - Flame.ObjectData.MoveAcceleration.x >= 0
					Flame.ObjectData.MoveSpeed.x = Flame.ObjectData.MoveSpeed.x - Flame.ObjectData.MoveAcceleration.x
				else
					Flame.ObjectData.MoveSpeed.x = 0
				endif
			else
				if Flame.ObjectData.MoveSpeed.x < 0
					if Flame.ObjectData.MoveSpeed.x + Flame.ObjectData.MoveAcceleration.x <= 0
						Flame.ObjectData.MoveSpeed.x = Flame.ObjectData.MoveSpeed.x + Flame.ObjectData.MoveAcceleration.x
					else
						Flame.ObjectData.MoveSpeed.x = 0
					endif
				endif
			endif
			
			if Flame.ObjectData.MoveSpeed.y > 0
				if Flame.ObjectData.MoveSpeed.y - Flame.ObjectData.MoveAcceleration.y >= 0
					Flame.ObjectData.MoveSpeed.y = Flame.ObjectData.MoveSpeed.y - Flame.ObjectData.MoveAcceleration.y
				else
					Flame.ObjectData.MoveSpeed.y = 0
				endif
			else
				if Flame.ObjectData.MoveSpeed.y < 0
					if Flame.ObjectData.MoveSpeed.y + Flame.ObjectData.MoveAcceleration.y <= 0
						Flame.ObjectData.MoveSpeed.y = Flame.ObjectData.MoveSpeed.y + Flame.ObjectData.MoveAcceleration.y
					else
						Flame.ObjectData.MoveSpeed.y = 0
					endif
				endif
			endif
			
			SpritePositionCalc(Flame.SpriteData.Position,Flame.ObjectData.Position,World.Position)
			
			Flame.CollisionData.Position1.x = Flame.ObjectData.Position.x - (Flame.ObjectData.Size.Width  * Flame.SpriteData.Scale * 0.5)
			Flame.CollisionData.Position1.y = Flame.ObjectData.Position.y - (Flame.ObjectData.Size.Height * Flame.SpriteData.Scale * 0.5)
			Flame.CollisionData.Position2.x = Flame.ObjectData.Position.x + (Flame.ObjectData.Size.Width  * Flame.SpriteData.Scale * 0.5)
			Flame.CollisionData.Position2.y = Flame.ObjectData.Position.y + (Flame.ObjectData.Size.Height * Flame.SpriteData.Scale * 0.5)
			
			TimeReset(Flame.ObjectData.MoveTimer,Now)
			
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameMoveAll(FlameList ref as TFlameList,World ref as TWorld,Now as integer)

	Local i as integer
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			FlameMove(FlameList.Flame[i],World,Now)
			if FlameList.Flame[i].ObjectData.Position.y < -FlameList.Flame[i].ObjectData.Size.Height
				FlameDelete(FlameList,i)
			else
				if FlameList.Flame[i].ObjectData.Position.y > World.Size.Height+FlameList.Flame[i].ObjectData.Size.Height
					FlameDelete(FlameList,i)
				else
					if FlameList.Flame[i].ObjectData.Position.x > World.Size.Width+FlameList.Flame[i].ObjectData.Size.Width
						FlameDelete(FlameList,i)
					else
						if FlameList.Flame[i].ObjectData.Position.x < -FlameList.Flame[i].ObjectData.Size.Width
							FlameDelete(FlameList,i)
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

function FlameLifeCycle(FlameList ref as TFlameList,Now as integer)
	
	local i as integer
	
	for i = 0 to FlameList.Flame.Length
		
		if FlameList.Flame[i].Enabled = TRUE
			if FlameList.Flame[i].EffectData.LifeCycle < FlameList.Flame[i].EffectData.LifeCycleMax
				if TimeGet(FlameList.Flame[i].EffectData.LifeCycleTimer,Now) > 0
					FlameList.Flame[i].EffectData.LifeCycle = FlameList.Flame[i].EffectData.LifeCycle +1
					
					FlameList.Flame[i].SpriteData.Scale = 0.15+0.85*sqrt(FlameList.Flame[i].EffectData.LifeCycle)/sqrt(FlameList.Flame[i].EffectData.LifeCycleMax)
					
					ColorSet(FlameList.Flame[i].SpriteData.Color,0,255,0,255-200*FlameList.Flame[i].EffectData.LifeCycle/FlameList.Flame[i].EffectData.LifeCycleMax)
					TimeReset(FlameList.Flame[i].EffectData.LifeCycleTimer,Now)
				endif
			else
				FlameDelete(FlameList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameDraw(Flame ref as TFlame,ProtoFlame ref as TProtoFlame)
	
	if Flame.Enabled = TRUE
		SpriteDraw(ProtoFlame.AnimFlame.Sprite,Flame.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameDrawAll(FlameList ref as TFlameList,ProtoFlame ref as TProtoFlame)
	
	local i as integer
	
	for i = 0 to FlameList.Flame.Length
		FlameDraw(FlameList.Flame[i],ProtoFlame)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function FlameCountAll(FlameList ref as TFlameList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to FlameList.Flame.Length
		if FlameList.Flame[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------


