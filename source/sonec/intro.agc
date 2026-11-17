
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function IntroProtoLoad(Intro ref as TIntro)
	
	local File as TFilePath
	
	Intro.ProtoBackground.Image.File.Path = "/media/gfx/background"
	Intro.ProtoBackground.Image.File.Name = "intro.png"
	
	if FilePathSetAndCheck(Intro.ProtoBackground.Image.File) = TRUE
		if ImageLoad(Intro.ProtoBackground.Image) = TRUE
			SpriteLoad(Intro.ProtoBackground)
		endif
	endif
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function IntroCreate(Intro ref as TIntro,vx as integer,vy as integer,Now as integer)
	local k as integer

	IntroProtoLoad(Intro)
	
	
	Intro.Background.SpriteData.Center = TRUE
	Intro.Background.SpriteData.Position.x = vx*0.5
	Intro.Background.SpriteData.Position.y = vy*0.5 - 12
	
	Intro.TextStart = CreateText("START")
	SetTextAlignment(Intro.TextStart,2)
	SetTextPosition(Intro.TextStart,vx-20,vy-140)
	SetTextSize(Intro.TextStart,28)
	SetTextBold(Intro.TextStart,1)
	
	Intro.TextOption = CreateText("OPTIONS")
	SetTextAlignment(Intro.TextOption,2)
	SetTextPosition(Intro.TextOption,vx-20,vy-110)
	SetTextSize(Intro.TextOption,28)
	SetTextBold(Intro.TextOption,1)
	
	Intro.TextEnd = CreateText("QUIT")
	SetTextAlignment(Intro.TextEnd,2)
	SetTextPosition(Intro.TextEnd,vx-20,vy-80)
	SetTextSize(Intro.TextEnd,28)
	SetTextBold(Intro.TextEnd,1)
	
	Intro.TextHelp = CreateText("U need a Joypad")
	SetTextAlignment(Intro.TextHelp,1)
	SetTextPosition(Intro.TextHelp,vx/2,vy-23)
	SetTextSize(Intro.TextHelp,18)
	SetTextBold(Intro.TextHelp,1)
	SetTextColor(Intro.TextHelp,255,255,255,222)
	
	// Reusable options rows: root categories and compact submenu screens.
	Intro.TextOptionsTitle = CreateText("OPTIONS")
	SetTextAlignment(Intro.TextOptionsTitle,1)
	SetTextPosition(Intro.TextOptionsTitle,vx/2,vy/2-90)
	SetTextSize(Intro.TextOptionsTitle,30)
	SetTextBold(Intro.TextOptionsTitle,1)
	SetTextColor(Intro.TextOptionsTitle,0,255,255,222)

	Intro.TextOptionsEntry1 = CreateText("GAMEPLAY")
	SetTextAlignment(Intro.TextOptionsEntry1,1)
	SetTextPosition(Intro.TextOptionsEntry1,vx/2,vy/2-35)
	SetTextSize(Intro.TextOptionsEntry1,19)
	SetTextBold(Intro.TextOptionsEntry1,1)

	Intro.TextOptionsEntry2 = CreateText("CONTROLS")
	SetTextAlignment(Intro.TextOptionsEntry2,1)
	SetTextPosition(Intro.TextOptionsEntry2,vx/2,vy/2)
	SetTextSize(Intro.TextOptionsEntry2,19)
	SetTextBold(Intro.TextOptionsEntry2,1)

	Intro.TextOptionsEntry3 = CreateText("AUDIO")
	SetTextAlignment(Intro.TextOptionsEntry3,1)
	SetTextPosition(Intro.TextOptionsEntry3,vx/2,vy/2+35)
	SetTextSize(Intro.TextOptionsEntry3,19)
	SetTextBold(Intro.TextOptionsEntry3,1)

	Intro.TextOptionsEntry4 = CreateText("BACK")
	SetTextAlignment(Intro.TextOptionsEntry4,1)
	SetTextPosition(Intro.TextOptionsEntry4,vx/2,vy/2+70)
	SetTextSize(Intro.TextOptionsEntry4,19)
	SetTextBold(Intro.TextOptionsEntry4,1)

	// Two compact keyboard tables share eleven fixed rows (no scrolling).
	// Labels are right aligned, key values left aligned, close to the centre.
	Intro.KeyboardCenterX = vx/2
	Intro.KeyboardCenterY = vy/2
	for k = 0 to 10
		Intro.TextKeyboardLabel[k] = CreateText("")
		SetTextAlignment(Intro.TextKeyboardLabel[k],2)
		SetTextPosition(Intro.TextKeyboardLabel[k],Intro.KeyboardCenterX-9,Intro.KeyboardCenterY)
		SetTextSize(Intro.TextKeyboardLabel[k],17)
		SetTextBold(Intro.TextKeyboardLabel[k],1)
		Intro.TextKeyboardKey[k] = CreateText("")
		SetTextAlignment(Intro.TextKeyboardKey[k],0)
		SetTextPosition(Intro.TextKeyboardKey[k],Intro.KeyboardCenterX+9,Intro.KeyboardCenterY)
		SetTextSize(Intro.TextKeyboardKey[k],17)
		SetTextBold(Intro.TextKeyboardKey[k],1)
	next k

	Intro.SelctionPos = 1
	Intro.OptionSelectionPos = 1
	Intro.OptionPage = 1 // 1=OPTIONS, 2=GAMEPLAY, 3=CONTROLS, 4=AUDIO, 5=MOVEMENT, 6=ACTIONS
	Intro.IsOption = FALSE
	Intro.AnalogMenuHeld = FALSE
	Intro.IsQuit = FALSE
	
	TimeSet(Intro.TimerHelp,11000,1)
	TimeReset(Intro.TimerHelp,Now)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function IntroGambleHelp(Intro ref as TIntro)

	local i as integer
	
	i = random(0,14)
	
	select i
		case 0
			SetTextString(Intro.TextHelp,"U need a Joypad")
		endcase
		case 1
			SetTextString(Intro.TextHelp,"Move with Left Stick or Left Cross")
		endcase
		case 2
			SetTextString(Intro.TextHelp,"Press Left Stick to hold Position")
		endcase
		case 3
			SetTextString(Intro.TextHelp,"Press L2 or R2 to move back")
		endcase
		case 4
			SetTextString(Intro.TextHelp,"Press L1 to activate Energy Attraction")
		endcase
		case 5
			SetTextString(Intro.TextHelp,"Press R1 to activate Shield")
		endcase
		case 6
			SetTextString(Intro.TextHelp,"Press A for the Large Mashinegun")
		endcase
		case 7
			SetTextString(Intro.TextHelp,"Press B for the Grande Launcher")
		endcase
		case 8
			SetTextString(Intro.TextHelp,"Press X for the Plasma Flame Trower")
		endcase
		case 9
			SetTextString(Intro.TextHelp,"Press Y for the Plasma Blitz")
		endcase
		case 10
			SetTextString(Intro.TextHelp,"The Jetpack consume your global Energy")
		endcase
		case 11
			SetTextString(Intro.TextHelp,"Energy Overload will damage UR Health")
		endcase
		case 12
			SetTextString(Intro.TextHelp,"The Shield consume your global Energy")
		endcase
		case 13
			SetTextString(Intro.TextHelp,"The Energy Attraction consume your global Energy")
		endcase
		case 14
			SetTextString(Intro.TextHelp,"The Energy Attraction will attract Mines")
		endcase
	endselect

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

