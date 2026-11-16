//----------------------------------------------------------------------
// SonecBot input binding defaults.
// This step only initializes data; gameplay still uses its existing input.
//----------------------------------------------------------------------

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

    // Additional actions; hover L3 is deliberately not assigned until tested.
    Keys.Binding[ACTION_HOVER].Key = KEY_CONTROL
    Keys.Binding[ACTION_START].Key = KEY_ENTER
    Keys.Binding[ACTION_START].PadButton = JoystickButtonStart
    Keys.Binding[ACTION_BACK].Key = KEY_BACK
    Keys.Binding[ACTION_BACK].PadButton = JoystickButtonBack

endfunction
