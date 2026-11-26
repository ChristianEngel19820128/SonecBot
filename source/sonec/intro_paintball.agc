// Main-menu-only Easter egg: rising energy orbs and persistent paint splashes.
// The transparent paintball.png strip is 900x30: 30 frames of 30x30 pixels.
#constant MENU_PAINT_LIMIT 200
#constant MENU_ORB_COUNT 8
#constant MENU_PAINT_FRAMES 30

function IntroPaintCreate(Intro ref as TIntro,Width as integer,Height as integer,Now as integer)
    local i as integer
    Intro.MenuWidth = Width
    Intro.MenuHeight = Height
    Intro.Paint.Length = -1
    Intro.LastPaintFrame = -1
    Intro.NextOrbMs = Now+500
    Intro.OrbImageID = LoadImage("/media/gfx/objects/energie.png")
    if Intro.OrbImageID > 0
        Intro.OrbSpriteID = CreateSprite(Intro.OrbImageID)
    endif
    Intro.PaintImageID = LoadImage("/media/gfx/effects/paintball.png")
    for i = 0 to MENU_ORB_COUNT-1
        Intro.Orbs[i].Enabled = FALSE
    next i
endfunction

function IntroPaintUpdate(Intro ref as TIntro,Now as integer)
    local i as integer
    local Delta as float
    local FreeSlot as integer
    local DripLength as float
    if Intro.NextOrbMs > Now+2000 then Intro.NextOrbMs = Now+500
    if Intro.NextOrbMs <= Now
        FreeSlot = -1
        for i = 0 to MENU_ORB_COUNT-1
            if Intro.Orbs[i].Enabled = FALSE and FreeSlot = -1
                FreeSlot = i
            endif
        next i
        if FreeSlot >= 0
            Intro.Orbs[FreeSlot].Enabled = TRUE
            Intro.Orbs[FreeSlot].X = Random(35,Intro.MenuWidth-35)
            Intro.Orbs[FreeSlot].Y = Intro.MenuHeight+30
            Intro.Orbs[FreeSlot].Size = Random(6,20)
            Intro.Orbs[FreeSlot].Speed = Random(18,48)*0.001
            Intro.Orbs[FreeSlot].SpeedX = Random(-18,18)*0.001
            Intro.Orbs[FreeSlot].NextSteerMs = Now+Random(180,450)
        endif
        Intro.NextOrbMs = Now+Random(600,1400)
    endif
    Delta = GetFrameTime()*1000
    if Delta > 60 then Delta = 60
    // Let each paint drip grow slowly, then keep it on the menu.
    for i = 0 to Intro.Paint.Length
        if Intro.Paint[i].Drip1Length < Intro.Paint[i].Drip1Max
            DripLength = Intro.Paint[i].Drip1Length+Delta*0.018
            if DripLength > Intro.Paint[i].Drip1Max then DripLength = Intro.Paint[i].Drip1Max
            Intro.Paint[i].Drip1Length = DripLength
            SetSpriteSize(Intro.Paint[i].Drip1SpriteID,Intro.Paint[i].Drip1Width,DripLength)
            SetSpritePositionByOffset(Intro.Paint[i].Drip1TipSpriteID,Intro.Paint[i].Drip1X+Intro.Paint[i].Drip1Width*0.5,Intro.Paint[i].DripY+DripLength)
        endif
        if Intro.Paint[i].Drip2Length < Intro.Paint[i].Drip2Max
            DripLength = Intro.Paint[i].Drip2Length+Delta*0.012
            if DripLength > Intro.Paint[i].Drip2Max then DripLength = Intro.Paint[i].Drip2Max
            Intro.Paint[i].Drip2Length = DripLength
            SetSpriteSize(Intro.Paint[i].Drip2SpriteID,Intro.Paint[i].Drip2Width,DripLength)
            SetSpritePositionByOffset(Intro.Paint[i].Drip2TipSpriteID,Intro.Paint[i].Drip2X+Intro.Paint[i].Drip2Width*0.5,Intro.Paint[i].DripY+DripLength)
        endif
    next i
    for i = 0 to MENU_ORB_COUNT-1
        if Intro.Orbs[i].Enabled = TRUE
            // Every few moments randomly accelerate or decelerate horizontally.
            // SpeedX is in virtual pixels per millisecond, including direction.
            if Now >= Intro.Orbs[i].NextSteerMs
                if Random(0,1) = 0
                    Intro.Orbs[i].SpeedX = Intro.Orbs[i].SpeedX-Random(3,9)*0.001
                else
                    Intro.Orbs[i].SpeedX = Intro.Orbs[i].SpeedX+Random(3,9)*0.001
                endif
                if Intro.Orbs[i].SpeedX > 0.045 then Intro.Orbs[i].SpeedX = 0.045
                if Intro.Orbs[i].SpeedX < -0.045 then Intro.Orbs[i].SpeedX = -0.045
                Intro.Orbs[i].NextSteerMs = Now+Random(180,450)
            endif
            Intro.Orbs[i].X = Intro.Orbs[i].X+Intro.Orbs[i].SpeedX*Delta
            // Bounce off the menu edges instead of disappearing sideways.
            if Intro.Orbs[i].X < Intro.Orbs[i].Size*0.5
                Intro.Orbs[i].X = Intro.Orbs[i].Size*0.5
                Intro.Orbs[i].SpeedX = Abs(Intro.Orbs[i].SpeedX)
            endif
            if Intro.Orbs[i].X > Intro.MenuWidth-Intro.Orbs[i].Size*0.5
                Intro.Orbs[i].X = Intro.MenuWidth-Intro.Orbs[i].Size*0.5
                Intro.Orbs[i].SpeedX = -Abs(Intro.Orbs[i].SpeedX)
            endif
            Intro.Orbs[i].Y = Intro.Orbs[i].Y-Intro.Orbs[i].Speed*Delta
            if Intro.Orbs[i].Y < -50 then Intro.Orbs[i].Enabled = FALSE
        endif
    next i
