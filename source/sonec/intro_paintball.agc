// Main-menu-only Easter egg: rising energy orbs and persistent paint splashes.
// The transparent paintball.png atlas uses 90x90 cells in ten columns.
#constant MENU_PAINT_LIMIT 500
#constant MENU_ORB_COUNT 8
#constant MENU_PAINT_CELL 90

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
    if Intro.PaintImageID > 0
        Intro.PaintColumns = Floor(GetImageWidth(Intro.PaintImageID)*1.0/MENU_PAINT_CELL)
        Intro.PaintRows = Floor(GetImageHeight(Intro.PaintImageID)*1.0/MENU_PAINT_CELL)
        Intro.PaintFrames = Intro.PaintColumns*Intro.PaintRows
        Intro.PaintSpriteID = CreateSprite(Intro.PaintImageID)
        Intro.PaintDripSpriteID = CreateSprite(0)
        Intro.PaintTipSpriteID = CreateSprite(Intro.OrbImageID)
    endif
    for i = 0 to MENU_ORB_COUNT-1
        Intro.Orbs[i].Enabled = FALSE
    next i
endfunction

// Choose a stable color per spawned orb, including occasional pure black and white.
function IntroPaintRandomColor(Orb ref as TMenuOrb)
    local Mode as integer
    Mode = Random(0,19)
    if Mode = 0
        Orb.Red = 0
        Orb.Green = 0
        Orb.Blue = 0
    else
        if Mode = 1
            Orb.Red = 255
            Orb.Green = 255
            Orb.Blue = 255
        else
            Orb.Red = Random(0,255)
            Orb.Green = Random(0,255)
            Orb.Blue = Random(0,255)
        endif
    endif
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
            Intro.Orbs[FreeSlot].Size = Random(5,20)
            Intro.Orbs[FreeSlot].Speed = Random(18,48)*0.001
            Intro.Orbs[FreeSlot].SpeedX = Random(-18,18)*0.001
            Intro.Orbs[FreeSlot].NextSteerMs = Now+Random(180,450)
            IntroPaintRandomColor(Intro.Orbs[FreeSlot])
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
        endif
        if Intro.Paint[i].Drip2Length < Intro.Paint[i].Drip2Max
            DripLength = Intro.Paint[i].Drip2Length+Delta*0.012
            if DripLength > Intro.Paint[i].Drip2Max then DripLength = Intro.Paint[i].Drip2Max
            Intro.Paint[i].Drip2Length = DripLength
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
    local HitRadius as float
    if Intro.PaintImageID <= 0 then exitfunction
    for i = MENU_ORB_COUNT-1 to 0 step -1
        if Intro.Orbs[i].Enabled = TRUE
            // Match the visible orb radius without extra edge tolerance.
            HitRadius = Intro.Orbs[i].Size*0.5
            if (X-Intro.Orbs[i].X)*(X-Intro.Orbs[i].X)+(Y-Intro.Orbs[i].Y)*(Y-Intro.Orbs[i].Y) <= HitRadius*HitRadius
                Intro.Orbs[i].Enabled = FALSE
                if Intro.Paint.Length >= MENU_PAINT_LIMIT-1
                    Intro.Paint.Remove(0)
                endif
                Frame = Random(0,Intro.PaintFrames-1)
                if Frame = Intro.LastPaintFrame
                    Frame = Mod(Frame+1,Intro.PaintFrames)
                endif
                Intro.LastPaintFrame = Frame
                Size = Intro.Orbs[i].Size*4.5
                Paint.Frame = Frame
                Paint.X = X
                Paint.Y = Y
                Paint.Size = Size
                Paint.Red = Intro.Orbs[i].Red
                Paint.Green = Intro.Orbs[i].Green
                Paint.Blue = Intro.Orbs[i].Blue
                // One-pixel vertical trails with small, rounded splatter tips.
                Paint.DripY = Y+Size*0.12
                Paint.Drip1X = X-Size*0.12
                Paint.Drip2X = X+Size*0.10
                Paint.Drip1Width = 1
                Paint.Drip2Width = 1
                Paint.Drip1TipWidth = Random(2,3)
                Paint.Drip1TipHeight = Random(2,5)
                Paint.Drip2TipWidth = Random(2,3)
                Paint.Drip2TipHeight = Random(2,5)
                Paint.Drip1Length = 1
                Paint.Drip2Length = 1
                Paint.Drip1Max = Random(10,28)
                Paint.Drip2Max = Random(7,20)
                Intro.Paint.Insert(Paint)
                exitfunction
            endif
        endif
    next i
endfunction

