Global imgbot=LoadAnimImage("images/bot.bmp",25,25,0,16,2)
Global imgflame=LoadAnimImage("images/flame.bmp",10,10,0,18,2)
Global imgfire=LoadAnimImage("images/fire.bmp",6,7,0,2,2)
Global imgbullet=LoadAnimImage("images/bullet.bmp",3,1,0,2,2)
Global imglaser=LoadImage("images/laser.bmp",2)
Global imgjetfire=LoadAnimImage("images/jetfire.bmp",8,8,0,3,2)
Global imginenergie=LoadAnimImage("images/inenergie.bmp",75,75,0,4,2)

MaskImage imgbot,0,0,0
MaskImage imgflame,0,0,0
MaskImage imgfire,0,0,0
MaskImage imgbullet,0,0,0
MaskImage imglaser,0,0,0
MaskImage imgjetfire,0,0,0
MaskImage imginenergie,0,0,0


Global imghud=LoadImage("images/hud.bmp")
Global imghudscore=LoadImage("images/hudscore.bmp")
Global imghudtime=LoadImage("images/hudtime.bmp")
MaskImage imghud,0,0,0
MaskImage imghudscore,0,0,0
MaskImage imghudtime,0,0,0

;-----------------------------------------

Global sndgun=LoadSound("sound/ak74-fire.wav")
Global snddryfire=LoadSound("sound/DRYFIRE1.WAV")
Global sndreload=LoadSound("sound/RELOAD1.WAV")
Global sndscock=LoadSound("sound/SCOCK1.WAV")
Global sndflame=LoadSound("sound/flamer.wav")
Global sndjet=LoadSound("sound/firethrust.wav")
LoopSound sndjet

Global sndstep=LoadSound("sound/step3.wav")
Global botdie=LoadSound("sound/burn.wav")
;-----------------------------------------

Const move=2

Const mxbot=3
Global ebene=windy

Global tback=0

;botdata

Dim levelbot(mxbot)

Dim glueck(mxbot)

Dim xpbot(mxbot)
Dim mxxpbot(mxbot)
Dim rank(mxbot)

Dim mxhbot(mxbot)
Dim hbot(mxbot)

Dim mxebot(mxbot)
Dim ebot(mxbot)


Dim score(mxbot)

Dim typbot(mxbot)
Dim fbot(mxbot)

Dim tbot(mxbot)
Dim sbot(mxbot)

Dim tgravbot(mxbot)

Dim forward(mxbot)
Dim fall(mxbot)
Dim jump(mxbot)
Dim duck(mxbot)
Dim back(mxbot)
Dim jet(mxbot)
Dim align(mxbot)

Dim xbot(mxbot)
Dim ybot(mxbot)

Dim tflamer(mxbot)
Dim sflamer(mxbot)

Const mxflame=18
Dim flame(mxbot,mxflame)
Dim xflame(mxbot,mxflame)
Dim yflame(mxbot,mxflame)
Dim tflame(mxbot,mxflame)
Dim sflame(mxbot,mxflame)

Dim laser(mxbot)
Dim tlaser(mxbot)
Dim slaser(mxbot)
Dim dflamer(mxbot)


Dim xlaser(mxbot)
Dim ylaser(mxbot)
Dim dlaser(mxbot)

Dim tgun(mxbot)
Dim sgun(mxbot)
Dim dbgun(mxbot)
Dim sbgun(mxbot)

Dim mxgabot(mxbot)
Dim gabot(mxbot)

Const mbul=15

Dim bul(mxbot,mbul)
Dim xbul(mxbot,mbul)
Dim ybul(mxbot,mbul)
Dim tbul(mxbot,mbul)
Dim sbul(mxbot,mbul)
Dim dbul(mxbot,mbul)


Dim tinenergie(mxbot)
Dim sinenergie(mxbot)
Dim inenergie(mxbot)

Dim theal(mxbot)
Dim sheal(mxbot)
Dim rheal(mxbot)
Dim kheal(mxbot)


;-----------------------------------------

Include "joy.bb"
Include "walker.bb"
Include "obj.bb"
Include "emup.bb"
Include "cworld.bb"
Include "spacejet.bb"


;-----------------------------------------
Function sndplay(s)
 chas=PlaySound(s)
 ChannelVolume chas,sound
End Function

Global jeton=False
Global chajet
Function sndplayjet(i=0)
If i=1 Then
 If jeton=False Then
  jeton=True
  chajet=PlaySound(sndjet)
  ChannelVolume chajet,sound
 End If
Else
 jeton=False
 StopChannel chajet
End If
End Function

;-----------------------------------------

