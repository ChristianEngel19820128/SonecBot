// FIFO message stack. Kind 0 = danger, kind 1 = positive.
#constant NOTICE_WIDTH 440
#constant NOTICE_HEIGHT 58
#constant NOTICE_TOP 13
#constant NOTICE_MAX 4
#constant NOTICE_GAP 8
#constant NOTICE_LINE_HEIGHT 8
#constant NOTICE_PREVIEW 1800
#constant PICKUP_STAR_MS 1100

function WarningCreate(Warning ref as TWarning,Screen as TSize)
    local i as integer
    Warning.CenterX = Screen.Width*0.5
    Warning.Icon.Image.File.Path = "/media/gfx/effects"
    Warning.Icon.Image.File.Name = "warning.png"
    if ImageLoad(Warning.Icon.Image) = TRUE
        SpriteLoad(Warning.Icon)
    endif
    Warning.IconData.Center = TRUE
    Warning.IconData.Scale = 0.75
    Warning.IconData.Position.x = Warning.CenterX-171
    ColorSet(Warning.IconData.Color,255,104,104,255)
    Warning.StarIcon.Image.File.Path = "/media/gfx/effects"
    Warning.StarIcon.Image.File.Name = "star.png"
    if ImageLoad(Warning.StarIcon.Image) = TRUE
        SpriteLoad(Warning.StarIcon)
    endif
    Warning.StarData.Center = TRUE
    Warning.StarData.Scale = 0.75
    Warning.StarData.Position.x = Warning.CenterX-171
    ColorSet(Warning.StarData.Color,140,230,173,255)
    for i = 0 to NOTICE_MAX-1
        Warning.Notice[i].BarSpriteID = CreateSprite(0)
        Warning.Notice[i].TextID = CreateText("")
        SetTextAlignment(Warning.Notice[i].TextID,1)
        SetTextSize(Warning.Notice[i].TextID,23)
        SetTextBold(Warning.Notice[i].TextID,1)
    next i
    WarningReset(Warning)
endfunction

function WarningReset(Warning ref as TWarning)
    local i as integer
    Warning.Count = 0
    Warning.PickupStarStartMs = 0
    Warning.PickupStarUntilMs = 0
    for i = 0 to NOTICE_MAX-1
        Warning.Notice[i].MessageString = ""
        Warning.Notice[i].UntilMs = 0
        Warning.Notice[i].PreviewUntilMs = 0
        SetTextString(Warning.Notice[i].TextID,"")
    next i
endfunction

function WarningUpdate(Warning ref as TWarning,Now as integer)
    local i as integer
    local k as integer
    Warning.Now = Now
    i = 0
    while i < Warning.Count
        if Now >= Warning.Notice[i].UntilMs
            for k = i to Warning.Count-2
                Warning.Notice[k].MessageString = Warning.Notice[k+1].MessageString
                Warning.Notice[k].Kind = Warning.Notice[k+1].Kind
                Warning.Notice[k].UntilMs = Warning.Notice[k+1].UntilMs
                Warning.Notice[k].PreviewUntilMs = Warning.Notice[k+1].PreviewUntilMs
            next k
            Warning.Count = Warning.Count-1
        else
            i = i+1
        endif
    endwhile
endfunction

// Retain the original call signature for existing warning producers.
function WarningShow(Warning ref as TWarning,MessageString as string,Priority as integer,DurationMs as integer,Now as integer)
    WarningPush(Warning,MessageString,0,DurationMs,Now)
endfunction

function WarningShowPositive(Warning ref as TWarning,MessageString as string,DurationMs as integer,Now as integer)
    Warning.PickupStarStartMs = Now
    Warning.PickupStarUntilMs = Now+PICKUP_STAR_MS
    WarningPush(Warning,MessageString,1,DurationMs,Now)
endfunction

