Function creatememfile()
f=WriteFile("data.sys")
;--------------
WriteInt(f,0)
WriteInt(f,False)
;--------------
CloseFile(f)
End Function


Function loadmem()
;-------------------------------------------------
; load data
f=0
timeout=0
While f=0 And timeout<5
 f=ReadFile("data.sys")
 If f=0 Then
  creatememfile()
  timeout=timeout+1
 End If
Wend
If f>0 Then
;--------------
rank(0)=ReadInt(f)
bloodon=ReadInt(f)
;--------------
CloseFile(f)
End If
;-------------------
; load config
f=0
timeout=0
While f=0 And timeout<5
 f=ReadFile("config.txt")
 If f=0 Then
  timeout=timeout+1
 End If
Wend
If f>0 Then
;--------------
;--------------
CloseFile(f)
End If
;-------------------------------------------------
End Function


Function savemem()
f=WriteFile("data.sys")
;--------------
WriteInt(f,rank(0))
WriteInt(f,bloodon)
;--------------
CloseFile(f)
End Function

loadmem()