Function killbots()
For i=0 To mxbot
typbot(i)=0
Next
End Function

;-----------------------------------------

Function initbot()

i=0
f=False
While f=False And i<=mxbot
 If typbot(i)=0 Then f=True Else i=i+1
Wend

If f=True Then

typbot(i)=1
fbot(i)=0

tbot(i)=0
sbot(i)=40

tgravbot(i)=0


forward(i)=False
fall(i)=False
jump(i)=False
back(i)=False
align(i)=True
jet(i)=False

xbot(i)=50
ybot(i)=-30

tgun(i)=0
sgun(i)=100
sbgun(i)=6
dbgun(i)=10

tflamer(i)=0
sflamer(i)=45
dflamer(i)=2

tlaser(i)=0
slaser(i)=50
dlaser(i)=5

xpbot(i)=0
mxxpbot(i)=100

levelbot(i)=1

mxhbot(i)=100
mxebot(i)=1500
mxgabot(i)=100

hbot(i)=hbot(i)+mxhbot(i)
gabot(i)=gabot(i)+mxgabot(i)/2
ebot(i)=ebot(i)+mxebot(i)/2

tinenergie(i)=0
sinenergie(i)=75
inenergie(i)=1

theal(i)=0
sheal(i)=100
rheal(i)=1
kheal(i)=5

End If
End Function

;-----------------------------------------

Function setbot(i,x,y,s,h,e,ga)
hbot(i)=h
gabot(i)=ga
ebot(i)=e
xbot(i)=x
ybot(i)=y
sbot(i)=s
End Function


;-----------------------------------------


Function setbotback(i)

typbot(i)=1
fbot(i)=0

tbot(i)=0
sbot(i)=40

tgravbot(i)=0

forward(i)=False
fall(i)=False
jump(i)=False
back(i)=False
align(i)=True
jet(i)=False

xbot(i)=50
ybot(i)=400

tgun(i)=0
sgun(i)=100

tflamer(k)=0
sflamer(k)=45

tlaser(i)=0
slaser(i)=5


xpbot(i)=0
mxxpbot(i)=100

levelbot(i)=1

mxhbot(i)=200
mxebot(i)=1000
mxgabot(i)=100

hbot(i)=mxhbot(i)
gabot(i)=mxgabot(i)
ebot(i)=mxebot(i)

tinenergie(i)=0
sinenergie(i)=75
inenergie(i)=1

theal(i)=0
sheal(i)=100
rheal(i)=1
kheal(i)=5

End Function


;-----------------------------------------

Function checkbotdata(i)

If hbot(i)>mxhbot(i) Then hbot(i)=mxhbot(i)
If gabot(i)>mxgabot(i) Then gabot(i)=mxgabot(i)
If ebot(i)>mxebot(i) Then ebot(i)=mxebot(i)

End Function

;-----------------------------------------

Function dobots()

doworld()

For i=0 To mxbot
If typbot(i)>0 Then

 If ybot(i)<ebene Then fall(i)=True

 If typbot(i)=1 Then joy(i)

 ;kollision mit world lines
If jump(i)=False Then
k=colline(xbot(i),ybot(i)+24,move+1)
If k>0 Then
fall(i)=False
ybot(i)=ybot(i)+k-1
If tback+clspeed*4<now Then
tback=now
;bot zurückwerfen
If xbot(i)>0 Then xbot(i)=xbot(i)
End If
End If
End If

 movebot(i)


 If ybot(i)>=ebene Then lose=True
 If hbot(i)<1 Then lose=True
 If hbot(i)<1 Then hbot(i)=0

 checkbotdata(i)
 doweapon(i)
 dobul(i)
 doflame(i)

 colobjects(imgbot,xbot(i),ybot(i),fbot(i),i)

End If
Next


drawbots()

setfalse()

End Function

;-----------------------------------------

Function doweapon(i)

If now-tgun(i)<55 Then
  If align(i)=True Then
    If duck(i)=True Then DrawImage(imgfire,xbot(i)+26,ybot(i)+11,0)
    If jump(i)=True Then DrawImage(imgfire,xbot(i)+26,ybot(i)+6,0)
    If duck(i)=False And jump(i)=False Then DrawImage(imgfire,xbot(i)+25,ybot(i)+6,0)
  Else 
    If duck(i)=True Then DrawImage(imgfire,xbot(i)-5,ybot(i)+11,1)
    If jump(i)=True Then DrawImage(imgfire,xbot(i)-5,ybot(i)+6,1)
    If duck(i)=False And jump(i)=False Then DrawImage(imgfire,xbot(i)-6,ybot(i)+6,1)    
  End If
