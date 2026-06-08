
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
	
	Intro.SelctionPos = 1
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

function IntroDo(Intro ref as TIntro,Sound ref as TSound,Now as integer)
	
	local Value as integer
	
	if TimeGet(Intro.TimerHelp,Now) > 0
		IntroGambleHelp(Intro)
		TimeReset(Intro.TimerHelp,Now)
	endif
	
	if GetRawJoystickButtonPressed(1,joystickButtonCrossUp) = 1
		if Intro.SelctionPos <= 1
			Intro.SelctionPos = 3
		else
			dec Intro.SelctionPos
		endif
		PlaySound(Sound.MenuSound)
	endif
	
		if GetRawJoystickButtonPressed(1,joystickButtonCrossDown) = 1
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
	
	if GetRawJoystickButtonPressed(1,joystickButtonStart) = 1 or GetRawJoystickButtonPressed(1,joystickButtonA) = 1
		select Intro.SelctionPos
			case 1
				Value = TRUE
			endcase
			case 2
				Intro.IsOption = TRUE
			endcase
			case 3
				Intro.IsQuit = TRUE
			endcase
		endselect
		PlaySound(Sound.SelectSound)
	endif
	
	if GetPointerPressed()
		
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function IntroDraw(Intro ref as TIntro)

	SpriteDraw(Intro.ProtoBackground.Sprite,Intro.Background.SpriteData)
	
	Drawtext(Intro.TextStart)
	Drawtext(Intro.TextOption)
	Drawtext(Intro.TextEnd)
	Drawtext(Intro.TextHelp)
	
endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------
