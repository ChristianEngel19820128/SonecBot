// S3: timed automatic diagonal formations (18-30 s, maximum 6 active).
// No catch-up spawning; use the virtual gameplay clock so pause stops the schedule.
// Simple mines never read Sonec or Inenergie; intelligent mines are unchanged.
#constant SIMPLE_MINE_COLOR_R 32
#constant SIMPLE_MINE_COLOR_G 125
#constant SIMPLE_MINE_COLOR_B 55
#constant SIMPLE_MINE_PACK_MIN_COUNT 3
#constant SIMPLE_MINE_PACK_MAX_COUNT 6
#constant SIMPLE_MINE_PACK_JITTER 8
#constant SIMPLE_MINE_WEDGE_MIN_COUNT 3
#constant SIMPLE_MINE_WEDGE_MAX_COUNT 5
#constant SIMPLE_MINE_FORMATION_MIN_COUNT 2
#constant SIMPLE_MINE_FORMATION_MAX_COUNT 4
#constant SIMPLE_MINE_FORMATION_MIN_SPACING_X 32
#constant SIMPLE_MINE_FORMATION_MAX_SPACING_X 48
#constant SIMPLE_MINE_FORMATION_MIN_SPACING_Y 48
#constant SIMPLE_MINE_FORMATION_MAX_SPACING_Y 72
#constant SIMPLE_MINE_MAX_ACTIVE 6
#constant SIMPLE_MINE_MIN_SPAWN_MS 18000
#constant SIMPLE_MINE_MAX_SPAWN_MS 30000
#constant SIMPLE_MINE_WORLD_MARGIN_Y 50

function SimpleMineNew(Mine ref as TMine,ProtoMine ref as TProtoMine,World ref as TWorld,y as integer,Now as integer)
    // Reuse the existing mine dimensions, health, collision box and sprite setup.
    MineNew(Mine,ProtoMine,World,y,Now)
    // The white 11x11 source sprite takes its opaque dark-green tint from code.
    ColorSet(Mine.SpriteData.Color,SIMPLE_MINE_COLOR_R,SIMPLE_MINE_COLOR_G,SIMPLE_MINE_COLOR_B,255)
endfunction

function SimpleMineAdd(MineList ref as TMineList,ProtoMine ref as TProtoMine,World ref as TWorld,y as integer,Now as integer)
    local Mine as TMine
    local Found as integer
    local i as integer
    local Value as integer

    Value = -1
    SimpleMineNew(Mine,ProtoMine,World,y,Now)

    Found = FALSE
    i = MineList.FirstFree
    while Found = FALSE and i <= MineList.Mine.Length
        if MineList.Mine[i].Enabled = FALSE
            Found = TRUE
        else
            i = i+1
        endif
    endwhile

    if Found = FALSE
        MineList.Mine.Insert(Mine)
        MineList.FirstFree = MineList.Mine.Length
        Value = MineList.Mine.Length
    else
        MineList.Mine[i] = Mine
        MineList.FirstFree = i+1
        Value = i
    endif
endfunction Value


// Shared diagonal formation placement with variable count, spacing and slope.
// Geometry depends on index rather than special-case positions.
// All mines share initial drift speed to preserve their relative positions.
function SimpleMineFormationAdd(MineList ref as TMineList,ProtoMine ref as TProtoMine,World ref as TWorld,CenterY as integer,MineCount as integer,SpacingX as integer,SpacingY as integer,Direction as integer,Now as integer)
    local i as integer
    local Index as integer
    local FirstY as integer
    local DriftSpeed as float

    if MineCount <= 0 then exitfunction

    FirstY = CenterY - (MineCount-1)*SpacingY/2
    DriftSpeed = random(35,100)*0.001

    for i = 0 to MineCount-1
        Index = SimpleMineAdd(MineList,ProtoMine,World,FirstY+i*SpacingY,Now)
        if Index >= 0
            MineList.Mine[Index].ObjectData.Position.x = MineList.Mine[Index].ObjectData.Position.x + i*SpacingX*Direction
            MineList.Mine[Index].ObjectData.MoveSpeed.x = DriftSpeed
            SpritePositionCalc(MineList.Mine[Index].SpriteData.Position,MineList.Mine[Index].ObjectData.Position,World.Position)
            MineList.Mine[Index].CollisionData.Position1.x = MineList.Mine[Index].ObjectData.Position.x - MineList.Mine[Index].ObjectData.Size.Width*0.5
            MineList.Mine[Index].CollisionData.Position2.x = MineList.Mine[Index].ObjectData.Position.x + MineList.Mine[Index].ObjectData.Size.Width*0.5
        endif
    next i