End If

End Function

;-----------------------------------------

Function newbullet(k,stand)

If gabot(k)>0

If (tgun(k)+sgun(k)<now) Then
tgun(k)=now

f=False
i=0
While (f=False And i<=mbul)
 If bul(k,i)=0 Then f=True Else i=i+1
Wend

If f=True Then

sndplay(sndgun)

tbul(k,i)=now
sbul(k,i)=sbgun(k)
dbul(k,i)=dbgun(k)

gabot(k)=gabot(k)-1
If align(k)=True Then
 bul(k,i)=1
 If stand=True Then
  xbul(k,i)=xbot(k)+27
  ybul(k,i)=ybot(k)+14
 Else
  xbul(k,i)=xbot(k)+27
  ybul(k,i)=ybot(k)+9
 End If
Else
 bul(k,i)=2
 If stand=True Then
  xbul(k,i)=xbot(k)-8
  ybul(k,i)=ybot(k)+14
 Else
  xbul(k,i)=xbot(k)-8
  ybul(k,i)=ybot(k)+9
 End If
End If
End If

End If

End If

End Function

;-----------------------------------------

Function dobul(k)

;paint bul
Color 0,255,0
For i=0 To mbul
If bul(k,i)>0 Then

If tbul(k,i)+sbul(k,i)<now Then
Select bul(k,i)
Case 1 
 ;move bul
 xbul(k,i)=xbul(k,i)+move*3
 If xbul(k,i)>windx Then bul(k,i)=0
Case 2
 xbul(k,i)=xbul(k,i)-move
 If xbul(k,i)<0 Then bul(k,i)=0
End Select
tbul(k,i)=now
End If

;ausgabe bullets
If bul(k,i)=1 Then DrawImage(imgbullet,xbul(k,i)-2,ybul(k,i),0)
If bul(k,i)=2 Then DrawImage(imgbullet,xbul(k,i),ybul(k,i),1)

;collision mit emup
If bul(k,i)=1 Then If colemup((xbul(k,i)-2),ybul(k,i),3,1,imgbullet,0)=True Then bul(k,i)=0
If bul(k,i)=2 Then If colemup(xbul(k,i),ybul(k,i),3,1,imgbullet,1)=True Then bul(k,i)=0

End If
Next

End Function

;-----------------------------------------


Function colbullet(x,y,dx,dy,img,f)
 For i=0 To mxpl
  For k=0 To mxbul
   If bul(i,k)>0 Then
    If bul(i,k)=1 Then
     If RectsOverlap(x,y,dx,dy,xbul(i,k)-2,ybul(i,k),3,1)=True Then
      If ImagesCollide(img,x,y,f,imgbullet,xbul(i,k),ybul(i,k),0)=True Then
       bul(i,k)=0
       Return dbul(i,k)
      Else 
       Return 0
      End If
     End If
    End If
    If bul(i,k)=2 Then 
     If RectsOverlap(x,y,dx,dy,xbul(i,k),ybul(i,k),3,1)=True Then
      If ImagesCollide(img,x,y,f,imgbullet,xbul(i,k),ybul(i,k),1)=True Then
       bul(i,k)=0
       Return dbul(i,k)
      Else
       Return 0
      End If
     End If
    End If
   End If
  Next
 Next
End Function

;-----------------------------------------


Function dolaser(i,stand)
laser(i)=0
If tlaser(i)+slaser(i)<now And ebot(i)>0 Then
tlaser(i)=now
ebot(i)=ebot(i)-1
laser(i)=1
If align(i)=True Then
 If stand=True Then
  xlaser(i)=xbot(i)+20
  ylaser(i)=ybot(i)+13
 Else
  xlaser(i)=xbot(i)+20
  ylaser(i)=ybot(i)+8
 End If
 DrawImage imglaser,xlaser(i),ylaser(i)
 colemup(xlaser(i),ylaser(i),640,3,imglaser,0)
Else
 If stand=True Then
  xlaser(i)=xbot(i)+5
  ylaser(i)=ybot(i)+13
 Else
  xlaser(i)=xbot(i)+5
  ylaser(i)=ybot(i)+8
 End If

 DrawImage imglaser,xlaser(i)-640,ylaser(i)
 colemup(xlaser(i)-640,ylaser(i),640,3,imglaser,0)
End If

End If
End Function

;-----------------------------------------