// Display only; keyboard capture and rebinding arrive in the next step.
function IntroKeyboardKeyName(KeyCode as integer)
	local Result as string
	Result = Str(KeyCode)
	if KeyCode = 0 then Result = "-"
	if KeyCode >= 65 and KeyCode <= 90 then Result = Chr(KeyCode)
	if KeyCode >= 48 and KeyCode <= 57 then Result = Chr(KeyCode)
	if KeyCode = KEY_SPACE then Result = "SPACE"
	if KeyCode = KEY_ENTER then Result = "ENTER"
	if KeyCode = KEY_BACK then Result = "BACKSPACE"
	if KeyCode = KEY_UP then Result = "UP"
	if KeyCode = KEY_DOWN then Result = "DOWN"
	if KeyCode = KEY_LEFT then Result = "LEFT"
	if KeyCode = KEY_RIGHT then Result = "RIGHT"
	if KeyCode = KEY_TAB then Result = "TAB"
	if KeyCode = KEY_SHIFT then Result = "SHIFT"
	if KeyCode = KEY_CONTROL then Result = "CTRL"
endfunction Result

// Render one of two non-scrolling keyboard categories.
function IntroKeyboardTableUpdate(Intro ref as TIntro,Keys ref as TKeys)
	local Row as integer
	local Count as integer
	local Index as integer
	local Label as string
	local KeyValue as string
	local RowStart as integer
	local RowY as integer
	local IsNavigation as integer
	local NavigationGap as integer

	Count = 8 // MOVEMENT: six actions + NEXT + BACK
	if Intro.OptionPage = 6 then Count = 11 // ACTIONS: nine actions + MOVEMENT + BACK

	// Same type sizes on both pages. A 12-pixel break separates the
	// navigation pair from the action table without splitting that pair.
	// Include the break when vertically centering title and full contents.
	NavigationGap = 12
	RowStart = Intro.KeyboardCenterY - ((Count-1)*20+NavigationGap+62)/2+44
	SetTextPosition(Intro.TextOptionsTitle,Intro.KeyboardCenterX,RowStart-44)

	for Row = 0 to 10
		RowY = RowStart + Row*20
		if Row >= Count-2 then RowY = RowY + NavigationGap
		IsNavigation = FALSE
		Label = ""
		KeyValue = ""
		if Row < Count
			if Intro.OptionPage = 5
				if Row < 6
					Index = Row
					select Row
						case 0
							Label = "MOVE UP"
						endcase
						case 1
							Label = "MOVE DOWN"
						endcase
						case 2
							Label = "MOVE LEFT"
						endcase
						case 3
							Label = "MOVE RIGHT"
						endcase
						case 4
							Label = "BACK LEFT"
						endcase
						case 5
							Label = "BACK RIGHT"
						endcase
					endselect
					KeyValue = IntroKeyboardKeyName(Keys.Binding[Index].Key)
				else
					IsNavigation = TRUE
					if Row = 6 then Label = "ACTIONS"
					if Row = 7 then Label = "BACK"
				endif
			else
				if Row < 9
					Index = Row+6
					select Row
						case 0
							Label = "MACHINE GUN"
						endcase
						case 1
							Label = "GRENADE"
						endcase
						case 2
							Label = "FLAME"
						endcase
						case 3
							Label = "PLASMA"
						endcase
						case 4
							Label = "ATTRACT ENERGY"
						endcase
						case 5
							Label = "SHIELD"
						endcase
						case 6
							Label = "HOVER"
						endcase
						case 7
							Label = "START"
						endcase
						case 8
							Label = "BACK KEY"
						endcase
					endselect
					KeyValue = IntroKeyboardKeyName(Keys.Binding[Index].Key)
				else
					IsNavigation = TRUE
					if Row = 9 then Label = "MOVEMENT"
					if Row = 10 then Label = "BACK"
				endif
			endif
		endif
		// Navigation entries belong to the whole screen, not the key column.
		if IsNavigation = TRUE
			SetTextAlignment(Intro.TextKeyboardLabel[Row],1)
			SetTextPosition(Intro.TextKeyboardLabel[Row],Intro.KeyboardCenterX,RowY)
		else
			SetTextAlignment(Intro.TextKeyboardLabel[Row],2)
			SetTextPosition(Intro.TextKeyboardLabel[Row],Intro.KeyboardCenterX-9,RowY)
		endif
		SetTextPosition(Intro.TextKeyboardKey[Row],Intro.KeyboardCenterX+9,RowY)
		SetTextString(Intro.TextKeyboardLabel[Row],Label)
		SetTextString(Intro.TextKeyboardKey[Row],KeyValue)
		SetTextSize(Intro.TextKeyboardLabel[Row],17)
		SetTextSize(Intro.TextKeyboardKey[Row],17)
		SetTextColor(Intro.TextKeyboardLabel[Row],255,255,255,170)
		SetTextColor(Intro.TextKeyboardKey[Row],255,255,255,170)
		if Row+1 = Intro.OptionSelectionPos
			SetTextSize(Intro.TextKeyboardLabel[Row],19)
			SetTextSize(Intro.TextKeyboardKey[Row],19)
			SetTextColor(Intro.TextKeyboardLabel[Row],0,255,255,222)
			SetTextColor(Intro.TextKeyboardKey[Row],0,255,255,222)
		endif
	next Row