endfunction


// A2: left-pointing symmetric wedge (3 or 5 mines).
// The single tip is at the left; each pair extends right, above and below.
function SimpleMineWedgeAdd(MineList ref as TMineList,ProtoMine ref as TProtoMine,World ref as TWorld,CenterY as integer,MineCount as integer,SpacingX as integer,SpacingY as integer,Now as integer)
    local Arm as integer
    local Side as integer
    local Index as integer
    local DriftSpeed as float

    if MineCount < 3 then exitfunction
    if MineCount > 5 then exitfunction

    DriftSpeed = random(35,100)*0.001
    for Arm = 0 to (MineCount-1)/2
        for Side = -1 to 1
            if (Arm = 0 and Side = 0) or (Arm > 0 and Side <> 0)
                Index = SimpleMineAdd(MineList,ProtoMine,World,CenterY+Side*Arm*SpacingY,Now)
                if Index >= 0
                    MineList.Mine[Index].ObjectData.Position.x = MineList.Mine[Index].ObjectData.Position.x + Arm*SpacingX
                    MineList.Mine[Index].ObjectData.MoveSpeed.x = DriftSpeed
                    SpritePositionCalc(MineList.Mine[Index].SpriteData.Position,MineList.Mine[Index].ObjectData.Position,World.Position)
                    MineList.Mine[Index].CollisionData.Position1.x = MineList.Mine[Index].ObjectData.Position.x - MineList.Mine[Index].ObjectData.Size.Width*0.5
                    MineList.Mine[Index].CollisionData.Position2.x = MineList.Mine[Index].ObjectData.Position.x + MineList.Mine[Index].ObjectData.Size.Width*0.5
                endif
            endif
        next Side
    next Arm
endfunction


// A3: random pack of 3-6 mines in a bounded 2x3 area.
// Random unused slots and small offsets keep spacing safe without rejection loops.
function SimpleMinePackAdd(MineList ref as TMineList,ProtoMine ref as TProtoMine,World ref as TWorld,CenterY as integer,MineCount as integer,SpacingX as integer,SpacingY as integer,Now as integer)
    local Used as integer[5]
    local i as integer
    local Slot as integer
    local Column as integer
    local Row as integer
    local Index as integer
    local DriftSpeed as float

    if MineCount < SIMPLE_MINE_PACK_MIN_COUNT then exitfunction
    if MineCount > SIMPLE_MINE_PACK_MAX_COUNT then exitfunction

    DriftSpeed = random(35,100)*0.001
    for i = 0 to MineCount-1
        Slot = random(0,5)
        while Used[Slot] = TRUE
            Slot = random(0,5)
        endwhile
        Used[Slot] = TRUE
        Column = floor(Slot/3)
        Row = Slot-Column*3

        Index = SimpleMineAdd(MineList,ProtoMine,World,CenterY+(Row-1)*SpacingY+random(-SIMPLE_MINE_PACK_JITTER,SIMPLE_MINE_PACK_JITTER),Now)
        if Index >= 0
            MineList.Mine[Index].ObjectData.Position.x = MineList.Mine[Index].ObjectData.Position.x + Column*SpacingX + random(-SIMPLE_MINE_PACK_JITTER,SIMPLE_MINE_PACK_JITTER)
            MineList.Mine[Index].ObjectData.MoveSpeed.x = DriftSpeed
            SpritePositionCalc(MineList.Mine[Index].SpriteData.Position,MineList.Mine[Index].ObjectData.Position,World.Position)
            MineList.Mine[Index].CollisionData.Position1.x = MineList.Mine[Index].ObjectData.Position.x - MineList.Mine[Index].ObjectData.Size.Width*0.5
            MineList.Mine[Index].CollisionData.Position2.x = MineList.Mine[Index].ObjectData.Position.x + MineList.Mine[Index].ObjectData.Size.Width*0.5
            MineList.Mine[Index].CollisionData.Position1.y = MineList.Mine[Index].ObjectData.Position.y - MineList.Mine[Index].ObjectData.Size.Height*0.5
            MineList.Mine[Index].CollisionData.Position2.y = MineList.Mine[Index].ObjectData.Position.y + MineList.Mine[Index].ObjectData.Size.Height*0.5
        endif
    next i
