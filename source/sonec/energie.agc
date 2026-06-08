
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoEnergieLoad(ProtoEnergie ref as TProtoEnergie,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoEnergie.FromJson(ReadFileString(File))
		
		for i = 0 to ProtoEnergie.AnimEnergie.Length
			if ImageLoad(ProtoEnergie.AnimEnergie[i].Image) = TRUE
				SpriteLoad(ProtoEnergie.AnimEnergie[i])
			endif
		next i
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieInit(EnergieList ref as TEnergieList)
	
	TimeSet(EnergieList.CreateTimer,1000,1)
	EnergieList.Energie.Length = -1
	EnergieList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieNew(Energie ref as TEnergie,ProtoEnergie ref as TProtoEnergie,World ref as TWorld,EnergieType as integer,Position as TPosition,Now)
	
	Energie.Enabled = TRUE
	TimeSet(Energie.ObjectData.MoveTimer,10,10)
	TimeReset(Energie.ObjectData.MoveTimer,Now)
	
	Energie.EnergieType = EnergieType
	Energie.Value = random(1,100)
	
	Energie.ObjectData.Position.x = Position.x
	Energie.ObjectData.Position.y = Position.y
	
	Energie.ObjectData.MoveSpeedMax.x = random(1,101-Energie.Value) * 0.00015
	Energie.ObjectData.MoveSpeedMax.y = random(1,101-Energie.Value) * 0.00005
	Energie.ObjectData.MoveSpeed.x = 0
	Energie.ObjectData.MoveSpeed.y = 0
	Energie.ObjectData.MoveAcceleration.x = 0.00015 * random(1,101-Energie.Value)*0.025
	Energie.ObjectData.MoveAcceleration.y = 0.00005 * random(1,101-Energie.Value)*0.025
	
	Energie.ObjectData.MoveAlignment.x = random(0,1)
	Energie.ObjectData.MoveAlignment.y = random(0,1)
	
	Energie.SpriteData.Angle = 0
	Energie.SpriteData.Center = TRUE
	Energie.SpriteData.Scale = Energie.Value*0.01
	
	ColorSet(Energie.SpriteData.Color,255,255,255,255)
	
	Energie.ObjectData.Size.Width = GetImageWidth(ProtoEnergie.AnimEnergie[EnergieType].Image.ID)*Energie.SpriteData.Scale
	Energie.ObjectData.Size.Height = GetImageHeight(ProtoEnergie.AnimEnergie[EnergieType].Image.ID)*Energie.SpriteData.Scale
	
	TimeReset(Energie.EffectData.LifeCycleTimer,Now)
	
	TimeSet(Energie.EffectData.LifeCycleTimer,1000,1)
	Energie.EffectData.LifeCycle = 0
	Energie.EffectData.LifeCycleMax = 100

	Energie.IsAttracted = FALSE

	SpritePositionCalc(Energie.SpriteData.Position,Energie.ObjectData.Position,World.Position)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieAdd(EnergieList ref as TEnergieList,ProtoEnergie ref as TProtoEnergie,World ref as TWorld,EnergieType as integer,Position as TPosition,Now as integer)
	
	local Found as integer
	local i as integer
	local k as integer
	local Energie as TEnergie
	
	EnergieNew(Energie,ProtoEnergie,World,EnergieType,Position,Now)
			
	Found = FALSE
	i = EnergieList.FirstFree
	while Found = FALSE and i <= EnergieList.Energie.Length
		if EnergieList.Energie[i].Enabled = FALSE
			Found = TRUE
		else
			i = i+1
		endif
	endwhile
	
	if Found = FALSE
		EnergieList.Energie.Insert(Energie)
		EnergieList.FirstFree = EnergieList.Energie.Length
	else
		EnergieList.Energie[i] = Energie
		EnergieList.FirstFree = i+1
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieCreate(EnergieList ref as TEnergieList,ProtoEnergie ref as TProtoEnergie,World ref as TWorld,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local k as integer
	local Energie as TEnergie
	local Position as TPosition
	local EnergieType as integer
	
	Value = FALSE
	
	if TimeGet(EnergieList.CreateTimer,Now) > 0
		
		Position.x = random(0,World.Size.Width)
		Position.y = World.Size.Height+25
		
		EnergieType = 0
		
		for k = 0 to random(3,10)
			
			Position.x = Position.x + random(-10,10)
			EnergieAdd(EnergieList,ProtoEnergie,World,EnergieType,Position,Now)
			Value = TRUE
		
		next k
		
		TimeReset(EnergieList.CreateTimer,Now)
	
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieDelete(EnergieList ref as TEnergieList,Index as integer)
	
	EnergieList.Energie[Index].Enabled = FALSE
	if EnergieList.FirstFree > Index
		EnergieList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieCollect(EnergieList ref as TEnergieList,Sonec ref as TSonec)
	
	local i as integer
	local Radius as float
	
	for i = 0 to EnergieList.Energie.Length
		if EnergieList.Energie[i].Enabled = TRUE
			Radius = CalcRadius(EnergieList.Energie[i].ObjectData.Position,Sonec.ObjectData.Position)
			if Radius < 25
				
				select EnergieList.Energie[i].EnergieType
					case 0
						Sonec.Energy.State = Sonec.Energy.State + EnergieList.Energie[i].Value
						if Sonec.Energy.State > 1.5*Sonec.Energy.StateMax
							Sonec.Health.State = Sonec.Health.State - ((Sonec.Energy.State + EnergieList.Energie[i].Value)-(Sonec.Energy.State*150/Sonec.Energy.StateMax))
							Sonec.Energy.State = Sonec.Energy.State*150/Sonec.Energy.StateMax
						endif						
					endcase
					case 1
						if Sonec.Energy.RegRate > 200
							Sonec.Energy.RegRate = Sonec.Energy.RegRate-1
						endif
						TimeSet(Sonec.Energy.RegenerationTimer,Sonec.Energy.RegRate,1)
					endcase
					case 2
						Sonec.Health.State = Sonec.Health.State + EnergieList.Energie[i].Value
						if Sonec.Health.State > Sonec.Health.StateMax
							Sonec.Health.State = Sonec.Health.StateMax
						endif
					endcase
					case 3
						if Sonec.Health.RegRate > 200
							Sonec.Health.RegRate = Sonec.Health.RegRate-1
						endif
						TimeSet(Sonec.Energy.RegenerationTimer,Sonec.Health.RegRate,1)
					endcase
					case 4
						if Sonec.MGun.FireRate > 400
							Sonec.MGun.FireRate  = Sonec.MGun.FireRate -1
						endif
						if Sonec.MGun.FireBurstRate > 120
							Sonec.MGun.FireBurstRate  = Sonec.MGun.FireBurstRate -1
						endif
						TimeSet(Sonec.MGun.FireTimer,Sonec.MGun.FireRate,1)
						TimeSet(Sonec.MGun.FireBurstTimer,Sonec.MGun.FireBurstRate,1)
					endcase
					case 5
						if Sonec.MGun.FireBurstMax < Sonec.MGun.FireBurstLimit
							Sonec.MGun.FireBurstMax  = Sonec.MGun.FireBurstMax +1
						endif
					endcase
					case 6
						if Sonec.MGun.Ammo + 10 < Sonec.MGun.AmmoMax
							Sonec.MGun.Ammo = Sonec.MGun.Ammo +10
						else
							Sonec.MGun.Ammo = Sonec.MGun.AmmoMax
						endif
					endcase
					case 7
						if Sonec.GrenadeLauncher.Ammo < Sonec.GrenadeLauncher.AmmoMax
							Sonec.GrenadeLauncher.Ammo = Sonec.GrenadeLauncher.Ammo +1
						endif
					endcase
				endselect
				EnergieDelete(EnergieList,i)
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieAttract(EnergieList ref as TEnergieList,Position as TPosition,Now as integer)
	
	local i as integer
	local Radius as float
	local Angle as float
	local Pos as TPosition
	
	for i = 0 to EnergieList.Energie.Length
		if EnergieList.Energie[i].Enabled = TRUE
	 		Radius = CalcRadius(EnergieList.Energie[i].ObjectData.Position,Position)
	 		if Radius > 0
	 			EnergieList.Energie[i].IsAttracted = TRUE
		 		Angle = CalcAngle(EnergieList.Energie[i].ObjectData.Position,Position)
		 		Pos = EnergieList.Energie[i].ObjectData.Position
		 		CalcPosition(Pos,Angle,(EnergieList.Energie[i].Value/(radius*5+1)))
		 		EnergieList.Energie[i].ObjectData.MoveSpeed.x = CalcDeltaX(EnergieList.Energie[i].ObjectData.Position,Pos)
		 		EnergieList.Energie[i].ObjectData.MoveSpeed.y = CalcDeltaY(EnergieList.Energie[i].ObjectData.Position,Pos)
	 		endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieMove(Energie ref as TEnergie,World ref as TWorld,Now as integer)

	if Energie.Enabled = TRUE
		if TimeGet(Energie.ObjectData.MoveTimer,Now) > 0
			
			if Energie.IsAttracted = FALSE
		
				if Random(0,100) < 10
					if Random(0,100) < 35
						Energie.ObjectData.MoveAlignment.x = 1
					else
						Energie.ObjectData.MoveAlignment.x = 0
					endif
				endif
				
				if Energie.ObjectData.MoveAlignment.x = 0
					if Energie.ObjectData.MoveSpeed.x < Energie.ObjectData.MoveSpeedMax.x
						Energie.ObjectData.MoveSpeed.x = Energie.ObjectData.MoveSpeed.x - Energie.ObjectData.MoveAcceleration.x
					endif
				else
					if Energie.ObjectData.MoveSpeed.x > -Energie.ObjectData.MoveSpeedMax.x
						Energie.ObjectData.MoveSpeed.x = Energie.ObjectData.MoveSpeed.x + Energie.ObjectData.MoveAcceleration.x
					endif
				endif
				
				if Random(0,100) < 10
					Energie.ObjectData.MoveAlignment.y = random(0,1)
				endif
				
				if Energie.ObjectData.MoveAlignment.y = 0
					if Energie.ObjectData.MoveSpeed.y < Energie.ObjectData.MoveSpeedMax.y
						Energie.ObjectData.MoveSpeed.y = Energie.ObjectData.MoveSpeed.y - Energie.ObjectData.MoveAcceleration.y
					endif
				else
					if Energie.ObjectData.MoveSpeed.y > 0
						Energie.ObjectData.MoveSpeed.y = Energie.ObjectData.MoveSpeed.y + Energie.ObjectData.MoveAcceleration.y
					endif
				endif
			
			endif
			
			Energie.ObjectData.Position.x = Energie.ObjectData.Position.x + Energie.ObjectData.MoveSpeed.x * Energie.ObjectData.MoveTimer.CalcRange
			Energie.ObjectData.Position.y = Energie.ObjectData.Position.y + Energie.ObjectData.MoveSpeed.y * Energie.ObjectData.MoveTimer.CalcRange
			
			SpritePositionCalc(Energie.SpriteData.Position,Energie.ObjectData.Position,World.Position)
			
			if Energie.IsAttracted = TRUE
				Energie.IsAttracted = FALSE
				Energie.ObjectData.MoveSpeed.x = 0
				Energie.ObjectData.MoveSpeed.y = 0
			endif
			
			TimeReset(Energie.ObjectData.MoveTimer,Now)
			
		endif
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieMoveAll(EnergieList ref as TEnergieList,World ref as TWorld,Now as integer)

	Local i as integer
	
	for i = 0 to EnergieList.Energie.Length
		if EnergieList.Energie[i].Enabled = TRUE
			EnergieMove(EnergieList.Energie[i],World,Now)
			if EnergieList.Energie[i].ObjectData.Position.y < -EnergieList.Energie[i].ObjectData.Size.Height
				EnergieDelete(EnergieList,i)
			else
				if EnergieList.Energie[i].ObjectData.Position.x > World.Size.Width+EnergieList.Energie[i].ObjectData.Size.Width
					EnergieDelete(EnergieList,i)
				else
					if EnergieList.Energie[i].ObjectData.Position.x < -EnergieList.Energie[i].ObjectData.Size.Width
						EnergieDelete(EnergieList,i)
					endif
				endif
			endif
		endif
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieLifeCycle(EnergieList ref as TEnergieList,Now as integer)
	
	local i as integer
	
	for i = 0 to EnergieList.Energie.Length
		
		if EnergieList.Energie[i].Enabled = TRUE
			if EnergieList.Energie[i].EffectData.LifeCycle < EnergieList.Energie[i].EffectData.LifeCycleMax
				if TimeGet(EnergieList.Energie[i].EffectData.LifeCycleTimer,Now) > 0
					EnergieList.Energie[i].EffectData.LifeCycle = EnergieList.Energie[i].EffectData.LifeCycle +1
					TimeReset(EnergieList.Energie[i].EffectData.LifeCycleTimer,Now)
					ColorSet(EnergieList.Energie[i].SpriteData.Color,255,255,255,Floor(255*(EnergieList.Energie[i].EffectData.LifeCycleMax-EnergieList.Energie[i].EffectData.LifeCycle)/EnergieList.Energie[i].EffectData.LifeCycleMax))
					EnergieList.Energie[i].Value = EnergieList.Energie[i].Value * 0.99
					EnergieList.Energie[i].SpriteData.Scale = EnergieList.Energie[i].Value*0.01
					if EnergieList.Energie[i].ObjectData.MoveAcceleration.y < 0.00015
						EnergieList.Energie[i].ObjectData.MoveAcceleration.y = EnergieList.Energie[i].ObjectData.MoveAcceleration.y + 0.00001
					endif
					if EnergieList.Energie[i].Value <= 0
						EnergieDelete(EnergieList,i)
					endif
				endif
			else
				EnergieDelete(EnergieList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieDraw(Energie ref as TEnergie,ProtoEnergie ref as TProtoEnergie)
	
	if Energie.Enabled = TRUE
		SpriteDraw(ProtoEnergie.AnimEnergie[Energie.EnergieType].Sprite,Energie.SpriteData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieDrawAll(EnergieList ref as TEnergieList,ProtoEnergie ref as TProtoEnergie)
	
	local i as integer
	
	for i = 0 to EnergieList.Energie.Length
		EnergieDraw(EnergieList.Energie[i],ProtoEnergie)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function EnergieCountAll(EnergieList ref as TEnergieList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to EnergieList.Energie.Length
		if EnergieList.Energie[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------





