Const mxobjtyp=17
Global objects=LoadAnimImage("images/bonus.bmp",10,10,0,mxobjtyp,2)
MaskImage objects,0,0,0
Const mxobj=30
Dim obj(mxobj)
Dim objx(mxobj)
Dim objy(mxobj)
Dim obja(mxobj)
Global objtimer=0
Global objtimer2=0

Global getobject=LoadSound("sound/U.I. Sound 13.wav")



Function initobjects()

For i=0 To mxobj
obj(i)=0
Next

End Function



Function newobject(x=0,y=0,o=0,b=0)
i=0
f=False

While f=False And i<=mxobj
 If obj(i)=0 Then f=True Else i=i+1
Wend

If f=True Then

If o=0 Then
 obj(i)=Rand(mxobjtyp)
 If obj(i)>5 Then obj(i)=Rand(mxobjtyp)
Else
 If b=0 Then
  obj(i)=o
 Else
  obj(i)=Rand(o,b)
 End If
End If

obja(i)=Rand(12)

If x=0 And y=0 Then
If Rand(0,1)=0 Then
  objx(i)=windx
  objy(i)=Rand(windy)
 Else
  objx(i)=Rand(windx)
  objy(i)=windy
End If
Else
 objx(i)=x
 objy(i)=y
End If

End If

End Function


Global alignox=0
Function doobjects()

If objtimer+130+Rand(50)<now Then 

For i=0 To mxobj
If obj(i)>0 Then 

If obja(i)<9 Then 
 objx(i)=objx(i)-1
Else
 objx(i)=objx(i)+1
End If

obja(i)=obja(i)+1
If obja(i)>12+Rand(10) Then obja(i)=0

If objx(i)<-12 Then obj(i)=0
End If 
Next
objtimer=now
End If

If objtimer2+125+Rand(50)<now Then
For i=0 To mxobj
If obj(i)>0 Then
objy(i)=objy(i)-Rand(2)
If objy(i)<-10 Then obj(i)=0
End If
Next
objtimer2=now
End If


If Rand(800)<1 Then
 ox=Rand(windx-80)+40
 oy=windy

If Rand(100)<50 Then newobject(ox,oy+Rand(mxobjtyp))
If Rand(100)<50 Then newobject(ox,oy+Rand(mxobjtyp))
If Rand(100)<50 Then newobject(ox,oy+Rand(mxobjtyp))
If Rand(100)<50 Then newobject(ox,oy+Rand(mxobjtyp))
If Rand(100)<5 Then newobject(ox,oy+Rand(mxobjtyp))
If Rand(100)<4 Then newobject(ox,oy+Rand(mxobjtyp))
If Rand(100)<3 Then newobject(ox,oy+Rand(mxobjtyp))
If Rand(100)<2 Then newobject(ox,oy+Rand(mxobjtyp))
If Rand(100)<1 Then newobject(ox,oy+Rand(mxobjtyp))
End If


If timeportal<65 Then drawobjects()

End Function


Function drawobjects()
For i=0 To mxobj
 If obj(i)>0 Then 
  DrawImage(objects,objx(i),objy(i),obj(i)-1)
 End If
Next
End Function


Function colobjects(img,x,y,fr,index)
For i=0 To mxobj
If obj(i)>0 Then
If RectsOverlap(x,y,25,25,objx(i),objy(i),10,10) Then
If ImagesCollide(img,x,y,fr,objects,objx(i),objy(i),obj(i)-1) Then
getobjbonus(obj(i),index)
obj(i)=0
chas=PlaySound(getobject)
ChannelVolume chas,sound
End If
End If
End If
Next
End Function


Function getobjbonus(typ,index)
Select typ
Case 1
 ebot(index)=ebot(index)+1
 xpbot(index)=xpbot(index)+1
Case 2
 ebot(index)=ebot(index)+2
 xpbot(index)=xpbot(index)+1
Case 3 
 ebot(index)=ebot(index)+5
 xpbot(index)=xpbot(index)+1
Case 4
 ebot(index)=ebot(index)+7
 xpbot(index)=xpbot(index)+1
Case 5
 ebot(index)=ebot(index)+10
 xpbot(index)=xpbot(index)+1
Case 6
 ebot(index)=ebot(index)+15
 xpbot(index)=xpbot(index)+1
Case 7
 ebot(index)=ebot(index)+20
 xpbot(index)=xpbot(index)+1
Case 8
 ebot(index)=ebot(index)+25
 xpbot(index)=xpbot(index)+1
Case 9
 ebot(index)=ebot(index)+50
 xpbot(index)=xpbot(index)+1
Case 10
 rank(index)=rank(index)+2
Case 11
 score(index)=score(index)+5
Case 12 
 score(index)=score(index)+25
Case 13
 gabot(index)=gabot(index)+25
Case 14
 hbot(index)=hbot(index)+25
Case 15
 rank(index)=rank(index)+5
Case 16
 rank(index)=rank(index)+1
Case 17
 rank(index)=rank(index)+10
End Select
score(index)=score(index)+5

checkbotdata(index)

End Function


Function showobjdata()
For i=0 To mxobj
 Text 260,20*i+5,obj(i)
 Text 280,20*i+5,objx(i)
 Text 330,20*i+5,objy(i)
Next
End Function