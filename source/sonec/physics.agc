// Shared ballistic motion. World units: px, ms, px/ms, px/ms^2.
// Positive Y is down. Angles follow AGK/Sonec: 0 up, 90 right, 270 left.
// No sprite, collision, timer or weapon dependencies.

function PhysicsLaunchVelocity(Velocity ref as TSpeed,Angle as float,Speed as float)
    Velocity.x = Sin(Angle)*Speed
    Velocity.y = -Cos(Angle)*Speed
    // Avoid a tiny trigonometric vertical component on horizontal shots.
    if Angle = 90
        Velocity.x = Speed
        Velocity.y = 0
    endif
    if Angle = 270
        Velocity.x = -Speed
        Velocity.y = 0
    endif
endfunction

// Calibrate a horizontal launch without drag to a desired drop and range.
function PhysicsHorizontalRangeGravity(Drop as float,Speed as float,RangePx as float)
    local FlightMs as float
    if RangePx <= 0 or Speed <= 0 or Drop <= 0 then exitfunction 0.0
    FlightMs = RangePx/Speed
endfunction 2.0*Drop/(FlightMs*FlightMs)

// Exact integration of constant gravity and optional linear velocity drag.
// Drag is a nonnegative coefficient in 1/ms. Zero selects the parabola.
// Small drag*dt uses a series to avoid cancellation in float arithmetic.
function PhysicsBallisticStep(Position ref as TPosition,Velocity ref as TSpeed,Gravity as float,Drag as float,DeltaMs as float)
    local Z as float
    local Decay as float
    local Travel as float
    local GravityTravel as float
    if DeltaMs <= 0 then exitfunction
    if Drag <= 0
        Position.x = Position.x+Velocity.x*DeltaMs
        Position.y = Position.y+Velocity.y*DeltaMs+0.5*Gravity*DeltaMs*DeltaMs
        Velocity.y = Velocity.y+Gravity*DeltaMs
        exitfunction
    endif
    Z = Drag*DeltaMs
    Decay = 2.718281828^(-Z)
    if Z < 0.1
        Travel = DeltaMs*(1.0-Z*0.5+Z*Z/6.0-Z*Z*Z/24.0+Z*Z*Z*Z/120.0)
        GravityTravel = DeltaMs*DeltaMs*(0.5-Z/6.0+Z*Z/24.0-Z*Z*Z/120.0+Z*Z*Z*Z/720.0)
    else
        Travel = (1.0-Decay)/Drag
        GravityTravel = (DeltaMs-Travel)/Drag
    endif
    Position.x = Position.x+Velocity.x*Travel
    Position.y = Position.y+Velocity.y*Travel+Gravity*GravityTravel
    Velocity.x = Velocity.x*Decay
    Velocity.y = Velocity.y*Decay+Gravity*Travel
endfunction
