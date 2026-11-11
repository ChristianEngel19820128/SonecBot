


Function GetKeyPressed(x as Integer)
    Local result as integer
    If GetRawKeyPressed(x) then result = 1
EndFunction result

Function GetKeyState(x as Integer)
    Local result as integer
    If GetRawKeyState(x) then result = 1
EndFunction result



Function GetJoyPressed(JoystickIndex as integer,x as integer)
    Local result as Integer
    If GetRawJoystickExists(JoystickIndex) 
        If GetRawJoystickButtonPressed(JoystickIndex,x) then result = 1
    EndIf
Endfunction result

Function GetJoyState(JoystickIndex as integer,x as integer)
    Local result as Integer
    If GetRawJoystickExists(JoystickIndex) 
        If GetRawJoystickButtonState(JoystickIndex,x) then result = 1
    EndIf
Endfunction result

Function GetJoyX(JoystickIndex as integer)
    Local result as Float
    If GetRawJoystickExists(JoystickIndex) 
        result = GetRawJoystickX(JoystickIndex)
    EndIf
EndFunction result

Function GetJoyY(JoystickIndex as integer)
    Local result as Float
    If GetRawJoystickExists(JoystickIndex) 
        result = GetRawJoystickY(JoystickIndex)
    EndIf
EndFunction result

Function GetJoyZ(JoystickIndex as integer)
    Local result as Float
    If GetRawJoystickExists(JoystickIndex) 
        result = GetRawJoystickZ(JoystickIndex)
    EndIf
EndFunction result

Function GetJoyRZ(JoystickIndex as integer)
    Local result as Float
    If GetRawJoystickExists(JoystickIndex) 
        result = GetRawJoystickRZ(JoystickIndex)
    EndIf
EndFunction result



Function GetStartPressed(JoystickIndex as integer)
    Local result as integer
    If GetKeyPressed(KEY_ENTER) or GetJoyPressed(JoystickIndex,joystickButtonStart) then result = 1
EndFunction result

Function GetESCPressed()
    Local result as Integer
    If Device$ = "windows" and GetKeyPressed(Key_Escape) then result = 1
Endfunction result



