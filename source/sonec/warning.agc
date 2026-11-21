// FIFO message stack. Kind 0 = danger, kind 1 = positive.
#constant NOTICE_WIDTH 440
#constant NOTICE_HEIGHT 58
#constant NOTICE_TOP 13
#constant NOTICE_MAX 4
#constant NOTICE_QUEUE_MAX 64
#constant NOTICE_GAP 8
#constant NOTICE_LINE_HEIGHT 8
#constant NOTICE_PREVIEW 1800
#constant PICKUP_STAR_MS 1100
#constant NOTICE_SLIDE_MS 500
#constant NOTICE_REPEAT_MS 250
#constant NOTICE_BAR_ALPHA 89

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
    Warning.OutBarSpriteID = CreateSprite(0)
    Warning.OutTextID = CreateText("")
    SetTextAlignment(Warning.OutTextID,1)
    SetTextSize(Warning.OutTextID,23)
    SetTextBold(Warning.OutTextID,1)
    Warning.RepeatSpriteID = CreateSprite(0)
    WarningReset(Warning)
endfunction

function WarningReset(Warning ref as TWarning)
    local i as integer
    Warning.Count = 0
    Warning.OverflowCount = 0
    Warning.PickupStarStartMs = 0
    Warning.PickupStarUntilMs = 0
    Warning.SlideStartMs = -NOTICE_SLIDE_MS
    Warning.RepeatStartMs = -NOTICE_REPEAT_MS
    Warning.OutUntilMs = 0
    Warning.OutMessage = ""
    for i = 0 to NOTICE_QUEUE_MAX-1
        Warning.Notice[i].DurationMs = 0
        Warning.Notice[i].RepeatCount = 0
        Warning.Notice[i].MessageString = ""
        Warning.Notice[i].UntilMs = 0
        Warning.Notice[i].PreviewUntilMs = 0
        if i < NOTICE_MAX
            SetTextString(Warning.Notice[i].TextID,"")
        endif
    next i
endfunction

// Copy only message data: sprite/text IDs belong to fixed visible slots.
function WarningCopy(Warning ref as TWarning,Destination as integer,Source as integer)
    Warning.Notice[Destination].MessageString = Warning.Notice[Source].MessageString
    Warning.Notice[Destination].Kind = Warning.Notice[Source].Kind
    Warning.Notice[Destination].UntilMs = Warning.Notice[Source].UntilMs
    Warning.Notice[Destination].PreviewUntilMs = Warning.Notice[Source].PreviewUntilMs
    Warning.Notice[Destination].DurationMs = Warning.Notice[Source].DurationMs
    Warning.Notice[Destination].RepeatCount = Warning.Notice[Source].RepeatCount
endfunction

function WarningRemove(Warning ref as TWarning,Index as integer)
    local k as integer
    for k = Index to Warning.Count-2
        WarningCopy(Warning,k,k+1)
    next k
    Warning.Count = Warning.Count-1
endfunction

function WarningUpdate(Warning ref as TWarning,Now as integer)
    Warning.Now = Now
    if Warning.Count > 0
        if Now >= Warning.Notice[0].UntilMs
            WarningCaptureOutgoing(Warning,Now)
            WarningRemove(Warning,0)
            if Warning.Count > 0
                // Waiting messages receive their full display duration on promotion.
                Warning.Notice[0].UntilMs = Now+Warning.Notice[0].DurationMs
                Warning.SlideStartMs = Now
            endif
        endif
    endif
endfunction

