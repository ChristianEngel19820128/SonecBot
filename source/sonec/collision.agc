
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


