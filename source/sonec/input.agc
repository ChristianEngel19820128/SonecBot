//----------------------------------------------------------------------
// SonecBot input binding defaults.
// Initializes defaults and provides digital action queries.
// Gameplay still uses its existing input until a separate migration step.
//----------------------------------------------------------------------

// Defaults for grouped gameplay preferences; persistence comes in step 7e.
function InputSetDefaultGameOptions(Options ref as TGameOptions)
    Options.Version = GAME_OPTIONS_VERSION
    Options.HoverMode = HOVER_MODE_TOGGLE
endfunction

// One compact, versioned GameOptions record. Key bindings use a separate
// persistence group in a later step; do not create one cookie per option.
// v1 payloads: "1|0" (HOLD) and "1|1" (TOGGLE).
function GameOptionsLoad(Options ref as TGameOptions)
    local Data as string
    local FileID as integer

    // The caller already applied safe defaults. Only known v1 values load.
    Data = ""
    if GetDeviceBaseName() = "html5"
        Data = LoadSharedVariable("sonec_game_options","")
    else
        if GetFileExists("/sonec_game_options.dat") = 1
            FileID = OpenToRead("/sonec_game_options.dat")
            if FileID > 0
                Data = ReadLine(FileID)
                CloseFile(FileID)
            endif
        endif
    endif

    if Data = "1|0"
        Options.HoverMode = HOVER_MODE_HOLD
    endif
    if Data = "1|1"
        Options.HoverMode = HOVER_MODE_TOGGLE
    endif
endfunction

function GameOptionsSave(Options ref as TGameOptions)
    local Data as string
    local FileID as integer

    // Never write malformed or unsupported preferences.
    if Options.Version <> GAME_OPTIONS_VERSION
        exitfunction
    endif
    if Options.HoverMode <> HOVER_MODE_HOLD and Options.HoverMode <> HOVER_MODE_TOGGLE
        exitfunction
    endif

    Data = Str(Options.Version)+"|"+Str(Options.HoverMode)
    if GetDeviceBaseName() = "html5"
        SaveSharedVariable("sonec_game_options",Data)
    else
        FileID = OpenToWrite("/sonec_game_options.dat")
        if FileID > 0
            WriteLine(FileID,Data)
            CloseFile(FileID)
        endif
    endif
endfunction

