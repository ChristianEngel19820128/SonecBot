
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ProtoPlateLoad(ProtoPlate ref as TProtoPlate,File as TFilePath)
	
	local i as integer
	
	if FilePathSetAndCheck(File) = TRUE
		
		ProtoPlate.FromJson(ReadFileString(File))
		
		for i = 0 to ProtoPlate.AnimPlate.Length
			if ImageLoad(ProtoPlate.AnimPlate[i].Image) = TRUE
				SpriteLoad(ProtoPlate.AnimPlate[i])
			endif
		next i
		
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateInit(PlateList ref as TPlateList)
	
	TimeSet(PlateList.CreateTimer,1000,1)
	PlateList.Plate.Length = -1
	PlateList.FirstFree = 0
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateNew(Plate ref as TPlate,ProtoPlate ref as TProtoPlate,World ref as TWorld,y as integer,Now as integer)
	
	Plate.Enabled = TRUE
	Plate.DebugDeltaX = 0
	Plate.DebugDeltaY = 0
	Plate.DebugCalcRange = 0
	Plate.DebugElapsedMs = 0
	Plate.DebugUpdated = 0
	Plate.DebugFrameMs = 0
	Plate.DebugLastNow = Now
	Plate.DebugHistoryCount = 0
	Plate.DebugHistoryNext = 0
	TimeSet(Plate.ObjectData.MoveTimer,10,10)
	TimeReset(Plate.ObjectData.MoveTimer,Now)
	Plate.ProtoIndex = random(0,ProtoPlate.AnimPlate.Length)
	Plate.ObjectData.MoveSpeed.x = random(35,100)*0.001
	Plate.ObjectData.MoveSpeed.y = random(0,50)*0.001
	
	Plate.ObjectData.Position.x = World.Size.Width
	Plate.ObjectData.Position.y = y
	Plate.ObjectData.Size.Width = GetImageWidth(ProtoPlate.AnimPlate[Plate.ProtoIndex].Image.ID)
	Plate.ObjectData.Size.Height = GetImageHeight(ProtoPlate.AnimPlate[Plate.ProtoIndex].Image.ID)
	
	if random(0,ProtoPlate.AnimPlate.Length) >= Plate.ProtoIndex
		Plate.YShift.Enabled = random(0,1)
		Plate.YShift.Alignment = random(0,1)
		Plate.YShift.Min = random(Plate.ObjectData.Position.y-200,Plate.ObjectData.Position.y)
		if Plate.YShift.Min < 64
			Plate.YShift.Min = 64
		endif
		Plate.YShift.Max = random(Plate.ObjectData.Position.y,Plate.ObjectData.Position.y+200)
		if Plate.YShift.Max > World.Size.Height - 64
			Plate.YShift.Max = World.Size.Height - 64
		endif
	endif
	
	Plate.SpriteData.Angle = 0
	Plate.SpriteData.Center = FALSE
	Plate.SpriteData.Scale = 1
	
	Plate.CollisionData.Position1.x = Plate.ObjectData.Position.x
	Plate.CollisionData.Position1.y = Plate.ObjectData.Position.y
	Plate.CollisionData.Position2.x = Plate.ObjectData.Position.x + Plate.ObjectData.Size.Width
	Plate.CollisionData.Position2.y = Plate.ObjectData.Position.y + Plate.ObjectData.Size.Height
	
	SpritePositionCalc(Plate.SpriteData.Position,Plate.ObjectData.Position,World.Position)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateAdd(PlateList ref as TPlateList,ProtoPlate ref as TProtoPlate,World ref as TWorld,Now as integer)
	
	local Value as integer
	local Found as integer
	local i as integer
	local Plate as TPlate
	local y as integer

	y = random(64,floor((World.Size.Height-64)/8))*8
	
	Value = -1
	
	if PlateExists(PlateList,World,y) = FALSE
	
		if TimeGet(PlateList.CreateTimer,Now) > 0
			
			PlateNew(Plate,ProtoPlate,World,y,Now)
			
			Found = FALSE
			i = PlateList.FirstFree
			while Found = FALSE and i <= PlateList.Plate.Length
				if PlateList.Plate[i].Enabled = FALSE
					Found = TRUE
				else
					i = i+1
				endif
			endwhile
			
			if Found = FALSE
				PlateList.Plate.Insert(Plate)
				PlateList.FirstFree = PlateList.Plate.Length
				Value = PlateList.Plate.Length
			else
				PlateList.Plate[i] = Plate
				PlateList.FirstFree = i+1
				Value = i
			endif
		
			TimeReset(PlateList.CreateTimer,Now)
			
		endif
	endif
	
