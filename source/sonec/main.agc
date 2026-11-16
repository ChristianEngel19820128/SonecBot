
// Project: sonec 
// Created: 25-10-25

// TEMPORARY renderer A/B test (Windows): this directive takes effect at app startup.
// Basic = OpenGL; Advanced = Vulkan; Prefer Best = automatic (previous behavior).
// Change ONLY this line, then recompile/restart; restore Prefer Best after diagnosis.
// IMPORTANT: do not ship the temporary Basic setting without a release decision.
#renderer "Basic"

// show all errors

SetErrorMode(2)

// set window properties
SetWindowTitle("SonecBot")

local dx as integer
local dy as integer
local wx as integer
local wy as integer
local vx as integer
local vy as integer
local cx as float
local cy as float

wx = 1350
wy = 675

vx = 900//1280
vy = 450//720

cx = vx/2
cy = vy/2

SetOrientationAllowed(0,0,1,0)
SetWindowSize(wx,wy,0)
SetWindowAllowResize(1)
SetVirtualResolution(vx,vy)

// Windows VSync A/B test: 1 = request monitor VSync, 0 = previous 60 FPS limiter.
// This labels the API call made by the game, not the driver's actual presentation.
#constant WINDOWS_VSYNC_TEST 1
#constant FALLBACK_SYNC_RATE_FPS 60
global MotionDebugSyncRequest as string
// F2 clock diagnostics: never used by gameplay calculations.
global MotionDebugClockRealDeltaMs as integer
global MotionDebugClockVirtualDeltaMs as integer
global MotionDebugClockReadGapMs as integer
global MotionDebugClockGapTotalMs as integer
global MotionDebugClockGapFrames as integer
global MotionDebugClockActiveFrames as integer

if GetDeviceBaseName() = "html5"
	SetVSync(1)
	MotionDebugSyncRequest = "SetVSync(1) requested"
else
	if GetDeviceBaseName() = "windows" and WINDOWS_VSYNC_TEST = 1
		SetVSync(1)
		MotionDebugSyncRequest = "SetVSync(1) requested"
	else
		SetSyncRate(FALLBACK_SYNC_RATE_FPS,1)
		MotionDebugSyncRequest = "SetSyncRate("+Str(FALLBACK_SYNC_RATE_FPS)+",1) requested"
	endif
endif

SetScissor(0,0,0,0)
UseNewDefaultFonts(1)

#constant Device$ GetDeviceBaseName()

#option_explicit

#constant FALSE 0
#constant TRUE 1

#include "def_joypad.agc"
#include "def_keys.agc"
#include "def_input.agc"
#include "def_game.agc"
#include "controls.agc"
#include "input.agc"
#include "math.agc"
#include "collision.agc"
#include "color.agc"
#include "file.agc"
#include "timer.agc"
#include "image.agc"
#include "sprite.agc"
#include "jetfire.agc"
#include "shield.agc"
#include "inenergie.agc"
#include "energie.agc"
#include "flame.agc"
#include "bullet.agc"
#include "grenade.agc"
#include "plasmablitz.agc"
#include "flash.agc"
#include "sonec.agc"
#include "walker.agc"
#include "background.agc"
#include "cloud.agc"
#include "tower.agc"
#include "plate.agc"
#include "chest.agc"
#include "orb.agc"
#include "mine.agc"
#include "explosion.agc"
#include "world.agc"
#include "gui.agc"
#include "sound.agc"
#include "game.agc"
#include "intro.agc"

local FPS as integer
FPS = CreateText("")
SetTextPosition(FPS,10,vy-25)
SetTextSize(FPS,20)

local Pause as integer
Pause = CreateText("PAUSE")
SetTextAlignment(Pause,1)
SetTextBold(Pause,1)
SetTextColor(Pause,0,255,255,222)
SetTextPosition(Pause,vx/2,vy/2)
SetTextSize(Pause,30)

// Prepared binding data; existing gameplay input is not switched over yet.
local Keys as TKeys
InputSetDefaultBindings(Keys)

local Intro as TIntro
local Game as TGame

local Now as integer
Now = GetMilliseconds()

local CurrentNow as integer
CurrentNow = GetMilliseconds()

// Keep both existing clock reads untouched in order and purpose.
local ClockFirstReadMs as integer
local ClockPreviousNowMs as integer
local ClockPreviousVirtualMs as integer