function InputSetDefaultBindings(Keys ref as TKeys)

    local i as integer

    Keys.Version = INPUT_BINDINGS_VERSION

    // Clear every slot so future default changes never leave stale values.
    for i = 0 to ACTION_LAST
        Keys.Binding[i].Key = 0
        Keys.Binding[i].PadButton = 0
    next i

    // Movement: left hand, WASD + Q/E.
    Keys.Binding[ACTION_MOVE_UP].Key = KEY_W
    Keys.Binding[ACTION_MOVE_DOWN].Key = KEY_S
    Keys.Binding[ACTION_MOVE_LEFT].Key = KEY_A
    Keys.Binding[ACTION_MOVE_RIGHT].Key = KEY_D
    Keys.Binding[ACTION_MOVE_BACK_LEFT].Key = KEY_Q
    Keys.Binding[ACTION_MOVE_BACK_RIGHT].Key = KEY_E

    // D-pad defaults are informational at this stage. Analog sticks and
    // triggers remain in the existing Sonec input code.
    Keys.Binding[ACTION_MOVE_UP].PadButton = JoystickButtonCrossUp
    Keys.Binding[ACTION_MOVE_DOWN].PadButton = JoystickButtonCrossDown
    Keys.Binding[ACTION_MOVE_LEFT].PadButton = JoystickButtonCrossLeft
    Keys.Binding[ACTION_MOVE_RIGHT].PadButton = JoystickButtonCrossRight

    // Actions: right hand, J/K/L + U/I/O.
    Keys.Binding[ACTION_FIRE_MG].Key = KEY_J
    Keys.Binding[ACTION_FIRE_GRENADE].Key = KEY_K
    Keys.Binding[ACTION_FIRE_FLAME].Key = KEY_L
    Keys.Binding[ACTION_FIRE_PLASMA].Key = KEY_I
    Keys.Binding[ACTION_ATTRACT_ENERGY].Key = KEY_U
    Keys.Binding[ACTION_SHIELD].Key = KEY_O

    // Preserve existing gamepad action assignments as default data.
    Keys.Binding[ACTION_FIRE_MG].PadButton = JoystickButtonA
    Keys.Binding[ACTION_FIRE_GRENADE].PadButton = JoystickButtonB
    Keys.Binding[ACTION_FIRE_FLAME].PadButton = JoystickButtonX
    Keys.Binding[ACTION_FIRE_PLASMA].PadButton = JoystickButtonY
    Keys.Binding[ACTION_ATTRACT_ENERGY].PadButton = JoystickButtonLR
    Keys.Binding[ACTION_SHIELD].PadButton = JoystickButtonRR

    // Hover keeps the existing pad button 9 assignment. Its physical identity
    // (L3 or another control) remains to be verified on the target gamepad.
    Keys.Binding[ACTION_HOVER].Key = KEY_SPACE
    Keys.Binding[ACTION_HOVER].PadButton = JoystickButtonPadLeft
    Keys.Binding[ACTION_START].Key = KEY_ENTER
    Keys.Binding[ACTION_START].PadButton = JoystickButtonStart
    Keys.Binding[ACTION_BACK].Key = KEY_BACK
    Keys.Binding[ACTION_BACK].PadButton = JoystickButtonBack

endfunction

//----------------------------------------------------------------------
// Versioned KeyBindings persistence (step 7e.2).
// One compact record for all 15 actions, not a cookie per binding.
// Format: version|key0|pad0|...|key14|pad14 (31 tokens for v1).
// No rebinding UI yet: create the default record only when none exists.
//----------------------------------------------------------------------

function KeyBindingsSerialize(Keys ref as TKeys)
    local Data as string
    local i as integer

    Data = Str(Keys.Version)
    for i = 0 to ACTION_LAST
        Data = Data+"|"+Str(Keys.Binding[i].Key)+"|"+Str(Keys.Binding[i].PadButton)
    next i

endfunction Data

function KeyBindingsSave(Keys ref as TKeys)
    local FileID as integer
    local Data as string
    local i as integer

    if Keys.Version <> INPUT_BINDINGS_VERSION
        exitfunction
    endif
    for i = 0 to ACTION_LAST
        if Keys.Binding[i].Key < 0 or Keys.Binding[i].Key > 255
            exitfunction
        endif
        if Keys.Binding[i].PadButton < 0 or Keys.Binding[i].PadButton > 255
            exitfunction
        endif
    next i

    // Match the loader's safeguard for essential menu controls.
    if Keys.Binding[ACTION_START].Key = 0 and Keys.Binding[ACTION_START].PadButton = 0
        exitfunction
    endif
    if Keys.Binding[ACTION_BACK].Key = 0 and Keys.Binding[ACTION_BACK].PadButton = 0
        exitfunction
    endif

    Data = KeyBindingsSerialize(Keys)
    if GetDeviceBaseName() = "html5"
        SaveSharedVariable("sonec_key_bindings",Data)
    else
        FileID = OpenToWrite("/sonec_key_bindings.dat")
        if FileID > 0
            WriteLine(FileID,Data)
            CloseFile(FileID)
        endif
    endif
endfunction

