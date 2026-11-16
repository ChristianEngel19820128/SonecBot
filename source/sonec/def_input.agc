//----------------------------------------------------------------------
// SonecBot input action identifiers and binding data
// Data definitions only: no input behavior, loading or saving yet.
//----------------------------------------------------------------------

// Six movement actions (left hand).
#constant ACTION_MOVE_UP         0
#constant ACTION_MOVE_DOWN       1
#constant ACTION_MOVE_LEFT       2
#constant ACTION_MOVE_RIGHT      3
#constant ACTION_MOVE_BACK_LEFT  4
#constant ACTION_MOVE_BACK_RIGHT 5

// Six combat/energy actions (right hand).
#constant ACTION_FIRE_MG         6
#constant ACTION_FIRE_GRENADE    7
#constant ACTION_FIRE_FLAME      8
#constant ACTION_FIRE_PLASMA     9
#constant ACTION_ATTRACT_ENERGY 10
#constant ACTION_SHIELD         11

// Additional functions, separate from the 6 + 6 main layout.
#constant ACTION_HOVER          12
#constant ACTION_START          13
#constant ACTION_BACK           14

// AGK fixed-array upper bound (15 actions, indexes 0..14).
#constant ACTION_LAST           14
#constant INPUT_BINDINGS_VERSION 1

type TActionBinding
    Key as integer
    PadButton as integer
endtype

type TKeys
    Version as integer
    Binding as TActionBinding[14]
endtype

// PadButton = 0 can mean no digital button assigned.
// Analog axes and directions remain handled by the existing gamepad code
// until a separately approved input-mapping implementation.
// No default values are initialized in this definitions-only step.