endfunction


// S3: Schedule one attempt at a time. Both initialization and update use the
// same pause-aware virtual timestamp already passed to GameInit and GameDo.
function SimpleMineSpawnInit(Game ref as TGame,Now as integer)
    Game.SimpleMineNextSpawnMs = Now + random(SIMPLE_MINE_MIN_SPAWN_MS,SIMPLE_MINE_MAX_SPAWN_MS)
endfunction

function SimpleMineSpawnDo(Game ref as TGame,Now as integer)
    local CenterY as integer
    local ActiveCount as integer
    local SafeHalfHeight as integer
    local FormationCount as integer
    local SpacingX as integer
    local SpacingY as integer
    local Direction as integer
    local FormationType as integer

    if Now >= Game.SimpleMineNextSpawnMs
        // Always reschedule, even if capacity blocks the attempt; no backlog.
        Game.SimpleMineNextSpawnMs = Now + random(SIMPLE_MINE_MIN_SPAWN_MS,SIMPLE_MINE_MAX_SPAWN_MS)

        // Roll one complete formation; blocked attempts are not retried.
        FormationType = random(0,2)
        if FormationType = 0
            FormationCount = random(SIMPLE_MINE_FORMATION_MIN_COUNT,SIMPLE_MINE_FORMATION_MAX_COUNT)
        else
            if FormationType = 1
                FormationCount = random(0,1)*2 + SIMPLE_MINE_WEDGE_MIN_COUNT
            else
                FormationCount = random(SIMPLE_MINE_PACK_MIN_COUNT,SIMPLE_MINE_PACK_MAX_COUNT)
            endif
        endif
        SpacingX = random(SIMPLE_MINE_FORMATION_MIN_SPACING_X,SIMPLE_MINE_FORMATION_MAX_SPACING_X)
        SpacingY = random(SIMPLE_MINE_FORMATION_MIN_SPACING_Y,SIMPLE_MINE_FORMATION_MAX_SPACING_Y)
        Direction = 1
        if random(0,1) = 0 then Direction = -1

        ActiveCount = MineCountAll(Game.SimpleMineList)
        if ActiveCount + FormationCount <= SIMPLE_MINE_MAX_ACTIVE
            // Use the entire world's vertical range, not the 450 px viewport.
            // Preserve at least 50 px from both world edges for every mine
            // in the formation, including its half-height (11 px art).
            if FormationType = 0
                SafeHalfHeight = ((FormationCount-1)*SpacingY)/2
            else
                if FormationType = 1
                    SafeHalfHeight = ((FormationCount-1)/2)*SpacingY
                else
                    SafeHalfHeight = SpacingY + SIMPLE_MINE_PACK_JITTER
                endif
            endif
            SafeHalfHeight = SafeHalfHeight + SIMPLE_MINE_WORLD_MARGIN_Y + floor((GetImageHeight(Game.ProtoSimpleMine.AnimMine.Image.ID)+1)*0.5)
            if Game.World.Size.Height > SafeHalfHeight*2
                CenterY = random(SafeHalfHeight,Game.World.Size.Height-SafeHalfHeight)
                if FormationType = 0
                    SimpleMineFormationAdd(Game.SimpleMineList,Game.ProtoSimpleMine,Game.World,CenterY,FormationCount,SpacingX,SpacingY,Direction,Now)
                else
                    if FormationType = 1
                        SimpleMineWedgeAdd(Game.SimpleMineList,Game.ProtoSimpleMine,Game.World,CenterY,FormationCount,SpacingX,SpacingY,Now)
                    else
                        SimpleMinePackAdd(Game.SimpleMineList,Game.ProtoSimpleMine,Game.World,CenterY,FormationCount,SpacingX,SpacingY,Now)
                    endif
                endif
                // Warn only for an actually spawned formation, never for a blocked attempt.
                WarningShow(Game.Warning,"MINEFIELD DETECTED",1,6000,Now)
            endif
        endif
    endif