function KeyBindingsLoad(Keys ref as TKeys)
    local Data as string
    local FileID as integer
    local Candidate as TKeys
    local i as integer
    local KeyText as string
    local PadText as string
    local KeyCode as integer
    local PadCode as integer

    // Caller has already installed the complete fallback defaults.
    Data = ""
    if GetDeviceBaseName() = "html5"
        Data = LoadSharedVariable("sonec_key_bindings","")
    else
        if GetFileExists("/sonec_key_bindings.dat") = 1
            FileID = OpenToRead("/sonec_key_bindings.dat")
            if FileID > 0
                Data = ReadLine(FileID)
                CloseFile(FileID)
            endif
        endif
    endif

    // A missing record is initialized once. Never overwrite damaged data
    // or records from a future version automatically.
    if Data = ""
        KeyBindingsSave(Keys)
        exitfunction
    endif

    if CountStringTokens(Data,"|") <> 1+(ACTION_LAST+1)*2
        exitfunction
    endif
    if GetStringToken(Data,"|",1) <> Str(INPUT_BINDINGS_VERSION)
        exitfunction
    endif

    Candidate.Version = INPUT_BINDINGS_VERSION
    for i = 0 to ACTION_LAST
        KeyText = GetStringToken(Data,"|",2+i*2)
        PadText = GetStringToken(Data,"|",3+i*2)
        KeyCode = Val(KeyText)
        PadCode = Val(PadText)
        if KeyCode < 0 or KeyCode > 255 or PadCode < 0 or PadCode > 255
            exitfunction
        endif
        // Reject malformed numeric tokens, e.g. non-numeric or whitespace.
        if KeyText <> Str(KeyCode) or PadText <> Str(PadCode)
            exitfunction
        endif
        Candidate.Binding[i].Key = KeyCode
        Candidate.Binding[i].PadButton = PadCode
    next i

    // Reject extra separators or tokens discarded by the token parser.
    // Do not partially apply a corrupted record.
    if Data <> KeyBindingsSerialize(Candidate)
        exitfunction
    endif

    // Keep at least one usable input for essential Start/Back actions.
    if Candidate.Binding[ACTION_START].Key = 0 and Candidate.Binding[ACTION_START].PadButton = 0
        exitfunction
    endif
    if Candidate.Binding[ACTION_BACK].Key = 0 and Candidate.Binding[ACTION_BACK].PadButton = 0
        exitfunction
    endif

    for i = 0 to ACTION_LAST
        Keys.Binding[i].Key = Candidate.Binding[i].Key
        Keys.Binding[i].PadButton = Candidate.Binding[i].PadButton
    next i
endfunction

//----------------------------------------------------------------------
// Digital action queries. Return 1 if either assigned device is active.
// No axis/trigger mapping yet: existing movement code still owns those.
// Invalid action indices and unassigned (0) buttons never generate input.
//----------------------------------------------------------------------

function InputActionState(Keys ref as TKeys,JoystickIndex as integer,Action as integer)

    local Value as integer
    local KeyCode as integer
    local PadCode as integer

    Value = 0

    if Action < 0 or Action > ACTION_LAST
        exitfunction Value
    endif

    KeyCode = Keys.Binding[Action].Key
    PadCode = Keys.Binding[Action].PadButton

    if KeyCode > 0
        if GetKeyState(KeyCode) = 1 then Value = 1
    endif

    if PadCode > 0
        if GetJoyState(JoystickIndex,PadCode) = 1 then Value = 1
    endif

endfunction Value

//----------------------------------------------------------------------
// Edge-triggered version for toggle/menu actions.
//----------------------------------------------------------------------

function InputActionPressed(Keys ref as TKeys,JoystickIndex as integer,Action as integer)

    local Value as integer
    local KeyCode as integer
    local PadCode as integer

    Value = 0

    if Action < 0 or Action > ACTION_LAST
        exitfunction Value
    endif

    KeyCode = Keys.Binding[Action].Key
    PadCode = Keys.Binding[Action].PadButton

    if KeyCode > 0
        if GetKeyPressed(KeyCode) = 1 then Value = 1
    endif

    if PadCode > 0
        if GetJoyPressed(JoystickIndex,PadCode) = 1 then Value = 1
    endif

endfunction Value
