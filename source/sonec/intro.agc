
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

#constant CONFLICT_RED 255
#constant CONFLICT_GREEN 65
#constant CONFLICT_BLUE 65
#constant CONFLICT_ALPHA 222

#constant SELECTED_RED 0
#constant SELECTED_GREEN 255
#constant SELECTED_BLUE 255
#constant SELECTED_ALPHA 222

#constant NORMAL_RED 255
#constant NORMAL_GREEN 255
#constant NORMAL_BLUE 255
#constant NORMAL_ALPHA 222

#constant ALIGNMENT_HELP_STANDARD 1
#constant BOLD_HELP_STANDARD 1

#constant SIZE_HELP_STANDARD 28

#constant ALIGNMENT_MENU_STANDARD 2
#constant BOLD_MENU_STANDARD 1

#constant SIZE_MENU_STANDARD 30
#constant SIZE_MENU_SELECTION 40

#constant SIZE_MENU_LINEHEIGHT 32
#constant SIZE_MENU_MARGINRIGHT 30
#constant SIZE_MENU_MARGINBOTTOM 45

#constant ALIGNMENT_OPTION_STANDARD 1
#constant BOLD_OPTION_STANDARD 1

#constant SIZE_OPTION_HEADER 48
#constant SIZE_OPTION_STANDARD 32
#constant SIZE_OPTION_SELECTION 38

#constant SIZE_OPTION_LINEHEIGHT 34

#constant ALIGNMENT_KEYBOARD_STANDARD 1
#constant BOLD_KEYBOARD_STANDARD 1

