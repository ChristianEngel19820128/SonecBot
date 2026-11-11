Global windx%=640
Global windy%=480
Global winx%
Global winy%
Global winx2%
Global winy2% 

Global winmain
Global canvas

  winx=GadgetWidth(Desktop())/2-windx/2
  winy=GadgetHeight(Desktop())/2-windy/2
  winx2=winx+windx
  winy2=winy+windy
  winmain=CreateWindow("sonec",winx,winy,windx,windy,0,0);1+4+8)
  canvas=CreateCanvas(0,0,ClientWidth(winmain),ClientHeight(winmain),winmain)
  SetBuffer CanvasBuffer(canvas)


Text windx/2,windy/2,"Loading ...",1,1
FlipCanvas(canvas)

Global now=MilliSecs()
SeedRnd (MilliSecs()) 
HidePointer(canvas)

Global music#=0.5
Global sound#=0.5

Global cham
Global chas

;-----------------------------

Global imgintro=LoadImage("images/intro.bmp")
Global intromusic=LoadSound("sound/intro.ogg");sound/original_instrumental.mp3")

LoopSound intromusic
cham=PlaySound(intromusic)
ChannelVolume cham,music

Include "bot2.bb"
Include "game.bb"
Include "blood.bb"
Include "data.bb"
Include "frame.bb"

loadimageblood()


;initwalkergraf intro
twalker(0)=0
xwalker(0)=windx/2-ImageWidth(imgintro)/2
ywalker(0)=windy/2-ImageHeight(imgintro)/2-20
awalker(0)=False

;-----------------------------

Function graf()
For i=0 To 1024
Color 110-i/10,110-i/10,180-i/9
Line 0,i,windx,i
Next 
End Function

;------------------------------------------
Global ende=False
While (ende=False)
now=MilliSecs()
Cls
;----------------------

;graf()


If KeyHit(156) Or KeyHit(28) Or JoyHit(12) Then
 StopChannel cham
 game()
 FlushKeys()
 FlushJoy()
twalker(0)=0
xwalker(0)=windx/2-ImageWidth(imgintro)/2
ywalker(0)=windy/2-ImageHeight(imgintro)/2-20
awalker(0)=False
End If

DrawImage imgintro,windx/2-ImageWidth(imgintro)/2,windy/2-ImageHeight(imgintro)/2-1
headshoot()

Color Rand(155)+100,Rand(155)+100,Rand(155)+100
Text windx/2,windy/2+150,"press start",1,0


;walker
If twalker(0)+150<now Then 
 twalker(0)=now
 If awalker(0)=False Then
  If i>2 Then i=0
  i=i+1
  xwalker(0)=xwalker(0)-move
 Else
  If i<5 Then i=7
  i=i-1
  xwalker(0)=xwalker(0)+move
 End If
 If xwalker(0)>windx/2+ImageWidth(imgintro)/2-20 Then awalker(0)=False
 If xwalker(0)<windx/2-ImageWidth(imgintro)/2 Then awalker(0)=True
End If
DrawImage(imgwalker,xwalker(0),ywalker(0),i)

logo(windx-20,windy-10)
;----------------------
If KeyHit(1) Then ende=True
FlipCanvas(canvas)
Wend
;------------------------------------------
savemem()