// Snapshot the departing active panel before queue data shifts.
function WarningCaptureOutgoing(Warning ref as TWarning,Now as integer)
    if Warning.Count <= 0 then exitfunction
    Warning.OutMessage = Warning.Notice[0].MessageString
    if Warning.Notice[0].RepeatCount > 1
        Warning.OutMessage = Warning.OutMessage+" x"+Str(Warning.Notice[0].RepeatCount)
    endif
    Warning.OutKind = Warning.Notice[0].Kind
    Warning.OutUntilMs = Now+NOTICE_SLIDE_MS
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
    local j as integer
    if DurationMs <= 0 then exitfunction
    WarningUpdate(Warning,Now)
    // Merge identical events across active and waiting messages.
    for i = 0 to Warning.Count-1
        if Warning.Notice[i].Kind = Kind and Warning.Notice[i].MessageString = MessageString
            Warning.Notice[i].RepeatCount = Warning.Notice[i].RepeatCount+1
            if i = 0
                Warning.RepeatStartMs = Now
                Warning.Notice[i].UntilMs = Now+DurationMs
            endif
            exitfunction
        endif
    next i
    // A new danger supersedes the current panel, including an older danger.
    // N1b will animate this transition; for now it is immediate.
    if Kind = 0 and Warning.Count > 0
        WarningCaptureOutgoing(Warning,Now)
        WarningRemove(Warning,0)
    endif
    if Warning.Count >= NOTICE_QUEUE_MAX
        // Prefer retaining danger messages if the queue is saturated.
        j = -1
        for i = Warning.Count-1 to 0 step -1
            if Warning.Notice[i].Kind = 1 and j = -1 then j = i
        next i
        if j >= 0
            WarningRemove(Warning,j)
        else
            Warning.OverflowCount = Warning.OverflowCount+1
            exitfunction
        endif
    endif
    i = Warning.Count
    if Kind = 0
        // Insert the new warning at the front, keeping waiting order intact.
        for j = Warning.Count to 1 step -1
            WarningCopy(Warning,j,j-1)
        next j
        i = 0
    endif
    Warning.Notice[i].MessageString = MessageString
    Warning.Notice[i].Kind = Kind
    Warning.Notice[i].DurationMs = DurationMs
    Warning.Notice[i].RepeatCount = 1
    Warning.Notice[i].UntilMs = Now+DurationMs
    Warning.Notice[i].PreviewUntilMs = Now+NOTICE_PREVIEW
    Warning.Count = Warning.Count+1
    if i = 0 then Warning.SlideStartMs = Now
endfunction

