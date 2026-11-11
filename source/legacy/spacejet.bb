Global sndrocketfire=LoadSound("sound/rocketfire.wav")
Global sndrocketimpact=LoadSound("sound/rocketimpact.wav")


Const mxrocket=5

Dim rocket(mxrocket)
Dim rocketx(mxrocket)
Dim rockety(mxrocket)
Dim rockettx(mxrocket)
Dim rocketty(mxrocket)
Dim rockettmx(mxrocket)
Dim rocketsmx(mxrocket)
Dim rockettmy(mxrocket)
Dim rocketsmy(mxrocket)
Const mxspeed=25

Function drawrocket()
 For i=0 To mxrocket
  If rocket(i)>0 Then
   Plot(rocketx(i),rockety(i))
  End If
 Next
End Function


Function searchtarget()
For i=0 To mxrocket
rockettx(i)=xbot(0)+12
rocketty(i)=ybot(0)+12
Next
End Function


Function moverocket()
For i=0 To mxrocket
   If rockettmx(i)+rocketsmx(i)<now Then
    rockettmx(i)=now
    If rockettx(i)<rocketx(i) Then rocketx(i)=rocketx(i)-1
    If rockettx(i)>rocketx(i) Then rocketx(i)=rocketx(i)+1
   End If

   If rockettmy(i)+rocketsmy(i)<now Then
    rockettmy(i)=now
    If rocketty(i)<rockety(i) Then rockety(i)=rockety(i)-1
    If rocketty(i)>rockety(i) Then rockety(i)=rockety(i)+1
   End If

   dx#=Abs(rocketx(i)-rockettx(i))
   dy#=Abs(rockety(i)-rocketty(i))
   dxy#=dx+dy

   rocketsmx(i)=mxspeed-mxspeed*dx/dxy
   rocketsmy(i)=mxspeed-mxspeed*dy/dxy
Next
End Function

Function colliderocket()
For i=0 To mxrocket
If rocket(i)>0 Then
If rockettx(i)=rocketx(i) And rocketty(i)=rockety(i) Then
rocket(i)=0
Oval(rockettx(i)-10,rocketty(i)-10,20,20,0)
hbot(0)=hbot(0)-5
sndplay(sndrocketimpact)
End If
End If
Next
End Function



Function initrocket()
For i=0 To mxrocket
rocket(i)=0
Next
End Function


Function newrocket(x,y)
i=0
f=False
While i<mxrocket And f=False
 If rocket(i)=0 Then f=True Else i=i+1
Wend


If f=True Then
sndplay(sndrocketfire)
rocket(i)=1
rocketx(i)=x
rockety(i)=y
rocketsmx(i)=mxspeed
rocketsmy(i)=mxspeed
searchtarget()
End If
End Function


Function dorocket()
searchtarget()
colliderocket()
moverocket()
End Function