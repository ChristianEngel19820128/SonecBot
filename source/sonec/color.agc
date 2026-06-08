
//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

type TColor

	Red as integer
	Green as integer
	Blue as integer
	Alpha as integer
	
	Value as integer
	
endtype

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

function ColorSet(c ref as TColor,r,g,b,a)

	c.Red = r
	c.Green = g
	c.Blue = b
	c.Alpha = a
	c.Value = MakeColor(r,g,b,a)

endfunction c

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

function ColorCalc(Color ref as TColor)

	Color.Value = MakeColor(Color.Red,Color.Green,Color.Blue,Color.Alpha)
	
endfunction Color.Value

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

function GetRandomColor(Color ref as TColor)

	Color.Red = random(0,255)
	
	if Color.Red < 155
		Color.Green = random(155,255)
	else
		Color.Green = random(0,255)
	endif
	
	if Color.Red < 155 and Color.Green < 155
		Color.Blue = random(155,255)
	else
		Color.Blue = random(0,255)
	endif

	Color.Alpha = 255

	Color.Value = MakeColor(Color.Red,Color.Green,Color.Blue,Color.Alpha)

endfunction Color

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------




