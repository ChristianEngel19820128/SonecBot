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
            Intro.Orbs[FreeSlot].Size = Random(12,18)
            Intro.Orbs[FreeSlot].Speed = Random(18,48)*0.001
        endif
        Intro.NextOrbMs = Now+Random(600,1400)
    endif
    Delta = GetFrameTime()*1000
    if Delta > 60 then Delta = 60
    for i = 0 to MENU_ORB_COUNT-1
        if Intro.Orbs[i].Enabled = TRUE
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
    if Intro.PaintImageID <= 0 then exitfunction
    for i = MENU_ORB_COUNT-1 to 0 step -1
        if Intro.Orbs[i].Enabled = TRUE
            if (X-Intro.Orbs[i].X)*(X-Intro.Orbs[i].X)+(Y-Intro.Orbs[i].Y)*(Y-Intro.Orbs[i].Y) <= Intro.Orbs[i].Size*Intro.Orbs[i].Size*0.25
                Intro.Orbs[i].Enabled = FALSE
                if Intro.Paint.Length >= MENU_PAINT_LIMIT-1
                    DeleteSprite(Intro.Paint[0].SpriteID)
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
                SetSpriteUV(Paint.SpriteID,U1,0,U2,0,U1,1,U2,1)
                Size = Random(24,75)
                SetSpriteSize(Paint.SpriteID,Size,Size)
                SetSpriteOffset(Paint.SpriteID,Size*0.5,Size*0.5)
                SetSpritePositionByOffset(Paint.SpriteID,X,Y)
                SetSpriteAngle(Paint.SpriteID,Random(0,359))
                Intro.Paint.Insert(Paint)
                exitfunction
            endif
        endif
    next i
endfunction

function IntroPaintDraw(Intro ref as TIntro)
    local i as integer
    for i = 0 to Intro.Paint.Length
        DrawSprite(Intro.Paint[i].SpriteID)
    next i
    if Intro.OrbSpriteID > 0
        for i = 0 to MENU_ORB_COUNT-1
            if Intro.Orbs[i].Enabled = TRUE
                SetSpriteSize(Intro.OrbSpriteID,Intro.Orbs[i].Size,Intro.Orbs[i].Size)
                SetSpriteOffset(Intro.OrbSpriteID,Intro.Orbs[i].Size*0.5,Intro.Orbs[i].Size*0.5)
                SetSpritePositionByOffset(Intro.OrbSpriteID,Intro.Orbs[i].X,Intro.Orbs[i].Y)
                DrawSprite(Intro.OrbSpriteID)
            endif
        next i
    endif
endfunction