endfunction

function IntroPaintShoot(Intro ref as TIntro,X as float,Y as float)
    local i as integer
    local Frame as integer
    local Paint as TMenuPaint
    local Size as float
    local U1 as float
    local U2 as float
    local HitRadius as float
    local PaintColor as integer
    local R as integer
    local G as integer
    local B as integer
    if Intro.PaintImageID <= 0 then exitfunction
    for i = MENU_ORB_COUNT-1 to 0 step -1
        if Intro.Orbs[i].Enabled = TRUE
            // Allow a 2px edge tolerance around the displayed orb.
            HitRadius = Intro.Orbs[i].Size*0.5+2
            if (X-Intro.Orbs[i].X)*(X-Intro.Orbs[i].X)+(Y-Intro.Orbs[i].Y)*(Y-Intro.Orbs[i].Y) <= HitRadius*HitRadius
                Intro.Orbs[i].Enabled = FALSE
                if Intro.Paint.Length >= MENU_PAINT_LIMIT-1
                    DeleteSprite(Intro.Paint[0].SpriteID)
                    DeleteSprite(Intro.Paint[0].Drip1SpriteID)
                    DeleteSprite(Intro.Paint[0].Drip2SpriteID)
                    DeleteSprite(Intro.Paint[0].Drip1TipSpriteID)
                    DeleteSprite(Intro.Paint[0].Drip2TipSpriteID)
                    Intro.Paint.Remove(0)
                endif
                Frame = Random(0,MENU_PAINT_FRAMES-1)
                if Frame = Intro.LastPaintFrame
                    Frame = Mod(Frame+1,MENU_PAINT_FRAMES)
                endif
                Intro.LastPaintFrame = Frame
                Paint.SpriteID = CreateSprite(Intro.PaintImageID)
                U1 = Frame*1.0/MENU_PAINT_FRAMES
                U2 = (Frame+1)*1.0/MENU_PAINT_FRAMES
                // AGK UV order: top-left, bottom-left, top-right, bottom-right.
                SetSpriteUV(Paint.SpriteID,U1,0,U1,1,U2,0,U2,1)
                Size = Random(24,75)
                SetSpriteSize(Paint.SpriteID,Size,Size)
                SetSpriteOffset(Paint.SpriteID,Size*0.5,Size*0.5)
                SetSpritePositionByOffset(Paint.SpriteID,X,Y)
                // Preserve the source frame's upright orientation and baked-in drips.
                // White paintball frames can now be tinted to match their drips.
                PaintColor = Random(0,5)
                R = 238
                G = 76
                B = 148
                if PaintColor = 1
                    R = 40
                    G = 201
                    B = 232
                endif
                if PaintColor = 2
                    R = 246
                    G = 212
                    B = 71
                endif
                if PaintColor = 3
                    R = 140
                    G = 230
                    B = 173
                endif
                if PaintColor = 4
                    R = 173
                    G = 117
                    B = 232
                endif
                if PaintColor = 5
                    R = 242
                    G = 123
                    B = 66
                endif
                SetSpriteColor(Paint.SpriteID,R,G,B,255)
                // One-pixel vertical trails with small, rounded splatter tips.
                Paint.DripY = Y+Size*0.12
                Paint.Drip1X = X-Size*0.12
                Paint.Drip2X = X+Size*0.10
                Paint.Drip1Width = 1
                Paint.Drip2Width = 1
                Paint.Drip1Length = 1
                Paint.Drip2Length = 1
                Paint.Drip1Max = Random(10,28)
                Paint.Drip2Max = Random(7,20)
                Paint.Drip1SpriteID = CreateSprite(0)
                SetSpriteColor(Paint.Drip1SpriteID,R,G,B,230)
                SetSpriteSize(Paint.Drip1SpriteID,Paint.Drip1Width,Paint.Drip1Length)
                SetSpritePosition(Paint.Drip1SpriteID,Paint.Drip1X,Paint.DripY)
                Paint.Drip2SpriteID = CreateSprite(0)
                SetSpriteColor(Paint.Drip2SpriteID,R,G,B,230)
                SetSpriteSize(Paint.Drip2SpriteID,Paint.Drip2Width,Paint.Drip2Length)
                SetSpritePosition(Paint.Drip2SpriteID,Paint.Drip2X,Paint.DripY)
                // Reuse a tiny white paintball frame as each rounded drop end.
                Paint.Drip1TipSpriteID = CreateSprite(Intro.PaintImageID)
                SetSpriteUV(Paint.Drip1TipSpriteID,0,0,0,1,1.0/MENU_PAINT_FRAMES,0,1.0/MENU_PAINT_FRAMES,1)
                SetSpriteColor(Paint.Drip1TipSpriteID,R,G,B,255)
                SetSpriteSize(Paint.Drip1TipSpriteID,Paint.Drip1Width+1,Paint.Drip1Width+1)
                SetSpriteOffset(Paint.Drip1TipSpriteID,(Paint.Drip1Width+1)*0.5,(Paint.Drip1Width+1)*0.5)
                SetSpritePositionByOffset(Paint.Drip1TipSpriteID,Paint.Drip1X+Paint.Drip1Width*0.5,Paint.DripY+1)
                Paint.Drip2TipSpriteID = CreateSprite(Intro.PaintImageID)
                SetSpriteUV(Paint.Drip2TipSpriteID,0,0,0,1,1.0/MENU_PAINT_FRAMES,0,1.0/MENU_PAINT_FRAMES,1)
                SetSpriteColor(Paint.Drip2TipSpriteID,R,G,B,255)
                SetSpriteSize(Paint.Drip2TipSpriteID,Paint.Drip2Width+1,Paint.Drip2Width+1)
                SetSpriteOffset(Paint.Drip2TipSpriteID,(Paint.Drip2Width+1)*0.5,(Paint.Drip2Width+1)*0.5)
                SetSpritePositionByOffset(Paint.Drip2TipSpriteID,Paint.Drip2X+Paint.Drip2Width*0.5,Paint.DripY+1)
                Intro.Paint.Insert(Paint)
                exitfunction
            endif
        endif
    next i