function IntroPaintDraw(Intro ref as TIntro)
    local i as integer
    local U1 as float
    local U2 as float
    local V1 as float
    local V2 as float
    local Column as integer
    local Row as integer
    local Size as float
    for i = 0 to Intro.Paint.Length
        // Draw both one-pixel trails before their rounded tips and the splat.
        SetSpriteColor(Intro.PaintDripSpriteID,Intro.Paint[i].Red,Intro.Paint[i].Green,Intro.Paint[i].Blue,230)
        SetSpriteSize(Intro.PaintDripSpriteID,Intro.Paint[i].Drip1Width,Intro.Paint[i].Drip1Length)
        SetSpritePosition(Intro.PaintDripSpriteID,Intro.Paint[i].Drip1X,Intro.Paint[i].DripY)
        DrawSprite(Intro.PaintDripSpriteID)
        SetSpriteSize(Intro.PaintDripSpriteID,Intro.Paint[i].Drip2Width,Intro.Paint[i].Drip2Length)
        SetSpritePosition(Intro.PaintDripSpriteID,Intro.Paint[i].Drip2X,Intro.Paint[i].DripY)
        DrawSprite(Intro.PaintDripSpriteID)
        SetSpriteColor(Intro.PaintTipSpriteID,Intro.Paint[i].Red,Intro.Paint[i].Green,Intro.Paint[i].Blue,255)
        SetSpriteScaleByOffset(Intro.PaintTipSpriteID,Intro.Paint[i].Drip1TipWidth/20.0,Intro.Paint[i].Drip1TipHeight/20.0)
        SetSpriteOffset(Intro.PaintTipSpriteID,GetSpriteWidth(Intro.PaintTipSpriteID)*0.5,GetSpriteHeight(Intro.PaintTipSpriteID)*0.5)
        SetSpritePositionByOffset(Intro.PaintTipSpriteID,Intro.Paint[i].Drip1X+Intro.Paint[i].Drip1Width*0.5,Intro.Paint[i].DripY+Intro.Paint[i].Drip1Length)
        DrawSprite(Intro.PaintTipSpriteID)
        SetSpriteScaleByOffset(Intro.PaintTipSpriteID,Intro.Paint[i].Drip2TipWidth/20.0,Intro.Paint[i].Drip2TipHeight/20.0)
        SetSpriteOffset(Intro.PaintTipSpriteID,GetSpriteWidth(Intro.PaintTipSpriteID)*0.5,GetSpriteHeight(Intro.PaintTipSpriteID)*0.5)
        SetSpritePositionByOffset(Intro.PaintTipSpriteID,Intro.Paint[i].Drip2X+Intro.Paint[i].Drip2Width*0.5,Intro.Paint[i].DripY+Intro.Paint[i].Drip2Length)
        DrawSprite(Intro.PaintTipSpriteID)
        // Select one 90x90 atlas cell in row-major order.
        Column = Mod(Intro.Paint[i].Frame,Intro.PaintColumns)
        Row = Floor(Intro.Paint[i].Frame*1.0/Intro.PaintColumns)
        U1 = Column*1.0/Intro.PaintColumns
        U2 = (Column+1)*1.0/Intro.PaintColumns
        V1 = Row*1.0/Intro.PaintRows
        V2 = (Row+1)*1.0/Intro.PaintRows
        SetSpriteUV(Intro.PaintSpriteID,U1,V1,U1,V2,U2,V1,U2,V2)
        Size = Intro.Paint[i].Size
        SetSpriteScaleByOffset(Intro.PaintSpriteID,Size/GetImageWidth(Intro.PaintImageID),Size/GetImageHeight(Intro.PaintImageID))
        SetSpriteOffset(Intro.PaintSpriteID,GetSpriteWidth(Intro.PaintSpriteID)*0.5,GetSpriteHeight(Intro.PaintSpriteID)*0.5)
        SetSpritePositionByOffset(Intro.PaintSpriteID,Intro.Paint[i].X,Intro.Paint[i].Y)
        SetSpriteColor(Intro.PaintSpriteID,Intro.Paint[i].Red,Intro.Paint[i].Green,Intro.Paint[i].Blue,255)
        DrawSprite(Intro.PaintSpriteID)
    next i
    if Intro.OrbSpriteID > 0
        for i = 0 to MENU_ORB_COUNT-1
            if Intro.Orbs[i].Enabled = TRUE
                // Absolute scale of the native 20x20 orb; apply the final pivot after scaling.
                SetSpriteScaleByOffset(Intro.OrbSpriteID,Intro.Orbs[i].Size/20.0,Intro.Orbs[i].Size/20.0)
                SetSpriteOffset(Intro.OrbSpriteID,GetSpriteWidth(Intro.OrbSpriteID)*0.5,GetSpriteHeight(Intro.OrbSpriteID)*0.5)
                SetSpritePositionByOffset(Intro.OrbSpriteID,Intro.Orbs[i].X,Intro.Orbs[i].Y)
                SetSpriteColor(Intro.OrbSpriteID,Intro.Orbs[i].Red,Intro.Orbs[i].Green,Intro.Orbs[i].Blue,255)
                DrawSprite(Intro.OrbSpriteID)
            endif
        next i
    endif
endfunction
