;kisten
;fallen
;decken


Const mxl=10
Dim clx(mxl)
Dim cldx(mxl)
Dim cly(mxl)
Dim clt(mxl)
Global cltimer=0
Global clspeed=50
Global clreg=40

Dim cle(mxl)
Dim cleu(mxl)
Dim cleh(mxl)
Dim mxcleh(mxl)

Global sgravspeed=25

Global start
Global time

Global lines=0
Global round=0

Global imgback=LoadImage("images/back.bmp")
Global yback

Global schicksal=100000

Global script


;------------------------------------------

Function initworld()
 For i=0 To mxl
  clt(i)=False
 Next

 start=now

 clx(0)=0
 cldx(0)=1500
 cly(0)=windy-25
 clt(0)=True
 cle(0)=False

 script=0

initemup()
initwalker()
initrocket()

End Function

;------------------------------------------

Function showworlddata()
For i=0 To mxl
 Text 260,20*i+5,clt(i)
 Text 280,20*i+5,clx(i)
 Text 330,20*i+5,cldx(i)
 Text 380,20*i+5,cly(i)
Next
End Function

;------------------------------------------

Function worldscript()

If time>30 Then clspeed=45
If time>80 Then clspeed=40
If time>150 And script=0 Then
 clspeed=35
 script=script+1
 longline()
End If
If time>300 And script=1 Then
 clreg=30
 script=script+1
 longline()
End If

If Rand(schicksal)<clreg Then randlines()
If lines<5 Then randlines()


If Rand(schicksal)<emupreg Then newemup()
If Rand(schicksal)<walkerreg Then newwalker()

;If round+1000<now Then
;round=now
;score(index)=score(index)+15
;End If

End Function

;------------------------------------------

Function doworld()
 worldscript()

 ;background anpassen
 yback=(-100-ybot(0))*9/10

 time=(now-start)/1000

 DrawImage imgback,0,yback

 If cltimer+clspeed<now Then
  For i=0 To mxl
   If clt(i)=True Then clx(i)=clx(i)-1

   ;elevators
   If cle(i)=True Then
    If cleu(i)=True Then
     cleh(i)=cleh(i)+1 
     cly(i)=cly(i)+1
    Else
     For k=0 To mxbot
      If typbot(k)>0 Then
       If xbot(k)>clx(i) And xbot(k)<clx(i)+cldx(i) And ybot(k)<cly(i) Then
        ;nicht gut aber es funktioniert erstmal
        fall(0)=False
        ybot(0)=ybot(0)-1
       End If
      End If
     Next
     For k=0 To mxwalker
      If walker(k)>0 Then
       If xwalker(k)>clx(i) And xwalker(k)<clx(i)+cldx(i) And ywalker(k)<cly(i) Then
        ;nicht gut aber es funktioniert erstmal
        walkerfall(0)=False
        ywalker(0)=ywalker(0)-1
       End If
      End If
     Next
     cleh(i)=cleh(i)-1
     cly(i)=cly(i)-1
    End If
    If cleh(i)>mxcleh(i) Then cleu(i)=False
    If cleh(i)<1 Then cleu(i)=True
   End If

  Next
  cltimer=now
  doemup()
 End If

lines=0
For i=0 To mxl
 lines=lines+1
 If clx(i)+cldx(i)<0 Then clt(i)=False
 If clt(i)=True Then Line clx(i),cly(i),clx(i)+cldx(i),cly(i)
Next



dowalker()
doobjects()
dorocket()

drawobjects()
drawemup()
drawwalker()
drawrocket()

;newobj;;;;;;;;;;;;;;;;;;;
If Rand(999)<3 Then
 ox=Rand(windx-26)+13
 oy=windy+23
If Rand(100)<25 Then newobject(ox,oy,1,2)
If Rand(100)<15 Then newobject(ox,oy,1,4)
If Rand(100)<5 Then newobject(ox,oy,1,9)
If Rand(100)<4 Then newobject(ox,oy,1,9)
If Rand(100)<3 Then newobject(ox,oy,1,9)
If Rand(100)<2 Then newobject(ox,oy,1,9)
If Rand(100)<1 Then newobject(ox,oy,1,9)
End If

End Function

;------------------------------------------

Function randlines()
i=0
f=False

While f=False And i<=mxl
 If clt(i)=False Then f=True Else i=i+1
Wend

If f=True Then
 clx(i)=windx
 cldx(i)=Rand(250)+50
 cly(i)=Rand(windy-50)+50
 clt(i)=True

 If cldx(i)<100 Then
  cle(i)=Rand(1)
  mxcleh(i)=Rand(50,150)
 Else
  cle(i)=0
 End If

End If

End Function


Function longline()
i=0
f=False

While f=False And i<=mxl
 If clt(i)=False Then f=True Else i=i+1
Wend

If f=True Then
 clx(i)=windx
 cldx(i)=2500
 cly(i)=windy-25
 clt(i)=True
 cle(i)=True
 mxcleh(i)=Rand(20,65)

End If
End Function


;------------------------------------------

Function colline(x,y,tol=1)
col=0
For i=0 To mxl
If clt(i)=True Then
If x+5>clx(i) And x+20<clx(i)+cldx(i) Then

If cly(i)>y And y>=cly(i)-tol Then
For k=1 To tol
If cly(i)=y+k Then col=k
Next
End If

End If
End If
Next
Return col
End Function

;------------------------------------------
