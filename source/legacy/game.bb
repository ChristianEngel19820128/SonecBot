Global lose=True
Global gamemusic=LoadSound("sound/intro.ogg")


;Global intro=LoadSound("");sound/intro1.mp3")

Function game()

cham=PlaySound(gamemusic)
ChannelVolume cham,music

If lose=True Then
initbot()
initworld()
lose=False
End If

While (lose=False And ende=False)
now=MilliSecs()
Cls
;----------------------
dobots()
dostats()

If KeyHit(37) Then lose=True

;----------------------
If KeyHit(1) Or JoyHit(11) Then ende=True
FlipCanvas(canvas)
Wend
ende=False
If lose=True Then
 gabot(0)=rank(0)
 killbots()
 sndplay(botdie)
 StopChannel cham
Else
 PauseChannel cham
End If
End Function