
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
	WalkerSkeletonInit()
	
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
	
	ColorSet(SpriteData.Color,0,255,0,255)
	
	SpriteAngleCalc(SpriteData,ObjectData)
	SpritePositionCalc(SpriteData.Position,ObjectData.Position,World.Position)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Configure leg artwork; IK owns joint positions and rotations.
function WalkerIKPartSetup(Proto ref as TProtoData,SpriteData ref as TSpriteData)
	SpriteData.Center = TRUE
	SpriteData.OffsetOn = TRUE
	SpriteData.Offset.x = Proto.Offset.x
	SpriteData.Offset.y = Proto.Offset.y
	SpriteData.Scale = 1
	ColorSet(SpriteData.Color,0,255,0,255)
endfunction

// Place a body part by either its local pivot (Offset) or its local connector
// (Anchor). Both points are unrotated image coordinates. No extra angle
// correction is applied here; use the same rotation as the rendered sprite.
function WalkerBodyPartAttach(Proto ref as TProtoData,ObjectData ref as TObjectData,SpriteData ref as TSpriteData,JointPosition as TPosition,AttachAtAnchor as integer,World ref as TWorld)
	local dx as float
	local dy as float
	local rx as float
	local ry as float
	local c as float
	local sn as float

	ObjectData.Rotation = NormalizeAngle(ObjectData.Rotation)
	dx = Proto.Anchor.x-Proto.Offset.x
	dy = Proto.Anchor.y-Proto.Offset.y
	c = Cos(ObjectData.Rotation)
	sn = Sin(ObjectData.Rotation)
	rx = dx*c-dy*sn
	ry = dx*sn+dy*c

	if AttachAtAnchor = TRUE
		ObjectData.AnchorPosition = JointPosition
		ObjectData.Position.x = JointPosition.x-rx
		ObjectData.Position.y = JointPosition.y-ry
	else
		ObjectData.Position = JointPosition
		ObjectData.AnchorPosition.x = JointPosition.x+rx
		ObjectData.AnchorPosition.y = JointPosition.y+ry
	endif

	ObjectData.Size.Width = GetImageWidth(Proto.Image.ID)
	ObjectData.Size.Height = GetImageHeight(Proto.Image.ID)
	WalkerIKPartSetup(Proto,SpriteData)
	SpriteAngleCalc(SpriteData,ObjectData)
	SpritePositionCalc(SpriteData.Position,ObjectData.Position,World.Position)
endfunction

