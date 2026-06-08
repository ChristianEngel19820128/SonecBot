
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoWalkerLoad(ProtoWalker ref as TProtoWalker,File as TFilePath)
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoWalker.FromJson(ReadFileString(File))

		SpriteRadiusCalc(ProtoWalker.AnimLeft.Tower)
		SpriteRadiusCalc(ProtoWalker.AnimLeft.Corpus)
		SpriteRadiusCalc(ProtoWalker.AnimLeft.Thigh)
		SpriteRadiusCalc(ProtoWalker.AnimLeft.Shank)
		SpriteRadiusCalc(ProtoWalker.AnimLeft.Socket)
		
		SpriteRadiusCalc(ProtoWalker.AnimRight.Tower)
		SpriteRadiusCalc(ProtoWalker.AnimRight.Corpus)
		SpriteRadiusCalc(ProtoWalker.AnimRight.Thigh)
		SpriteRadiusCalc(ProtoWalker.AnimRight.Shank)
		SpriteRadiusCalc(ProtoWalker.AnimRight.Socket)
		
		if ImageLoad(ProtoWalker.AnimLeft.Tower.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimLeft.Tower)
		endif
		
		if ImageLoad(ProtoWalker.AnimLeft.Corpus.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimLeft.Corpus)
		endif
		
		if ImageLoad(ProtoWalker.AnimLeft.Thigh.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimLeft.Thigh)
		endif
		
		if ImageLoad(ProtoWalker.AnimLeft.Shank.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimLeft.Shank)
		endif
		
		if ImageLoad(ProtoWalker.AnimLeft.Socket.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimLeft.Socket)
		endif

		if ImageLoad(ProtoWalker.AnimRight.Tower.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimRight.Tower)
		endif
		
		if ImageLoad(ProtoWalker.AnimRight.Corpus.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimRight.Corpus)
		endif
		
		if ImageLoad(ProtoWalker.AnimRight.Thigh.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimRight.Thigh)
		endif
		
		if ImageLoad(ProtoWalker.AnimRight.Shank.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimRight.Shank)
		endif
		
		if ImageLoad(ProtoWalker.AnimRight.Socket.Image) = TRUE
			SpriteLoad(ProtoWalker.AnimRight.Socket)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerInit(WalkerList ref as TWalkerList)
	
	TimeSet(WalkerList.CreateTimer,1000,1)
	WalkerList.Walker.Length = -1
	WalkerList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerPartCalculate(State ref as TObjectState,AnchorProto ref as TProtoData,Anchor ref as TObjectData,ProtoData ref as TProtoData,ObjectData ref as TObjectData,SpriteData ref as TSpriteData,World ref as TWorld)
	
	ObjectData.Position = Anchor.AnchorPosition
	ObjectData.AnchorPosition = Anchor.AnchorPosition
	
	ObjectData.Rotation = NormalizeAngle(ObjectData.Rotation)
	//ObjectData.Angle = NormalizeAngle(ObjectData.Angle)
	//ObjectData.Radius= ProtoData.Radius

	if AnchorProto.Radius <> 0
		//CalcPosition(ObjectData.Position,NormalizeAngle(AnchorProto.Rotation),AnchorProto.Radius)
	endif
	
	if ProtoData.Radius <> 0
		CalcPosition(ObjectData.AnchorPosition,NormalizeAngle(ProtoData.Angle+ObjectData.Rotation),ProtoData.Radius)
	endif
	
	
	ObjectData.Size.Width = GetImageWidth(ProtoData.Image.ID)
	ObjectData.Size.Height = GetImageHeight(ProtoData.Image.ID)
	
	SpriteData.Center = TRUE
	SpriteData.OffsetOn = TRUE
	SpriteData.Offset.x = ProtoData.Offset.x
	SpriteData.Offset.y = ProtoData.Offset.y
	SpriteData.Scale  = 1
	
	ColorSet(SpriteData.Color,255,255,255,255)
	
	SpriteAngleCalc(SpriteData,ObjectData)
	SpritePositionCalc(SpriteData.Position,ObjectData.Position,World.Position)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerPartsCalculate(Walker ref as TWalker,ProtoWalker ref as TProtoWalker,World ref as TWorld)
	
	Walker.WalkerObjectData.Tower.Position       = Walker.ObjectData.Position
	Walker.WalkerObjectData.Tower.AnchorPosition = Walker.ObjectData.Position
	
	if Walker.State.LookAlignment = LOOKLEFT
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimLeft.Tower,Walker.WalkerObjectData.Tower,ProtoWalker.AnimLeft.Tower,Walker.WalkerObjectData.Tower,Walker.WalkerSpriteData.Tower,World)
	else
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimRight.Tower,Walker.WalkerObjectData.Tower,ProtoWalker.AnimRight.Tower,Walker.WalkerObjectData.Tower,Walker.WalkerSpriteData.Tower,World)
	endif
	
	if Walker.State.Alignment = MOVELEFT
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimLeft.Tower,Walker.WalkerObjectData.Tower,ProtoWalker.AnimLeft.Corpus,Walker.WalkerObjectData.Corpus,Walker.WalkerSpriteData.Corpus,World)
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimLeft.Corpus,Walker.WalkerObjectData.Corpus,ProtoWalker.AnimLeft.Thigh,Walker.WalkerObjectData.Thigh,Walker.WalkerSpriteData.Thigh,World)
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimLeft.Thigh,Walker.WalkerObjectData.Thigh,ProtoWalker.AnimLeft.Shank,Walker.WalkerObjectData.Shank,Walker.WalkerSpriteData.Shank,World)
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimLeft.Shank,Walker.WalkerObjectData.Shank,ProtoWalker.AnimLeft.Socket,Walker.WalkerObjectData.Socket,Walker.WalkerSpriteData.Socket,World)
	else
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimRight.Tower,Walker.WalkerObjectData.Tower,  ProtoWalker.AnimRight.Corpus, Walker.WalkerObjectData.Corpus, Walker.WalkerSpriteData.Corpus, World)
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimRight.Corpus,Walker.WalkerObjectData.Corpus, ProtoWalker.AnimRight.Thigh,  Walker.WalkerObjectData.Thigh,  Walker.WalkerSpriteData.Thigh, World)
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimRight.Thigh,Walker.WalkerObjectData.Thigh,  ProtoWalker.AnimRight.Shank,  Walker.WalkerObjectData.Shank,  Walker.WalkerSpriteData.Shank, World)
		WalkerPartCalculate(Walker.State,ProtoWalker.AnimRight.Shank,Walker.WalkerObjectData.Shank,  ProtoWalker.AnimRight.Socket, Walker.WalkerObjectData.Socket, Walker.WalkerSpriteData.Socket, World)
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerNew(Walker ref as TWalker,ProtoWalker ref as TProtoWalker,World ref as TWorld,y as integer,Now as integer)
	
	Walker.Enabled = TRUE
	TimeSet(Walker.ObjectData.MoveTimer,10,10)
	TimeReset(Walker.ObjectData.MoveTimer,Now)
	
	Walker.ObjectData.MoveSpeed.x = random(35,100)*0.001
	Walker.ObjectData.MoveSpeed.y = random(25,50)*0.001
	
	//Walker.ObjectData.Size.Width =
	//Walker.ObjectData.Size.Height =
	
	if Walker.ObjectData.Size.Width > Walker.ObjectData.Size.Height
		Walker.ObjectData.Radius = Walker.ObjectData.Size.Width * 0.5
	else
		Walker.ObjectData.Radius = Walker.ObjectData.Size.Height * 0.5
	endif
	
	Walker.State.LookAlignment = LOOKLEFT
	Walker.State.Alignment = MOVELEFT
	
	Walker.ObjectData.Position.x = World.Size.Width + Walker.ObjectData.Size.Width*0.5
	Walker.ObjectData.Position.y = y
	
	if Walker.State.Alignment = MOVELEFT
		
		Walker.WalkerObjectData.Tower.Angle     = ProtoWalker.AnimLeft.Tower.Angle
		Walker.WalkerObjectData.Tower.Radius    = ProtoWalker.AnimLeft.Tower.Radius
		Walker.WalkerObjectData.Tower.Rotation  = ProtoWalker.AnimLeft.Tower.Rotation-90
		
		Walker.WalkerObjectData.Corpus.Angle    = ProtoWalker.AnimLeft.Corpus.Angle
		Walker.WalkerObjectData.Corpus.Radius   = ProtoWalker.AnimLeft.Corpus.Radius
		Walker.WalkerObjectData.Corpus.Rotation = ProtoWalker.AnimLeft.Corpus.Rotation-90
		
		Walker.WalkerObjectData.Thigh.Angle     = ProtoWalker.AnimLeft.Thigh.Angle
		Walker.WalkerObjectData.Thigh.Radius    = ProtoWalker.AnimLeft.Thigh.Radius
		Walker.WalkerObjectData.Thigh.Rotation  = ProtoWalker.AnimLeft.Thigh.Rotation-90
		
		Walker.WalkerObjectData.Shank.Angle     = ProtoWalker.AnimLeft.Shank.Angle
		Walker.WalkerObjectData.Shank.Radius    = ProtoWalker.AnimLeft.Shank.Radius
		Walker.WalkerObjectData.Shank.Rotation  = ProtoWalker.AnimLeft.Shank.Rotation-90
		
		Walker.WalkerObjectData.Socket.Angle    = ProtoWalker.AnimLeft.Socket.Angle
		Walker.WalkerObjectData.Socket.Radius   = ProtoWalker.AnimLeft.Socket.Radius
		Walker.WalkerObjectData.Socket.Rotation = ProtoWalker.AnimLeft.Socket.Rotation-90
		
	else
		
		Walker.WalkerObjectData.Tower.Angle     = ProtoWalker.AnimRight.Tower.Angle
		Walker.WalkerObjectData.Tower.Radius    = ProtoWalker.AnimRight.Tower.Radius
		Walker.WalkerObjectData.Tower.Rotation  = ProtoWalker.AnimRight.Tower.Rotation+90
		
		Walker.WalkerObjectData.Corpus.Angle    = ProtoWalker.AnimRight.Corpus.Angle
		Walker.WalkerObjectData.Corpus.Radius   = ProtoWalker.AnimRight.Corpus.Radius
		Walker.WalkerObjectData.Corpus.Rotation = ProtoWalker.AnimRight.Corpus.Rotation+90
		
		Walker.WalkerObjectData.Thigh.Angle     = ProtoWalker.AnimRight.Thigh.Angle
		Walker.WalkerObjectData.Thigh.Radius    = ProtoWalker.AnimRight.Thigh.Radius
		Walker.WalkerObjectData.Thigh.Rotation  = ProtoWalker.AnimRight.Thigh.Rotation+90
		
		Walker.WalkerObjectData.Shank.Angle     = ProtoWalker.AnimRight.Shank.Angle
		Walker.WalkerObjectData.Shank.Radius    = ProtoWalker.AnimRight.Shank.Radius
		Walker.WalkerObjectData.Shank.Rotation  = ProtoWalker.AnimRight.Shank.Rotation+90
		
		Walker.WalkerObjectData.Socket.Angle    = ProtoWalker.AnimRight.Socket.Angle
		Walker.WalkerObjectData.Socket.Radius   = ProtoWalker.AnimRight.Socket.Radius
		Walker.WalkerObjectData.Socket.Rotation = ProtoWalker.AnimRight.Socket.Rotation+90
		
	endif

	WalkerPartsCalculate(Walker,ProtoWalker,World)
	
	Walker.Health.StateMax = 25
	Walker.Health.State = 25
	Walker.Health.RegRate = 1000
	
	TimeSet(Walker.Health.RegenerationTimer,Walker.Health.RegRate,1)
	TimeReset(Walker.Health.RegenerationTimer,Now)
	
	Walker.CollisionData.Position1.x = Walker.ObjectData.Position.x - Walker.ObjectData.Size.Width  * 0.5
	Walker.CollisionData.Position1.y = Walker.ObjectData.Position.y - Walker.ObjectData.Size.Height * 0.5
	Walker.CollisionData.Position2.x = Walker.ObjectData.Position.x + Walker.ObjectData.Size.Width  * 0.5
	Walker.CollisionData.Position2.y = Walker.ObjectData.Position.y + Walker.ObjectData.Size.Height * 0.5
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerAdd(WalkerList ref as TWalkerList,ProtoWalker ref as TProtoWalker,World ref as TWorld,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Walker as TWalker
	local y as integer

	y = random(64,floor((World.Size.Height-64)/8))*8
	
	Value = -1
	
	if WalkerExists(WalkerList,World,y) = FALSE
	
		if TimeGet(WalkerList.CreateTimer,Now) > 0
			
			WalkerNew(Walker,ProtoWalker,World,y,Now)
			
			Found = FALSE
			i = WalkerList.FirstFree
			while Found = FALSE and i <= WalkerList.Walker.Length
				if WalkerList.Walker[i].Enabled = FALSE
					Found = TRUE
				else
					i = i+1
				endif
			endwhile
			
			if Found = FALSE
				WalkerList.Walker.Insert(Walker)
				WalkerList.FirstFree = WalkerList.Walker.Length
				Value = WalkerList.Walker.Length
			else
				WalkerList.Walker[i] = Walker
				WalkerList.FirstFree = i+1
				Value = i
			endif
		
			TimeReset(WalkerList.CreateTimer,Now)
			
		endif
	endif
	
endfunction Value


//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerExists(WalkerList ref as TWalkerList,World ref as TWorld,y as integer)
	
	local Value as integer
	local i as integer
	
	Value = FALSE
	
	for i = 0 to WalkerList.Walker.Length
		if WalkerList.Walker[i].Enabled = TRUE
			if WalkerList.Walker[i].ObjectData.Position.y > y - WalkerList.Walker[i].ObjectData.Size.Height*4
				if WalkerList.Walker[i].ObjectData.Position.y < y + WalkerList.Walker[i].ObjectData.Size.Height*4
					Value = TRUE
				endif
			endif
		endif
		
	next i
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerDelete(WalkerList ref as TWalkerList,Index as integer)
	
	WalkerList.Walker[Index].Enabled = FALSE
	if WalkerList.FirstFree > Index
		WalkerList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerDestroy(WalkerList ref as TWalkerList,Index as integer,ExplosionList ref as TExplosionList,ProtoExplosion ref as TProtoExplosion,Game ref as TGame,Position ref as TPosition,Now as integer)

	ExplosionAdd(ExplosionList,ProtoExplosion,Game,0,Position,Now)
	WalkerDelete(WalkerList,Index)

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerCheckAll(WalkerList ref as TWalkerList,ProtoWalker ref as TProtoWalker)
	
	local i as integer
	local px as float
	local pdx as float
	
	for i = 0 to WalkerList.Walker.Length
		
		if WalkerList.Walker[i].Enabled = TRUE
		
			px = WalkerList.Walker[i].ObjectData.Position.x
			pdx = WalkerList.Walker[i].ObjectData.Size.Width*0.5
				
			if px+pdx < 0
				WalkerDelete(WalkerList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerHealthRegenerate(WalkerList ref as TWalkerList,Game ref as TGame,Now as integer)
	
	local i as integer
	local k as integer
	local EnergieType as integer
	local Position as TPosition
	
	for i = 0 to WalkerList.Walker.Length
		if WalkerList.Walker[i].Enabled = TRUE
			if TimeGet(WalkerList.Walker[i].Health.RegenerationTimer,Now) > 0
				
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Corpus.Color,0,255,0,255)
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Shank.Color,0,255,0,255)
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Socket.Color,0,255,0,255)
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Thigh.Color,0,255,0,255)
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Tower.Color,0,255,0,255)
				
				if WalkerList.Walker[i].Health.State + REGHEALTH <= WalkerList.Walker[i].Health.StateMax
					WalkerList.Walker[i].Health.State = WalkerList.Walker[i].Health.State + REGHEALTH
				else
					if WalkerList.Walker[i].Health.State < WalkerList.Walker[i].Health.StateMax
						WalkerList.Walker[i].Health.State = WalkerList.Walker[i].Health.StateMax
					endif
				endif
				
				TimeReset(WalkerList.Walker[i].Health.RegenerationTimer,Now)
			
			endif
			
			if WalkerList.Walker[i].Health.State < 0
				
				for k = 0 to random(0,12)
					EnergieType = 0
					if random(0,8) > 5
						EnergieType = random(0,Game.ProtoEnergie.AnimEnergie.Length)
					endif
					Position.x = WalkerList.Walker[i].ObjectData.Position.x + random(0,20) - 10
					Position.y = WalkerList.Walker[i].ObjectData.Position.y + random(0,20) - 10
					EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,EnergieType,Position,Now)
				next k
				
				WalkerDestroy(WalkerList,i,Game.ExplosionList,Game.ProtoExplosion,Game,WalkerList.Walker[i].ObjectData.Position,Now)
			
			endif
			
		endif
	next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerMove(Walker ref as TWalker,ProtoWalker ref as TProtoWalker,World ref as TWorld,Now as integer)

	local x as float
	local y as float
	local sx as float
	local sy as float
	local r as float
	
	if Walker.Enabled = TRUE
		if TimeGet(Walker.ObjectData.MoveTimer,Now) > 0
			
			x = Walker.ObjectData.Position.x
			y = Walker.ObjectData.Position.y
			sx = Walker.ObjectData.MoveSpeed.x
			sy = Walker.ObjectData.MoveSpeed.y
			r = Walker.ObjectData.MoveTimer.CalcRange
			
			Walker.ObjectData.Position.x = x - sx*r
			
			WalkerPartsCalculate(Walker,ProtoWalker,World)
			
			Walker.CollisionData.Position1.x = Walker.ObjectData.Position.x - (Walker.ObjectData.Size.Width  * 0.5)
			Walker.CollisionData.Position1.y = Walker.ObjectData.Position.y - (Walker.ObjectData.Size.Height * 0.5)
			Walker.CollisionData.Position2.x = Walker.ObjectData.Position.x + (Walker.ObjectData.Size.Width  * 0.5)
			Walker.CollisionData.Position2.y = Walker.ObjectData.Position.y + (Walker.ObjectData.Size.Height * 0.5)
			
			TimeReset(Walker.ObjectData.MoveTimer,Now)
			
			/*
			Walker.WalkerSpriteData.Tower.Angle = Walker.WalkerSpriteData.Tower.Angle + 1
			if Walker.WalkerSpriteData.Tower.Angle > 360 then Walker.WalkerSpriteData.Tower.Angle = 0
			
			Walker.WalkerSpriteData.Corpus.Angle = Walker.WalkerSpriteData.Corpus.Angle + 2
			if Walker.WalkerSpriteData.Corpus.Angle > 360 then Walker.WalkerSpriteData.Corpus.Angle = 0
			
			Walker.WalkerSpriteData.Thigh.Angle = Walker.WalkerSpriteData.Thigh.Angle + 3
			if Walker.WalkerSpriteData.Thigh.Angle > 360 then Walker.WalkerSpriteData.Thigh.Angle = 0
			
			Walker.WalkerSpriteData.Shank.Angle = Walker.WalkerSpriteData.Shank.Angle + 4
			if Walker.WalkerSpriteData.Shank.Angle > 360 then Walker.WalkerSpriteData.Shank.Angle = 0
			
			Walker.WalkerSpriteData.Socket.Angle = Walker.WalkerSpriteData.Socket.Angle + 5
			if Walker.WalkerSpriteData.Socket.Angle > 360 then Walker.WalkerSpriteData.Socket.Angle = 0
			*/
		endif
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerMoveAll(WalkerList ref as TWalkerList,ProtoWalker ref as TProtoWalker,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to WalkerList.Walker.Length
		WalkerMove(WalkerList.Walker[i],ProtoWalker,World,Now)
		if WalkerList.Walker[i].ObjectData.Position.x + WalkerList.Walker[i].ObjectData.Size.Width < World.Position.x
			WalkerDelete(WalkerList,i)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerDraw(Walker ref as TWalker,ProtoWalker ref as TProtoWalker)
	
	if Walker.Enabled = TRUE
		
		
		if Walker.State.Alignment = MOVELEFT
			SpriteDraw(ProtoWalker.AnimLeft.Thigh.Sprite,Walker.WalkerSpriteData.Thigh)
			SpriteDraw(ProtoWalker.AnimLeft.Shank.Sprite,Walker.WalkerSpriteData.Shank)
			SpriteDraw(ProtoWalker.AnimLeft.Socket.Sprite,Walker.WalkerSpriteData.Socket)
			SpriteDraw(ProtoWalker.AnimLeft.Corpus.Sprite,Walker.WalkerSpriteData.Corpus)
		else
			SpriteDraw(ProtoWalker.AnimRight.Thigh.Sprite,Walker.WalkerSpriteData.Thigh)
			SpriteDraw(ProtoWalker.AnimRight.Shank.Sprite,Walker.WalkerSpriteData.Shank)
			SpriteDraw(ProtoWalker.AnimRight.Socket.Sprite,Walker.WalkerSpriteData.Socket)
			SpriteDraw(ProtoWalker.AnimRight.Corpus.Sprite,Walker.WalkerSpriteData.Corpus)
		endif
		
		if Walker.State.LookAlignment = LOOKLEFT then SpriteDraw(ProtoWalker.AnimLeft.Tower.Sprite,Walker.WalkerSpriteData.Tower)
		if Walker.State.LookAlignment = LOOKRIGHT then SpriteDraw(ProtoWalker.AnimRight.Tower.Sprite,Walker.WalkerSpriteData.Tower)

	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerDrawAll(WalkerList ref as TWalkerList,ProtoWalker ref as TProtoWalker)
	
	local i as integer
	
	for i = 0 to WalkerList.Walker.Length
		WalkerDraw(WalkerList.Walker[i],ProtoWalker)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerCountAll(WalkerList ref as TWalkerList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to WalkerList.Walker.Length
		if WalkerList.Walker[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------