endfunction Value


//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateExists(PlateList ref as TPlateList,World ref as TWorld,y as integer)
	
	local Value as integer
	local i as integer
	
	Value = FALSE
	
	for i = 0 to PlateList.Plate.Length
		if PlateList.Plate[i].Enabled = TRUE
			if PlateList.Plate[i].ObjectData.Position.y > y - PlateList.Plate[i].ObjectData.Size.Height*4
				if PlateList.Plate[i].ObjectData.Position.y < y + PlateList.Plate[i].ObjectData.Size.Height*4
					Value = TRUE
				endif
			endif
		endif
		
	next i
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateDelete(PlateList ref as TPlateList,Index as integer)
	
	PlateList.Plate[Index].Enabled = FALSE
	if PlateList.FirstFree > Index
		PlateList.FirstFree = Index
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateCheckAll(PlateList ref as TPlateList,ProtoPlate ref as TProtoPlate)
	
	local i as integer
	local px as float
	local pdx as float
	
	for i = 0 to PlateList.Plate.Length
		
		if PlateList.Plate[i].Enabled = TRUE
		
			px = PlateList.Plate[i].ObjectData.Position.x
			pdx = PlateList.Plate[i].ObjectData.Size.Width
				
			if px+pdx < 0
				PlateDelete(PlateList,i)
			endif
			
		endif
		
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateMove(Plate ref as TPlate,World ref as TWorld,Now as integer)

	local x as float
	local y as float
	local sx as float
	local sy as float
	local r as float
	
	if Plate.Enabled = TRUE
		// GameDo-frame duration and timer advances are measured separately.
		Plate.DebugFrameMs = Now - Plate.DebugLastNow
		if Plate.DebugFrameMs < 0 then Plate.DebugFrameMs = 0
		Plate.DebugLastNow = Now
		// Per-frame sample: a zero step means the 10 ms timer did not advance this frame.
		Plate.DebugUpdated = 0
		Plate.DebugDeltaX = 0
		Plate.DebugDeltaY = 0
		Plate.DebugCalcRange = 0
		Plate.DebugElapsedMs = 0
		if TimeGet(Plate.ObjectData.MoveTimer,Now) > 0
			
			x = Plate.ObjectData.Position.x
			y = Plate.ObjectData.Position.y
			sx = Plate.ObjectData.MoveSpeed.x
			sy = Plate.ObjectData.MoveSpeed.y
			r = Plate.ObjectData.MoveTimer.CalcRange
			Plate.DebugCalcRange = r
			Plate.DebugElapsedMs = Plate.ObjectData.MoveTimer.FullDifference
			Plate.DebugUpdated = 1
			
			Plate.ObjectData.Position.x = x - sx*r
			
			if Plate.YShift.Enabled = TRUE
				if Plate.YShift.Alignment = MOVEUP
					Plate.ObjectData.Position.y = y - sy*r
					if Plate.ObjectData.Position.y < Plate.YShift.Min
						Plate.ObjectData.Position.y = Plate.YShift.Min
						Plate.YShift.Alignment = MOVEDOWN
					endif
				else
					Plate.ObjectData.Position.y = y + sy*r
					if Plate.ObjectData.Position.y > Plate.YShift.Max
						Plate.ObjectData.Position.y = Plate.YShift.Max
						Plate.YShift.Alignment = MOVEUP
					endif
				endif
			endif
			
			// Store the actual displacement after any vertical boundary clamp.
			Plate.DebugDeltaX = Plate.ObjectData.Position.x - x
			Plate.DebugDeltaY = Plate.ObjectData.Position.y - y
			SpritePositionCalc(Plate.SpriteData.Position,Plate.ObjectData.Position,World.Position)
			
			Plate.CollisionData.Position1.x = Plate.ObjectData.Position.x
			Plate.CollisionData.Position1.y = Plate.ObjectData.Position.y
			Plate.CollisionData.Position2.x = Plate.ObjectData.Position.x + Plate.ObjectData.Size.Width
			Plate.CollisionData.Position2.y = Plate.ObjectData.Position.y + Plate.ObjectData.Size.Height
			
			TimeReset(Plate.ObjectData.MoveTimer,Now)
			
		endif
		// Capture the last 60 game-update frames, including skipped movement steps.
		Plate.DebugHistoryDX[Plate.DebugHistoryNext] = Plate.DebugDeltaX
		Plate.DebugHistoryFrameMs[Plate.DebugHistoryNext] = Plate.DebugFrameMs
		Plate.DebugHistoryStep[Plate.DebugHistoryNext] = Plate.DebugUpdated
		Plate.DebugHistoryNext = Plate.DebugHistoryNext + 1
		if Plate.DebugHistoryNext >= 60 then Plate.DebugHistoryNext = 0
		if Plate.DebugHistoryCount < 60 then Plate.DebugHistoryCount = Plate.DebugHistoryCount + 1
	endif
		
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateMoveAll(PlateList ref as TPlateList,World ref as TWorld,Now as integer)
	
	local i as integer
	
	for i = 0 to PlateList.Plate.Length
		PlateMove(PlateList.Plate[i],World,Now)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateDraw(Plate ref as TPlate,ProtoPlate ref as TProtoPlate)
	local DrawData as TSpriteData
	
	if Plate.Enabled = TRUE
		// Never quantize the actual platform, only the data passed to SpriteDraw.
		DrawData = Plate.SpriteData
		if MotionRenderSnapEnabled = 1
			MotionRenderSnapPosition(DrawData.Position)
		endif
		SpriteDraw(ProtoPlate.AnimPlate[Plate.ProtoIndex].Sprite,DrawData)
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateDrawAll(PlateList ref as TPlateList,ProtoPlate ref as TProtoPlate)
	
	local i as integer
	
	for i = 0 to PlateList.Plate.Length
		PlateDraw(PlateList.Plate[i],ProtoPlate)
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function PlateAndChestDrawAll(PlateList ref as TPlateList,ProtoPlate ref as TProtoPlate,ChestList ref as TChestList,ProtoChest ref as TProtoChest)
	
	local i as integer
	local k as integer
	
	for i = 0 to PlateList.Plate.Length
		PlateDraw(PlateList.Plate[i],ProtoPlate)
		for k = 0 to ChestList.Chest.Length
			if ChestList.Chest[k].CollisionData.Index = i
				ChestDraw(ChestList.Chest[k],ProtoChest)
			endif
		next k
	next i
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// F2-only overlay. Keep instrumentation separate from Walker/IK F1 diagnostics.
global PlateDebugEnabled as integer
global PlateDebugHudText as integer
global PlateDebugIndexText as integer
#constant PLATE_DEBUG_MAX_ENTRIES 1

