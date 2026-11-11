Global flame=LoadAnimImage("images/flame.bmp",10,10,0,9,2)

Const mxflame=13
Const mxfflame=9

Dim typflame(mxflame)
Dim xflame(mxflame)
Dim yflame(mxflame)
Dim zflame(mxflame)
Dim t1flame(mxflame)
Dim s1flame(mxflame)
Dim t2flame(mxflame)
Dim s2flame(mxflame)
Dim aflame(mxflame)


Function initflame(x,y,a,s)
i=0
f=False
While f=False And i=0
If typflame(i)=0 Then f=True Else i=i+1
Wend
If f=True

typflame(i)=1
xflame(i)=x
yflame(i)=y
zflame(i)=0
t1flame(i)=now
s1flame(i)=s
t2flame(i)=now
s2flame(i)=s*2
aflame(i)=a

Return i
End If
Return -1
End Function

;------------------------------------------

Function changeflame(i,x,y,a)
aflame(i)=a
xflame(i)=x
yflame(i)=y
End Function

;------------------------------------------

Function flamegrow(i)


If typflame(i)>0 Then
If t1flame(i)+s1flame(i)<now Then
 t1flame(i)=now
 If zflame(i)<mxfflame Then zflame(i)=zflame(i)+1
End If
End If
End Function

;------------------------------------------

Function doflame()
For i=0 To mxflame
If typflame(i)>0 Then

 If t2flame(i)+s2flame(i)<now Then
  t2flame(i)=now
  If zflame(i)>0 Then zflame(i)=zflame(i)-1
 End If

 If zflame(i)>0 Then
  For k=1 To zflame(i)
   If aflame(i)=True Then DrawImage flame,xflame(i)+k*10,yflame(i),k-1 Else DrawImage flame,xflame(i)-k*10,yflame(i),k-1
  Next
 End If

End If
Next
End Function

;------------------------------------------