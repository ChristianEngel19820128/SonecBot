// S4: reusable top warning. Render order: bar -> warning triangle -> bold text.
// GameDo uses the existing pause-aware virtual game clock for expiration.

#constant WARNING_BAR_WIDTH 440
#constant WARNING_BAR_HEIGHT 58
#constant WARNING_BAR_TOP 13
#constant WARNING_TEXT_SIZE 23

function WarningCreate(Warning ref as TWarning,Screen as TSize)
    local CenterX as float
    local CenterY as float

    CenterX = Screen.Width*0.5
    CenterY = WARNING_BAR_TOP + WARNING_BAR_HEIGHT*0.5

    Warning.Icon.Image.File.Path = "/media/gfx/effects"
    Warning.Icon.Image.File.Name = "warning.png"
    if ImageLoad(Warning.Icon.Image) = TRUE
        SpriteLoad(Warning.Icon)
    endif

    Warning.IconData.Center = TRUE
    Warning.IconData.Scale = 0.75
    Warning.IconData.Position.x = CenterX - 171
    Warning.IconData.Position.y = CenterY
    ColorSet(Warning.IconData.Color,255,104,104,255)

    Warning.BarSpriteID = CreateSprite(0)
    SetSpriteSize(Warning.BarSpriteID,WARNING_BAR_WIDTH,WARNING_BAR_HEIGHT)
    SetSpriteColor(Warning.BarSpriteID,12,12,24,180)
    SetSpritePosition(Warning.BarSpriteID,CenterX-WARNING_BAR_WIDTH*0.5,WARNING_BAR_TOP)

    Warning.TextID = CreateText("")
    SetTextAlignment(Warning.TextID,1)
    SetTextPosition(Warning.TextID,CenterX+20,CenterY-WARNING_TEXT_SIZE*0.55)
    SetTextSize(Warning.TextID,WARNING_TEXT_SIZE)
    SetTextBold(Warning.TextID,1)
    SetTextColor(Warning.TextID,255,100,100,255)

    Warning.Active = FALSE
    Warning.MessageString = ""
    Warning.Priority = 0
    Warning.UntilMs = 0
endfunction

function WarningReset(Warning ref as TWarning)
    Warning.Active = FALSE
    Warning.Priority = 0
    Warning.UntilMs = 0
    Warning.MessageString = ""
    SetTextString(Warning.TextID,"")
endfunction

// Equal or higher-priority messages may replace the active one.
// A queue and additional message sources are outside S4.
function WarningShow(Warning ref as TWarning,MessageString as string,Priority as integer,DurationMs as integer,Now as integer)
    if DurationMs > 0
        if Warning.Active = FALSE or Priority >= Warning.Priority or Now >= Warning.UntilMs
            Warning.Active = TRUE
            Warning.MessageString = MessageString
            Warning.Priority = Priority
            Warning.UntilMs = Now + DurationMs
            SetTextString(Warning.TextID,MessageString)
        endif
    endif
endfunction

function WarningUpdate(Warning ref as TWarning,Now as integer)
    if Warning.Active = TRUE
        if Now >= Warning.UntilMs
            WarningReset(Warning)
        endif
    endif
endfunction

function WarningDraw(Warning ref as TWarning)
    if Warning.Active = TRUE
        DrawSprite(Warning.BarSpriteID)
        SpriteDraw(Warning.Icon.Sprite,Warning.IconData)
        DrawText(Warning.TextID)
    endif
endfunction