function WalkerPartsCalculate(Walker ref as TWalker,ProtoWalker ref as TProtoWalker,World ref as TWorld)
	local i as integer

	// Walker.ObjectData.Position remains the IK hip. Attach the Corpus by
	// its Anchor, leaving all IK joints and platform-relative feet unchanged.
	if Walker.State.Alignment = MOVELEFT
		WalkerBodyPartAttach(ProtoWalker.AnimLeft.Corpus,Walker.WalkerObjectData.Corpus,Walker.WalkerSpriteData.Corpus,Walker.ObjectData.Position,TRUE,World)
	else
		WalkerBodyPartAttach(ProtoWalker.AnimRight.Corpus,Walker.WalkerObjectData.Corpus,Walker.WalkerSpriteData.Corpus,Walker.ObjectData.Position,TRUE,World)
	endif

	// The tower pivot docks at the Corpus pivot, not at the IK hip.
	// Update ObjectData as well as SpriteData so the turret hitbox follows.
	if Walker.State.LookAlignment = LOOKLEFT
		WalkerBodyPartAttach(ProtoWalker.AnimLeft.Tower,Walker.WalkerObjectData.Tower,Walker.WalkerSpriteData.Tower,Walker.WalkerObjectData.Corpus.Position,FALSE,World)
	else
		WalkerBodyPartAttach(ProtoWalker.AnimRight.Tower,Walker.WalkerObjectData.Tower,Walker.WalkerSpriteData.Tower,Walker.WalkerObjectData.Corpus.Position,FALSE,World)
	endif

	// Both legs share the same Proto setup; no legacy joint chain.
	for i = 0 to 1
		if Walker.State.Alignment = MOVELEFT
			WalkerIKPartSetup(ProtoWalker.AnimLeft.Thigh,Walker.WalkerSpriteData.Thigh[i])
			WalkerIKPartSetup(ProtoWalker.AnimLeft.Shank,Walker.WalkerSpriteData.Shank[i])
			WalkerIKPartSetup(ProtoWalker.AnimLeft.Socket,Walker.WalkerSpriteData.Socket[i])
		else
			WalkerIKPartSetup(ProtoWalker.AnimRight.Thigh,Walker.WalkerSpriteData.Thigh[i])
			WalkerIKPartSetup(ProtoWalker.AnimRight.Shank,Walker.WalkerSpriteData.Shank[i])
			WalkerIKPartSetup(ProtoWalker.AnimRight.Socket,Walker.WalkerSpriteData.Socket[i])
		endif
	next i
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerNew(Walker ref as TWalker,ProtoWalker ref as TProtoWalker,World ref as TWorld,Plate ref as TPlate,PlateIndex as integer,Now as integer)
	
	Walker.Enabled = TRUE
	Walker.PlateIndex = PlateIndex
	TimeSet(Walker.ObjectData.MoveTimer,10,10)
	TimeReset(Walker.ObjectData.MoveTimer,Now)
	
	// Fixed slower test pace: compare foot contact and turns at a consistent speed.
	Walker.ObjectData.MoveSpeed.x = 0.05
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
	
	// Place the body anchor above the platform; feet offset can be tuned after visual testing.
	Walker.ObjectData.Position.x = Plate.ObjectData.Position.x + Plate.ObjectData.Size.Width*0.5
	Walker.ObjectData.Position.y = Plate.ObjectData.Position.y - 30
	Walker.PlateOffsetX = Walker.ObjectData.Position.x - Plate.ObjectData.Position.x
	Walker.PlateOffsetY = Walker.ObjectData.Position.y - Plate.ObjectData.Position.y
	Walker.WalkPhase = 0
	Walker.TurnPending = 0
	Walker.SkeletonFootX[0] = Walker.PlateOffsetX-10
	Walker.SkeletonFootX[1] = Walker.PlateOffsetX+10
	Walker.SkeletonSwing[0] = 0
	Walker.SkeletonSwing[1] = 0
	Walker.SkeletonFootY[0] = 0
	Walker.SkeletonFootY[1] = 0
	Walker.PauseUntilMs = 0
	Walker.NextPauseMs = Now + random(2500,5000)
	
	if Walker.State.LookAlignment = LOOKLEFT
		
		Walker.WalkerObjectData.Tower.Angle     = ProtoWalker.AnimLeft.Tower.Angle
		Walker.WalkerObjectData.Tower.Radius    = ProtoWalker.AnimLeft.Tower.Radius
		Walker.WalkerObjectData.Tower.Rotation  = ProtoWalker.AnimLeft.Tower.Rotation-90
		
	else
		
		Walker.WalkerObjectData.Tower.Angle     = ProtoWalker.AnimRight.Tower.Angle
		Walker.WalkerObjectData.Tower.Radius    = ProtoWalker.AnimRight.Tower.Radius
		Walker.WalkerObjectData.Tower.Rotation  = ProtoWalker.AnimRight.Tower.Rotation+90
		
	endif
	
	if Walker.State.Alignment = MOVELEFT
		
		Walker.WalkerObjectData.Corpus.Angle    = ProtoWalker.AnimLeft.Corpus.Angle
		Walker.WalkerObjectData.Corpus.Radius   = ProtoWalker.AnimLeft.Corpus.Radius
		Walker.WalkerObjectData.Corpus.Rotation = ProtoWalker.AnimLeft.Corpus.Rotation-90
		
		Walker.WalkerObjectData.Thigh[ELEMENTRIGHT].Angle     = ProtoWalker.AnimLeft.Thigh.Angle
		Walker.WalkerObjectData.Thigh[ELEMENTRIGHT].Radius    = ProtoWalker.AnimLeft.Thigh.Radius
		Walker.WalkerObjectData.Thigh[ELEMENTRIGHT].Rotation  = ProtoWalker.AnimLeft.Thigh.Rotation-90
		
		Walker.WalkerObjectData.Shank[ELEMENTRIGHT].Angle     = ProtoWalker.AnimLeft.Shank.Angle
		Walker.WalkerObjectData.Shank[ELEMENTRIGHT].Radius    = ProtoWalker.AnimLeft.Shank.Radius
		Walker.WalkerObjectData.Shank[ELEMENTRIGHT].Rotation  = ProtoWalker.AnimLeft.Shank.Rotation-90
		
		Walker.WalkerObjectData.Socket[ELEMENTRIGHT].Angle    = ProtoWalker.AnimLeft.Socket.Angle
		Walker.WalkerObjectData.Socket[ELEMENTRIGHT].Radius   = ProtoWalker.AnimLeft.Socket.Radius
		Walker.WalkerObjectData.Socket[ELEMENTRIGHT].Rotation = ProtoWalker.AnimLeft.Socket.Rotation-90
		
		Walker.WalkerObjectData.Thigh[ELEMENTLEFT].Angle     = ProtoWalker.AnimLeft.Thigh.Angle
		Walker.WalkerObjectData.Thigh[ELEMENTLEFT].Radius    = ProtoWalker.AnimLeft.Thigh.Radius
		Walker.WalkerObjectData.Thigh[ELEMENTLEFT].Rotation  = ProtoWalker.AnimLeft.Thigh.Rotation-90
		
		Walker.WalkerObjectData.Shank[ELEMENTLEFT].Angle     = ProtoWalker.AnimLeft.Shank.Angle
		Walker.WalkerObjectData.Shank[ELEMENTLEFT].Radius    = ProtoWalker.AnimLeft.Shank.Radius
		Walker.WalkerObjectData.Shank[ELEMENTLEFT].Rotation  = ProtoWalker.AnimLeft.Shank.Rotation-90
		
		Walker.WalkerObjectData.Socket[ELEMENTLEFT].Angle    = ProtoWalker.AnimLeft.Socket.Angle
		Walker.WalkerObjectData.Socket[ELEMENTLEFT].Radius   = ProtoWalker.AnimLeft.Socket.Radius
		Walker.WalkerObjectData.Socket[ELEMENTLEFT].Rotation = ProtoWalker.AnimLeft.Socket.Rotation-90
		
	else
		
		Walker.WalkerObjectData.Corpus.Angle    = ProtoWalker.AnimRight.Corpus.Angle
		Walker.WalkerObjectData.Corpus.Radius   = ProtoWalker.AnimRight.Corpus.Radius
		Walker.WalkerObjectData.Corpus.Rotation = ProtoWalker.AnimRight.Corpus.Rotation+90
		
		Walker.WalkerObjectData.Thigh[ELEMENTLEFT].Angle     = ProtoWalker.AnimRight.Thigh.Angle
		Walker.WalkerObjectData.Thigh[ELEMENTLEFT].Radius    = ProtoWalker.AnimRight.Thigh.Radius
		Walker.WalkerObjectData.Thigh[ELEMENTLEFT].Rotation  = ProtoWalker.AnimRight.Thigh.Rotation+90
		
		Walker.WalkerObjectData.Shank[ELEMENTLEFT].Angle     = ProtoWalker.AnimRight.Shank.Angle
		Walker.WalkerObjectData.Shank[ELEMENTLEFT].Radius    = ProtoWalker.AnimRight.Shank.Radius
		Walker.WalkerObjectData.Shank[ELEMENTLEFT].Rotation  = ProtoWalker.AnimRight.Shank.Rotation+90
		
		Walker.WalkerObjectData.Socket[ELEMENTLEFT].Angle    = ProtoWalker.AnimRight.Socket.Angle
		Walker.WalkerObjectData.Socket[ELEMENTLEFT].Radius   = ProtoWalker.AnimRight.Socket.Radius
		Walker.WalkerObjectData.Socket[ELEMENTLEFT].Rotation = ProtoWalker.AnimRight.Socket.Rotation+90
		
		Walker.WalkerObjectData.Thigh[ELEMENTRIGHT].Angle     = ProtoWalker.AnimRight.Thigh.Angle
		Walker.WalkerObjectData.Thigh[ELEMENTRIGHT].Radius    = ProtoWalker.AnimRight.Thigh.Radius
		Walker.WalkerObjectData.Thigh[ELEMENTRIGHT].Rotation  = ProtoWalker.AnimRight.Thigh.Rotation+90
		
		Walker.WalkerObjectData.Shank[ELEMENTRIGHT].Angle     = ProtoWalker.AnimRight.Shank.Angle
		Walker.WalkerObjectData.Shank[ELEMENTRIGHT].Radius    = ProtoWalker.AnimRight.Shank.Radius
		Walker.WalkerObjectData.Shank[ELEMENTRIGHT].Rotation  = ProtoWalker.AnimRight.Shank.Rotation+90
		
		Walker.WalkerObjectData.Socket[ELEMENTRIGHT].Angle    = ProtoWalker.AnimRight.Socket.Angle
		Walker.WalkerObjectData.Socket[ELEMENTRIGHT].Radius   = ProtoWalker.AnimRight.Socket.Radius
		Walker.WalkerObjectData.Socket[ELEMENTRIGHT].Rotation = ProtoWalker.AnimRight.Socket.Rotation+90
		
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

