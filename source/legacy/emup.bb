Global imgemup=LoadAnimImage("images/emup.bmp",20,20,0,2,2)
Global imgup=LoadAnimImage("images/up.bmp",20,20,0,2,2)

Global sndhitemup=LoadSound("sound/health.wav")

Const mxemup=4
Dim emup(mxemup)
Dim xemup(mxemup)
Dim yemup(mxemup)
Dim hemup(mxemup)

Dim emupdown(mxemup)
Dim ypemup(mxemup)

Global emupreg=30


Function initemup()
For i=0 To mxemup
emup(i)=0
Next
End Function



Function newemup()
 i=0
 f=False
 While f=False And i<=mxemup
  If emup(i)=0 Then f=True Else i=i+1
 Wend
 If f=True Then
  emup(i)=Rand(1,2)
  xemup(i)=windx+20
  yemup(i)=Rand(windy)
  hemup(i)=10
 End If
End Function


Function doemup()
 For i=0 To mxemup
  If emup(i)>0 Then
   xemup(i)=xemup(i)-1
   If xemup(i)<-20 Then emup(i)=0

If ypemup(i)<1 Then emupdown(i)=True
If ypemup(i)>15 Then emupdown(i)=False
If emupdown(i)=True Then
  yemup(i)=yemup(i)+1
  ypemup(i)=ypemup(i)+1
 Else
  yemup(i)=yemup(i)-1
  ypemup(i)=ypemup(i)-1
End If

  End If
 Next
End Function


Function drawemup()
 For i=0 To mxemup
  If emup(i)>0 Then DrawImage imgemup,xemup(i),yemup(i),emup(i)-1
 Next
End Function


Function colemup(x,y,dx,dy,img,f)
 col=False
 For i=0 To mxemup
  If emup(i)>0 Then
   If RectsOverlap(xemup(i),yemup(i),20,20,x,y,dx,dy)
    If ImagesCollide(imgemup,xemup(i),yemup(i),emup(i)-1,img,x,y,f)
     ;treffer
     col=True
     sndplay(sndhitemup)
     If hemup(i) Mod 2 = 0 Then 
      If emup(i)=2 Then newobject(xemup(i),yemup(i),10,16)
      If emup(i)=1 Then newobject(xemup(i),yemup(i),1,9)
     End If
     hemup(i)=hemup(i)-1
     If hemup(i)<1 Then
      emup(i)=0
      If emup(i)=2 Then newobject(xemup(i),yemup(i),10,16)
      If emup(i)=1 Then
       newobject(xemup(i),yemup(i),1,9)
       newobject(xemup(i),yemup(i),1,9)
       newobject(xemup(i),yemup(i),1,9)
      End If
     End If
    End If
   End If
  End If
 Next
 Return col
End Function