function IntroCreate(Intro ref as TIntro,Now as integer)
	local k as integer
	local dy as float

	IntroProtoLoad(Intro)
    IntroPaintCreate(Intro,wx,wy,Now)
    Intro.CrossImageID = LoadImage("/media/gfx/gui/cross.png")
    if Intro.CrossImageID > 0
        Intro.CrossSpriteID = CreateSprite(Intro.CrossImageID)
        SetSpriteOffset(Intro.CrossSpriteID,GetSpriteWidth(Intro.CrossSpriteID)*0.5,GetSpriteHeight(Intro.CrossSpriteID)*0.5)
    endif
    Intro.MusicSoundID = LoadSound("/media/mfx/mystery_loop_2026-11-11.wav")
	
	dy = wy - GetImageHeight(Intro.ProtoBackground.Image.ID)

	Intro.Background.SpriteData.Center = TRUE
	Intro.Background.SpriteData.Position.x = wx * 0.5
	Intro.Background.SpriteData.Position.y = wy * 0.5 - dy
	
	Intro.TextStart = CreateText("START")
	SetTextSize(Intro.TextStart,SIZE_MENU_SELECTION)
	SetTextBold(Intro.TextStart,BOLD_MENU_STANDARD)
	SetTextAlignment(Intro.TextStart,ALIGNMENT_MENU_STANDARD)
	
	Intro.TextOption = CreateText("OPTIONS")
	SetTextSize(Intro.TextOption,SIZE_MENU_STANDARD)
	SetTextBold(Intro.TextOption,BOLD_MENU_STANDARD)
	SetTextAlignment(Intro.TextOption,ALIGNMENT_MENU_STANDARD)
	
	Intro.TextEnd = CreateText("QUIT")
	SetTextSize(Intro.TextEnd,SIZE_MENU_STANDARD)
	SetTextBold(Intro.TextEnd,BOLD_MENU_STANDARD)
	SetTextAlignment(Intro.TextEnd,ALIGNMENT_MENU_STANDARD)
	
	Intro.TextHelp = CreateText("U need a Joypad")
    if GetDeviceBaseName() = "html5"
        SetTextString(Intro.TextHelp,"Click game window to enable keyboard and audio")
    endif
	SetTextSize(Intro.TextHelp,SIZE_HELP_STANDARD)
	SetTextBold(Intro.TextHelp,BOLD_HELP_STANDARD)
	SetTextAlignment(Intro.TextHelp,ALIGNMENT_HELP_STANDARD)
	SetTextPosition(Intro.TextHelp,wx*0.5,wy-GetTextTotalHeight(Intro.TextHelp)-dy*0.5)
	SetTextColor(Intro.TextHelp,NORMAL_RED,NORMAL_GREEN,NORMAL_BLUE,NORMAL_ALPHA)
	
	// Reusable options rows: root categories and compact submenu screens.
	Intro.TextOptionsTitle = CreateText("OPTIONS")
	SetTextAlignment(Intro.TextOptionsTitle,ALIGNMENT_OPTION_STANDARD)
	SetTextSize(Intro.TextOptionsTitle,SIZE_OPTION_HEADER)
	SetTextBold(Intro.TextOptionsTitle,BOLD_OPTION_STANDARD)
	SetTextColor(Intro.TextOptionsTitle,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)

	Intro.TextOptionsEntry1 = CreateText("GAMEPLAY")
	SetTextAlignment(Intro.TextOptionsEntry1,ALIGNMENT_OPTION_STANDARD)
	SetTextSize(Intro.TextOptionsEntry1,SIZE_OPTION_STANDARD)
	SetTextBold(Intro.TextOptionsEntry1,BOLD_OPTION_STANDARD)

	Intro.TextOptionsEntry2 = CreateText("CONTROLS")
	SetTextAlignment(Intro.TextOptionsEntry2,ALIGNMENT_OPTION_STANDARD)
	SetTextSize(Intro.TextOptionsEntry2,SIZE_OPTION_STANDARD)
	SetTextBold(Intro.TextOptionsEntry2,BOLD_OPTION_STANDARD)

	Intro.TextOptionsEntry3 = CreateText("AUDIO")
	SetTextAlignment(Intro.TextOptionsEntry3,ALIGNMENT_OPTION_STANDARD)
	SetTextSize(Intro.TextOptionsEntry3,SIZE_OPTION_STANDARD)
	SetTextBold(Intro.TextOptionsEntry3,BOLD_OPTION_STANDARD)

	Intro.TextOptionsEntry4 = CreateText("BACK")
	SetTextAlignment(Intro.TextOptionsEntry4,ALIGNMENT_OPTION_STANDARD)
	SetTextSize(Intro.TextOptionsEntry4,SIZE_OPTION_STANDARD)
	SetTextBold(Intro.TextOptionsEntry4,BOLD_OPTION_STANDARD)

	// Two compact keyboard tables share eleven fixed rows (no scrolling).
	// Labels are right aligned, key values left aligned, close to the centre.
	Intro.KeyboardCenterX = wx*0.5
	Intro.KeyboardCenterY = wy*0.5
	for k = 0 to 10
		Intro.TextKeyboardLabel[k] = CreateText("")
		SetTextAlignment(Intro.TextKeyboardLabel[k],ALIGNMENT_OPTION_STANDARD)
		SetTextSize(Intro.TextKeyboardLabel[k],SIZE_OPTION_STANDARD)
		SetTextBold(Intro.TextKeyboardLabel[k],BOLD_OPTION_STANDARD)
		SetTextPosition(Intro.TextKeyboardLabel[k],Intro.KeyboardCenterX-9,Intro.KeyboardCenterY)
		Intro.TextKeyboardKey[k] = CreateText("")
		SetTextAlignment(Intro.TextKeyboardKey[k],ALIGNMENT_OPTION_STANDARD)
		SetTextSize(Intro.TextKeyboardKey[k],SIZE_OPTION_STANDARD)
		SetTextBold(Intro.TextKeyboardKey[k],BOLD_OPTION_STANDARD)
		SetTextPosition(Intro.TextKeyboardKey[k],Intro.KeyboardCenterX+9,Intro.KeyboardCenterY)
	next k

	Intro.TextCapturePrompt = CreateText("PRESS NEW KEY")
	SetTextAlignment(Intro.TextCapturePrompt,ALIGNMENT_OPTION_STANDARD)
	SetTextSize(Intro.TextCapturePrompt,SIZE_OPTION_STANDARD)
	SetTextBold(Intro.TextCapturePrompt,BOLD_OPTION_STANDARD)
	SetTextPosition(Intro.TextCapturePrompt,Intro.KeyboardCenterX,Intro.KeyboardCenterY-15)
	SetTextColor(Intro.TextCapturePrompt,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
	Intro.TextCaptureCancel = CreateText("BACKSPACE - CANCEL")
	SetTextAlignment(Intro.TextCaptureCancel,ALIGNMENT_OPTION_STANDARD)
	SetTextSize(Intro.TextCaptureCancel,SIZE_OPTION_STANDARD)
	SetTextBold(Intro.TextCaptureCancel,BOLD_OPTION_STANDARD)
	SetTextPosition(Intro.TextCaptureCancel,Intro.KeyboardCenterX,Intro.KeyboardCenterY+25)
	SetTextColor(Intro.TextCaptureCancel,NORMAL_RED,NORMAL_GREEN,NORMAL_BLUE,NORMAL_ALPHA)
	Intro.KeyboardCapture = FALSE
	Intro.KeyboardCaptureArmed = FALSE
	Intro.KeyboardCaptureAction = 0

	Intro.SelctionPos = 1
	Intro.OptionSelectionPos = 1
	Intro.OptionPage = 1 // 1=OPTIONS, 2=GAMEPLAY, 3=CONTROLS, 4=AUDIO, 5=MOVEMENT, 6=ACTIONS, 7=RESTORE CONFIRM
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
	
	i = random(0,16)
	
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

// Keyboard capture accepts exactly SPACE, arrows, digits and A-Z.
function IntroKeyboardAllowed(KeyCode as integer)
	local Allowed as integer
	if KeyCode = KEY_SPACE then Allowed = 1
	if KeyCode >= KEY_LEFT and KeyCode <= KEY_DOWN then Allowed = 1
	if KeyCode >= KEY_0 and KeyCode <= KEY_9 then Allowed = 1
	if KeyCode >= KEY_A and KeyCode <= KEY_Z then Allowed = 1
endfunction Allowed

// Prevent Ctrl/Alt/Win shortcuts from becoming a binding.
function IntroKeyboardModifierHeld()
	local Held as integer
	if GetKeyState(KEY_CONTROL) = 1 then Held = 1
	if GetKeyState(18) = 1 then Held = 1 // Alt
	if GetKeyState(91) = 1 or GetKeyState(92) = 1 or GetKeyState(93) = 1 then Held = 1 // OS keys
endfunction Held

// The pressed scan is restricted to our 41-key whitelist.
function IntroKeyboardFindPressed()
	local KeyCode as integer
	local Result as integer
	if IntroKeyboardModifierHeld() = 1 then exitfunction 0
	for KeyCode = KEY_SPACE to KEY_Z
		if IntroKeyboardAllowed(KeyCode) = 1
			if GetKeyPressed(KeyCode) = 1
				Result = KeyCode
				exitfunction Result
			endif
		endif
	next KeyCode
endfunction Result

// Show the capture prompt in place of the table without changing its layout.
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

// Detect duplicate nonzero keyboard assignments across all 15 actions.
// A conflict is visual only: both bindings remain valid and unchanged.
function IntroKeyboardKeyConflict(Keys ref as TKeys,Action as integer)
	local Other as integer
	local KeyCode as integer
	local Conflict as integer

	if Action < 0 or Action > ACTION_LAST then exitfunction 0
	KeyCode = Keys.Binding[Action].Key
	if KeyCode = 0 then exitfunction 0

	for Other = 0 to ACTION_LAST
		if Other <> Action
			if Keys.Binding[Other].Key = KeyCode
				Conflict = 1
				exitfunction Conflict
			endif
		endif
	next Other
endfunction Conflict

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

	// Same title and first action height on both keyboard pages.
	// Use the taller ACTIONS page (11 rows) to anchor both tables;
	// MOVEMENT then has more free space below its shorter list.
	// Keep the 12-pixel break before each two-row navigation pair.
	NavigationGap = 12
	RowStart = Intro.KeyboardCenterY - ((11-1)*20+NavigationGap+62)/2+44
	SetTextPosition(Intro.TextOptionsTitle,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*4-GetTextTotalHeight(Intro.TextOptionsTitle)*0.5)

	for Row = 0 to 10
		RowY = RowStart + Row*20
		if Row >= Count-2 then RowY = RowY + NavigationGap
		IsNavigation = FALSE
		Index = -1 // navigation entries never represent a key binding
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
		SetTextAlignment(Intro.TextKeyboardLabel[Row],ALIGNMENT_KEYBOARD_STANDARD)
		SetTextBold(Intro.TextKeyboardLabel[Row],BOLD_KEYBOARD_STANDARD)
		if IsNavigation = TRUE
			SetTextPosition(Intro.TextKeyboardLabel[Row],wx*0.5,wy*0.5-2*SIZE_OPTION_LINEHEIGHT+SIZE_OPTION_LINEHEIGHT*(Row+1)-GetTextTotalHeight(Intro.TextKeyboardLabel[Row])*0.5)
		else
			SetTextPosition(Intro.TextKeyboardLabel[Row],wx*0.5,wy*0.5-2*SIZE_OPTION_LINEHEIGHT+SIZE_OPTION_LINEHEIGHT*(Row)-GetTextTotalHeight(Intro.TextKeyboardLabel[Row])*0.5)
		endif
		
		SetTextString(Intro.TextKeyboardLabel[Row],Label)
		if Len(KeyValue) > 0 then SetTextString(Intro.TextKeyboardKey[Row],"("+KeyValue+")")
		SetTextSize(Intro.TextKeyboardLabel[Row],SIZE_OPTION_STANDARD)
		SetTextSize(Intro.TextKeyboardKey[Row],SIZE_OPTION_STANDARD)
		SetTextColor(Intro.TextKeyboardLabel[Row],255,255,255,170)
		SetTextColor(Intro.TextKeyboardKey[Row],255,255,255,170)
		if Row+1 = Intro.OptionSelectionPos
			SetTextSize(Intro.TextKeyboardLabel[Row],SIZE_OPTION_STANDARD)
			SetTextSize(Intro.TextKeyboardKey[Row],SIZE_OPTION_STANDARD)
			SetTextColor(Intro.TextKeyboardLabel[Row],SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
			SetTextColor(Intro.TextKeyboardKey[Row],SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
		endif
		// Keep selected action labels cyan; only conflicting key values turn red.
		if Index >= 0
			if IntroKeyboardKeyConflict(Keys,Index) = 1
				SetTextColor(Intro.TextKeyboardKey[Row],CONFLICT_RED,CONFLICT_GREEN,CONFLICT_BLUE,CONFLICT_ALPHA)
			endif
		endif

		SetTextPosition(Intro.TextKeyboardKey[Row],wx*0.5+120,wy*0.5-2*SIZE_OPTION_LINEHEIGHT+SIZE_OPTION_LINEHEIGHT*(Row)-GetTextTotalHeight(Intro.TextKeyboardLabel[Row])*0.5)

	next Row
endfunction

// Experimental menu-only loop; keep sound effects and gameplay audio independent.
function IntroMusicStart(Intro ref as TIntro)
    if Intro.MusicSoundID > 0 and Intro.MusicInstanceID = 0
        Intro.MusicInstanceID = PlaySound(Intro.MusicSoundID,100,1)
    endif
endfunction

function IntroMusicStop(Intro ref as TIntro)
    if Intro.MusicSoundID > 0 and Intro.MusicInstanceID > 0
        StopSound(Intro.MusicSoundID)
        Intro.MusicInstanceID = 0
    endif
endfunction

function IntroDo(Intro ref as TIntro,Sound ref as TSound,Keys ref as TKeys,Options ref as TGameOptions,JoystickIndex as integer,Now as integer)
	
	local Value as integer
	local AnalogStep as integer
	local AnalogY as float
	local OptionCount as integer
	local CapturedKey as integer
	local DefaultKeys as TKeys
	local BindingIndex as integer
	local dy as float
	local Main as integer
	local Option as integer

	// Capture is modal: no navigation, page changes or gameplay keys run.
	if Intro.KeyboardCapture = TRUE
		if GetKeyPressed(KEY_BACK) = 1
			Intro.KeyboardCapture = FALSE
			Intro.KeyboardCaptureArmed = FALSE
			PlaySound(Sound.SelectSound)
		else
			// Do not capture the Enter/A press that opened the prompt.
			if Intro.KeyboardCaptureArmed = FALSE
				if GetKeyState(KEY_ENTER) = 0 and GetJoyState(JoystickIndex,JoystickButtonA) = 0
					Intro.KeyboardCaptureArmed = TRUE
				endif
			else
				CapturedKey = IntroKeyboardFindPressed()
				if CapturedKey > 0
					Keys.Binding[Intro.KeyboardCaptureAction].Key = CapturedKey
					KeyBindingsSave(Keys)
					Intro.KeyboardCapture = FALSE
					Intro.KeyboardCaptureArmed = FALSE
					PlaySound(Sound.SelectSound)
				endif
			endif
		endif
		exitfunction Value
	endif
	
		if Intro.IsOption = FALSE
			Main = 1
			Option = 0
		else
			Main = 0
			Option = 1
		endif

		if Main = 1 and (GetKeyPressed(KEY_ENTER) = 1 or GetJoyPressed(JoystickIndex,joystickButtonA) = 1)
			select Intro.SelctionPos
				case 1
					Value = TRUE
				endcase
				case 2
					Intro.IsOption = TRUE
					Intro.OptionSelectionPos = 1
					Intro.OptionPage = 1
					// IntroDraw can render OPTIONS in this same frame.
					// Initialize the correct title and highlight immediately,
					// instead of displaying the previous page's stale colours.
					SetTextString(Intro.TextOptionsTitle,"OPTIONS")
					SetTextPosition(Intro.TextOptionsTitle,Intro.KeyboardCenterX,Intro.KeyboardCenterY-90)
					SetTextSize(Intro.TextOptionsTitle,SIZE_OPTION_HEADER)
					SetTextString(Intro.TextOptionsEntry1,"GAMEPLAY")
					SetTextString(Intro.TextOptionsEntry2,"CONTROLS")
					SetTextString(Intro.TextOptionsEntry3,"AUDIO")
					SetTextString(Intro.TextOptionsEntry4,"BACK")
					SetTextSize(Intro.TextOptionsEntry1,SIZE_OPTION_STANDARD)
					SetTextSize(Intro.TextOptionsEntry2,SIZE_OPTION_STANDARD)
					SetTextSize(Intro.TextOptionsEntry3,SIZE_OPTION_STANDARD)
					SetTextSize(Intro.TextOptionsEntry4,SIZE_OPTION_STANDARD)
					SetTextColor(Intro.TextOptionsEntry1,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
					SetTextColor(Intro.TextOptionsEntry2,255,255,255,111)
					SetTextColor(Intro.TextOptionsEntry3,255,255,255,111)
					SetTextColor(Intro.TextOptionsEntry4,255,255,255,111)
					SetTextPosition(Intro.TextOptionsEntry1,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*1-GetTextTotalHeight(Intro.TextOptionsEntry1)*0.5)
					SetTextPosition(Intro.TextOptionsEntry2,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*0-GetTextTotalHeight(Intro.TextOptionsEntry2)*0.5)
					SetTextPosition(Intro.TextOptionsEntry3,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*-1-GetTextTotalHeight(Intro.TextOptionsEntry3)*0.5)
					SetTextPosition(Intro.TextOptionsEntry4,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*-2-GetTextTotalHeight(Intro.TextOptionsEntry4)*0.5)
					Option = 1
				endcase
				case 3
					Intro.IsQuit = TRUE
				endcase
			endselect
			PlaySound(Sound.SelectSound)
		endif


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
	
	if Intro.IsOption = FALSE
        IntroPaintUpdate(Intro,Now)
    endif

	if Intro.IsOption = TRUE
		// Page 1=OPTIONS, 2=GAMEPLAY, 3=CONTROLS, 4=AUDIO.
		OptionCount = 3
		if Intro.OptionPage = 1 or Intro.OptionPage = 3
			OptionCount = 4
		endif
		if Intro.OptionPage = 4
			OptionCount = 1
		endif
		if Intro.OptionPage = 7 then OptionCount = 2
		if Intro.OptionPage = 5 then OptionCount = 8
		if Intro.OptionPage = 6 then OptionCount = 11

		if GetKeyPressed(KEY_W) = 1 or GetKeyPressed(KEY_UP) = 1 or GetJoyPressed(JoystickIndex,JoystickButtonCrossUp) = 1 or AnalogStep = -1
			if Intro.OptionSelectionPos <= 1
				Intro.OptionSelectionPos = OptionCount
			else
				dec Intro.OptionSelectionPos
			endif
			PlaySound(Sound.MenuSound)
		endif
		if GetKeyPressed(KEY_S) = 1 or GetKeyPressed(KEY_DOWN) = 1 or GetJoyPressed(JoystickIndex,JoystickButtonCrossDown) = 1 or AnalogStep = 1
			if Intro.OptionSelectionPos >= OptionCount
				Intro.OptionSelectionPos = 1
			else
				inc Intro.OptionSelectionPos
			endif
			PlaySound(Sound.MenuSound)
		endif

		// Backspace/Select/Y navigate one page back; only root exits to main.
		if GetKeyPressed(KEY_BACK) = 1 or GetJoyPressed(JoystickIndex,JoystickButtonBack) = 1 or GetJoyPressed(JoystickIndex,JoystickButtonY) = 1
			if Intro.OptionPage = 1
				Intro.IsOption = FALSE
			else
				if Intro.OptionPage = 5 or Intro.OptionPage = 6
					Intro.OptionPage = 3
					Intro.OptionSelectionPos = 1
				else
					if Intro.OptionPage = 7
						Intro.OptionPage = 3
						Intro.OptionSelectionPos = 2
					else
						Intro.OptionSelectionPos = Intro.OptionPage - 1
						Intro.OptionPage = 1
					endif
				endif
			endif
			PlaySound(Sound.SelectSound)
		else
			if Main = 1 and Option = 1
				Main = 0
			else
			if (GetKeyPressed(KEY_ENTER) = 1 or GetJoyPressed(JoystickIndex,joystickButtonA) = 1)
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
								Option = 0
								Main = 1
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
						if Intro.OptionSelectionPos = 2
							Intro.OptionPage = 7
							Intro.OptionSelectionPos = 2 // CANCEL is the safe default
							PlaySound(Sound.SelectSound)
						endif
						if Intro.OptionSelectionPos = 4
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
						if Intro.OptionSelectionPos >= 1 and Intro.OptionSelectionPos <= 6
							Intro.KeyboardCaptureAction = Intro.OptionSelectionPos-1
							Intro.KeyboardCapture = TRUE
							Intro.KeyboardCaptureArmed = FALSE
							PlaySound(Sound.SelectSound)
						endif
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
					case 7
						if Intro.OptionSelectionPos = 1
							// Take keyboard defaults only; preserve all current pad bindings.
							InputSetDefaultBindings(DefaultKeys)
							for BindingIndex = 0 to ACTION_LAST
								Keys.Binding[BindingIndex].Key = DefaultKeys.Binding[BindingIndex].Key
							next BindingIndex
							KeyBindingsSave(Keys)
						endif
						Intro.OptionPage = 3
						Intro.OptionSelectionPos = 2
						PlaySound(Sound.SelectSound)
					endcase
					case 6
						if Intro.OptionSelectionPos >= 1 and Intro.OptionSelectionPos <= 9
							Intro.KeyboardCaptureAction = Intro.OptionSelectionPos+5
							Intro.KeyboardCapture = TRUE
							Intro.KeyboardCaptureArmed = FALSE
							PlaySound(Sound.SelectSound)
						endif
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
				SetTextString(Intro.TextOptionsEntry2,"RESTORE DEFAULTS")
				SetTextString(Intro.TextOptionsEntry3,"GAMEPAD - COMING LATER")
				SetTextString(Intro.TextOptionsEntry4,"BACK")
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
			case 7
				SetTextString(Intro.TextOptionsTitle,"RESTORE KEYBOARD DEFAULTS?")
				SetTextString(Intro.TextOptionsEntry1,"RESET")
				SetTextString(Intro.TextOptionsEntry2,"CANCEL")
			endcase
		endselect

		// During capture, the existing title identifies the selected action.
		// The action row text is already populated by IntroKeyboardTableUpdate.
		if Intro.OptionPage <> 5 and Intro.OptionPage <> 6
			if Intro.KeyboardCapture = TRUE
				SetTextString(Intro.TextOptionsTitle,"CHANGE KEY - "+GetTextString(Intro.TextKeyboardLabel[Intro.OptionSelectionPos-1]))
			endif
			SetTextSize(Intro.TextOptionsTitle,SIZE_OPTION_HEADER)
			SetTextPosition(Intro.TextOptionsTitle,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*3-GetTextTotalHeight(Intro.TextOptionsTitle)*0.5)
		endif

		SetTextSize(Intro.TextOptionsEntry1,SIZE_OPTION_STANDARD)
		SetTextSize(Intro.TextOptionsEntry2,SIZE_OPTION_STANDARD)
		SetTextSize(Intro.TextOptionsEntry3,SIZE_OPTION_STANDARD)
		SetTextSize(Intro.TextOptionsEntry4,SIZE_OPTION_STANDARD)
		SetTextColor(Intro.TextOptionsEntry1,255,255,255,111)
		SetTextColor(Intro.TextOptionsEntry2,255,255,255,111)
		SetTextColor(Intro.TextOptionsEntry3,255,255,255,111)
		SetTextColor(Intro.TextOptionsEntry4,255,255,255,111)
		select Intro.OptionSelectionPos
			case 1
				SetTextSize(Intro.TextOptionsEntry1,SIZE_OPTION_SELECTION)
				SetTextColor(Intro.TextOptionsEntry1,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
			endcase
			case 2
				SetTextSize(Intro.TextOptionsEntry2,SIZE_OPTION_SELECTION)
				SetTextColor(Intro.TextOptionsEntry2,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
			endcase
			case 3
				SetTextSize(Intro.TextOptionsEntry3,SIZE_OPTION_SELECTION)
				SetTextColor(Intro.TextOptionsEntry3,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
			endcase
			case 4
				SetTextSize(Intro.TextOptionsEntry4,SIZE_OPTION_SELECTION)
				SetTextColor(Intro.TextOptionsEntry4,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
			endcase
		endselect
	SetTextPosition(Intro.TextOptionsEntry1,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*1-GetTextTotalHeight(Intro.TextOptionsEntry1)*0.5)
	SetTextPosition(Intro.TextOptionsEntry2,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*0-GetTextTotalHeight(Intro.TextOptionsEntry2)*0.5)
	SetTextPosition(Intro.TextOptionsEntry3,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*-1-GetTextTotalHeight(Intro.TextOptionsEntry3)*0.5)
	SetTextPosition(Intro.TextOptionsEntry4,wx*0.5,wy*0.5-SIZE_OPTION_LINEHEIGHT*-2-GetTextTotalHeight(Intro.TextOptionsEntry4)*0.5)
	else
		if GetKeyPressed(KEY_W) = 1 or GetKeyPressed(KEY_UP) = 1 or GetJoyPressed(JoystickIndex,JoystickButtonCrossUp) = 1 or AnalogStep = -1
			if Intro.SelctionPos <= 1
				Intro.SelctionPos = 3
			else
				dec Intro.SelctionPos
			endif
			PlaySound(Sound.MenuSound)
		endif
		
		if GetKeyPressed(KEY_S) = 1 or GetKeyPressed(KEY_DOWN) = 1 or GetJoyPressed(JoystickIndex,JoystickButtonCrossDown) = 1 or AnalogStep = 1
			if Intro.SelctionPos >= 3
				Intro.SelctionPos = 1
			else
				inc Intro.SelctionPos
			endif
			PlaySound(Sound.MenuSound)
		endif
		
		select Intro.SelctionPos
			case 1
				SetTextColor(Intro.TextStart,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
				SetTextColor(Intro.TextOption,255,255,255,111)
				SetTextColor(Intro.TextEnd,255,255,255,111)
				SetTextSize(Intro.TextStart,SIZE_MENU_SELECTION)
				SetTextSize(Intro.TextOption,SIZE_MENU_STANDARD)
				SetTextSize(Intro.TextEnd,SIZE_MENU_STANDARD)

			endcase
			case 2
				
				SetTextColor(Intro.TextStart,255,255,255,111)
				SetTextColor(Intro.TextOption,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
				SetTextColor(Intro.TextEnd,255,255,255,111)
				SetTextSize(Intro.TextStart,SIZE_MENU_STANDARD)
				SetTextSize(Intro.TextOption,SIZE_MENU_SELECTION)
				SetTextSize(Intro.TextEnd,SIZE_MENU_STANDARD)
			endcase
			case 3
				SetTextColor(Intro.TextStart,255,255,255,111)
				SetTextColor(Intro.TextOption,255,255,255,111)
				SetTextColor(Intro.TextEnd,SELECTED_RED,SELECTED_GREEN,SELECTED_BLUE,SELECTED_ALPHA)
				SetTextSize(Intro.TextStart,SIZE_MENU_STANDARD)
				SetTextSize(Intro.TextOption,SIZE_MENU_STANDARD)
				SetTextSize(Intro.TextEnd,SIZE_MENU_SELECTION)
			endcase
		endselect
	
dy = wy - GetImageHeight(Intro.ProtoBackground.Image.ID)	
SetTextPosition(Intro.TextStart,wx-SIZE_MENU_MARGINRIGHT,wy-dy-SIZE_MENU_MARGINBOTTOM-SIZE_MENU_LINEHEIGHT*3.0-GetTextTotalHeight(Intro.TextStart)*0.5)
SetTextPosition(Intro.TextOption,wx-SIZE_MENU_MARGINRIGHT,wy-dy-SIZE_MENU_MARGINBOTTOM-SIZE_MENU_LINEHEIGHT*2.0-GetTextTotalHeight(Intro.TextOption)*0.5)
SetTextPosition(Intro.TextEnd,wx-SIZE_MENU_MARGINRIGHT,wy-dy-SIZE_MENU_MARGINBOTTOM-SIZE_MENU_LINEHEIGHT*1.0-GetTextTotalHeight(Intro.TextEnd)*0.5)

		if GetPointerPressed()
            IntroPaintShoot(Intro,pointerNX,pointerNY,Now)
        endif
		
	endif
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function IntroCrossDraw(Intro ref as TIntro)
    local X as float
    local Y as float
    X = pointerNX + pointerSX
    Y = pointerNY + pointerSY
    if Intro.CrossSpriteID > 0 and X >= 1 and X < Intro.MenuWidth - 1 and Y >= 1 and Y < Intro.MenuHeight - 1
        SetRawMouseVisible(0)
        SetSpritePositionByOffset(Intro.CrossSpriteID,pointerNX,pointerNY)
        DrawSprite(Intro.CrossSpriteID)
    else
        SetRawMouseVisible(1)
    endif
endfunction

function IntroDraw(Intro ref as TIntro)
	local k as integer

	SpriteDraw(Intro.ProtoBackground.Sprite,Intro.Background.SpriteData)
    if Intro.IsOption = FALSE
        IntroPaintDraw(Intro)
        if Intro.PaintResultEnd > 0 then DrawText(Intro.PaintScoreText)
    endif
	
	if Intro.IsOption = TRUE
		Drawtext(Intro.TextOptionsTitle)
		if Intro.OptionPage = 5 or Intro.OptionPage = 6
			if Intro.KeyboardCapture = TRUE
				Drawtext(Intro.TextCapturePrompt)
				Drawtext(Intro.TextCaptureCancel)
			else
				for k = 0 to 10
					Drawtext(Intro.TextKeyboardLabel[k])
					Drawtext(Intro.TextKeyboardKey[k])
				next k
			endif
		else
			Drawtext(Intro.TextOptionsEntry1)
			if Intro.OptionPage <> 4
				Drawtext(Intro.TextOptionsEntry2)
				if Intro.OptionPage <> 7
					Drawtext(Intro.TextOptionsEntry3)
				endif
			endif
			if Intro.OptionPage = 1 or Intro.OptionPage = 3
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
