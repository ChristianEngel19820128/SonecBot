// B1: one unarmed spacejet overflight for visual speed/size evaluation.
// Temporary once-per-game test entry; Chat B will later own spawn scheduling.
#constant BOMBER_TEST_WAIT_MS 4000
#constant BOMBER_WARNING_LEAD_MS 2200
#constant BOMBER_SPEED_PX_PER_MS 0.40
#constant BOMBER_ENTRY_MARGIN_X 65
#constant BOMBER_VIEW_MARGIN_Y 16
#constant BOMBER_JET_INTERVAL_MS 20
#constant BOMBER_JET_PARTICLE_SCALE 0.85

// Phase: 0 = waiting for a visible flight corridor, 1 = warning,
// 2 = flying, 3 = finished. At most one bomber; no bomber array.
function BomberProtoLoad(ProtoBomber ref as TProtoBomber)
    ProtoBomber.Body.Image.File.Path = "/media/gfx/enemies"
    ProtoBomber.Body.Image.File.Name = "spacejet.png"
    if ImageLoad(ProtoBomber.Body.Image) = TRUE
        SpriteLoad(ProtoBomber.Body)
    endif
endfunction

function BomberInit(Bomber ref as TBomber,Now as integer)
    Bomber.Enabled = FALSE
    Bomber.Phase = 0
    Bomber.NextWarningMs = Now+BOMBER_TEST_WAIT_MS
    Bomber.SpawnAtMs = 0
    Bomber.LastMoveMs = Now
    Bomber.NextJetMs = Now
    Bomber.Position.x = 0
    Bomber.Position.y = 0
    Bomber.SpriteData.Angle = 0
    Bomber.SpriteData.Scale = 1
    Bomber.SpriteData.Center = TRUE
    ColorSet(Bomber.SpriteData.Color,80,232,80,255)
endfunction

// Dedicated emitter timer: Sonec and drone retain their own jetfire cadence.
// Particles use the shared existing list/lifecycle, but not its add timer.
function BomberJetfireDo(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Now as integer)
    local Position as TPosition
    local Jetfire as TJetfire
    local i as integer
    local Found as integer

    if Bomber.Enabled = TRUE and Now >= Bomber.NextJetMs and ProtoJetfire.AnimJetfire.Sprite.ID > 0
        // The ship faces left; the engine is near its right-hand tail.
        Position.x = Bomber.Position.x+GetSpriteWidth(ProtoBomber.Body.Sprite.ID)*0.42
        Position.y = Bomber.Position.y
        JetfireNew(Jetfire,ProtoJetfire,World,Position,Now)
        Jetfire.SpriteData.Angle = -90
        Jetfire.SpriteData.Scale = BOMBER_JET_PARTICLE_SCALE

        Found = FALSE
        i = JetfireList.FirstFree
        while Found = FALSE and i <= JetfireList.Jetfire.Length
            if JetfireList.Jetfire[i].Enabled = FALSE
                Found = TRUE
            else
                i = i+1
            endif
        endwhile
        if Found = FALSE
            JetfireList.Jetfire.Insert(Jetfire)
            JetfireList.FirstFree = JetfireList.Jetfire.Length
        else
            JetfireList.Jetfire[i] = Jetfire
            JetfireList.FirstFree = i+1
        endif
        Bomber.NextJetMs = Now+BOMBER_JET_INTERVAL_MS
    endif
endfunction

function BomberDo(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,Warning ref as TWarning,JetfireList ref as TJetfireList,ProtoJetfire ref as TProtoJetfire,World ref as TWorld,Screen as TSize,Now as integer)
    local MinY as float
    local MaxY as float
    local HalfHeight as float
    local HalfWidth as float
    local DeltaMs as integer

    if ProtoBomber.Body.Sprite.ID <= 0 then exitfunction

    HalfHeight = GetSpriteHeight(ProtoBomber.Body.Sprite.ID)*0.5
    HalfWidth = GetSpriteWidth(ProtoBomber.Body.Sprite.ID)*0.5

    if Bomber.Phase = 0 and Now >= Bomber.NextWarningMs
        // World-relative altitude 10%-30%; only preview while the whole
        // ship can be seen in the current camera view.
        MinY = World.Size.Height*0.10
        MaxY = World.Size.Height*0.30
        if MinY < World.Position.y+HalfHeight+BOMBER_VIEW_MARGIN_Y
            MinY = World.Position.y+HalfHeight+BOMBER_VIEW_MARGIN_Y
        endif
        if MaxY > World.Position.y+Screen.Height-HalfHeight-BOMBER_VIEW_MARGIN_Y
            MaxY = World.Position.y+Screen.Height-HalfHeight-BOMBER_VIEW_MARGIN_Y
        endif
        if MaxY >= MinY and Warning.Count < NOTICE_MAX
            Bomber.Position.y = (MinY+MaxY)*0.5
            WarningShow(Warning,"SPACEJET INCOMING!",1,BOMBER_WARNING_LEAD_MS,Now)
            Bomber.SpawnAtMs = Now+BOMBER_WARNING_LEAD_MS
            Bomber.Phase = 1
        endif
    endif

    if Bomber.Phase = 1 and Now >= Bomber.SpawnAtMs
        Bomber.Position.x = Screen.Width+HalfWidth+BOMBER_ENTRY_MARGIN_X
        Bomber.LastMoveMs = Now
        Bomber.NextJetMs = Now
        Bomber.Enabled = TRUE
        Bomber.Phase = 2
    endif

    if Bomber.Enabled = TRUE
        DeltaMs = Now-Bomber.LastMoveMs
        if DeltaMs > 0
            Bomber.Position.x = Bomber.Position.x-DeltaMs*BOMBER_SPEED_PX_PER_MS
            Bomber.LastMoveMs = Now
        endif
        if Bomber.Position.x < -HalfWidth-BOMBER_ENTRY_MARGIN_X
            Bomber.Enabled = FALSE
            Bomber.Phase = 3
        else
            BomberJetfireDo(Bomber,ProtoBomber,JetfireList,ProtoJetfire,World,Now)
        endif
    endif
endfunction

function BomberDraw(Bomber ref as TBomber,ProtoBomber ref as TProtoBomber,World ref as TWorld)
    if Bomber.Enabled = TRUE
        SpritePositionCalc(Bomber.SpriteData.Position,Bomber.Position,World.Position)
        SpriteDraw(ProtoBomber.Body.Sprite,Bomber.SpriteData)
    endif
endfunction