function WalkerAdd(WalkerList ref as TWalkerList,ProtoWalker ref as TProtoWalker,World ref as TWorld,Plate ref as TPlate,PlateIndex as integer,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Walker as TWalker
	local y as integer

	y = Plate.ObjectData.Position.y
	
	Value = -1
	
	if WalkerExists(WalkerList,World,y) = FALSE
	
		if TimeGet(WalkerList.CreateTimer,Now) > 0
			
			WalkerNew(Walker,ProtoWalker,World,Plate,PlateIndex,Now)
			
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
				
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Tower.Color,0,255,0,255)
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Corpus.Color,0,255,0,255)
				
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Shank[ELEMENTLEFT].Color,0,255,0,255)
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Thigh[ELEMENTLEFT].Color,0,255,0,255)
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Socket[ELEMENTLEFT].Color,0,255,0,255)
				
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Shank[ELEMENTRIGHT].Color,0,255,0,255)
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Thigh[ELEMENTRIGHT].Color,0,255,0,255)
				ColorSet(WalkerList.Walker[i].WalkerSpriteData.Socket[ELEMENTRIGHT].Color,0,255,0,255)
				
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

function WalkerAnimate(Walker ref as TWalker,ProtoWalker ref as TProtoWalker,World ref as TWorld,Now as integer)

	// Heavy gait follows distance travelled on the platform; no leg cycling while idle.
	
	// IK owns the final leg angles. Keep neutral Proto rotations for the
	// legacy part-position pass, without sine or fixed angle corrections.
	if Walker.State.LookAlignment = LOOKLEFT
		Walker.WalkerObjectData.Tower.Rotation  = ProtoWalker.AnimLeft.Tower.Rotation-90
	else
		Walker.WalkerObjectData.Tower.Rotation  = ProtoWalker.AnimRight.Tower.Rotation+90
	endif
	
	if Walker.State.Alignment = MOVELEFT
		
		Walker.WalkerObjectData.Corpus.Rotation = ProtoWalker.AnimLeft.Corpus.Rotation-90
		
		
		
	else

		Walker.WalkerObjectData.Corpus.Rotation = ProtoWalker.AnimRight.Corpus.Rotation+90


		
	endif

	WalkerPartsCalculate(Walker,ProtoWalker,World)
	WalkerTowerCollisionCalculate(Walker,ProtoWalker)
	if Walker.HitFlashUntil > Now
		ColorSet(Walker.WalkerSpriteData.Tower.Color,255,0,0,255)
	endif

endfunction


//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Calculate the turret hitbox from its rotated image and sprite offset.
function WalkerTowerCollisionCalculate(Walker ref as TWalker,ProtoWalker ref as TProtoWalker)
	local Offset as TPosition
	local Width as float
	local Height as float
	local CenterX as float
	local CenterY as float
	local HalfX as float
	local HalfY as float
	local c as float
	local sn as float

	if Walker.State.LookAlignment = LOOKLEFT
		Offset = ProtoWalker.AnimLeft.Tower.Offset
	else
		Offset = ProtoWalker.AnimRight.Tower.Offset
	endif

	Width = Walker.WalkerObjectData.Tower.Size.Width
	Height = Walker.WalkerObjectData.Tower.Size.Height
	c = cos(Walker.WalkerObjectData.Tower.Rotation)
	sn = sin(Walker.WalkerObjectData.Tower.Rotation)
	CenterX = Width*0.5 - Offset.x
	CenterY = Height*0.5 - Offset.y
	HalfX = Width*0.45
	HalfY = Height*0.45

	Walker.WalkerCollisionData.Tower.Position.x = Walker.WalkerObjectData.Tower.Position.x + CenterX*c - CenterY*sn
	Walker.WalkerCollisionData.Tower.Position.y = Walker.WalkerObjectData.Tower.Position.y + CenterX*sn + CenterY*c
	Walker.WalkerCollisionData.Tower.Position1.x = Walker.WalkerCollisionData.Tower.Position.x - abs(HalfX*c) - abs(HalfY*sn)
	Walker.WalkerCollisionData.Tower.Position1.y = Walker.WalkerCollisionData.Tower.Position.y - abs(HalfX*sn) - abs(HalfY*c)
	Walker.WalkerCollisionData.Tower.Position2.x = Walker.WalkerCollisionData.Tower.Position.x + abs(HalfX*c) + abs(HalfY*sn)
	Walker.WalkerCollisionData.Tower.Position2.y = Walker.WalkerCollisionData.Tower.Position.y + abs(HalfX*sn) + abs(HalfY*c)
endfunction

