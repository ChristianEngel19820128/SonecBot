
// Project: sonec 
// Created: 25-10-25

// show all errors

SetErrorMode(2)

// set window properties
SetWindowTitle( "sonec" )

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

SetOrientationAllowed(0,0,1,0)
SetWindowSize(wx,wy,0)
SetWindowAllowResize(0)

dx = GetDeviceWidth()
dy = GetDeviceHeight()
//vx = wx/(wy/vy)
cx = vx/2
cy = vy/2

SetVirtualResolution(vx,vy)

SetSyncRate(120,0)
//SetVSync(1)
SetScissor(0,0,0,0)
UseNewDefaultFonts(1)

#option_explicit

#constant FALSE 0
#constant TRUE 1

#include "def_joypad.agc"
#include "def_keys.agc"
#include "def_game.agc"
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

local Intro as TIntro
local Game as TGame

local Now as integer
Now = GetMilliseconds()

local CurrentNow as integer
CurrentNow = 0

IntroCreate(Intro,vx,vy,Now)
GameCreate(Game,vx,vy)

repeat
	
	SetTextString(FPS,Str(Trunc(ScreenFPS())))
	
	if Game.IsPause = FALSE
		CurrentNow = CurrentNow + GetMilliseconds() - Now
	endif
	
	Now = GetMilliseconds()
	
	if Game.IsLost = TRUE
		if IntroDo(Intro,Game.Sound,CurrentNow) = TRUE
			GameInit(Game,CurrentNow)
		endif
		IntroDraw(Intro)
	else
		if GetRawJoystickButtonPressed(1,joystickButtonStart) = 1
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
	
until GetRawKeyPressed(Key_Escape) = 1 or Intro.IsQuit = TRUE


