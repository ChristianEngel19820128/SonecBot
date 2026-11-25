
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function BoxInBox(Box1P1 as TPosition,Box1P2 as TPosition,Box2P1 as TPosition,Box2P2 as TPosition)

	local Value as integer
	
	Value = FALSE

	if Box1P1.X <= Box2P2.X
		if Box1P2.X >= Box2P1.X
			if Box1P1.Y <= Box2P2.Y
				if Box1P2.Y >= Box2P1.Y
					Value = TRUE
				endif
			endif
		endif
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------



// Pure geometry: earliest segment entry, -1 = miss, 0 = initial overlap.
// Expand a target AABB by projectile half extents (swept AABB).
function CollisionBoxSweepEntry(StartPos as TPosition,EndPos as TPosition,BoxMin as TPosition,BoxMax as TPosition,HalfW as float,HalfH as float)
    local Dx as float
    local Dy as float
    local MinX as float
    local MaxX as float
    local MinY as float
    local MaxY as float
    local NearTime as float
    local FarTime as float
    local AxisNear as float
    local AxisFar as float
    local Temp as float
    MinX = BoxMin.x-HalfW
    MaxX = BoxMax.x+HalfW
    MinY = BoxMin.y-HalfH
    MaxY = BoxMax.y+HalfH
    Dx = EndPos.x-StartPos.x
    Dy = EndPos.y-StartPos.y
    NearTime = 0
    FarTime = 1
    if Dx = 0
        if StartPos.x < MinX or StartPos.x > MaxX then exitfunction -1.0
    else
        AxisNear = (MinX-StartPos.x)/Dx
        AxisFar = (MaxX-StartPos.x)/Dx
        if AxisNear > AxisFar
            Temp = AxisNear
            AxisNear = AxisFar
            AxisFar = Temp
        endif
        if AxisNear > NearTime then NearTime = AxisNear
        if AxisFar < FarTime then FarTime = AxisFar
    endif
    if Dy = 0
        if StartPos.y < MinY or StartPos.y > MaxY then exitfunction -1.0
    else
        AxisNear = (MinY-StartPos.y)/Dy
        AxisFar = (MaxY-StartPos.y)/Dy
        if AxisNear > AxisFar
            Temp = AxisNear
            AxisNear = AxisFar
            AxisFar = Temp
        endif
        if AxisNear > NearTime then NearTime = AxisNear
        if AxisFar < FarTime then FarTime = AxisFar
    endif
    if NearTime <= FarTime and FarTime >= 0 and NearTime <= 1 then exitfunction NearTime
endfunction -1.0

// Exact segment-circle entry, including a circle entered before an endpoint
// whose closest approach would lie beyond the segment.
function CollisionCircleSweepEntry(StartPos as TPosition,EndPos as TPosition,Center as TPosition,Radius as float)
    local X as float
    local Y as float
    local Dx as float
    local Dy as float
    local A as float
    local B as float
    local C as float
    local Disc as float
    local Entry as float
    X = StartPos.x-Center.x
    Y = StartPos.y-Center.y
    C = X*X+Y*Y-Radius*Radius
    if C <= 0 then exitfunction 0.0
    Dx = EndPos.x-StartPos.x
    Dy = EndPos.y-StartPos.y
    A = Dx*Dx+Dy*Dy
    if A <= 0 then exitfunction -1.0
    B = X*Dx+Y*Dy
    Disc = B*B-A*C
    if Disc < 0 then exitfunction -1.0
    Entry = (-B-Sqrt(Disc))/A
    if Entry >= 0 and Entry <= 1 then exitfunction Entry
endfunction -1.0
