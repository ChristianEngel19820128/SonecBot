
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoJetfireLoad(ProtoJetfire ref as TProtoJetfire,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoJetfire.FromJson(ReadFileString(File))
		
		if ImageLoad(ProtoJetfire.AnimJetfire.Image) = TRUE
			SpriteLoad(ProtoJetfire.AnimJetfire)
		endif
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function JetfireInit(JetfireList ref as TJetfireList)
	
	TimeSet(JetfireList.CreateTimer,10,1)
	JetfireList.Jetfire.Length = -1
	JetfireList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function JetfireNew(Jetfire ref as TJetfire,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Position as TPosition,Now)
	
	Jetfire.Enabled = TRUE
	TimeSet(Jetfire.ObjectData.MoveTimer,10,10)
	TimeReset(Jetfire.ObjectData.MoveTimer,Now)
	
	Jetfire.ObjectData.Position.x = Position.x
	Jetfire.ObjectData.Position.y = Position.y
	
	Jetfire.ObjectData.Size.Width = GetSpriteWidth(ProtoJetfire.AnimJetfire.Sprite.ID)
	Jetfire.ObjectData.Size.Height = GetSpriteHeight(ProtoJetfire.AnimJetfire.Sprite.ID)
	
	TimeSet(Jetfire.EffectData.LifeCycleTimer,10,1)
	TimeReset(Jetfire.EffectData.LifeCycleTimer,Now)
	
	Jetfire.EffectData.LifeCycle = 0
	Jetfire.EffectData.LifeCycleMax = 10
	
	Jetfire.SpriteData.Angle = 0
	Jetfire.SpriteData.Center = TRUE
	Jetfire.SpriteData.Scale = 1
	
	ColorSet(Jetfire.SpriteData.Color,255,255,255,255)
	
	SpritePositionCalc(Jetfire.SpriteData.Position,Jetfire.ObjectData.Position,World.Position)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function JetfireAdd(JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Position as TPosition,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Jetfire as TJetfire
	
	Value = FALSE
	
	if TimeGet(JetfireList.CreateTimer,Now) > 0
		
		JetfireNew(Jetfire,ProtoJetfire,World,Position,Now)
		
		Found = FALSE
		i = JetfireList.FirstFree
		while Found = FALSE and i <= JetfireList.Jetfire.Length
			if JetfireList.Jetfire[i].Enabled = FALSE
				Found = TRUE
			else
				i = i+1
			endif
		endwhile
		
		if Found = FALSE
			JetfireList.Jetfire.Insert(Jetfire)
			JetfireList.FirstFree = JetfireList.Jetfire.Length
		else
			JetfireList.Jetfire[i] = Jetfire
			JetfireList.FirstFree = i+1
		endif
		
		Value = TRUE
		
		TimeReset(JetfireList.CreateTimer,Now)
	
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function JetfireDelete(JetfireList ref as TJetfireList,Index as integer)
	
	JetfireList.Jetfire[Index].Enabled = FALSE
	if JetfireList.FirstFree > Index
		JetfireList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function JetfireLifeCycle(JetfireList ref as TJetfireList,Now as integer)
	
	local i as integer
	
	for i = 0 to JetfireList.Jetfire.Length
		
		if JetfireList.Jetfire[i].Enabled = TRUE
			if JetfireList.Jetfire[i].EffectData.LifeCycle < JetfireList.Jetfire[i].EffectData.LifeCycleMax
				if TimeGet(JetfireList.Jetfire[i].EffectData.LifeCycleTimer,Now) > 0
					JetfireList.Jetfire[i].EffectData.LifeCycle = JetfireList.Jetfire[i].EffectData.LifeCycle +1
					ColorSet(JetfireList.Jetfire[i].SpriteData.Color,255,255,255,Floor(JetfireList.Jetfire[i].SpriteData.Color.Alpha * 0.75))
					TimeReset(JetfireList.Jetfire[i].EffectData.LifeCycleTimer,Now)
				endif
			else
				JetfireDelete(JetfireList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function JetfireDraw(Jetfire ref as TJetfire,ProtoJetfire ref as TProtoJetfire)
	
	if Jetfire.Enabled = TRUE
		SpriteDraw(ProtoJetfire.AnimJetfire.Sprite,Jetfire.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function JetfireDrawAll(JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire)
	
	local i as integer
	
	for i = 0 to JetfireList.Jetfire.Length
		JetfireDraw(JetfireList.Jetfire[i],ProtoJetfire)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function JetfireCountAll(JetfireList ref as TJetfireList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to JetfireList.Jetfire.Length
		if JetfireList.Jetfire[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

