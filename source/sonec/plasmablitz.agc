
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoPlasmaBlitzLoad(ProtoPlasmaBlitz ref as TProtoPlasmaBlitz,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoPlasmaBlitz.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoPlasmaBlitz.AnimPlasmaBlitz.Image) = TRUE
			SpriteLoad(ProtoPlasmaBlitz.AnimPlasmaBlitz)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzInit(PlasmaBlitzList ref as TPlasmaBlitzList)
	
	PlasmaBlitzList.PlasmaBlitz.Length = -1
	PlasmaBlitzList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzNew(PlasmaBlitz ref as TPlasmaBlitz,ProtoPlasmaBlitz ref as TProtoPlasmaBlitz,World ref as TWorld,Position as TPosition,Angle as float,Radius as float,Now)
	
	Speed as TPosition
	
	PlasmaBlitz.Enabled = TRUE
	TimeSet(PlasmaBlitz.ObjectData.MoveTimer,10,10)
	TimeReset(PlasmaBlitz.ObjectData.MoveTimer,Now)
	TimeSet(PlasmaBlitz.EffectData.LifeCycleTimer,10,1)
	TimeReset(PlasmaBlitz.EffectData.LifeCycleTimer,Now)
	
	PlasmaBlitz.ObjectData.Angle = Angle
	
	PlasmaBlitz.SpriteData.Angle = Angle
	PlasmaBlitz.SpriteData.Center = TRUE
	PlasmaBlitz.SpriteData.Scale = 1
		
	ColorSet(PlasmaBlitz.SpriteData.Color,55,255,200,100)
	
	PlasmaBlitz.ObjectData.Size.Width = GetImageWidth(ProtoPlasmaBlitz.AnimPlasmaBlitz.Image.ID)*PlasmaBlitz.SpriteData.Scale
	PlasmaBlitz.ObjectData.Size.Height = GetImageHeight(ProtoPlasmaBlitz.AnimPlasmaBlitz.Image.ID)*PlasmaBlitz.SpriteData.Scale

	if PlasmaBlitz.ObjectData.Size.Width > PlasmaBlitz.ObjectData.Size.Height
		PlasmaBlitz.ObjectData.Radius = PlasmaBlitz.ObjectData.Size.Width * 0.5
	else
		PlasmaBlitz.ObjectData.Radius = PlasmaBlitz.ObjectData.Size.Height * 0.5
	endif
	
	PlasmaBlitz.ObjectData.Position = Position
	CalcPosition(PlasmaBlitz.ObjectData.Position,Angle,Radius+PlasmaBlitz.ObjectData.Size.Height*0.5)
	
	PlasmaBlitz.ObjectData.MoveSpeedMax.x = 0
	PlasmaBlitz.ObjectData.MoveSpeedMax.y = 0

	PlasmaBlitz.ObjectData.MoveSpeed.x = 0
	PlasmaBlitz.ObjectData.MoveSpeed.y = 0
	
	PlasmaBlitz.ObjectData.MoveAcceleration.x = 0
	PlasmaBlitz.ObjectData.MoveAcceleration.y = 0
	
	PlasmaBlitz.ObjectData.MoveAlignment.x = 0
	PlasmaBlitz.ObjectData.MoveAlignment.y = 0
	
	SpritePositionCalc(PlasmaBlitz.SpriteData.Position,PlasmaBlitz.ObjectData.Position,World.Position)
	
	PlasmaBlitz.EffectData.LifeCycle = 0
	PlasmaBlitz.EffectData.LifeCycleMax = 25
	
	PlasmaBlitz.BulletData.BulletType = 1
	PlasmaBlitz.BulletData.Damage = 10
	
	PlasmaBlitz.CollisionData.Position1.x = PlasmaBlitz.ObjectData.Position.x - PlasmaBlitz.ObjectData.Size.Height * 0.5
	PlasmaBlitz.CollisionData.Position1.y = PlasmaBlitz.ObjectData.Position.y - PlasmaBlitz.ObjectData.Size.Width  * 0.5
	PlasmaBlitz.CollisionData.Position2.x = PlasmaBlitz.ObjectData.Position.x + PlasmaBlitz.ObjectData.Size.Height * 0.5
	PlasmaBlitz.CollisionData.Position2.y = PlasmaBlitz.ObjectData.Position.y + PlasmaBlitz.ObjectData.Size.Width  * 0.5
	
	TimeSet(PlasmaBlitz.CollisionData.CollisionTimer,50,1)
	TimeReset(PlasmaBlitz.CollisionData.CollisionTimer,Now)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzAdd(PlasmaBlitzList ref as TPlasmaBlitzList,ProtoPlasmaBlitz ref as TProtoPlasmaBlitz,World ref as TWorld,Position as TPosition,Angle as float,Radius as float,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local PlasmaBlitz as TPlasmaBlitz
		
	PlasmaBlitzNew(PlasmaBlitz,ProtoPlasmaBlitz,World,Position,Angle,Radius,Now)
	
	Value = -1
	Found = FALSE
	i = PlasmaBlitzList.FirstFree
	while Found = FALSE and i <= PlasmaBlitzList.PlasmaBlitz.Length
		if PlasmaBlitzList.PlasmaBlitz[i].Enabled = FALSE
			Found = TRUE
		else
			i = i+1
		endif
	endwhile
	
	if Found = FALSE
		PlasmaBlitzList.PlasmaBlitz.Insert(PlasmaBlitz)
		PlasmaBlitzList.FirstFree = PlasmaBlitzList.PlasmaBlitz.Length
		Value = PlasmaBlitzList.PlasmaBlitz.Length
	else
		PlasmaBlitzList.PlasmaBlitz[i] = PlasmaBlitz
		PlasmaBlitzList.FirstFree = i+1
		Value = i
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzDelete(PlasmaBlitzList ref as TPlasmaBlitzList,Index as integer)
	
	PlasmaBlitzList.PlasmaBlitz[Index].Enabled = FALSE
	if PlasmaBlitzList.FirstFree > Index
		PlasmaBlitzList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzRefresh(PlasmaBlitzList ref as TPlasmaBlitzList,PlasmaBlitzIndex as integer,Position as TPosition,Angle as float,World ref as TWorld)

	local i as integer
	local Radius as float

	if PlasmaBlitzIndex >= 0
		
		i = PlasmaBlitzIndex
		
		PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Angle = Angle
		PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position = Position
		
		Radius = PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Size.Height * 0.5 + 25

		CalcPosition(PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position,PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Angle,Radius)
		
		PlasmaBlitzList.PlasmaBlitz[i].SpriteData.Angle = Angle
		SpritePositionCalc(PlasmaBlitzList.PlasmaBlitz[i].SpriteData.Position,PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position,World.Position)
		
		PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position1.x = PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position.x - PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Size.Height * 0.5
		PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position1.y = PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position.y - PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Size.Width  * 0.5
		PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position2.x = PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position.x + PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Size.Height * 0.5
		PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position2.y = PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position.y + PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Size.Width  * 0.5
	
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzLifeCycle(PlasmaBlitzList ref as TPlasmaBlitzList,Now as integer)
	
	local i as integer
	local Alpha as integer
	
	for i = 0 to PlasmaBlitzList.PlasmaBlitz.Length
		
		if PlasmaBlitzList.PlasmaBlitz[i].Enabled = TRUE
			if PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycle < PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycleMax
				if TimeGet(PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycleTimer,Now) > 0
					PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycle = PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycle +1
					if PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycle < PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycleMax/2
						Alpha = 100+Floor(100*(PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycle)/PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycleMax)
					else
						Alpha = 100+Floor(100*(PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycleMax-PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycle)/PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycleMax)
					endif
					ColorSet(PlasmaBlitzList.PlasmaBlitz[i].SpriteData.Color,55,255,200,Alpha)
					TimeReset(PlasmaBlitzList.PlasmaBlitz[i].EffectData.LifeCycleTimer,Now)
				endif
			else
				PlasmaBlitzDelete(PlasmaBlitzList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzCollide(PlasmaBlitzList ref as TPlasmaBlitzList,Sonec ref as TSonec)
	
	local i as integer
	local Radius as float
	
	for i = 0 to PlasmaBlitzList.PlasmaBlitz.Length
		if PlasmaBlitzList.PlasmaBlitz[i].Enabled = TRUE
			Radius = CalcRadius(PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position,Sonec.ObjectData.Position)
			if Radius < 15
				Sonec.Health.State = Sonec.Health.State - PlasmaBlitzList.PlasmaBlitz[i].BulletData.Damage
				//PlasmaBlitzDelete(PlasmaBlitzList,i)
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzCollideOrbs(PlasmaBlitzList ref as TPlasmaBlitzList,OrbList ref as TOrbList,Now as integer)
	
	local i as integer
	local k as integer
	local Radius as float
	
	for i = 0 to PlasmaBlitzList.PlasmaBlitz.Length
		if PlasmaBlitzList.PlasmaBlitz[i].Enabled = TRUE
			if TimeGet(PlasmaBlitzList.PlasmaBlitz[i].CollisionData.CollisionTimer,Now) > 0
				for k = 0 to OrbList.Orb.Length
					if OrbList.Orb[k].Enabled = TRUE
						//Radius = CalcRadius(PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position,OrbList.Orb[k].ObjectData.Position)
						//if Radius < OrbList.Orb[k].ObjectData.Radius
							if BoxInBox(PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position1,PlasmaBlitzList.PlasmaBlitz[i].CollisionData.Position2,OrbList.Orb[k].CollisionData.Position1,OrbList.Orb[k].CollisionData.Position2)
								OrbList.Orb[k].Health.State = OrbList.Orb[k].Health.State - PlasmaBlitzList.PlasmaBlitz[i].BulletData.Damage
								//PlasmaBlitzDelete(PlasmaBlitzList,i)
								ColorSet(OrbList.Orb[k].SpriteData.Color,255,0,0,255)
							endif
						//endif
					endif
				next k
				TimeReset(PlasmaBlitzList.PlasmaBlitz[i].CollisionData.CollisionTimer,Now)
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzCollideMine(PlasmaBlitzList ref as TPlasmaBlitzList,MineList ref as TMineList)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzCollideChest(PlasmaBlitzList ref as TPlasmaBlitzList,ChestList ref as TChestList)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------
/*
function PlasmaBlitzMove(PlasmaBlitz ref as TPlasmaBlitz,World ref as TWorld,Now as integer)

	if PlasmaBlitz.Enabled = TRUE
		if TimeGet(PlasmaBlitz.ObjectData.MoveTimer,Now) > 0
			
			PlasmaBlitz.ObjectData.Position.x = PlasmaBlitz.ObjectData.Position.x + PlasmaBlitz.ObjectData.MoveSpeed.x * PlasmaBlitz.ObjectData.MoveTimer.CalcRange
			PlasmaBlitz.ObjectData.Position.y = PlasmaBlitz.ObjectData.Position.y + PlasmaBlitz.ObjectData.MoveSpeed.y * PlasmaBlitz.ObjectData.MoveTimer.CalcRange
			
			SpritePositionCalc(PlasmaBlitz.SpriteData.Position,PlasmaBlitz.ObjectData.Position,World.Position)
			
			TimeReset(PlasmaBlitz.ObjectData.MoveTimer,Now)
			
		endif
	endif

endfunction
*/
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------
/*
function PlasmaBlitzMoveAll(PlasmaBlitzList ref as TPlasmaBlitzList,World ref as TWorld,Now as integer)

	Local i as integer
	
	for i = 0 to PlasmaBlitzList.PlasmaBlitz.Length
		if PlasmaBlitzList.PlasmaBlitz[i].Enabled = TRUE
			PlasmaBlitzMove(PlasmaBlitzList.PlasmaBlitz[i],World,Now)
			if PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position.y < -PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Size.Height
				PlasmaBlitzDelete(PlasmaBlitzList,i)
			else
				if PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position.y > World.Size.Height+PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Size.Height
					PlasmaBlitzDelete(PlasmaBlitzList,i)
				else
					if PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position.x > World.Size.Width+PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Size.Width
						PlasmaBlitzDelete(PlasmaBlitzList,i)
					else
						if PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Position.x < -PlasmaBlitzList.PlasmaBlitz[i].ObjectData.Size.Width
							PlasmaBlitzDelete(PlasmaBlitzList,i)
						endif
					endif
				endif
			endif
		endif
	next i
	
endfunction
*/
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzDraw(PlasmaBlitz ref as TPlasmaBlitz,ProtoPlasmaBlitz ref as TProtoPlasmaBlitz)

	if PlasmaBlitz.Enabled = TRUE
		SpriteDraw(ProtoPlasmaBlitz.AnimPlasmaBlitz.Sprite,PlasmaBlitz.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzDrawAll(PlasmaBlitzList ref as TPlasmaBlitzList,ProtoPlasmaBlitz ref as TProtoPlasmaBlitz)
	
	local i as integer
	
	for i = 0 to PlasmaBlitzList.PlasmaBlitz.Length
		PlasmaBlitzDraw(PlasmaBlitzList.PlasmaBlitz[i],ProtoPlasmaBlitz)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlasmaBlitzCountAll(PlasmaBlitzList ref as TPlasmaBlitzList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to PlasmaBlitzList.PlasmaBlitz.Length
		if PlasmaBlitzList.PlasmaBlitz[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------







