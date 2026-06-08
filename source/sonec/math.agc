
//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

function NormalizeAngle(Angle as float)
	
	local Value as float
	
	Value = Angle
	
	if Value <= -360 then Value = Value + floor(abs(Value) / 360) * 360
	if Value >= 360 then Value = Value - floor(Value / 360) * 360
	if Value < 0 then Value = Value + 360
	
endfunction Value

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

function NormalizeRad(Angle as float)
	
	local Value as float
	
	Value = Angle
	
	if Value <= -360 then Value = Value + floor(abs(Value) / 360) * 360
	if Value >= 360 then Value = Value - floor(Value / 360) * 360
	if Value < 0 then Value = Value + 360
	if Value < -180 then Value = Value + 180
	if Value > 180 then Value = Value - 180
	
endfunction Value

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

function CalcDeltaX(AbsolutePosition as TPosition,TargetPosition as TPosition)

	local Value as float
	
	Value = TargetPosition.X - AbsolutePosition.X
	
endfunction Value

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

function CalcDeltaY(AbsolutePosition as TPosition,TargetPosition as TPosition)

	local Value as float
	
	Value = TargetPosition.Y - AbsolutePosition.Y
	
endfunction Value

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

function CalcRadius(AbsolutePosition as TPosition,TargetPosition as TPosition)
	
	local Value as float
	local x as float
	local y as float
	
	x = TargetPosition.X - AbsolutePosition.X
	y = TargetPosition.Y - AbsolutePosition.Y
		
	Value = sqrt((x^2)+(y^2))
	
endfunction Value

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

function CalcAngle(AbsolutePosition as TPosition,TargetPosition as TPosition)
	
	local Value as float
	local Radius as float
	local x as float
	local y as float
	
	Value = 0
	
	if AbsolutePosition.X <> TargetPosition.X or AbsolutePosition.Y <> TargetPosition.Y
		
		x = TargetPosition.X - AbsolutePosition.X
		y = TargetPosition.Y - AbsolutePosition.Y
		
		Radius = CalcRadius(AbsolutePosition,TargetPosition)
		
		if Radius > 0
			if x > 0 and y < 0 then Value = asin(y/Radius) + 90
			if x > 0 and y > 0 then Value = asin(y/Radius) + 90
			if x < 0 and y > 0 then Value = -asin(y/Radius) - 90
			if x < 0 and y < 0 then Value = -asin(y/Radius) - 90
			Value = NormalizeAngle(Value)
		endif
	endif
	
endfunction Value

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

function CalcPosition(Position ref as TPosition,Angle as float,Radius as float)
	
	Position.X = CalcPositionX(Position.X,Angle,Radius)
	Position.Y = CalcPositionY(Position.Y,Angle,Radius)

endfunction

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

function CalcPositionX(PositionX as float,Angle as float,Radius as float)
	
	local Value as float
	
	if Angle >= 0 and Angle <= 90 then Value = PositionX + cos(Angle-90) * Radius
	if Angle >= 90 and Angle <= 180 then Value = PositionX + cos(Angle-90) * Radius
	if Angle >= 180 and Angle <= 270 then Value = PositionX - cos(Angle+90) * Radius
	if Angle >= 270 and Angle <= 360 then Value = PositionX - cos(Angle+90) * Radius

endfunction Value

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

function CalcPositionY(PositionY as float,Angle as float,Radius as float)
	
	local Value as float
	
	if Angle >= 0 and Angle <= 90 then Value = PositionY + sin(Angle-90) * Radius
	if Angle >= 90 and Angle <= 180 then Value = PositionY + sin(Angle-90) * Radius
	if Angle >= 180 and Angle <= 270 then Value = PositionY - sin(Angle+90) * Radius
	if Angle >= 270 and Angle <= 360 then Value = PositionY - sin(Angle+90) * Radius

endfunction Value

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------



