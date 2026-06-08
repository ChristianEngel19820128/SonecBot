
//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------

function ImageLoad(Image ref as TImage)
	
	local Value as integer
	
	Value = FALSE
	
	if FilePathSetAndCheck(Image.File) = TRUE
		Image.ID = LoadImage(Image.File.Name)
		if Image.ID > 0
			Value = TRUE
		endif
	endif
	
endfunction Value

//----------------------------------------------------------------------
// 
//----------------------------------------------------------------------



