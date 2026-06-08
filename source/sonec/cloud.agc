
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoCloudLoad(ProtoCloud ref as TProtoCloud,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoCloud.FromJson(ReadFileString(File))
		
		for i = 0 to ProtoCloud.AnimCloud.Length
			if ImageLoad(ProtoCloud.AnimCloud[i].Image) = TRUE
				SpriteLoad(ProtoCloud.AnimCloud[i])
			endif
		next i
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function CloudInit(CloudList ref as TCloudList,ProtoCloud ref as TProtoCloud,World ref as TWorld,Now as integer)
	
	local i as integer
	local Position as TPosition
	
	TimeSet(CloudList.CreateTimer,1000,1)
	CloudList.Cloud.Length = -1
	CloudList.FirstFree = 0
	
	for i = 0 to random(1,35)
		if random(0,100) < 75
			Position.x = random(0,World.Size.Width)-World.Size.Width*0.25
			Position.y = random(0,World.Size.Height)
			CloudAdd(CloudList,ProtoCloud,World,Position,Now)
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function CloudNew(Cloud ref as TCloud,ProtoCloud ref as TProtoCloud,World ref as TWorld,Position ref as TPosition,Now)
	
	Cloud.Enabled = TRUE
	TimeSet(Cloud.ObjectData.MoveTimer,10,10)
	TimeReset(Cloud.ObjectData.MoveTimer,Now)

	Cloud.ObjectData.MoveSpeedMax.x = random(1,101) * 0.00005
	Cloud.ObjectData.MoveSpeedMax.y = random(1,101) * 0.00005
	Cloud.ObjectData.MoveSpeed.x = 0
	Cloud.ObjectData.MoveSpeed.y = 0
	Cloud.ObjectData.MoveAcceleration.x = 0.00005 * random(1,101)*0.015
	Cloud.ObjectData.MoveAcceleration.y = 0.00005 * random(1,101)*0.015
	
	Cloud.ObjectData.MoveAlignment.x = random(0,1)
	Cloud.ObjectData.MoveAlignment.y = random(0,1)
	
	Cloud.ObjectData.RotationAlignment = random(0,1)
	Cloud.ObjectData.Rotation = random(0,100)*0.0001
	
	Cloud.SpriteData.Angle = random(0,360)
	Cloud.SpriteData.Center = TRUE
	Cloud.SpriteData.Scale = random(50,175)*0.01
	
	ColorSet(Cloud.SpriteData.Color,random(200,255),random(200,255),random(200,255),random(10,25))
	
	Cloud.CloudType = random(0,ProtoCloud.AnimCloud.Length)
	
	Cloud.ObjectData.Size.Width = GetImageWidth(ProtoCloud.AnimCloud[Cloud.CloudType].Image.ID)*Cloud.SpriteData.Scale
	Cloud.ObjectData.Size.Height = GetImageHeight(ProtoCloud.AnimCloud[Cloud.CloudType].Image.ID)*Cloud.SpriteData.Scale
	
	if Position.x = 0 and Position.y = 0
		Cloud.ObjectData.Position.x = World.Size.Width+(Cloud.ObjectData.Size.Width)
		Cloud.ObjectData.Position.y = World.Size.Height*0.5
	else
		Cloud.ObjectData.Position = Position
	endif	
	SpritePositionCalc(Cloud.SpriteData.Position,Cloud.ObjectData.Position,World.Position)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function CloudAdd(CloudList ref as TCloudList,ProtoCloud ref as TProtoCloud,World ref as TWorld,Position ref as TPosition,Now as integer)
	
	local Found as integer
	local i as integer
	local k as integer
	local Cloud as TCloud
	
	CloudNew(Cloud,ProtoCloud,World,Position,Now)
			
	Found = FALSE
	i = CloudList.FirstFree
	while Found = FALSE and i <= CloudList.Cloud.Length
		if CloudList.Cloud[i].Enabled = FALSE
			Found = TRUE
		else
			i = i+1
		endif
	endwhile
	
	if Found = FALSE
		CloudList.Cloud.Insert(Cloud)
		CloudList.FirstFree = CloudList.Cloud.Length
	else
		CloudList.Cloud[i] = Cloud
		CloudList.FirstFree = i+1
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function CloudCreate(CloudList ref as TCloudList,ProtoCloud ref as TProtoCloud,World ref as TWorld,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local k as integer
	local Cloud as TCloud
	local Position as TPosition
	local CloudType as integer
	
	Value = FALSE
	
	if TimeGet(CloudList.CreateTimer,Now) > 0
		
		Position.x = 0
		Position.y = 0
		
		for k = 0 to random(1,5)
			
			CloudAdd(CloudList,ProtoCloud,World,Position,Now)
			Value = TRUE
		
		next k
		
		TimeReset(CloudList.CreateTimer,Now)
	
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function CloudDelete(CloudList ref as TCloudList,Index as integer)
	
	CloudList.Cloud[Index].Enabled = FALSE
	if CloudList.FirstFree > Index
		CloudList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function CloudMove(Cloud ref as TCloud,World ref as TWorld,Now as integer)

	if Cloud.Enabled = TRUE
		if TimeGet(Cloud.ObjectData.MoveTimer,Now) > 0

			if Cloud.ObjectData.RotationAlignment = 1
			Cloud.SpriteData.Angle = Cloud.SpriteData.Angle + Cloud.ObjectData.Rotation
			else
				Cloud.SpriteData.Angle = Cloud.SpriteData.Angle - Cloud.ObjectData.Rotation
			endif

			if Random(0,100) < 15
				Cloud.ObjectData.MoveAlignment.x = random(0,1)
			endif
			
			if Cloud.ObjectData.MoveAlignment.y = 0
				if Cloud.ObjectData.MoveSpeed.x < Cloud.ObjectData.MoveSpeedMax.x
					Cloud.ObjectData.MoveSpeed.x = Cloud.ObjectData.MoveSpeed.x - Cloud.ObjectData.MoveAcceleration.x
				endif
			else
				if Cloud.ObjectData.MoveSpeed.x > 0
					Cloud.ObjectData.MoveSpeed.x = Cloud.ObjectData.MoveSpeed.x + Cloud.ObjectData.MoveAcceleration.x
				endif
			endif
			
			Cloud.ObjectData.MoveSpeed.x = Cloud.ObjectData.MoveSpeed.x - Cloud.ObjectData.MoveAcceleration.x
			
			if Random(0,100) < 15
				Cloud.ObjectData.MoveAlignment.y = random(0,1)
			endif
			
			if Cloud.ObjectData.MoveAlignment.y = 0
				if Cloud.ObjectData.MoveSpeed.y < Cloud.ObjectData.MoveSpeedMax.y
					Cloud.ObjectData.MoveSpeed.y = Cloud.ObjectData.MoveSpeed.y - Cloud.ObjectData.MoveAcceleration.y
				endif
			else
				if Cloud.ObjectData.MoveSpeed.y > 0
					Cloud.ObjectData.MoveSpeed.y = Cloud.ObjectData.MoveSpeed.y + Cloud.ObjectData.MoveAcceleration.y
				endif
			endif
			
			Cloud.ObjectData.Position.x = Cloud.ObjectData.Position.x + Cloud.ObjectData.MoveSpeed.x * Cloud.ObjectData.MoveTimer.CalcRange
			Cloud.ObjectData.Position.y = Cloud.ObjectData.Position.y + Cloud.ObjectData.MoveSpeed.y * Cloud.ObjectData.MoveTimer.CalcRange
			
			SpritePositionCalc(Cloud.SpriteData.Position,Cloud.ObjectData.Position,World.Position)
			
			TimeReset(Cloud.ObjectData.MoveTimer,Now)
			
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function CloudMoveAll(CloudList ref as TCloudList,World ref as TWorld,Now as integer)

	Local i as integer
	
	for i = 0 to CloudList.Cloud.Length
		if CloudList.Cloud[i].Enabled = TRUE
			CloudMove(CloudList.Cloud[i],World,Now)
			if CloudList.Cloud[i].ObjectData.Position.y > World.Size.Height+CloudList.Cloud[i].ObjectData.Size.Height*CloudList.Cloud[i].SpriteData.Scale
				CloudDelete(CloudList,i)
			else
				if CloudList.Cloud[i].ObjectData.Position.y < -CloudList.Cloud[i].ObjectData.Size.Height*CloudList.Cloud[i].SpriteData.Scale
					CloudDelete(CloudList,i)
				else
					if CloudList.Cloud[i].ObjectData.Position.x > World.Size.Width+CloudList.Cloud[i].ObjectData.Size.Width*CloudList.Cloud[i].SpriteData.Scale
						CloudDelete(CloudList,i)
					else
						if CloudList.Cloud[i].ObjectData.Position.x < -CloudList.Cloud[i].ObjectData.Size.Width*CloudList.Cloud[i].SpriteData.Scale
							CloudDelete(CloudList,i)
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

function CloudDraw(Cloud ref as TCloud,ProtoCloud ref as TProtoCloud,ScaleMin as float,ScaleMax as float)
	
	if Cloud.Enabled = TRUE
		if Cloud.SpriteData.Scale >= ScaleMin and Cloud.SpriteData.Scale <= ScaleMax
			SpriteDraw(ProtoCloud.AnimCloud[Cloud.CloudType].Sprite,Cloud.SpriteData)
		endif
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function CloudDrawAll(CloudList ref as TCloudList,ProtoCloud ref as TProtoCloud,ScaleMin as float,ScaleMax as float)
	
	local i as integer
	
	for i = 0 to CloudList.Cloud.Length
		CloudDraw(CloudList.Cloud[i],ProtoCloud,ScaleMin,ScaleMax)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function CloudCountAll(CloudList ref as TCloudList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to CloudList.Cloud.Length
		if CloudList.Cloud[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//---------------------------------------------------------------------