function WarningDraw(Warning ref as TWarning)
    local i as integer
    local y as float
    local r as integer
    local g as integer
    local b as integer
    local VisibleCount as integer
    local SlideOffset as float
    local Elapsed as integer
    local RepeatAlpha as integer
    local OutX as float

    VisibleCount = Warning.Count
    if VisibleCount > NOTICE_MAX then VisibleCount = NOTICE_MAX
    y = NOTICE_TOP
    for i = 0 to VisibleCount-1
        if Warning.Notice[i].Kind = 1
            r = 140
            g = 230
            b = 173
        else
            r = 255
            g = 100
            b = 100
        endif
        if i > 0
            SetSpriteSize(Warning.Notice[i].BarSpriteID,NOTICE_WIDTH,NOTICE_LINE_HEIGHT)
            SetSpriteColor(Warning.Notice[i].BarSpriteID,r,g,b,NOTICE_BAR_ALPHA)
            SetSpritePosition(Warning.Notice[i].BarSpriteID,Warning.CenterX-NOTICE_WIDTH*0.5,y)
            DrawSprite(Warning.Notice[i].BarSpriteID)
            y = y+NOTICE_LINE_HEIGHT+NOTICE_GAP
        else
            SlideOffset = 0
            Elapsed = Warning.Now-Warning.SlideStartMs
            if Elapsed >= 0 and Elapsed < NOTICE_SLIDE_MS
                SlideOffset = -NOTICE_WIDTH*(NOTICE_SLIDE_MS-Elapsed)/NOTICE_SLIDE_MS
            endif
            SetSpriteSize(Warning.Notice[i].BarSpriteID,NOTICE_WIDTH,NOTICE_HEIGHT)
            SetSpriteColor(Warning.Notice[i].BarSpriteID,12,12,24,NOTICE_BAR_ALPHA)
            SetSpritePosition(Warning.Notice[i].BarSpriteID,Warning.CenterX-NOTICE_WIDTH*0.5+SlideOffset,y)
            DrawSprite(Warning.Notice[i].BarSpriteID)
            if Warning.Notice[i].RepeatCount > 1
                SetTextString(Warning.Notice[i].TextID,Warning.Notice[i].MessageString+" x"+Str(Warning.Notice[i].RepeatCount))
            else
                SetTextString(Warning.Notice[i].TextID,Warning.Notice[i].MessageString)
            endif
            SetTextColor(Warning.Notice[i].TextID,r,g,b,255)
            SetTextPosition(Warning.Notice[i].TextID,Warning.CenterX+SlideOffset,y+NOTICE_HEIGHT*0.5-23*0.55)
            if Warning.Notice[i].Kind = 1
                Warning.StarData.Position.x = Warning.CenterX-171+SlideOffset
                Warning.StarData.Position.y = y+NOTICE_HEIGHT*0.5
                SpriteDraw(Warning.StarIcon.Sprite,Warning.StarData)
                Warning.StarData.Position.x = Warning.CenterX-171
            else
                Warning.IconData.Position.x = Warning.CenterX-171+SlideOffset
                Warning.IconData.Position.y = y+NOTICE_HEIGHT*0.5
                SpriteDraw(Warning.Icon.Sprite,Warning.IconData)
                Warning.IconData.Position.x = Warning.CenterX-171
            endif
            DrawText(Warning.Notice[i].TextID)
            Elapsed = Warning.Now-Warning.RepeatStartMs
            if Elapsed >= 0 and Elapsed < NOTICE_REPEAT_MS
                RepeatAlpha = (NOTICE_REPEAT_MS-Elapsed)*70/NOTICE_REPEAT_MS
                SetSpriteSize(Warning.RepeatSpriteID,NOTICE_WIDTH,NOTICE_HEIGHT)
                SetSpriteColor(Warning.RepeatSpriteID,r,g,b,RepeatAlpha)
                SetSpritePosition(Warning.RepeatSpriteID,Warning.CenterX-NOTICE_WIDTH*0.5+SlideOffset,y)
                DrawSprite(Warning.RepeatSpriteID)
            endif
            y = y+NOTICE_HEIGHT+NOTICE_GAP
        endif
    next i
    // The old panel slides out independently while the new one enters.
    if Warning.OutUntilMs > Warning.Now
        Elapsed = NOTICE_SLIDE_MS-(Warning.OutUntilMs-Warning.Now)
        if Elapsed < 0 then Elapsed = 0
        OutX = Warning.CenterX-NOTICE_WIDTH*0.5-NOTICE_WIDTH*Elapsed/NOTICE_SLIDE_MS
        SetSpriteSize(Warning.OutBarSpriteID,NOTICE_WIDTH,NOTICE_HEIGHT)
        SetSpriteColor(Warning.OutBarSpriteID,12,12,24,NOTICE_BAR_ALPHA)
        SetSpritePosition(Warning.OutBarSpriteID,OutX,NOTICE_TOP)
        DrawSprite(Warning.OutBarSpriteID)
        if Warning.OutKind = 1
            r = 140
            g = 230
            b = 173
        else
            r = 255
            g = 100
            b = 100
        endif
        SetTextString(Warning.OutTextID,Warning.OutMessage)
        SetTextColor(Warning.OutTextID,r,g,b,255)
        SetTextPosition(Warning.OutTextID,OutX+NOTICE_WIDTH*0.5,NOTICE_TOP+NOTICE_HEIGHT*0.5-23*0.55)
        DrawText(Warning.OutTextID)
    endif
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
        Warning.StarData.Position.y = Sonec.SpriteData.Position.y-Sonec.ObjectData.Size.Height*0.65+5-Elapsed*20/PICKUP_STAR_MS
        Warning.StarData.Scale = 0.35
        ColorSet(Warning.StarData.Color,140,230,173,Alpha)
        SpriteDraw(Warning.StarIcon.Sprite,Warning.StarData)
        // Restore the shared notification icon styling.
        Warning.StarData.Scale = 0.75
        Warning.StarData.Position.x = Warning.CenterX-171
        ColorSet(Warning.StarData.Color,140,230,173,255)
    endif
endfunction