IntroCreate(Intro,vx,vy,Now)
GameCreate(Game,vx,vy)

// Normal background motion: move tower parts on each GameDo with a positive dt.
// F5 retains the original 10-ms gate only as an F2 diagnostic comparison.
TowerMotionEveryFrameEnabled = 1

repeat
	
	SetTextString(FPS,Str(Trunc(ScreenFPS())))
	
	// Capture the existing two time samples without changing their call order.
	ClockPreviousNowMs = Now
	ClockPreviousVirtualMs = CurrentNow
	if Game.IsPause = FALSE
		ClockFirstReadMs = GetMilliseconds()
		CurrentNow = CurrentNow + ClockFirstReadMs - Now
	endif

	Now = GetMilliseconds()
	MotionDebugClockRealDeltaMs = Now - ClockPreviousNowMs
	MotionDebugClockVirtualDeltaMs = CurrentNow - ClockPreviousVirtualMs
	if Game.IsPause = FALSE
		MotionDebugClockReadGapMs = Now - ClockFirstReadMs
		MotionDebugClockGapTotalMs = MotionDebugClockGapTotalMs + MotionDebugClockReadGapMs
		MotionDebugClockActiveFrames = MotionDebugClockActiveFrames + 1
		if MotionDebugClockReadGapMs > 0 then MotionDebugClockGapFrames = MotionDebugClockGapFrames + 1
	else
		// There is only one sample while paused; -1 means no paired read.
		MotionDebugClockReadGapMs = -1
	endif
	// Windows diagnostics (also during pause): F1 Walker, F2 platforms.
	// Only one topic is shown at a time to keep the virtual screen readable.
	if Device$ = "windows" and Game.IsLost = FALSE
		if GetKeyPressed(KEY_F1) = 1
			WalkerDebugToggle()
			PlateDebugEnabled = 0
			MotionRenderSnapEnabled = 0
			TowerMotionEveryFrameEnabled = 1
			PlateMotionEveryFrameEnabled = 0
		endif
		if GetKeyPressed(KEY_F2) = 1
			PlateDebugToggle()
			WalkerDebugEnabled = 0
			if PlateDebugEnabled = 0
				MotionRenderSnapEnabled = 0
				TowerMotionEveryFrameEnabled = 1
				PlateMotionEveryFrameEnabled = 0
			endif
		endif
		// Only while F2 is visible: compare unchanged float drawing to a snapped copy.
		if GetKeyPressed(KEY_F4) = 1 and PlateDebugEnabled = 1
			if MotionRenderSnapEnabled = 0
				MotionRenderSnapEnabled = 1
			else
				MotionRenderSnapEnabled = 0
			endif
		endif
		// F5 compares normal per-GameDo tower movement with the former 10-ms gate.
		if GetKeyPressed(KEY_F5) = 1 and PlateDebugEnabled = 1
			if TowerMotionEveryFrameEnabled = 0
				TowerMotionEveryFrameEnabled = 1
			else
				TowerMotionEveryFrameEnabled = 0
			endif
		endif
		// F6: platform/chest/Walker regression test only; default stays gated.
		if GetKeyPressed(KEY_F6) = 1 and PlateDebugEnabled = 1
			if PlateMotionEveryFrameEnabled = 0
				PlateMotionEveryFrameEnabled = 1
			else
				PlateMotionEveryFrameEnabled = 0
			endif
		endif
	endif

	if Game.IsLost = TRUE
		if IntroDo(Intro,Game.Sound,Game.JoystickIndex,CurrentNow) = TRUE
			GameInit(Game,CurrentNow)
		endif
		IntroDraw(Intro)
	else
		if GetJoyPressed(Game.JoystickIndex,joystickButtonStart) = 1
			if Game.IsPause = FALSE
				Game.IsPause = TRUE
			else
				Game.IsPause = FALSE
			endif
		endif
		if Game.IsPause = FALSE
			GameInput(Game,CurrentNow)
			GameActionInput(Game,CurrentNow)
			GameDo(Game,CurrentNow)		
			GameAnimate(Game,CurrentNow)
		endif		
		GameDraw(Game)
		if Game.IsPause = TRUE
			Drawtext(Pause)
		endif
	endif	
	
	Drawtext(FPS)
	Swap()
	
until GetESCPressed() = 1 or (Device$ <> "html5" and Intro.IsQuit = TRUE)