Function collaser(x,y,dx,dy,img,f)
 For i=0 To mxpl
  If laser(i)>0 Then
  If align(i)=True Then
   If RectsOverlap(x,y,dx,dy,xlaser(i),ylaser(i),640,3)=True Then
    If ImagesCollide(img,x,y,f,imglaser,xlaser(i),ylaser(i),0)=True Then
     Return dlaser(i)
    Else 
     Return 0
    End If
   End If
  End If
  If align(i)=False Then 
   If RectsOverlap(x,y,dx,dy,xlaser(i)-640,ylaser(i),640,3)=True Then
    If ImagesCollide(img,x,y,f,imglaser,xlaser(i)-640,ylaser(i),0)=True Then
     Return dlaser(i)
    Else
     Return 0
    End If
   End If
  End If
  End If
  laser(i)=0
 Next
End Function

;-----------------------------------------

Function newflame(k,stand)

If tflamer(k)+sflamer(k)<now Then
tflamer(k)=now
i=0
f=False
While i<=mxflame And f=False
If flame(k,i)=0 Then f=True Else i=i+1
Wend

If f=True And ebot(k)>=5 Then

;sndplay(sndflame)
tflamer(k)=now
ebot(k)=ebot(k)-5
sflame(k,i)=55

If align(k)=True Then
 flame(k,i)=1
 If stand=True Then
  xflame(k,i)=xbot(k)+23
  yflame(k,i)=ybot(k)+10
 Else
  xflame(k,i)=xbot(k)+23
  yflame(k,i)=ybot(k)+5
 End If
Else
 flame(k,i)=18
 If stand=True Then
  xflame(k,i)=xbot(k)-8
  yflame(k,i)=ybot(k)+10
 Else
  xflame(k,i)=xbot(k)-8
  yflame(k,i)=ybot(k)+5
 End If
End If

End If


End If

End Function

;-----------------------------------------

Function doflame(i)

For k=0 To mxflame

;Text 10,10+k*15,flame(i,k)

If tflame(i,k)+sflame(i,k)<now Then
tflame(i,k)=now
If flame(i,k)>0 And flame(i,k)<10 Then
 xflame(i,k)=xflame(i,k)+10
 If flame(i,k)<9 Then flame(i,k)=flame(i,k)+1 Else flame(i,k)=0
Else
 If flame(i,k)>9 And flame(i,k)<19 Then
  xflame(i,k)=xflame(i,k)-10
  If flame(i,k)>10 Then flame(i,k)=flame(i,k)-1 Else flame(i,k)=0
 End If
End If

If flame(i,k)>0 Then 
colemup(xflame(i,k),yflame(i,k),10,10,imgflame,flame(i,k)-1)
End If

End If

If flame(i,k)>0 Then DrawImage(imgflame,xflame(i,k),yflame(i,k),flame(i,k)-1)


Next

End Function

;-----------------------------------------

Function colflame(x,y,dx,dy,img,f)
 For i=0 To mxpl
  For k=0 To mxflame
   If flame(i,k)>0 Then
    If RectsOverlap(x,y,dx,dy,xflame(i,k),yflame(i,k),10,10)=True Then
     If ImagesCollide(img,x,y,f,imgflame,xflame(i,k),yflame(i,k),flame(i,k)-1)=True Then
      flame(i,k)=0
      Return dflamer(i)
     Else 
      Return 0
     End If
    End If
   End If
  Next
 Next
End Function

;-----------------------------------------

Function setfalse()
For i=0 To mxbot
If typbot(i)>0 Then
 jump(i)=False
 forward(i)=False
 back(i)=False
 fall(i)=False
 duck(i)=False
End If
Next
End Function

;-----------------------------------------

Function movebot(i)

;bewegungspriorität
If tbot(i)+sbot(i)<now Then

tbot(i)=now

;festlegen des botimages
If align(i)=True Then
  If forward(i)=False And back(i)=False Then fbot(i)=0
  If forward(i)=True And xbot(i)<windx-25 Then
    xbot(i)=xbot(i)+move+jump(i)
    fbot(i)=fbot(i)+1
    If fbot(i)>5 Then
     fbot(i)=0
     If jump(i)=False And fall(i)=False Then sndplay(sndstep)
    End If
  End If

  If back(i)=True And xbot(i)>0 Then
    xbot(i)=xbot(i)-move
    fbot(i)=fbot(i)-1
    If fbot(i)<0 Then fbot(i)=5
  End If

  If duck(i)=True Then fbot(i)=14
  If jump(i)=True Or fall(i)=True Then
    fbot(i)=12
  End If
