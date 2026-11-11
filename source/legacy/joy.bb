Function joy(i)

;bewegung
If (KeyDown(208) Or KeyDown(39) Or JoyY()=1) Then duck(i)=True
If (KeyDown(200) Or KeyDown(25) Or JoyY()=-1) And ebot(i)>0 Then
 jump(i)=True
 jet(i)=True
Else
 jet(i)=False
End If

If Not KeyDown(30) Then
If (KeyDown(205) Or KeyDown(40) Or JoyX()=1) Then
 forward(i)=True
 align(i)=True
End If
If (KeyDown(203) Or KeyDown(38) Or JoyX()=-1) Then
 forward(i)=True
 align(i)=False
End If
Else
back(i)=True
End If

If JoyDown(7) Then
 align(i)=True
 back(i)=True
 forward(i)=False
End If
If JoyDown(8) Then
 align(i)=False
 back(i)=True
 forward(i)=False
End If

;catch
If JoyDown(5) Or KeyDown(18) Then catch(i)
If JoyDown(6) Or KeyDown(17) Then heal(i)

;waffen
If KeyDown(31) Or JoyDown(3) Then newbullet(i,duck(i))
If JoyHit(1) Then newbullet(i,duck(i)) ; granaten
If KeyDown(32) Or JoyDown(4) Then newflame(i,duck(i))
If KeyDown(33) Or JoyDown(2) Then dolaser(i,duck(i))
End Function