function PlateDebugToggle()
	if PlateDebugEnabled = 0
		PlateDebugEnabled = 1
	else
		PlateDebugEnabled = 0
	endif
endfunction

// The history has one sample per GameDo frame, including zero-step frames.
// Min/average/max dX use those per-frame samples, and dt uses elapsed game-frame ms.
function PlateDebugDrawAll(PlateList ref as TPlateList,TowerList ref as TTowerList)
	local i as integer
	local j as integer
	local Visible as integer
	local Shown as integer
	local TowerIndex as integer
	local TowerMarkerX as float
	local TowerMarkerY as float
	local k as integer
	local Count as integer
	local Steps as integer
	local MinDX as float
	local MaxDX as float
	local AvgDX as float
	local SumDX as float
	local MinDT as integer
	local MaxDT as integer
	local AvgDT as float
	local SumDT as float
	local PosX as float
	local PosY as float
	local Data as string

	if PlateDebugEnabled = 1
		if PlateDebugHudText = 0
			PlateDebugHudText = CreateText("")
			SetTextSize(PlateDebugHudText,10)
			SetTextColor(PlateDebugHudText,120,240,255,255)
		endif
		if PlateDebugIndexText = 0
			PlateDebugIndexText = CreateText("")
			SetTextSize(PlateDebugIndexText,10)
			SetTextColor(PlateDebugIndexText,120,240,255,255)
		endif

		Visible = 0
		for i = 0 to PlateList.Plate.Length
			if PlateList.Plate[i].Enabled = TRUE
				if PlateList.Plate[i].SpriteData.Position.x <= GetVirtualWidth() and PlateList.Plate[i].SpriteData.Position.x + PlateList.Plate[i].ObjectData.Size.Width >= 0
					if PlateList.Plate[i].SpriteData.Position.y <= GetVirtualHeight() and PlateList.Plate[i].SpriteData.Position.y + PlateList.Plate[i].ObjectData.Size.Height >= 0
						Visible = Visible + 1
					endif
				endif
			endif
		next i

		Shown = 0
		if MotionRenderSnapEnabled = 0
			Data = "MOTION F2 | A: FLOAT | F4 switches | P: "+Str(Visible)+" | 60 frames"+Chr(10)
		else
			Data = "MOTION F2 | B: PIXEL SNAP | F4 switches | P: "+Str(Visible)+" | 60 frames"+Chr(10)
		endif
		// Renderer is queried live; sync text reports the startup command, NOT actual scanout.
		Data = Data+"Renderer: "+GetRendererName()+" | Sync call: "+MotionDebugSyncRequest+Chr(10)
		for i = 0 to PlateList.Plate.Length
			if PlateList.Plate[i].Enabled = TRUE
				if PlateList.Plate[i].SpriteData.Position.x <= GetVirtualWidth() and PlateList.Plate[i].SpriteData.Position.x + PlateList.Plate[i].ObjectData.Size.Width >= 0
					if PlateList.Plate[i].SpriteData.Position.y <= GetVirtualHeight() and PlateList.Plate[i].SpriteData.Position.y + PlateList.Plate[i].ObjectData.Size.Height >= 0
						if Shown < PLATE_DEBUG_MAX_ENTRIES
							SetTextString(PlateDebugIndexText,"P"+Str(i))
							SetTextPosition(PlateDebugIndexText,PlateList.Plate[i].SpriteData.Position.x+3,PlateList.Plate[i].SpriteData.Position.y-15)
							DrawText(PlateDebugIndexText)
							Count = PlateList.Plate[i].DebugHistoryCount
							Steps = 0
							MinDX = 0
							MaxDX = 0
							AvgDX = 0
							SumDX = 0
							MinDT = 0
							MaxDT = 0
							AvgDT = 0
							SumDT = 0
							if Count > 0
								MinDX = PlateList.Plate[i].DebugHistoryDX[0]
								MaxDX = MinDX
								MinDT = PlateList.Plate[i].DebugHistoryFrameMs[0]
								MaxDT = MinDT
								for j = 0 to Count-1
									if PlateList.Plate[i].DebugHistoryDX[j] < MinDX then MinDX = PlateList.Plate[i].DebugHistoryDX[j]
									if PlateList.Plate[i].DebugHistoryDX[j] > MaxDX then MaxDX = PlateList.Plate[i].DebugHistoryDX[j]
									if PlateList.Plate[i].DebugHistoryFrameMs[j] < MinDT then MinDT = PlateList.Plate[i].DebugHistoryFrameMs[j]
									if PlateList.Plate[i].DebugHistoryFrameMs[j] > MaxDT then MaxDT = PlateList.Plate[i].DebugHistoryFrameMs[j]
									SumDX = SumDX + PlateList.Plate[i].DebugHistoryDX[j]
									SumDT = SumDT + PlateList.Plate[i].DebugHistoryFrameMs[j]
									Steps = Steps + PlateList.Plate[i].DebugHistoryStep[j]
								next j
								AvgDX = SumDX*(1.0/Count)
								AvgDT = SumDT*(1.0/Count)
							endif
							Data = Data+"P"+Str(i)+" X "+Str(PlateList.Plate[i].ObjectData.Position.x,1)+" Y "+Str(PlateList.Plate[i].ObjectData.Position.y,1)+" dX "+Str(PlateList.Plate[i].DebugDeltaX,3)+Chr(10)
							Data = Data+"  Move dt "+Str(PlateList.Plate[i].DebugElapsedMs)+"ms R "+Str(PlateList.Plate[i].DebugCalcRange,1)+" Step "+Str(PlateList.Plate[i].DebugUpdated)+Chr(10)
							Data = Data+"  dX min/avg/max "+Str(MinDX,3)+" / "+Str(AvgDX,3)+" / "+Str(MaxDX,3)+Chr(10)
							Data = Data+"  Frame ms min/avg/max "+Str(MinDT)+" / "+Str(AvgDT,1)+" / "+Str(MaxDT)+" | Steps "+Str(Steps)+"/"+Str(Count)+Chr(10)
							Shown = Shown+1
						endif
					endif
				endif
			endif
		next i
		if Visible > Shown then Data = Data+"Other platforms: "+Str(Visible-Shown)+Chr(10)

		// Select the first actually visible skyscraper segment, not an offscreen Tower.
		// TowerPart coordinates are centered SpriteDraw positions after camera translation.
		TowerIndex = -1
		for i = 0 to TowerList.Tower.Length
			if TowerList.Tower[i].Enabled = TRUE and TowerIndex = -1
				for k = 0 to TowerList.Tower[i].TowerPart.Length
					if TowerIndex = -1
						if TowerList.Tower[i].TowerPart[k].SpriteData.Position.x + TowerList.Tower[i].TowerPart[k].ObjectData.Size.Width*0.5 >= 0 and TowerList.Tower[i].TowerPart[k].SpriteData.Position.x - TowerList.Tower[i].TowerPart[k].ObjectData.Size.Width*0.5 <= GetVirtualWidth()
							if TowerList.Tower[i].TowerPart[k].SpriteData.Position.y + TowerList.Tower[i].TowerPart[k].ObjectData.Size.Height*0.5 >= 0 and TowerList.Tower[i].TowerPart[k].SpriteData.Position.y - TowerList.Tower[i].TowerPart[k].ObjectData.Size.Height*0.5 <= GetVirtualHeight()
								TowerIndex = i
								TowerMarkerX = TowerList.Tower[i].TowerPart[k].SpriteData.Position.x-TowerList.Tower[i].TowerPart[k].ObjectData.Size.Width*0.5+4
								TowerMarkerY = TowerList.Tower[i].TowerPart[k].SpriteData.Position.y-TowerList.Tower[i].TowerPart[k].ObjectData.Size.Height*0.5+4
							endif
						endif
					endif
				next k
			endif
		next i

		if TowerIndex >= 0
			if TowerMarkerX < 4 then TowerMarkerX = 4
			if TowerMarkerX > GetVirtualWidth()-28 then TowerMarkerX = GetVirtualWidth()-28
			if TowerMarkerY < 4 then TowerMarkerY = 4
			if TowerMarkerY > GetVirtualHeight()-20 then TowerMarkerY = GetVirtualHeight()-20
			SetTextString(PlateDebugIndexText,"T"+Str(TowerIndex))
			SetTextPosition(PlateDebugIndexText,TowerMarkerX,TowerMarkerY)
			DrawText(PlateDebugIndexText)

			Count = TowerList.Tower[TowerIndex].DebugHistoryCount
			Steps = 0
			MinDX = 0
			MaxDX = 0
			AvgDX = 0
			SumDX = 0
			MinDT = 0
			MaxDT = 0
			AvgDT = 0
			SumDT = 0
			if Count > 0
				MinDX = TowerList.Tower[TowerIndex].DebugHistoryDX[0]
				MaxDX = MinDX
				MinDT = TowerList.Tower[TowerIndex].DebugHistoryFrameMs[0]
				MaxDT = MinDT
				for j = 0 to Count-1
					if TowerList.Tower[TowerIndex].DebugHistoryDX[j] < MinDX then MinDX = TowerList.Tower[TowerIndex].DebugHistoryDX[j]
					if TowerList.Tower[TowerIndex].DebugHistoryDX[j] > MaxDX then MaxDX = TowerList.Tower[TowerIndex].DebugHistoryDX[j]
					if TowerList.Tower[TowerIndex].DebugHistoryFrameMs[j] < MinDT then MinDT = TowerList.Tower[TowerIndex].DebugHistoryFrameMs[j]
					if TowerList.Tower[TowerIndex].DebugHistoryFrameMs[j] > MaxDT then MaxDT = TowerList.Tower[TowerIndex].DebugHistoryFrameMs[j]
					SumDX = SumDX + TowerList.Tower[TowerIndex].DebugHistoryDX[j]
					SumDT = SumDT + TowerList.Tower[TowerIndex].DebugHistoryFrameMs[j]
					Steps = Steps + TowerList.Tower[TowerIndex].DebugHistoryStep[j]
				next j
				AvgDX = SumDX*(1.0/Count)
				AvgDT = SumDT*(1.0/Count)
			endif
			Data = Data+Chr(10)+"T"+Str(TowerIndex)+" X "+Str(TowerList.Tower[TowerIndex].ObjectData.Position.x,1)+" dX "+Str(TowerList.Tower[TowerIndex].DebugDeltaX,3)+Chr(10)
			Data = Data+"  Move dt "+Str(TowerList.Tower[TowerIndex].DebugElapsedMs)+"ms R "+Str(TowerList.Tower[TowerIndex].DebugCalcRange,1)+" Step "+Str(TowerList.Tower[TowerIndex].DebugUpdated)+Chr(10)
			Data = Data+"  dX min/avg/max "+Str(MinDX,3)+" / "+Str(AvgDX,3)+" / "+Str(MaxDX,3)+Chr(10)
			Data = Data+"  Frame ms min/avg/max "+Str(MinDT)+" / "+Str(AvgDT,1)+" / "+Str(MaxDT)+" | Steps "+Str(Steps)+"/"+Str(Count)+Chr(10)
		else
			Data = Data+Chr(10)+"Tower: no visible skyscraper"+Chr(10)
		endif

		SetTextString(PlateDebugHudText,Data)
		SetTextSize(PlateDebugHudText,10)
		if GetTextTotalWidth(PlateDebugHudText) > GetVirtualWidth()-24 or GetTextTotalHeight(PlateDebugHudText) > GetVirtualHeight()-24
			SetTextSize(PlateDebugHudText,8)
		endif
		PosX = GetVirtualWidth()-GetTextTotalWidth(PlateDebugHudText)-12
		// F1 and F2 are exclusive: share the upper-right screen area.
		PosY = 12
		if PosX < 4 then PosX = 4
		if PosY < 4 then PosY = 4
		SetTextPosition(PlateDebugHudText,PosX,PosY)
		DrawText(PlateDebugHudText)
	endif
endfunction

function PlateCountAll(PlateList ref as TPlateList)
	
	local i as integer
	local Count as integer
	
	Count = 0
	
	for i = 0 to PlateList.Plate.Length
		if PlateList.Plate[i].Enabled = TRUE
			Count = Count +1
		endif
	next i
	
endfunction Count

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------




