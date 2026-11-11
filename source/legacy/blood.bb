Const mxblood=(27+28)*2
Global bloodammo=0
Global mxbloodammo=0
Const bloods=30
Global bloodon=False
Global iblood
Function loadimageblood()
If bloodon=False Then
 iblood=LoadAnimImage("images/paintball.bmp",30,30,0,bloods,2)
Else
 iblood=LoadAnimImage("images/blut.bmp",30,30,0,bloods,2)
End If
MaskImage iblood,0,0,0
End Function

Global fanatic=LoadSound("sound/FANATIC.WAV")
Global burnhead=LoadSound("sound/BURNHEAD.WAV")


Global bloodtimer=now
Global bloodtime=60000
Global bloodcount=23
Global bloodlevel=1



Global statistiktimer
Global bloodshoots=0
Global bloodhits=0

Dim bloodtargets(9)


Global pointer=LoadImage("images/pointer.bmp",2)
Dim blut(mxblood)
Dim blutx(mxblood)
Dim bluty(mxblood)
Dim blutline(mxblood)
Dim stopblutline(mxblood)
Dim tblutline(mxblood)
Dim blutlines(mxblood)

Global tblutwaffe=0
Global sblutwaffe=0
Global waffe=0
Global altewaffe=0

Dim bloodgun(7)
Dim bloodreload(7)

Global blooddry=LoadSound("sound/DRYFIRE1.WAV")

Const colt=1
bloodgun(colt)=LoadSound("sound/colt1911-fire.wav")
bloodreload(colt)=LoadSound("sound/colt1911-reload.wav")

Const desert=2
bloodgun(desert)=LoadSound("sound/deserteagle-fire.wav")
bloodreload(desert)=LoadSound("sound/deserteagle-reload.wav")

Const glock=3
bloodgun(glock)=LoadSound("sound/deserteagle-fire.wav")
bloodgun(glock)=LoadSound("sound/deserteagle-fire.wav")

Const mp5slim=4
bloodgun(mp5slim)=LoadSound("sound/mp5-fire.wav")
bloodgun(mp5slim)=LoadSound("sound/mp5-reload.wav")

Const mp5=5
bloodgun(mp5)=LoadSound("sound/mp5-fire.wav")
bloodreload(mp5)=LoadSound("sound/mp5-reload.wav")

Const ak47=6
bloodgun(ak47)=LoadSound("sound/ak74-fire.wav")
bloodreload(ak47)=LoadSound("sound/ak74-reload.wav")


Function coolblood(x,y)
For i=0 To mxobj
If obj(i)>0 Then
If RectsOverlap(x+15,y+5,1,1,objx(i),objy(i),10,10) Then
If ImagesCollide(pointer,x+15,y+5,0,objects,objx(i),objy(i),obj(i)-1) Then

If obj(i)<10 Then
gabot(0)=gabot(0)+(10-obj(i))
If Rand(999)<(10-obj(i))+(10-blutwaffe) Then
 rank(0)=rank(0)+1
 sndplay(fanatic)
End If
End If

bloodcount=bloodcount-1
bloodhits=bloodhits+1

bloodtargets(obj(i))=bloodtargets(obj(i))+1

getobjbonus(obj(i),0)
obj(i)=0
chas=PlaySound(getobject)
ChannelVolume chas,sound
newblood()

Return True

End If
End If
End If
Next

Return False

End Function


;------------------------------------------------

Function newblood()

endblood=False
f=False
i=0
While endblood=False

If blut(i)=0 Then
 endblood=True
 f=True
End If
If i=mxblood Then endblood=True Else If f=False Then i=i+1

Wend

If f=False Then i=Rand(mxblood)

blut(i)=Rand(1,bloods)
tblutline(i)=0
stopblutline(i)=False
blutline(i)=0
blutlines(i)=Rand(1)

blutx(i)=MouseX(canvas)
bluty(i)=MouseY(canvas)

End Function


initobjects();:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Function headshoot()

If bloodtime<1 Then 

 bloodcount=23+3*bloodlevel
 bloodtime=60000
 sndplay(burnhead)
 bloodammo=mxbloodammo
 gabot(0)=mxbloodammo 
 statistiktimer=now

Else

If bloodcount<1 Then
 sndplay(fanatic)
 rank(0)=rank(0)+bloodlevel
 bloodlevel=bloodlevel+1
 bloodcount=23*bloodlevel
 bloodtime=Log(bloodcount*3-bloodlevel*2)

 statistiktimer=now

End If

If bloodtimer-now<1000 Then
bloodtimer=now
bloodtime=bloodtime-1
End If

End If 




;newobj;;;;;;;;;;;;;;;;;;;
If Rand(999)<3 Then
 ox=Rand(windx-26)+13
 oy=windy+23

If Rand(100)<50 Then newobject(ox,oy,1,3)
If Rand(100)<25 Then newobject(ox,oy,1,6)
If Rand(100)<5 Then newobject(ox,oy,1,9)
If Rand(100)<4 Then newobject(ox,oy,1,9)
If Rand(100)<3 Then newobject(ox,oy,1,9)
If Rand(100)<2 Then newobject(ox,oy,1,9)
If Rand(100)<1 Then newobject(ox,oy,1,9)
End If

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

If KeyHit(48) Then 
If bloodon=True Then
 bloodon=False
 loadimageblood()
Else
 bloodon=True
 loadimageblood()
End If
End If

