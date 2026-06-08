
//--------------------------------------------------------------------
//
//--------------------------------------------------------------------

type TFilePath
	
	Path as string
	Name as string
	
endtype

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

function FilePathSetAndCheck(Source as TFilePath)

	local Value as integer

	Value = FALSE
	
	if SetFolder(ReplaceString(Source.Path,"\","/",-1))
		if Len(Source.Name) > 0
			if GetFileExists(Source.Name)
				Value = TRUE
			endif
		endif
	endif

endfunction Value

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

function ReadFileString(Source as TFilePath)

	local FileID as integer
	local FileString as string
	
	FileString = ""
	
	if FilePathSetAndCheck(Source) = TRUE
	
		FileID = OpenToRead(Source.Name)
						
		if FileID > 0
							
			while not FileEOF(FileID)						
				FileString = FileString + ReadLine(FileID)														
			endwhile
			
			CloseFile(FileID)
			
		endif
	
	endif

endfunction FileString

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