Else
  If forward(i)=False And back(i)=False Then fbot(i)=11
  If forward(i)=True And xbot(i)>0 Then
    xbot(i)=xbot(i)-move-jump(i)
    fbot(i)=fbot(i)-1
    If fbot(i)<6 Then
     fbot(i)=11
     If jump(i)=False And fall(i)=False Then sndplay(sndstep)
    End If
  End If
 
  If back(i)=True And xbot(i)<windx-25 Then 
    xbot(i)=xbot(i)+move
    fbot(i)=fbot(i)+1
    If fbot(i)>11 Then fbot(i)=6
  End If

  If duck(i)=True Then fbot(i)=15
  If jump(i)=True Or fall(i)=True Then
    fbot(i)=13
  End If
End If

; bewegungseffekte
If jump(i)=True Then
 ebot(i)=ebot(i)-1
 If ybot(i)>-100 Then
  ybot(i)=ybot(i)-move-1
 End If
End If

If jet(i)=True Then sndplayjet(1) Else sndplayjet(0)

End If

If tgravbot(i)+sgravspeed<now Then
tgravbot(i)=now
If fall(i)=True And jump(i)=False Then
  ybot(i)=ybot(i)+move+1
 
  yback=yback-1
End If
End If

End Function

;-----------------------------------------

Function drawbots()

For i=0 To mxbot
If typbot(i)>0 Then
; zeichnen des jetpack feuers
If jet(i)=True Then 

 If forward(i)=True Then
  If align(i)=True Then
   DrawImage imgjetfire,xbot(i),ybot(i)+8,1
  Else
   DrawImage imgjetfire,xbot(i)+19,ybot(i)+8,2
  End If
 Else
  If align(i)=True Then
   DrawImage imgjetfire,xbot(i)+6,ybot(i)+8,0
  Else
   DrawImage imgjetfire,xbot(i)+18,ybot(i)+8,0
  End If
 End If
End If

;zeichnen
DrawImage(imgbot,xbot(i),ybot(i),fbot(i))
Color(0,255,0)
;status anzeige
Rect xbot(i),ybot(i)-8,25*ebot(i)/mxebot(i),2
Rect xbot(i),ybot(i)-5,25*hbot(i)/mxhbot(i),2


End If
Next

End Function

;-----------------------------------------

Function colbot(x,y,dx,dy,img,f,s=1)
 For i=0 To mxbot
  If RectsOverlap(x,y,dx,dy,xbot(i),ybot(i),25,25)=True Then
   If ImagesCollide(img,x,y,f,imgbot,xbot(i),ybot(i),fbot(i))=True Then
    hbot(i)=hbot(i)-s
    Return True
   End If
  End If
 Next
End Function

;-----------------------------------------

;energie ansaugen
Function catch(i)
If inenergie(i)>0 Then 
If tinenergie(i)+sinenergie(i)<now Then
tinenergie(i)=now
ebot(i)=ebot(i)+1
If inenergie(i)<4 Then inenergie(i)=inenergie(i)+1 Else inenergie(i)=1
For k=0 To mxobj
If xbot(i)+12<objx(k) Then objx(k)=objx(k)-2
If xbot(i)+12>objx(k) Then objx(k)=objx(k)+2
If ybot(i)+3<objy(k) Then objy(k)=objy(k)-2
If ybot(i)+3>objy(k) Then objy(k)=objy(k)+2
Next
End If
DrawImage(imginenergie,xbot(i)-25,ybot(i)-25,inenergie(i)-1)
End If
End Function

;-----------------------------------------

;heilen mit energie
Function heal(i)
If theal(i)+sheal(i)<now Then
theal(i)=now
If ebot(i)>kheal(i) Then
ebot(i)=ebot(i)-kheal(i)
hbot(i)=hbot(i)+rheal(i)
End If
End If
End Function

;player 0 stats
Function dostats()

DrawImage imghudtime,windx-ImageWidth(imghudtime),0
k=1
l=time
While l>9
l=l/10 
k=k+1
Wend
Text windx-8*k-8,5,time


DrawImage imghudscore,windx/2-ImageWidth(imghudscore)/2,0
Text windx/2,5,score(0),1

;status anzeige
DrawImage(imghud,0,0)
Color 0,0,0
Rect 5,5,50,2
Rect 5,10,25,2
Rect 5,14,25,2
Rect 5,19,35,2

Color 255,200,255
Rect 5,5,50*xpbot(0)/mxxpbot(0),2
Color 50,150,255
Rect 5,10,25*ebot(0)/mxebot(0),2
Color 255,100,100
Rect 5,14,25*hbot(0)/mxhbot(0),2
If gabot(0)>0 Then
Color 0,255,0
For k=0 To (35*gabot(0)/mxgabot(0))/2
Line 5+k*2,19,5+k*2,20
Next
End If

Color 0,255,0
End Function