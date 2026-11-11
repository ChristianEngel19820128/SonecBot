
Const mxwalker=10
Global imgwalker=LoadAnimImage("images/walker.bmp",20,20,0,8,2)
MaskImage imgwalker,0,0,0

Global sndwalkerhit=LoadSound("sound/hit.wav")
Global sndwalkerdie=LoadSound("sound/m79-explosion.wav")
;Global sndwalkertouch=LoadSound("sound/m79-explosion.wav")


Dim walker(mxwalker)
Dim twalker(mxwalker)
Dim xwalker(mxwalker)
Dim ywalker(mxwalker)
Dim awalker(mxwalker)
Dim fwalker(mxwalker)

Dim xtwalker(mxwalker)
Dim ytwalker(mxwalker)

Dim hwalker(mxwalker)

Dim brwalker(mxwalker)
Dim frwalker(mxwalker)
Dim lrwalker(mxwalker)

Dim ctwalker(mxwalker)

Dim tgravwalker(mxwalker)
Dim walkerfall(mxwalker)

Global walkerreg=65


Function initwalker()
For i=0 To mxwalker
 walker(i)=0
Next
End Function


Function newwalker()
 i=0
 f=False
 While f=False And i<=mxwalker
  If walker(i)=0 Then f=True Else i=i+1
 Wend
 If f=True Then

  walker(i)=1
  twalker(i)=0
  xwalker(i)=windx
  ywalker(i)=0
  awalker(i)=True
  fwalker(i)=0
  walkerfall(i)=True
  tgravwalker(i)=now

  hwalker(i)=50

  brwalker(i)=1
  frwalker(i)=3
  lrwalker(i)=2

 End If
End Function

;----------------------------------------------------------------------------

Function walkerdie(i)
 walker(i)=0
 sndplay(sndwalkerdie)
 newobject(xwalker(i),ywalker(i),1,9) 
 newobject(xwalker(i),ywalker(i),1,9) 
 newobject(xwalker(i),ywalker(i),1,mxobjtyp) 
End Function




Function dowalker()

For i=0 To mxbot
If walker(i)>0 Then

;feuer
If Rand(100000)<13 Then newrocket(xwalker(i)+5,ywalker(i)+5)

If ywalker(i)>windy Then walker(i)=0

;move


If twalker(i)+150<now Then 
 twalker(i)=now
 If awalker(i)=False Then
  If fwalker(i)>2 Then fwalker(i)=0
  fwalker(i)=fwalker(i)+1
  xwalker(i)=xwalker(i)-move
 Else
  If fwalker(i)<5 Then fwalker(i)=7
  fwalker(i)=fwalker(i)-1
  xwalker(i)=xwalker(i)+move
 End If

  ;target aktualisierung
  xtwalker(i)=xbot(0)
  ytwalker(i)=ybot(0)

 If xwalker(i)>xtwalker(i)+50 Then awalker(i)=False
 If xwalker(i)<xtwalker(i)-50 Then awalker(i)=True
End If

End If

If tgravwalker(i)+sgravspeed<now And walkerfall(i)=True Then
tgravwalker(i)=now
ywalker(i)=ywalker(i)+move+1
If awalker(i)=False Then fwalker(i)=0 Else fwalker(i)=7
End If

;kollision mit world lines
k=colline(xwalker(i),ywalker(i)+18,move+1)
If k>0 Then
walkerfall(i)=False
ywalker(i)=ywalker(i)+k-1
Else
walkerfall(i)=True
End If

;kollision mit bullet
If walker(i)>0 Then
k=colbullet(xwalker(i),ywalker(i),20,20,imgwalker,fwalker(i))
If k>0 Then
sndplay(sndwalkerhit)
hwalker(i)=hwalker(i)-Ceil(k/brwalker(i))
If hwalker(i)<0 Then
 walkerdie(i)
End If
End If
End If

;kollision mit flame
If walker(i)>0 Then
k=colflame(xwalker(i),ywalker(i),20,20,imgwalker,fwalker(i))
If k>0 Then
sndplay(sndwalkerhit)
hwalker(i)=hwalker(i)-Ceil(k/frwalker(i))
If hwalker(i)<0 Then
 walkerdie(i)
End If
End If
End If

;kollision mit laser
If walker(i)>0 Then
k=collaser(xwalker(i),ywalker(i),20,20,imgwalker,fwalker(i))
If k>0 Then
sndplay(sndwalkerhit)
hwalker(i)=hwalker(i)-Ceil(k/lrwalker(i))
If hwalker(i)<0 Then
 walkerdie(i)
End If
End If
End If

;kollision mit bot
If walker(i)>0 Then
If colbot(xwalker(i),ywalker(i),20,20,imgwalker,fwalker(i)) Then sndplay(sndwalkertouch)
End If
Next
End Function


;--------------------------------------------------------------------------


Function drawwalker()
For i=0 To mxbot
If walker(i)>0 Then DrawImage(imgwalker,xwalker(i),ywalker(i),fwalker(i))
Next
End Function


Function colwalker(x,y,dx,dy,img,f,s)

For i=0 To mxwalker
If walker(i)>0 Then
If RectsOverlap(x,y,dx,dy,xwalker(i),ywalker(i),20,20)=True Then
If ImagesCollide(img,x,y,f,imgwalker,xwalker(i),ywalker(i),fwalker(i))=True Then
sndplay(sndwalkerhit)
hwalker(i)=hwalker(i)-s
If hwalker(i)<0 Then
 walker(i)=0
 sndplay(sndwalkerdie)
End If
Return True
End If
End If
End If
Next
End Function