endfunction

function SimpleMineMove(Mine ref as TMine,World ref as TWorld,Now as integer)
    local r as float

    if Mine.Enabled = TRUE
        if TimeGet(Mine.ObjectData.MoveTimer,Now) > 0
            r = Mine.ObjectData.MoveTimer.CalcRange
            Mine.ObjectData.Position.x = Mine.ObjectData.Position.x - Mine.ObjectData.MoveSpeed.x*r

            SpritePositionCalc(Mine.SpriteData.Position,Mine.ObjectData.Position,World.Position)
            Mine.CollisionData.Position1.x = Mine.ObjectData.Position.x - Mine.ObjectData.Size.Width*0.5
            Mine.CollisionData.Position1.y = Mine.ObjectData.Position.y - Mine.ObjectData.Size.Height*0.5
            Mine.CollisionData.Position2.x = Mine.ObjectData.Position.x + Mine.ObjectData.Size.Width*0.5
            Mine.CollisionData.Position2.y = Mine.ObjectData.Position.y + Mine.ObjectData.Size.Height*0.5
            TimeReset(Mine.ObjectData.MoveTimer,Now)
        endif
    endif
endfunction

function SimpleMineMoveAll(MineList ref as TMineList,World ref as TWorld,Now as integer)
    local i as integer

    for i = 0 to MineList.Mine.Length
        if MineList.Mine[i].Enabled = TRUE
            SimpleMineMove(MineList.Mine[i],World,Now)
            if MineList.Mine[i].ObjectData.Position.x + MineList.Mine[i].ObjectData.Size.Width < World.Position.x
                MineDelete(MineList,i)
            endif
        endif
    next i
endfunction

function SimpleMineHealthRegenerate(MineList ref as TMineList,Game ref as TGame,Now as integer)
    local i as integer
    local k as integer
    local Position as TPosition

    // Keep existing hit-flash and destruction/bubble mechanics but restore
    // this mine's own opaque dark-green color instead of the smart mine's green alpha.
    for i = 0 to MineList.Mine.Length
        if MineList.Mine[i].Enabled = TRUE
            if TimeGet(MineList.Mine[i].Health.RegenerationTimer,Now) > 0
                ColorSet(MineList.Mine[i].SpriteData.Color,SIMPLE_MINE_COLOR_R,SIMPLE_MINE_COLOR_G,SIMPLE_MINE_COLOR_B,255)
                if MineList.Mine[i].Health.State + REGHEALTH <= MineList.Mine[i].Health.StateMax
                    MineList.Mine[i].Health.State = MineList.Mine[i].Health.State + REGHEALTH
                else
                    if MineList.Mine[i].Health.State < MineList.Mine[i].Health.StateMax
                        MineList.Mine[i].Health.State = MineList.Mine[i].Health.StateMax
                    endif
                endif
                TimeReset(MineList.Mine[i].Health.RegenerationTimer,Now)
            endif
            if MineList.Mine[i].Health.State < 0
                RewardDrop(Game,REWARD_OBJECT_SIMPLE_MINE,MineList.Mine[i].ObjectData.Position,Now)
                MineDestroy(MineList,i,Game.ExplosionList,Game.ProtoExplosion,Game,MineList.Mine[i].ObjectData.Position,Now)
            endif
        endif
    next i
endfunction