function WalkerAnimateAll(WalkerList ref as TWalkerList,ProtoWalker ref as TProtoWalker,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to WalkerList.Walker.Length
		if WalkerList.Walker[i].Enabled = TRUE then WalkerAnimate(WalkerList.Walker[i],ProtoWalker,World,Now)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Temporary stand-pose diagnostic: set to 0 to restore walking.
// Keep the original IK geometry and Proto transforms unchanged.
#constant WALKER_STAND_POSE_TEST 0
// Walking distance per half-cycle: 180 / 12 = 15 platform pixels.
// The planted foot can stay fixed without exceeding the ~41 px leg reach.
#constant WALKER_GAIT_DEGREES_PER_PIXEL 12.0
#constant WALKER_GAIT_FORWARD_OFFSET 12.0
// Visual foot sole lies below the Proto.Socket pivot; lift joint, not platform.
// Keep both the rendered IK and diagnostic skeleton on exactly this target.
#constant WALKER_FOOT_JOINT_LIFT 8.0

// Update foot targets in platform-relative coordinates, never during drawing.
function WalkerSkeletonUpdate(Walker ref as TWalker,Moving as integer)
	local i as integer
	local progress as float
	local t as float
	local forward as float
	local StanceOffset as float
	local StandTargetX as float
	local SettleBlend as float
	// Use elapsed frame time for a gentle, frame-rate-independent return to stance.
	SettleBlend = GetFrameTime()*8.0
	if SettleBlend > 1 then SettleBlend = 1
	for i = 0 to 1
		if WALKER_STAND_POSE_TEST = 1
			Walker.SkeletonSwing[i] = 0
			Walker.SkeletonFootY[i] = 0
			if i = 0
				Walker.SkeletonFootX[i] = Walker.PlateOffsetX-10
			else
				Walker.SkeletonFootX[i] = Walker.PlateOffsetX+10
			endif
		else
		// Return both feet smoothly to their own stance targets when stopped.
		if Moving = 0
			Walker.SkeletonSwing[i] = 0
			StandTargetX = Walker.PlateOffsetX-10
			if i = 1 then StandTargetX = Walker.PlateOffsetX+10
			Walker.SkeletonFootX[i] = Walker.SkeletonFootX[i]+(StandTargetX-Walker.SkeletonFootX[i])*SettleBlend
			Walker.SkeletonFootY[i] = Walker.SkeletonFootY[i]*(1.0-SettleBlend)
			if abs(StandTargetX-Walker.SkeletonFootX[i]) < 0.1 then Walker.SkeletonFootX[i] = StandTargetX
			if abs(Walker.SkeletonFootY[i]) < 0.1 then Walker.SkeletonFootY[i] = 0
		else
		progress = mod(Walker.WalkPhase+i*180,360)
		if progress < 180
			if Walker.SkeletonSwing[i] = 0
				Walker.SkeletonSwing[i] = 1
				Walker.SkeletonFootStartX[i] = Walker.SkeletonFootX[i]
				// Aim ahead of the expected touchdown. The body advances by
				// 180 / WALKER_GAIT_DEGREES_PER_PIXEL pixels during this swing.
				forward = WALKER_GAIT_FORWARD_OFFSET + 180.0/WALKER_GAIT_DEGREES_PER_PIXEL
				if Walker.State.Alignment = MOVELEFT then forward = -forward
				// Keep the original left/right foot separation during each step.
				StanceOffset = -10
				if i = 1 then StanceOffset = 10
				Walker.SkeletonFootTargetX[i] = Walker.PlateOffsetX+StanceOffset+forward
			endif
			t = progress/180.0
			// Smooth acceleration and deceleration at touchdown.
			t = t*t*(3-2*t)
			Walker.SkeletonFootX[i] = Walker.SkeletonFootStartX[i]+(Walker.SkeletonFootTargetX[i]-Walker.SkeletonFootStartX[i])*t
			Walker.SkeletonFootY[i] = -sin(progress)*7
		else
			// Stance phase: foot X stays planted in platform coordinates.
			Walker.SkeletonSwing[i] = 0
			Walker.SkeletonFootY[i] = 0
		endif
		endif
		endif
	next i
endfunction

function WalkerMove(Walker ref as TWalker,ProtoWalker ref as TProtoWalker,PlateList ref as TPlateList,World ref as TWorld,Now as integer)

	local PlateIndex as integer
	local PlateWidth as float
	local EdgeMargin as float
	local StepX as float
	local Moving as integer

	StepX = 0
	Moving = 0
	if Walker.Enabled = TRUE
		PlateIndex = Walker.PlateIndex
		if PlateIndex < 0 or PlateIndex > PlateList.Plate.Length
			Walker.Enabled = FALSE
		else
			if PlateList.Plate[PlateIndex].Enabled = FALSE
				Walker.Enabled = FALSE
			else
				PlateWidth = PlateList.Plate[PlateIndex].ObjectData.Size.Width
				EdgeMargin = 20
				if PlateWidth < EdgeMargin*2 then EdgeMargin = PlateWidth*0.25

				if WALKER_STAND_POSE_TEST = 1
					Walker.PauseUntilMs = 0
					Walker.NextPauseMs = Now + 5000
				endif
				if TimeGet(Walker.ObjectData.MoveTimer,Now) > 0
					StepX = 0
					// The walker does not advance while waiting for both feet to settle.
					if Walker.TurnPending = 0
						if Walker.PauseUntilMs > 0
							if Now >= Walker.PauseUntilMs
								Walker.PauseUntilMs = 0
								Walker.NextPauseMs = Now + random(2500,5000)
							endif
						else
							if Now >= Walker.NextPauseMs
								Walker.PauseUntilMs = Now + random(1000,3000)
							else
								if WALKER_STAND_POSE_TEST = 0 then StepX = Walker.ObjectData.MoveSpeed.x*Walker.ObjectData.MoveTimer.CalcRange
								if Walker.State.Alignment = MOVELEFT
									Walker.PlateOffsetX = Walker.PlateOffsetX - StepX
								else
									Walker.PlateOffsetX = Walker.PlateOffsetX + StepX
								endif
								// Alternate swing feet every 15 px; planted feet stay fixed.
								if WALKER_STAND_POSE_TEST = 0 then Walker.WalkPhase = Walker.WalkPhase + StepX*WALKER_GAIT_DEGREES_PER_PIXEL
							endif
						endif

						// Begin turning only when moving toward the respective edge.
						// Keep the old facing until both feet have reached their stand pose.
						if WALKER_STAND_POSE_TEST = 0
							if Walker.State.Alignment = MOVELEFT and Walker.PlateOffsetX <= EdgeMargin
								Walker.PlateOffsetX = EdgeMargin
								Walker.TurnPending = 1
								StepX = 0
							endif
							if Walker.State.Alignment = MOVERIGHT and Walker.PlateOffsetX >= PlateWidth-EdgeMargin
								Walker.PlateOffsetX = PlateWidth-EdgeMargin
								Walker.TurnPending = 1
								StepX = 0
							endif
						endif
					endif
					TimeReset(Walker.ObjectData.MoveTimer,Now)
				endif

				if StepX > 0 and Walker.TurnPending = 0 then Moving = 1
				WalkerSkeletonUpdate(Walker,Moving)
				if Walker.TurnPending = 1
					// Only reverse when both feet are back on the platform at
					// their neutral offsets. The IK geometry is unchanged.
					if abs(Walker.SkeletonFootX[0]-(Walker.PlateOffsetX-10)) < 0.1 and abs(Walker.SkeletonFootX[1]-(Walker.PlateOffsetX+10)) < 0.1 and abs(Walker.SkeletonFootY[0]) < 0.1 and abs(Walker.SkeletonFootY[1]) < 0.1
						if Walker.State.Alignment = MOVELEFT
							Walker.State.Alignment = MOVERIGHT
							Walker.State.LookAlignment = LOOKRIGHT
							// Rightmost foot initiates the first step after turning right.
							Walker.WalkPhase = 180
						else
							Walker.State.Alignment = MOVELEFT
							Walker.State.LookAlignment = LOOKLEFT
							// Leftmost foot initiates the first step after turning left.
							Walker.WalkPhase = 0
						endif
						Walker.TurnPending = 0
						Walker.PauseUntilMs = 0
						Walker.NextPauseMs = Now + random(2500,5000)
					endif
				endif
				Walker.ObjectData.Position.x = PlateList.Plate[PlateIndex].ObjectData.Position.x + Walker.PlateOffsetX
				Walker.ObjectData.Position.y = PlateList.Plate[PlateIndex].ObjectData.Position.y + Walker.PlateOffsetY
				WalkerPartsCalculate(Walker,ProtoWalker,World)

				Walker.CollisionData.Position1.x = Walker.ObjectData.Position.x - Walker.ObjectData.Size.Width*0.5
				Walker.CollisionData.Position1.y = Walker.ObjectData.Position.y - Walker.ObjectData.Size.Height*0.5
				Walker.CollisionData.Position2.x = Walker.ObjectData.Position.x + Walker.ObjectData.Size.Width*0.5
				Walker.CollisionData.Position2.y = Walker.ObjectData.Position.y + Walker.ObjectData.Size.Height*0.5
			endif
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function WalkerMoveAll(WalkerList ref as TWalkerList,ProtoWalker ref as TProtoWalker,PlateList ref as TPlateList,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to WalkerList.Walker.Length
		WalkerMove(WalkerList.Walker[i],ProtoWalker,PlateList,World,Now)
		if WalkerList.Walker[i].Enabled = TRUE and WalkerList.Walker[i].ObjectData.Position.x + WalkerList.Walker[i].ObjectData.Size.Width < World.Position.x
			WalkerDelete(WalkerList,i)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Diagnostic: force the current leg angle onto the shared AGK sprite on every draw.
function WalkerDraw(Walker ref as TWalker,ProtoWalker ref as TProtoWalker)
	
	if Walker.Enabled = TRUE
		
		if Walker.State.Alignment = MOVELEFT
			
			SpriteDraw(ProtoWalker.AnimLeft.Thigh.Sprite,Walker.WalkerSpriteData.Thigh[ELEMENTRIGHT])
			SpriteDraw(ProtoWalker.AnimLeft.Shank.Sprite,Walker.WalkerSpriteData.Shank[ELEMENTRIGHT])

			SpriteDraw(ProtoWalker.AnimLeft.Socket.Sprite,Walker.WalkerSpriteData.Socket[ELEMENTRIGHT])
			
			SpriteDraw(ProtoWalker.AnimLeft.Thigh.Sprite,Walker.WalkerSpriteData.Thigh[ELEMENTLEFT])
			SpriteDraw(ProtoWalker.AnimLeft.Shank.Sprite,Walker.WalkerSpriteData.Shank[ELEMENTLEFT])

			SpriteDraw(ProtoWalker.AnimLeft.Socket.Sprite,Walker.WalkerSpriteData.Socket[ELEMENTLEFT])
			
			SpriteDraw(ProtoWalker.AnimLeft.Corpus.Sprite,Walker.WalkerSpriteData.Corpus)
			
		else
			
			SpriteDraw(ProtoWalker.AnimRight.Thigh.Sprite,Walker.WalkerSpriteData.Thigh[ELEMENTLEFT])
			SpriteDraw(ProtoWalker.AnimRight.Shank.Sprite,Walker.WalkerSpriteData.Shank[ELEMENTLEFT])

			SpriteDraw(ProtoWalker.AnimRight.Socket.Sprite,Walker.WalkerSpriteData.Socket[ELEMENTLEFT])
			
			SpriteDraw(ProtoWalker.AnimRight.Thigh.Sprite,Walker.WalkerSpriteData.Thigh[ELEMENTRIGHT])
			SpriteDraw(ProtoWalker.AnimRight.Shank.Sprite,Walker.WalkerSpriteData.Shank[ELEMENTRIGHT])

			SpriteDraw(ProtoWalker.AnimRight.Socket.Sprite,Walker.WalkerSpriteData.Socket[ELEMENTRIGHT])
			
			SpriteDraw(ProtoWalker.AnimRight.Corpus.Sprite,Walker.WalkerSpriteData.Corpus)
			
		endif
		
		if Walker.State.LookAlignment = LOOKLEFT then SpriteDraw(ProtoWalker.AnimLeft.Tower.Sprite,Walker.WalkerSpriteData.Tower)
		if Walker.State.LookAlignment = LOOKRIGHT then SpriteDraw(ProtoWalker.AnimRight.Tower.Sprite,Walker.WalkerSpriteData.Tower)

	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------


// Experimental IK sprite binding. Set to 0 to compare with the old sine gait.
#constant WALKER_IK_SPRITES 1
#constant WALKER_ANGLE_DEBUG 1
// Limb rotations now come from Proto Offset/Anchor reference directions.
global WalkerAngleDebugText as integer

// Align the Proto Offset-to-Anchor direction to IK, then apply the
// Proto rotation as an explicit artwork calibration offset.
// Unlike the previous formula, Proto.Rotation is not cancelled out.
// Convert the IK target direction (0 = up, clockwise) to the image's
// local Offset-to-Anchor direction. This is the same rule for all bones.
// Terminal parts with coincident points retain their neutral Proto angle.
function WalkerIKSpriteAngle(Proto ref as TProtoData,IKDirection as float)
	local dx as float
	local dy as float
	local ReferenceAngle as float
	local Result as float
	dx = Proto.Anchor.x-Proto.Offset.x
	dy = Proto.Anchor.y-Proto.Offset.y
	if dx = 0 and dy = 0
		Result = NormalizeAngle(Proto.Rotation)
	else
		ReferenceAngle = CalcAngleIK(dx,dy)
		Result = NormalizeAngle(IKDirection-ReferenceAngle+Proto.Rotation)
	endif
endfunction Result

// Length of a bone in its unrotated Proto image.
function WalkerProtoBoneLength(Proto ref as TProtoData)
	local dx as float
	local dy as float
	local Result as float
	dx = Proto.Anchor.x-Proto.Offset.x
	dy = Proto.Anchor.y-Proto.Offset.y
	Result = Sqrt(dx*dx+dy*dy)
endfunction Result

// Place the existing limb sprites at the IK joints, using the same screen
// coordinates as the skeleton overlay. Keep torso and turret unchanged.
function WalkerIKBindSprites(Walker ref as TWalker,ProtoWalker ref as TProtoWalker,World ref as TWorld)
	local i as integer
	local hipX as float
	local hipY as float
	local footX as float
	local footY as float
	local dx as float
	local dy as float
	local dist as float
	local thighLength as float
	local shankLength as float
	local reach as float
	local along as float
	local height as float
	local midX as float
	local midY as float
	local kneeX as float
	local kneeY as float
	local direction as float
	local upperAngle as float
	local lowerAngle as float
	local baseX as float
	local baseY as float

	if Walker.State.Alignment = MOVELEFT
		thighLength = WalkerProtoBoneLength(ProtoWalker.AnimLeft.Thigh)
		shankLength = WalkerProtoBoneLength(ProtoWalker.AnimLeft.Shank)
	else
		thighLength = WalkerProtoBoneLength(ProtoWalker.AnimRight.Thigh)
		shankLength = WalkerProtoBoneLength(ProtoWalker.AnimRight.Shank)
	endif
	reach = thighLength+shankLength
	baseX = Walker.ObjectData.Position.x-Walker.PlateOffsetX-World.Position.x
	baseY = Walker.ObjectData.Position.y-Walker.PlateOffsetY-World.Position.y
	hipX = Walker.ObjectData.Position.x-World.Position.x
	hipY = Walker.ObjectData.Position.y-World.Position.y
	direction = 1
	if Walker.State.Alignment = MOVELEFT then direction = -1
	for i = 0 to 1
		footX = baseX+Walker.SkeletonFootX[i]
		footY = baseY+Walker.SkeletonFootY[i]-WALKER_FOOT_JOINT_LIFT
		dx = footX-hipX
		dy = footY-hipY
		dist = sqrt(dx*dx+dy*dy)
		if dist > reach*0.999
			dx = dx*reach*0.999/dist
			dy = dy*reach*0.999/dist
			dist = reach*0.999
			footX = hipX+dx
			footY = hipY+dy
		endif
		if dist < 0.01 then dist = 0.01
		along = (thighLength*thighLength-shankLength*shankLength+dist*dist)/(2*dist)
		if along > thighLength then along = thighLength
		if along < -thighLength then along = -thighLength
		height = sqrt(thighLength*thighLength-along*along)
		midX = hipX+dx*along/dist
		midY = hipY+dy*along/dist
		direction = 1
		if Walker.State.Alignment = MOVELEFT then direction = -1
		kneeX = midX-dy/dist*height*direction
		kneeY = midY+dx/dist*height*direction
		// IK directions are absolute. Proto reference pose supplies each
		// sprite's original joint-to-joint direction and base rotation.
		upperAngle = CalcAngleIK(kneeX-hipX,kneeY-hipY)
		lowerAngle = CalcAngleIK(footX-kneeX,footY-kneeY)

		Walker.WalkerSpriteData.Thigh[i].Position.x = hipX
		Walker.WalkerSpriteData.Thigh[i].Position.y = hipY
		if Walker.State.Alignment = MOVELEFT
			Walker.WalkerSpriteData.Thigh[i].Angle = WalkerIKSpriteAngle(ProtoWalker.AnimLeft.Thigh,upperAngle)
		else
			Walker.WalkerSpriteData.Thigh[i].Angle = WalkerIKSpriteAngle(ProtoWalker.AnimRight.Thigh,upperAngle)
		endif
		if i = 0
			Walker.SkeletonDebugIK = NormalizeAngle(upperAngle)
			if Walker.State.Alignment = MOVELEFT
				Walker.SkeletonDebugProto = ProtoWalker.AnimLeft.Thigh.Rotation
			else
				Walker.SkeletonDebugProto = ProtoWalker.AnimRight.Thigh.Rotation
			endif
			Walker.SkeletonDebugSprite = Walker.WalkerSpriteData.Thigh[i].Angle
		endif
		Walker.WalkerSpriteData.Shank[i].Position.x = kneeX
		Walker.WalkerSpriteData.Shank[i].Position.y = kneeY
		if Walker.State.Alignment = MOVELEFT
			Walker.WalkerSpriteData.Shank[i].Angle = WalkerIKSpriteAngle(ProtoWalker.AnimLeft.Shank,lowerAngle)
		else
			Walker.WalkerSpriteData.Shank[i].Angle = WalkerIKSpriteAngle(ProtoWalker.AnimRight.Shank,lowerAngle)
		endif
		if i = 0
			Walker.SkeletonDebugShankIK = NormalizeAngle(lowerAngle)
			Walker.SkeletonDebugShankSprite = Walker.WalkerSpriteData.Shank[i].Angle
		endif
		Walker.WalkerSpriteData.Socket[i].Position.x = footX
		Walker.WalkerSpriteData.Socket[i].Position.y = footY
		// Temporary visual test: apply the facing-dependent foot angle only
		// to the final sprite angle, keeping neutral Proto rotations.
		if Walker.State.Alignment = MOVELEFT
			Walker.WalkerSpriteData.Socket[i].Angle = NormalizeAngle(WalkerIKSpriteAngle(ProtoWalker.AnimLeft.Socket,0)-90)
		else
			Walker.WalkerSpriteData.Socket[i].Angle = NormalizeAngle(WalkerIKSpriteAngle(ProtoWalker.AnimRight.Socket,0)+90)
		endif
	next i
endfunction

// Debug geometry uses manually drawn sprites so it shares the Swap() render path.
#constant WALKER_SKELETON_DEBUG 1
global WalkerDebugLineSprite as integer
global WalkerDebugJointSprite as integer
#constant WALKER_PROTO_POINTS_DEBUG 1
global WalkerProtoPivotSprite as integer
global WalkerProtoAnchorSprite as integer

function WalkerSkeletonInit()
	if WALKER_ANGLE_DEBUG = 1
		WalkerAngleDebugText = CreateText("")
		SetTextSize(WalkerAngleDebugText,12)
		SetTextColor(WalkerAngleDebugText,255,255,0,255)
	endif
	if WALKER_SKELETON_DEBUG = 1
		WalkerDebugLineSprite = CreateSprite(0)
		SetSpriteVisible(WalkerDebugLineSprite,1)
		SetSpriteOffset(WalkerDebugLineSprite,0,1)
		WalkerDebugJointSprite = CreateSprite(0)
		SetSpriteVisible(WalkerDebugJointSprite,1)
		SetSpriteSize(WalkerDebugJointSprite,5,5)
		SetSpriteOffset(WalkerDebugJointSprite,2.5,2.5)
	endif
	if WALKER_PROTO_POINTS_DEBUG = 1
		WalkerProtoPivotSprite = CreateSprite(0)
		SetSpriteVisible(WalkerProtoPivotSprite,1)
		SetSpriteSize(WalkerProtoPivotSprite,5,5)
		SetSpriteOffset(WalkerProtoPivotSprite,2.5,2.5)
		SetSpriteColor(WalkerProtoPivotSprite,255,60,60,255)
		WalkerProtoAnchorSprite = CreateSprite(0)
		SetSpriteVisible(WalkerProtoAnchorSprite,1)
		SetSpriteSize(WalkerProtoAnchorSprite,5,5)
		SetSpriteOffset(WalkerProtoAnchorSprite,2.5,2.5)
		SetSpriteColor(WalkerProtoAnchorSprite,0,255,255,255)
	endif
endfunction

function WalkerSkeletonLine(x1 as float,y1 as float,x2 as float,y2 as float)
	local dx as float
	local dy as float
	local length as float
	dx = x2-x1
	dy = y2-y1
	length = sqrt(dx*dx+dy*dy)
	if length > 0
		SetSpriteSize(WalkerDebugLineSprite,length,2)
		// Start of the 2 px line is anchored at the first IK joint.
		SetSpriteOffset(WalkerDebugLineSprite,0,1)
		SetSpriteAngle(WalkerDebugLineSprite,ATan2(dy,dx))
		SetSpritePositionByOffset(WalkerDebugLineSprite,x1,y1)
		DrawSprite(WalkerDebugLineSprite)
	endif
endfunction

function WalkerSkeletonJoint(x as float,y as float)
	// Center the 5x5 marker exactly on the IK joint.
	SetSpriteOffset(WalkerDebugJointSprite,2.5,2.5)
	SetSpritePositionByOffset(WalkerDebugJointSprite,x,y)
	DrawSprite(WalkerDebugJointSprite)
endfunction

// Independent two-bone IK preview. Coordinates are platform-relative.
// Foot targets are fixed during stance and advance during swing.
function WalkerSkeletonDraw(Walker ref as TWalker,World ref as TWorld,ProtoWalker ref as TProtoWalker)
	local i as integer
	local footX as float
	local footY as float
	local hipX as float
	local hipY as float
	local dx as float
	local dy as float
	local distance as float
	local midX as float
	local midY as float
	local height as float
	local kneeX as float
	local kneeY as float
	local direction as float
	local thighLength as float
	local shankLength as float
	local reach as float
	local along as float
	local baseX as float
	local baseY as float

	if Walker.State.Alignment = MOVELEFT
		thighLength = WalkerProtoBoneLength(ProtoWalker.AnimLeft.Thigh)
		shankLength = WalkerProtoBoneLength(ProtoWalker.AnimLeft.Shank)
	else
		thighLength = WalkerProtoBoneLength(ProtoWalker.AnimRight.Thigh)
		shankLength = WalkerProtoBoneLength(ProtoWalker.AnimRight.Shank)
	endif
	reach = thighLength+shankLength
	baseX = Walker.ObjectData.Position.x-Walker.PlateOffsetX
	baseY = Walker.ObjectData.Position.y-Walker.PlateOffsetY
	// Convert world coordinates to the same screen space as WalkerSpriteData.
	baseX = baseX-World.Position.x
	baseY = baseY-World.Position.y
	hipX = Walker.ObjectData.Position.x-World.Position.x
	hipY = Walker.ObjectData.Position.y-World.Position.y
	for i = 0 to 1
		footY = baseY+Walker.SkeletonFootY[i]-WALKER_FOOT_JOINT_LIFT
		footX = baseX+Walker.SkeletonFootX[i]
		dx = footX-hipX
		dy = footY-hipY
		distance = sqrt(dx*dx+dy*dy)
		if distance > reach*0.999
			dx = dx*reach*0.999/distance
			dy = dy*reach*0.999/distance
			distance = reach*0.999
			footX = hipX+dx
			footY = hipY+dy
		endif
		if distance < 0.01 then distance = 0.01
		along = (thighLength*thighLength-shankLength*shankLength+distance*distance)/(2*distance)
		if along > thighLength then along = thighLength
		if along < -thighLength then along = -thighLength
		height = sqrt(thighLength*thighLength-along*along)
		midX = hipX+dx*along/distance
		midY = hipY+dy*along/distance
		direction = 1
		if Walker.State.Alignment = MOVELEFT then direction = -1
		kneeX = midX-dy/distance*height*direction
		kneeY = midY+dx/distance*height*direction
		WalkerSkeletonLine(hipX,hipY,kneeX,kneeY)
		WalkerSkeletonLine(kneeX,kneeY,footX,footY)
		WalkerSkeletonJoint(kneeX,kneeY)
		WalkerSkeletonJoint(footX,footY)
	next i
	WalkerSkeletonJoint(hipX,hipY)
endfunction

// Red = actual sprite pivot (Proto.Offset); cyan = rotated Proto.Anchor.
// Markers use the same offset-based screen placement as the leg sprites.
function WalkerProtoPartPoints(Proto ref as TProtoData,Data ref as TSpriteData)
	local dx as float
	local dy as float
	local ax as float
	local ay as float
	dx = (Proto.Anchor.x-Proto.Offset.x)*Data.Scale
	dy = (Proto.Anchor.y-Proto.Offset.y)*Data.Scale
	ax = Data.Position.x+dx*Cos(Data.Angle)-dy*Sin(Data.Angle)
	ay = Data.Position.y+dx*Sin(Data.Angle)+dy*Cos(Data.Angle)
	SetSpritePositionByOffset(WalkerProtoPivotSprite,Data.Position.x,Data.Position.y)
	DrawSprite(WalkerProtoPivotSprite)
	SetSpritePositionByOffset(WalkerProtoAnchorSprite,ax,ay)
	DrawSprite(WalkerProtoAnchorSprite)
endfunction

function WalkerProtoPointsDraw(Walker ref as TWalker,ProtoWalker ref as TProtoWalker)
	local i as integer
	for i = 0 to 1
		if Walker.State.Alignment = MOVELEFT
			WalkerProtoPartPoints(ProtoWalker.AnimLeft.Thigh,Walker.WalkerSpriteData.Thigh[i])
			WalkerProtoPartPoints(ProtoWalker.AnimLeft.Shank,Walker.WalkerSpriteData.Shank[i])
			WalkerProtoPartPoints(ProtoWalker.AnimLeft.Socket,Walker.WalkerSpriteData.Socket[i])
		else
			WalkerProtoPartPoints(ProtoWalker.AnimRight.Thigh,Walker.WalkerSpriteData.Thigh[i])
			WalkerProtoPartPoints(ProtoWalker.AnimRight.Shank,Walker.WalkerSpriteData.Shank[i])
			WalkerProtoPartPoints(ProtoWalker.AnimRight.Socket,Walker.WalkerSpriteData.Socket[i])
		endif
	next i
endfunction

function WalkerDrawAll(WalkerList ref as TWalkerList,ProtoWalker ref as TProtoWalker,World ref as TWorld)
	
	local i as integer
	
	for i = 0 to WalkerList.Walker.Length
		if WALKER_IK_SPRITES = 1 and WalkerList.Walker[i].Enabled = TRUE
			WalkerIKBindSprites(WalkerList.Walker[i],ProtoWalker,World)
		endif
		WalkerDraw(WalkerList.Walker[i],ProtoWalker)
		if WALKER_SKELETON_DEBUG = 1 and WalkerList.Walker[i].Enabled = TRUE
			WalkerSkeletonDraw(WalkerList.Walker[i],World,ProtoWalker)
		endif
		if WALKER_PROTO_POINTS_DEBUG = 1 and WalkerList.Walker[i].Enabled = TRUE
			WalkerProtoPointsDraw(WalkerList.Walker[i],ProtoWalker)
		endif
		if WALKER_ANGLE_DEBUG = 1 and WALKER_IK_SPRITES = 1 and WalkerList.Walker[i].Enabled = TRUE
			// Show the angular difference between sprite and IK directions.
			local delta as float
			local shankDelta as float
			delta = NormalizeAngle(WalkerList.Walker[i].SkeletonDebugSprite-WalkerList.Walker[i].SkeletonDebugIK)
			if delta > 180 then delta = delta-360
			shankDelta = NormalizeAngle(WalkerList.Walker[i].SkeletonDebugShankSprite-WalkerList.Walker[i].SkeletonDebugShankIK)
			if shankDelta > 180 then shankDelta = shankDelta-360
			SetTextString(WalkerAngleDebugText,"Thigh IK: "+Str(WalkerList.Walker[i].SkeletonDebugIK)+" Sprite: "+Str(WalkerList.Walker[i].SkeletonDebugSprite)+" Delta: "+Str(delta)+Chr(10)+"Shank IK: "+Str(WalkerList.Walker[i].SkeletonDebugShankIK)+" Sprite: "+Str(WalkerList.Walker[i].SkeletonDebugShankSprite)+" Delta: "+Str(shankDelta))
			SetTextPosition(WalkerAngleDebugText,WalkerList.Walker[i].WalkerSpriteData.Corpus.Position.x-45,WalkerList.Walker[i].WalkerSpriteData.Corpus.Position.y-70)
			DrawText(WalkerAngleDebugText)
		endif
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



