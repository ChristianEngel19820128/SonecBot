'2 stunden

Strict


AppTitle="sonecbot"

Global wx=1920
Global wy=1080
Global wd=0
Global wh=0


Graphics wx,wy,wd,wh,graphics_backbuffer


SeedRnd MilliSecs()





Const c_left=0
Const c_right=1

Const c_stand=0
Const c_move=1
Const c_step=2
Const c_fly=3
Const c_jump=4
Const c_fall=5


Global img_bot:TImage=LoadAnimImage("gfx/bot.png",50,50,0,16,0)

Global bot_x=wx/2-25
Global bot_y=-25

Global bot_a
Global bot_p=c_fall
Global bot_m

Global bot_j


Global bot_i

Global bot_t
Global bot_s=5




Global img_plate:TImage=LoadImage("gfx/plate.png")

Const plate_max=20

Global plate[plate_max]

Global plate_x[plate_max]
Global plate_y[plate_max]




Function plate_new(x=-1)

  Local f=False
  Local i=0

  While f=False And i<plate_max

    If plate[i]=0 Then

      f=True
      plate[i]=1

      plate_x[i]=Rand(0,wx)
      plate_y[i]=wy

      If x>=0 Then
        plate_x[i]=x+100
      End If

      If Rand(0,100)<10 Then
        plate_new(plate_x[i])
      End If

    Else
      i:+1
    End If

  Wend



End Function


Function plate_do()

  For Local i=0 To plate_max-1
    plate_y[i]=plate_y[i]-3
    If plate_y[i]<-3 Then plate[i]=0

  Next

  If Rand(0,100)<1 Then plate_new()

End Function


Function plate_draw()

  For Local i=0 To plate_max-1
    If plate[i]>0 Then
      DrawImage(img_plate,plate_x[i],plate_y[i])
    End If
  Next

End Function









Function bot_move()


  If KeyDown(KEY_LEFT) Or KeyDown(KEY_A) Or JoyX()=-1 Then
    bot_a=c_left
    bot_p=c_move
  End If

  If KeyDown(KEY_RIGHT) Or KeyDown(KEY_D) Or JoyX()=1 Then
    bot_a=c_right
    bot_p=c_move
  End If

  If KeyHit(KEY_E) Then
    bot_p=c_step
  End If

  If JoyHit(3) Then

    If bot_j=0 Then
      bot_j=1
    Else
      bot_j=0
    End If

  End If


End Function



Function bot_fall()

  If bot_y<wy-100 Then
    bot_y=bot_y+3
  Else
    plate_do()
  End If

End Function



Function bot_draw()

  If MilliSecs()>bot_t+bot_s Then

    bot_t=MilliSecs()

    Select bot_a

      Case c_left

        Select bot_p

          Case c_fall

            bot_i=12
            bot_fall()

        End Select

      Case c_right

        Select bot_p

          Case c_fall

            bot_i=13
            bot_fall()

        End Select
    End Select

  End If

  plate_draw()

  DrawImage img_bot,bot_x,bot_y,bot_i


End Function




Function init()


End Function



Function do()

  bot_move()
  bot_draw()

EndFunction





'hauptschleife


init()

Global font:timagefont=LoadImageFont("font/arial.ttf",12)
SetImageFont font

SetBlend alphablend

Global now:Int=MilliSecs()
Global ende:Byte=False
Global draw_t:Int=now

Global mouse:Byte


Global fps
Global fps_a
Global fps_t
Global fps_c
Global cycle

While ende=False

now=MilliSecs()


mouse=0
If MouseHit(1) Then mouse=1
If MouseHit(2) Then mouse=2

Cls



do()



cycle=cycle+1


If MilliSecs()-draw_t>0 Then

SetColor 0,0,0
DrawRect wx-240,0,240,50
SetColor 255,255,255

  DrawText "cycle: "+(MilliSecs()-now),wx-120,10
  DrawText "steps: "+cycle,wx-240,10 
  cycle=0

  fps_c=fps_c+1
  fps=1000/(MilliSecs()-fps_t+1)
  fps_a=fps_a+fps


  DrawText "fps: "+(fps_a/fps_c)+" "+fps,wx-240,30 
  DrawText "cycle: "+(MilliSecs()-fps_t),wx-120,30


  If fps_c>100 Then
   fps_a=fps_a/fps_c
   fps_c=1
  End If

  fps_t=MilliSecs()

  Flip(-1)
  draw_t=MilliSecs()

End If





If KeyHit(key_escape) Then ende=True
Wend
