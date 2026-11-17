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
