
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SoundLoad(Sound ref as TSound)
	
	local File as TFilePath
	
	File.Path = "/media/sfx"
	File.Name = "mgun.wav"
	if FilePathSetAndCheck(File) = TRUE
		Sound.MGunSound = LoadSound(File.Name)
	endif
	File.Name = "grenade.wav"
	if FilePathSetAndCheck(File) = TRUE
		Sound.GrenadeLauncherSound = LoadSound(File.Name)
	endif
	File.Name = "mflame.wav"
	if FilePathSetAndCheck(File) = TRUE
		Sound.MFlameSound = LoadSound(File.Name)
	endif
	File.Name = "menu.wav"
	if FilePathSetAndCheck(File) = TRUE
		Sound.MenuSound = LoadSound(File.Name)
	endif
	File.Name = "start.wav"
	if FilePathSetAndCheck(File) = TRUE
		Sound.SelectSound = LoadSound(File.Name)
	endif
	File.Name = "impact.wav"
	if FilePathSetAndCheck(File) = TRUE
		Sound.ImpactSound = LoadSound(File.Name)
	endif
	File.Name = "explode.wav"
	if FilePathSetAndCheck(File) = TRUE
		Sound.ExplodeSound = LoadSound(File.Name)
	endif
	File.Name = "explosion.wav"
	if FilePathSetAndCheck(File) = TRUE
		Sound.ExplosionSound = LoadSound(File.Name)
	endif

endfunction

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function SoundPlayPitched(SoundID as integer,Rate as integer)
	
	local Value as integer
	
	if GetSoundExists(SoundID) = 1
		if GetSoundMinRate() < Rate and GetSoundMaxRate() > Rate
			SetSoundInstanceRate(SoundID,Rate)
		else
			SetSoundInstanceRate(SoundID,1)
		endif
		Value = PlaySound(SoundID)
	endif

endfunction Value

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

function SoundPlay(SoundID as integer)
	
	local Value as integer
	
	SoundPlayPitched(SoundID,1)

endfunction Value

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