endfunction

function IntroDo(Intro ref as TIntro,Sound ref as TSound,Keys ref as TKeys,Options ref as TGameOptions,JoystickIndex as integer,Now as integer)
	
	local Value as integer
	local AnalogStep as integer
	local AnalogY as float
	local OptionCount as integer
	
	// Analog menu navigation works in both the main and options screens.
	// One step per deflection, then rearm only when the stick returns to neutral.
	AnalogY = GetJoyY(JoystickIndex)
	if AnalogY > -0.3 and AnalogY < 0.3
		Intro.AnalogMenuHeld = FALSE
	else
		if Intro.AnalogMenuHeld = FALSE
			if AnalogY < -0.5
				AnalogStep = -1
				Intro.AnalogMenuHeld = TRUE
			endif
			if AnalogY > 0.5
				AnalogStep = 1
				Intro.AnalogMenuHeld = TRUE
			endif
		endif
	endif
	
	// Keep the existing rotating help text running on both menu screens.
	if TimeGet(Intro.TimerHelp,Now) > 0
		IntroGambleHelp(Intro)
		TimeReset(Intro.TimerHelp,Now)
	endif
	
	if Intro.IsOption = TRUE
		// Page 1=OPTIONS, 2=GAMEPLAY, 3=CONTROLS, 4=AUDIO.
		OptionCount = 3
		if Intro.OptionPage = 1
			OptionCount = 4
		endif
		if Intro.OptionPage = 4
			OptionCount = 1
		endif
		if Intro.OptionPage = 5 then OptionCount = 8
		if Intro.OptionPage = 6 then OptionCount = 11

		if InputActionPressed(Keys,JoystickIndex,ACTION_MOVE_UP) = 1 or GetKeyPressed(KEY_UP) = 1 or AnalogStep = -1
			if Intro.OptionSelectionPos <= 1
				Intro.OptionSelectionPos = OptionCount
			else
				dec Intro.OptionSelectionPos
			endif
			PlaySound(Sound.MenuSound)
		endif
		if InputActionPressed(Keys,JoystickIndex,ACTION_MOVE_DOWN) = 1 or GetKeyPressed(KEY_DOWN) = 1 or AnalogStep = 1
			if Intro.OptionSelectionPos >= OptionCount
				Intro.OptionSelectionPos = 1
			else
				inc Intro.OptionSelectionPos
			endif
			PlaySound(Sound.MenuSound)
		endif

		// Backspace/Select/Y navigate one page back; only root exits to main.
		if InputActionPressed(Keys,JoystickIndex,ACTION_BACK) = 1 or GetJoyPressed(JoystickIndex,JoystickButtonY) = 1
			if Intro.OptionPage = 1
				Intro.IsOption = FALSE
			else
				if Intro.OptionPage = 5 or Intro.OptionPage = 6
					Intro.OptionPage = 3
					Intro.OptionSelectionPos = 1
				else
					Intro.OptionSelectionPos = Intro.OptionPage - 1
					Intro.OptionPage = 1
				endif
			endif
			PlaySound(Sound.SelectSound)
		else
			if InputActionPressed(Keys,JoystickIndex,ACTION_START) = 1 or GetJoyPressed(JoystickIndex,joystickButtonA) = 1
				select Intro.OptionPage
					case 1
						select Intro.OptionSelectionPos
							case 1
								Intro.OptionPage = 2
								Intro.OptionSelectionPos = 1
							endcase
							case 2
								Intro.OptionPage = 3
								Intro.OptionSelectionPos = 1
							endcase
							case 3
								Intro.OptionPage = 4
								Intro.OptionSelectionPos = 1
							endcase
							case 4
								Intro.IsOption = FALSE
							endcase
						endselect
						PlaySound(Sound.SelectSound)
					endcase
					case 2
						select Intro.OptionSelectionPos
							case 1
								if Options.HoverMode = HOVER_MODE_TOGGLE
									Options.HoverMode = HOVER_MODE_HOLD
								else
									Options.HoverMode = HOVER_MODE_TOGGLE
								endif
								GameOptionsSave(Options)
								PlaySound(Sound.SelectSound)
							endcase
							case 3
								Intro.OptionPage = 1
								Intro.OptionSelectionPos = 1
								PlaySound(Sound.SelectSound)
							endcase
						endselect
					endcase
					case 3
						if Intro.OptionSelectionPos = 1
							Intro.OptionPage = 5
							Intro.OptionSelectionPos = 1
							PlaySound(Sound.SelectSound)
						endif
						if Intro.OptionSelectionPos = 3
							Intro.OptionPage = 1
							Intro.OptionSelectionPos = 2
							PlaySound(Sound.SelectSound)
						endif
					endcase
					case 4
						Intro.OptionPage = 1
						Intro.OptionSelectionPos = 3
						PlaySound(Sound.SelectSound)
					endcase
					case 5
						// Step 1 only: category navigation; key entries are read-only.
						if Intro.OptionSelectionPos = 7
							Intro.OptionPage = 6
							Intro.OptionSelectionPos = 1
							PlaySound(Sound.SelectSound)
						endif
						if Intro.OptionSelectionPos = 8
							Intro.OptionPage = 3
							Intro.OptionSelectionPos = 1
							PlaySound(Sound.SelectSound)
						endif
					endcase
					case 6
						if Intro.OptionSelectionPos = 10
							Intro.OptionPage = 5
							Intro.OptionSelectionPos = 1
							PlaySound(Sound.SelectSound)
						endif
						if Intro.OptionSelectionPos = 11
							Intro.OptionPage = 3
							Intro.OptionSelectionPos = 1
							PlaySound(Sound.SelectSound)
						endif
					endcase
				endselect
			endif
		endif

		// Keyboard pages position their title together with their centred table.
		// All other OPTIONS pages retain their original title placement.
		if Intro.OptionPage <> 5 and Intro.OptionPage <> 6
			SetTextPosition(Intro.TextOptionsTitle,Intro.KeyboardCenterX,Intro.KeyboardCenterY-90)
		endif

		// Reuse these four rows across all pages, including their alpha and bold.
		select Intro.OptionPage
			case 1
				SetTextString(Intro.TextOptionsTitle,"OPTIONS")
				SetTextString(Intro.TextOptionsEntry1,"GAMEPLAY")
				SetTextString(Intro.TextOptionsEntry2,"CONTROLS")
				SetTextString(Intro.TextOptionsEntry3,"AUDIO")
				SetTextString(Intro.TextOptionsEntry4,"BACK")
			endcase
			case 2
				SetTextString(Intro.TextOptionsTitle,"GAMEPLAY")
				if Options.HoverMode = HOVER_MODE_TOGGLE
					SetTextString(Intro.TextOptionsEntry1,"HOVER MODE - TOGGLE")
				else
					SetTextString(Intro.TextOptionsEntry1,"HOVER MODE - HOLD")
				endif
				SetTextString(Intro.TextOptionsEntry2,"ENERGY ATTRACT - COMING LATER")
				SetTextString(Intro.TextOptionsEntry3,"BACK")
			endcase
			case 3
				SetTextString(Intro.TextOptionsTitle,"CONTROLS")
				SetTextString(Intro.TextOptionsEntry1,"KEYBOARD")
				SetTextString(Intro.TextOptionsEntry2,"GAMEPAD - COMING LATER")
				SetTextString(Intro.TextOptionsEntry3,"BACK")
			endcase
			case 4
				SetTextString(Intro.TextOptionsTitle,"AUDIO")
				SetTextString(Intro.TextOptionsEntry1,"BACK")
			endcase
			case 5
				SetTextString(Intro.TextOptionsTitle,"KEYBOARD - MOVEMENT")
				IntroKeyboardTableUpdate(Intro,Keys)
			endcase
			case 6
				SetTextString(Intro.TextOptionsTitle,"KEYBOARD - ACTIONS")
				IntroKeyboardTableUpdate(Intro,Keys)
			endcase
		endselect

		SetTextSize(Intro.TextOptionsEntry1,19)
		SetTextSize(Intro.TextOptionsEntry2,19)
		SetTextSize(Intro.TextOptionsEntry3,19)
		SetTextSize(Intro.TextOptionsEntry4,19)
		SetTextColor(Intro.TextOptionsEntry1,255,255,255,111)
		SetTextColor(Intro.TextOptionsEntry2,255,255,255,111)
		SetTextColor(Intro.TextOptionsEntry3,255,255,255,111)
		SetTextColor(Intro.TextOptionsEntry4,255,255,255,111)
		select Intro.OptionSelectionPos
			case 1
				SetTextSize(Intro.TextOptionsEntry1,22)
				SetTextColor(Intro.TextOptionsEntry1,0,255,255,222)
			endcase
			case 2
				SetTextSize(Intro.TextOptionsEntry2,22)
				SetTextColor(Intro.TextOptionsEntry2,0,255,255,222)
			endcase
			case 3
				SetTextSize(Intro.TextOptionsEntry3,22)
				SetTextColor(Intro.TextOptionsEntry3,0,255,255,222)
			endcase
			case 4
				SetTextSize(Intro.TextOptionsEntry4,22)
				SetTextColor(Intro.TextOptionsEntry4,0,255,255,222)
			endcase
		endselect
	else
		if InputActionPressed(Keys,JoystickIndex,ACTION_MOVE_UP) = 1 or GetKeyPressed(KEY_UP) = 1 or AnalogStep = -1
			if Intro.SelctionPos <= 1
				Intro.SelctionPos = 3
			else
				dec Intro.SelctionPos
			endif
			PlaySound(Sound.MenuSound)
		endif
		
		if InputActionPressed(Keys,JoystickIndex,ACTION_MOVE_DOWN) = 1 or GetKeyPressed(KEY_DOWN) = 1 or AnalogStep = 1
			if Intro.SelctionPos >= 3
				Intro.SelctionPos = 1
			else
				inc Intro.SelctionPos
			endif
			PlaySound(Sound.MenuSound)
		endif
		
		select Intro.SelctionPos
			case 1
				SetTextColor(Intro.TextStart,0,255,255,222)
				SetTextColor(Intro.TextOption,255,255,255,111)
				SetTextColor(Intro.TextEnd,255,255,255,111)
				SetTextSize(Intro.TextStart,32)
				SetTextSize(Intro.TextOption,28)
				SetTextSize(Intro.TextEnd,28)
			endcase
			case 2
				
				SetTextColor(Intro.TextStart,255,255,255,111)
				SetTextColor(Intro.TextOption,0,255,255,222)
				SetTextColor(Intro.TextEnd,255,255,255,111)
				SetTextSize(Intro.TextStart,28)
				SetTextSize(Intro.TextOption,32)
				SetTextSize(Intro.TextEnd,28)
			endcase
			case 3
				SetTextColor(Intro.TextStart,255,255,255,111)
				SetTextColor(Intro.TextOption,255,255,255,111)
				SetTextColor(Intro.TextEnd,0,255,255,222)
				SetTextSize(Intro.TextStart,28)
				SetTextSize(Intro.TextOption,28)
				SetTextSize(Intro.TextEnd,32)
			endcase
		endselect
		
		if InputActionPressed(Keys,JoystickIndex,ACTION_START) = 1 or GetJoyPressed(JoystickIndex,joystickButtonA) = 1
			select Intro.SelctionPos
				case 1
					Value = TRUE
				endcase
				case 2
					Intro.IsOption = TRUE
					Intro.OptionSelectionPos = 1
					Intro.OptionPage = 1
				endcase
				case 3
					Intro.IsQuit = TRUE
				endcase
			endselect
			PlaySound(Sound.SelectSound)
		endif
		
		if GetPointerPressed()
			
		endif
		
	endif
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function IntroDraw(Intro ref as TIntro)
	local k as integer

	SpriteDraw(Intro.ProtoBackground.Sprite,Intro.Background.SpriteData)
	
	if Intro.IsOption = TRUE
		Drawtext(Intro.TextOptionsTitle)
		if Intro.OptionPage = 5 or Intro.OptionPage = 6
			for k = 0 to 10
				Drawtext(Intro.TextKeyboardLabel[k])
				Drawtext(Intro.TextKeyboardKey[k])
			next k
		else
			Drawtext(Intro.TextOptionsEntry1)
			if Intro.OptionPage <> 4
				Drawtext(Intro.TextOptionsEntry2)
				Drawtext(Intro.TextOptionsEntry3)
			endif
			if Intro.OptionPage = 1
				Drawtext(Intro.TextOptionsEntry4)
			endif
		endif
	else
		Drawtext(Intro.TextStart)
		Drawtext(Intro.TextOption)
		Drawtext(Intro.TextEnd)
	endif
	// Shared help string stays visible on the main and options screens.
	Drawtext(Intro.TextHelp)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------