endfunction

function IntroPaintDraw(Intro ref as TIntro)
    local i as integer
    for i = 0 to Intro.Paint.Length
        DrawSprite(Intro.Paint[i].Drip1SpriteID)
        DrawSprite(Intro.Paint[i].Drip2SpriteID)
        DrawSprite(Intro.Paint[i].Drip1TipSpriteID)
        DrawSprite(Intro.Paint[i].Drip2TipSpriteID)
        DrawSprite(Intro.Paint[i].SpriteID)
    next i
    if Intro.OrbSpriteID > 0
        for i = 0 to MENU_ORB_COUNT-1
            if Intro.Orbs[i].Enabled = TRUE
                // Absolute scale of the native 20x20 orb; apply the final pivot after scaling.
                SetSpriteScaleByOffset(Intro.OrbSpriteID,Intro.Orbs[i].Size/20.0,Intro.Orbs[i].Size/20.0)
                SetSpriteOffset(Intro.OrbSpriteID,GetSpriteWidth(Intro.OrbSpriteID)*0.5,GetSpriteHeight(Intro.OrbSpriteID)*0.5)
                SetSpritePositionByOffset(Intro.OrbSpriteID,Intro.Orbs[i].X,Intro.Orbs[i].Y)
                DrawSprite(Intro.OrbSpriteID)
            endif
        next i
    endif
endfunction