altewaffe=waffe
If rank(0)=0 Then waffe=0
If rank(0)>0 Then waffe=1
If rank(0)>125 Then waffe=2
If rank(0)>1250 Then waffe=3
If rank(0)>3500 Then waffe=4
If rank(0)>10000 Then waffe=5
If rank(0)>25000 Then waffe=6

If Not altewaffe=waffe Then

 sndplay(burnhead)

Select waffe
Case 0

Case colt
mxbloodammo=10
bloodammo=mxbloodammo
sblutwaffe=350
Case desert
mxbloodammo=15
bloodammo=mxbloodammo
sblutwaffe=320
Case glock
mxbloodammo=18
bloodammo=mxbloodammo
sblutwaffe=270
Case mp5slim
mxbloodammo=15
bloodammo=mxbloodammo
sblutwaffe=200
Case mp5
mxbloodammo=30
bloodammo=mxbloodammo
sblutwaffe=200
Case ak47
mxbloodammo=30
bloodammo=mxbloodammo
sblutwaffe=200
Default
mxbloodammo=30
bloodammo=mxbloodammo
sblutwaffe=150
End Select
End If

;shoot
If bloodammo>0 Then
 If MouseX()>winx And MouseX()<winx+windx And MouseY()>winy And MouseY()<winy+windy Then
  If (MouseHit(1) And waffe<=glock) Or (MouseDown(1) And waffe>glock) Then
   If tblutwaffe+sblutwaffe<now And waffe>0 Then
    tblutwaffe=now
    If waffe>6 Then chas=PlaySound(bloodgun(6)) Else chas=PlaySound(bloodgun(waffe))
    ChannelVolume chas,sound
    bloodammo=bloodammo-1
    bloodshoots=bloodshoots+1
    coolblood(MouseX(canvas)-15,MouseY(canvas)-5)
   End If
  End If
 End If
Else
 If (MouseHit(1) And bloodammo=0) Then
 ;klick
  If tblutwaffe+sblutwaffe<now And waffe>0 Then
   tblutwaffe=now
   chas=PlaySound(blooddry)
   ChannelVolume chas,sound
  End If
 End If
End If

If MouseHit(2) Then
 If gabot(0)>=mxbloodammo Then
  If waffe>6 Then chas=PlaySound(bloodreload(6)) Else chas=PlaySound(bloodreload(waffe))
  ChannelVolume chas,sound
  bloodammo=mxbloodammo
  gabot(0)=gabot(0)-mxbloodammo
 End If
End If
;---

For i=0 To mxblood
 If blut(i)>0 Then DrawImage iblood,blutx(i)-15,bluty(i)-5,blut(i)-1
Next
Color 255,255,255
For i=0 To mxblood
 If i>27 Then
  If stats=True Then Text windx-100,30+(i-28)*15,blut(i)+" "+blutx(i)+" "+bluty(i)+" "+blutline(i)+" "+blutlines(i)+" "+stopblutline(i),1
 Else
  If stats=True Then Text 100,30+i*15,blut(i)+" "+blutx(i)+" "+bluty(i)+" "+blutline(i)+" "+blutlines(i)+" "+stopblutline(i),1
 End If
Next



;zeichnet blutlinie
If bloodon=True Then 
For i=0 To mxblood
If blut(i)>0 Then
 Color 255,0,0
 If tblutline(i)+80<now And stopblutline(i)=False Then
   tblutline(i)=now
   blutline(i)=blutline(i)+1
   If Rand(1000)<10+blutline(i)/3 Then stopblutline(i)=True
 End If

 For k=-blutlines(i)/2 To blutlines(i)/2
  Line blutx(i)-blutlines(i)/4+k*2,bluty(i),blutx(i)-blutlines(i)/4+k*2,bluty(i)+(blutline(i)-k*2*blutline(i)/2)
 Next
End If
Next
End If

If stats=True Then
 Color 255,255,255
 Text 200,100,waffe+" "+rank(0)+" "+bloodammo+" "+mxbloodammo
End If


Color Rand(155)+100,Rand(155)+100,Rand(155)+100
Text 5,5,rank(0),0,0
Text 5,windy-18,bloodammo+"/"+mxbloodammo+" - "+gabot(0),0,0


k=1
l=bloodtime
While l>9
l=l/10 
k=k+1
Wend
Text windx-8*k-8,5,bloodtime

k=1
l=bloodcount
While l>9
l=l/10 
k=k+1
Wend
Text windx-8*k-8,20,bloodcount

Text 5,20,bloodlevel


If statistiktimer+15000>now Then

Text windx/2-70,10,"shoots : "+bloodshoots
Text windx/2-70,25,"hits   : "+bloodhits
If bloodhits>0 Then Text windx/2-70,40,"rate   : "+100*bloodhits/bloodshoots+" %"

For i=1 To 9
Text windx/2-70,55+15*i,"obj level "+i+" : "+bloodtargets(i)
Next

End If

doobjects()

Color 0,150,0

If MouseX()>winx And MouseX()<winx+windx And MouseY()>winy And MouseY()<winy+windy Then
 Line MouseX(canvas)-5,MouseY(canvas),MouseX(canvas)-2,MouseY(canvas)
 Line MouseX(canvas)+2,MouseY(canvas),MouseX(canvas)+5,MouseY(canvas)
 Line MouseX(canvas),MouseY(canvas)-5,MouseX(canvas),MouseY(canvas)-2
 Line MouseX(canvas),MouseY(canvas)+2,MouseX(canvas),MouseY(canvas)+5
End If

End Function