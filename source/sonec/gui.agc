
//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

function GuiImagesLoad(Gui ref as TGui)
	
	Gui.bar_horizontal.Image.File.Path = "/media/gfx/gui"
	Gui.bar_horizontal.Image.File.Name = "bar_horizontal.png"
	if FilePathSetAndCheck(Gui.bar_horizontal.Image.File) = TRUE
		if ImageLoad(Gui.bar_horizontal.Image) = TRUE
			SpriteLoad(Gui.bar_horizontal)
		endif
	endif
	
	Gui.bar_horizontal_small.Image.File.Path = "/media/gfx/gui"
	Gui.bar_horizontal_small.Image.File.Name = "bar_horizontal_small.png"
	if FilePathSetAndCheck(Gui.bar_horizontal_small.Image.File) = TRUE
		if ImageLoad(Gui.bar_horizontal_small.Image) = TRUE
			SpriteLoad(Gui.bar_horizontal_small)
		endif
	endif
	
	Gui.bar_horizontal_grenade_small.Image.File.Path = "/media/gfx/gui"
	Gui.bar_horizontal_grenade_small.Image.File.Name = "bar_horizontal_grenade_small.png"
	if FilePathSetAndCheck(Gui.bar_horizontal_grenade_small.Image.File) = TRUE
		if ImageLoad(Gui.bar_horizontal_grenade_small.Image) = TRUE
			SpriteLoad(Gui.bar_horizontal_grenade_small)
		endif
	endif
	
	Gui.bar_vertical.Image.File.Path = "/media/gfx/gui"
	Gui.bar_vertical.Image.File.Name = "bar_vertical.png"
	if FilePathSetAndCheck(Gui.bar_vertical.Image.File) = TRUE
		if ImageLoad(Gui.bar_vertical.Image) = TRUE
			SpriteLoad(Gui.bar_vertical)
		endif
	endif
	
	Gui.bar_vertical_small.Image.File.Path = "/media/gfx/gui"
	Gui.bar_vertical_small.Image.File.Name = "bar_vertical_small.png"
	if FilePathSetAndCheck(Gui.bar_vertical_small.Image.File) = TRUE
		if ImageLoad(Gui.bar_vertical_small.Image) = TRUE
			SpriteLoad(Gui.bar_vertical_small)
		endif
	endif
	
	
endfunction

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

function GuiEnergyDraw(Gui ref as TGui,Sonec ref as TSonec,Screen as TSize)
	
	local Data as TSpriteData
	local i as integer
	local max as integer
	local maxOverload as integer
	local EnergyLoad as integer
	local EnergyOverload as integer
	
	Data.Position.x = 10
	max = ceil(Sonec.Health.State*150.0/Sonec.Health.StateMax)
	maxOverload = ceil(Sonec.EnergyShield.State*25.0/Sonec.EnergyShield.StateMax)
	
	if max < 6
		ColorSet(Data.Color,255,0,0,255)
	else
		ColorSet(Data.Color,0,255,0,255)
	endif
	
	for i = 1 to max
		Data.Position.y = Screen.Height -37 - i*(GetSpriteHeight(Gui.bar_horizontal_small.Sprite.ID))
		SpriteDraw(Gui.bar_horizontal_small.Sprite,Data)
	next i
	
	ColorSet(Data.Color,0,127,255,255)
	
	for i = max+1 to max+maxOverload
		Data.Position.y = Screen.Height -37 - i*(GetSpriteHeight(Gui.bar_horizontal_small.Sprite.ID))
		SpriteDraw(Gui.bar_horizontal_small.Sprite,Data)
	next i
	
	
	if Sonec.Energy.State > Sonec.Energy.StateMax
		EnergyLoad = Sonec.Energy.StateMax
		EnergyOverload = Sonec.Energy.State - Sonec.Energy.StateMax
	else
		EnergyLoad = Sonec.Energy.State
		EnergyOverload = 0
	endif
	
	Data.Position.x = 30
	max = ceil(EnergyLoad*20.0/Sonec.Energy.StateMax)
	maxOverload = ceil(EnergyOverload*10.0/Sonec.Energy.StateMax)
	
	ColorSet(Data.Color,0,255,0,255)
	for i = 1 to max
		Data.Position.y = Screen.Height -35 - i*(GetSpriteHeight(Gui.bar_horizontal.Sprite.ID)+2)
		SpriteDraw(Gui.bar_horizontal.Sprite,Data)
	next i
	
	if EnergyOverload > 0
		ColorSet(Data.Color,255,0,0,255)
		for i = max+1 to max+maxOverload
			Data.Position.y = Screen.Height -35 - i*(GetSpriteHeight(Gui.bar_horizontal.Sprite.ID)+2)
			SpriteDraw(Gui.bar_horizontal.Sprite,Data)
		next i
	endif
	
	Data.Position.x = 66
	max = ceil(Sonec.MGun.Ammo*100.0/Sonec.MGun.AmmoMax)
	
	if max < 6
		ColorSet(Data.Color,255,0,0,255)
	else
		ColorSet(Data.Color,0,255,0,255)
	endif
	
	for i = 1 to max
		Data.Position.y = Screen.Height -36 - i*(GetSpriteHeight(Gui.bar_horizontal_small.Sprite.ID)+1)
		SpriteDraw(Gui.bar_horizontal_small.Sprite,Data)
	next i
	
	Data.Position.x = 92
	max = Sonec.GrenadeLauncher.Ammo
	
	if max < 6
		ColorSet(Data.Color,255,0,0,255)
	else
		ColorSet(Data.Color,0,255,0,255)
	endif
	
	for i = 1 to max
		Data.Position.y = Screen.Height -36 - i*(GetSpriteHeight(Gui.bar_horizontal_grenade_small.Sprite.ID)+1)
		SpriteDraw(Gui.bar_horizontal_grenade_small.Sprite,Data)
	next i
	
endfunction

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

