Global frame=False 
Global fpstimer=MilliSecs()
Global fpsmidtime=0
Global fpscounter=0
Global timeportal=0
Function frametime(x,y)
If KeyHit(88) Then If frame=False Then frame=True Else frame=False
If frame=True Then 
Color 0,255,0
fpsmidtime=fpsmidtime+MilliSecs()-fpstimer
fpscounter=fpscounter+1
If fpscounter>10000 Then
  fpsmidtime=fpsmidtime/fpscounter
  fpscounter=1
End If
Text x,y,"frametime "+(fpsmidtime/fpscounter)+" "+fpscounter
For i=0 To (MilliSecs()-fpstimer)
 Line x+i*2,y+14,x+i*2,y+15
Next
timeportal=fpsmidtime/fpscounter
fpstimer=MilliSecs()
End If
End Function

;-------------------------------------------------------------

Function logo(x,y)
Color 255,0,0
Line x,y,x,y+6
Line x,y+6,x+2,y+6
Line x+4,y+3,x+6,y+3
Line x+4,y+6,x+6,y+6
Line x+4,y+3,x+4,y+6
Line x+6,y+3,x+6,y+6
Line x+8,y,x+8,y+6
Line x+8,y+6,x+10,y+3
Line x+8,y+3,x+10,y+6
Line x+12,y,x+12,y+1
Line x+12,y+3,x+12,y+6
End Function

;------------------------------------------------------------

Function pixi(x,y,c)
LockBuffer(CanvasBuffer)
WritePixelFast(x,y,c)
UnlockBuffer(CanvasBuffer)
End Function

Dim colors(3)

Color 155,155,155
Plot 0,0
Color 255,0,0
Plot 1,0
Color 0,255,0
Plot 2,0
Color 0,0,255
Plot 3,0

LockBuffer(CanvasBuffer)
For i=0 To 3
colors(i)=ReadPixelFast(i,0)
Next
UnlockBuffer(CanvasBuffer)

;-------------------------------------------------

Global grad=0
Global gradt=0
Global grads=150

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::

Function dograd()
If gradt+grads<now Then
gradt=now
grad=grad+1
If grad>8 Then grad=1
End If
End Function

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Function drawgrad(x,y,r,a,c)

g=a+grad
If g>8 Then g=g-8
Select g
Case 1 DrawImage(imgpartikel,x-r+Floor(r/2),y+r-Floor(r/3),c-1)
Case 2 DrawImage(imgpartikel,x,y+r,c-1)
Case 3 DrawImage(imgpartikel,x+r-Floor(r/2),y+r-Floor(r/3),c-1)
Case 4 DrawImage(imgpartikel,x+r,y,c-1)
Case 5 DrawImage(imgpartikel,x+r-Floor(r/2),y-r+Floor(r/3),c-1)
Case 6 DrawImage(imgpartikel,x,y-r,c-1)
Case 7 DrawImage(imgpartikel,x-r+Floor(r/2),y-r+Floor(r/3),c-1)
Case 8 DrawImage(imgpartikel,x-r,y,c-1)
End Select
End Function

;-------------------------------------------------

Global timetextt
Global timetexts=2000
Global timetext$

Function starttimetext(s$)
timetext$=s
timetextt=now
End Function

Function dotimetext()
If timetextt+timetexts>now Then Text windx/2,windy/2,timetext,1,1
End Function

;-------------------------------------------------

Function snd(s)
 chas=PlaySound(s)
 ChannelVolume chas,sound
End Function


Global smessage=LoadSound("sound/message.wav")
Global sentermenu=LoadSound("sound/entermenu.wav")
Global senterportal=LoadSound("sound/portal.wav")

Global menuid
Global mxmenuid
Global buttonid=0
Function button(x,y,dx,dy,s$,t1=0,t2=0,v=0)


If KeyHit(200) Then
menuid=menuid-1
If menuid<1 Then menuid=mxmenuid
End If

If KeyHit(208) Then
menuid=menuid+1
If menuid>mxmenuid Then menuid=1
End If


If mox>x And mox<x+dx And moy>y And moy<y+dy Then
 If MouseDown(1) Then
  FlushMouse()
  buttonid=v
  Select t2

   Case 1 snd(sentermenu)
   Case 2 snd(sgold)
   Case 3 snd(smessage)

  End Select
  Return True
 End If
End If


If v=menuid Then

 If mox>x And mox<x+dx And moy>y And moy<y+dy Then

 Select t1
  Default
  Color 150,150,150
  Rect x,y,dx,dy,1
 End Select

 Color 0,0,0
 Select t1
  Case 0 Text x+dx/2,y+dy/2,s,1,1
  Case 1 Text x+5,y+dy/2,s,0,1
 End Select

 Else

 Color 255,255,255
 Rect x,y,dx,dy,0

 Select t1
  Case 0 Text x+dx/2,y+dy/2,s,1,1
  Case 1 Text x+5,y+dy/2,s,0,1
 End Select

 End If

 If KeyHit(28) Or KeyHit(156) Then
  Select t2

   Case 1 snd(sentermenu)
   Case 2 snd(sgold)
   Case 3 snd(smessage)

  End Select
  Return True
 End If

Else

If mox>x And mox<x+dx And moy>y And moy<y+dy Then 

 Select t1
 Case 2
  Color 255,255,255
  Rect x,y,dx,dy,0
 Default
  Color 150,150,150
  Rect x,y,dx,dy,1
 End Select

 Color 0,0,0
 Select t1
  Case 0 Text x+dx/2,y+dy/2,s,1,1
  Case 1 Text x+5,y+dy/2,s,0,1
 End Select

Else

 Select t1
  Default
   Color 150,150,150
   Rect x,y,dx,dy,0
 End Select

 Select t1
  Case 0 Text x+dx/2,y+dy/2,s,1,1
  Case 1 Text x+5,y+dy/2,s,0,1
 End Select

End If

End If

Return False
End Function