function WarningPush(Warning ref as TWarning,MessageString as string,Kind as integer,DurationMs as integer,Now as integer)
    local i as integer
    if DurationMs > 0
        WarningUpdate(Warning,Now)
        if Warning.Count < NOTICE_MAX
            i = Warning.Count
            Warning.Notice[i].MessageString = MessageString
            Warning.Notice[i].Kind = Kind
            Warning.Notice[i].UntilMs = Now+DurationMs
            Warning.Notice[i].PreviewUntilMs = Now+NOTICE_PREVIEW
            Warning.Count = Warning.Count+1
        endif
    endif
endfunction

function WarningDraw(Warning ref as TWarning)
    local i as integer
    local y as float
    local r as integer
    local g as integer
    local b as integer
    y = NOTICE_TOP
    for i = 0 to Warning.Count-1
        if Warning.Notice[i].Kind = 1
            r = 140
            g = 230
            b = 173
        else
            r = 255
            g = 100
            b = 100
        endif
        if i > 0 and Warning.Now >= Warning.Notice[i].PreviewUntilMs
            SetSpriteSize(Warning.Notice[i].BarSpriteID,NOTICE_WIDTH,NOTICE_LINE_HEIGHT)
            SetSpriteColor(Warning.Notice[i].BarSpriteID,r,g,b,240)
            SetSpritePosition(Warning.Notice[i].BarSpriteID,Warning.CenterX-NOTICE_WIDTH*0.5,y)
            DrawSprite(Warning.Notice[i].BarSpriteID)
            y = y+NOTICE_LINE_HEIGHT+NOTICE_GAP
        else
            SetSpriteSize(Warning.Notice[i].BarSpriteID,NOTICE_WIDTH,NOTICE_HEIGHT)
            SetSpriteColor(Warning.Notice[i].BarSpriteID,12,12,24,180)
            SetSpritePosition(Warning.Notice[i].BarSpriteID,Warning.CenterX-NOTICE_WIDTH*0.5,y)
            DrawSprite(Warning.Notice[i].BarSpriteID)
            SetTextString(Warning.Notice[i].TextID,Warning.Notice[i].MessageString)
            SetTextColor(Warning.Notice[i].TextID,r,g,b,255)
            SetTextPosition(Warning.Notice[i].TextID,Warning.CenterX+20,y+NOTICE_HEIGHT*0.5-23*0.55)
            if Warning.Notice[i].Kind = 1
                Warning.StarData.Position.y = y+NOTICE_HEIGHT*0.5
                SpriteDraw(Warning.StarIcon.Sprite,Warning.StarData)
            else
                Warning.IconData.Position.y = y+NOTICE_HEIGHT*0.5
                SpriteDraw(Warning.Icon.Sprite,Warning.IconData)
            endif
            DrawText(Warning.Notice[i].TextID)
            y = y+NOTICE_HEIGHT+NOTICE_GAP
        endif
    next i
endfunction

// A small local pickup confirmation; reuse the same star image as the top notice.
// Draw in screen space following Sonec, with a gentle upward drift and fade.
function WarningPickupStarDraw(Warning ref as TWarning,Sonec ref as TSonec)
    local Elapsed as integer
    local Alpha as integer
    if Warning.PickupStarUntilMs > Warning.Now
        Elapsed = Warning.Now-Warning.PickupStarStartMs
        if Elapsed < 0 then Elapsed = 0
        Alpha = 255-(Elapsed*255/PICKUP_STAR_MS)
        if Alpha < 0 then Alpha = 0
        Warning.StarData.Position.x = Sonec.SpriteData.Position.x
        Warning.StarData.Position.y = Sonec.SpriteData.Position.y-Sonec.ObjectData.Size.Height*0.65-Elapsed*20/PICKUP_STAR_MS
        Warning.StarData.Scale = 0.35
        ColorSet(Warning.StarData.Color,140,230,173,Alpha)
        SpriteDraw(Warning.StarIcon.Sprite,Warning.StarData)
        // Restore the shared notification icon styling.
        Warning.StarData.Scale = 0.75
        Warning.StarData.Position.x = Warning.CenterX-171
        ColorSet(Warning.StarData.Color,140,230,173,255)
    endif
endfunction
