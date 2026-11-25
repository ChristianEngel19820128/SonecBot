
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

// Relative segment against a horizontal capsule (half-length 0 = circle).
// Strict preserves the established enemy-bullet exclusion of pure tangency.
function CollisionRelativeSweepEntry(ShotStart as TPosition,ShotEnd as TPosition,TargetStart as TPosition,TargetEnd as TPosition,Radius as float,HalfLength as float,Strict as integer)
    local P0 as TPosition
    local P1 as TPosition
    local Center as TPosition
    local BoxMin as TPosition
    local BoxMax as TPosition
    local Dx as float
    local Dy as float
    local LengthSq as float
    local T as float
    local Entry as float
    local Best as float
    P0.x = ShotStart.x-TargetStart.x
    P0.y = ShotStart.y-TargetStart.y
    P1.x = ShotEnd.x-TargetEnd.x
    P1.y = ShotEnd.y-TargetEnd.y
    Center.x = 0
    Center.y = 0
    if HalfLength <= 0
        if Strict = TRUE
            Dx = P1.x-P0.x
            Dy = P1.y-P0.y
            LengthSq = Dx*Dx+Dy*Dy
            T = 0
            if LengthSq > 0
                T = -(P0.x*Dx+P0.y*Dy)/LengthSq
                if T < 0 then T = 0
                if T > 1 then T = 1
            endif
            Dx = P0.x+Dx*T
            Dy = P0.y+Dy*T
            if Dx*Dx+Dy*Dy >= Radius*Radius then exitfunction -1.0
        endif
        Entry = CollisionCircleSweepEntry(P0,P1,Center,Radius)
        exitfunction Entry
    endif
    BoxMin.x = -HalfLength
    BoxMin.y = -Radius
    BoxMax.x = HalfLength
    BoxMax.y = Radius
    Best = 2.0
    Entry = CollisionBoxSweepEntry(P0,P1,BoxMin,BoxMax,0,0)
    if Entry >= 0 then Best = Entry
    Center.x = -HalfLength
    Entry = CollisionCircleSweepEntry(P0,P1,Center,Radius)
    if Entry >= 0 and Entry < Best then Best = Entry
    Center.x = HalfLength
    Entry = CollisionCircleSweepEntry(P0,P1,Center,Radius)
    if Entry >= 0 and Entry < Best then Best = Entry
    if Best <= 1 then exitfunction Best
endfunction -1.0

// Relative circles, restricted to the common time interval. Entry is a
// fraction of the original A segment. Instantaneous paths test only now.
function CollisionTimedCircleEntry(A0 as TPosition,A1 as TPosition,AT0 as integer,AT1 as integer,B0 as TPosition,B1 as TPosition,BT0 as integer,BT1 as integer,Radius as float)
    local FromMs as integer
    local ToMs as integer
    local U0 as float
    local U1 as float
    local V0 as float
    local V1 as float
    local P0 as TPosition
    local P1 as TPosition
    local Q0 as TPosition
    local Q1 as TPosition
    local Entry as float
    FromMs = AT0
    if BT0 > FromMs then FromMs = BT0
    ToMs = AT1
    if BT1 < ToMs then ToMs = BT1
    if ToMs < FromMs then exitfunction -1.0
    U0 = 1
    U1 = 1
    V0 = 1
    V1 = 1
    if AT1 > AT0
        U0 = (FromMs-AT0)*1.0/(AT1-AT0)
        U1 = (ToMs-AT0)*1.0/(AT1-AT0)
    endif
    if BT1 > BT0
        V0 = (FromMs-BT0)*1.0/(BT1-BT0)
        V1 = (ToMs-BT0)*1.0/(BT1-BT0)
    endif
    P0.x = A0.x+(A1.x-A0.x)*U0
    P0.y = A0.y+(A1.y-A0.y)*U0
    P1.x = A0.x+(A1.x-A0.x)*U1
    P1.y = A0.y+(A1.y-A0.y)*U1
    Q0.x = B0.x+(B1.x-B0.x)*V0
    Q0.y = B0.y+(B1.y-B0.y)*V0
    Q1.x = B0.x+(B1.x-B0.x)*V1
    Q1.y = B0.y+(B1.y-B0.y)*V1
    Entry = CollisionRelativeSweepEntry(P0,P1,Q0,Q1,Radius,0,FALSE)
    if Entry < 0 then exitfunction -1.0
    if AT1 = AT0 then exitfunction 0.0
endfunction U0+(U1-U0)*Entry

// Sample the active plasma rectangle at its current pose. Never test
// an incoming object's path before the discharge was created.
function CollisionTimedAreaEntry(StartPos as TPosition,EndPos as TPosition,StartMs as integer,EndMs as integer,AreaStartMs as integer,MinPos as TPosition,MaxPos as TPosition,Radius as float)
    local P as TPosition
    local T as float
    local Entry as float
    if AreaStartMs > EndMs then exitfunction -1.0
    T = 0
    if StartMs < AreaStartMs and EndMs > StartMs then T = (AreaStartMs-StartMs)*1.0/(EndMs-StartMs)
    P.x = StartPos.x+(EndPos.x-StartPos.x)*T
    P.y = StartPos.y+(EndPos.y-StartPos.y)*T
    Entry = CollisionBoxSweepEntry(P,EndPos,MinPos,MaxPos,Radius,Radius)
    if Entry < 0 then exitfunction -1.0
endfunction T+(1.0-T)*Entry
