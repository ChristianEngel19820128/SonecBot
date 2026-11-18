// S1: independent simple mine, one manual test spawn per GameInit.
// It never reads Sonec or Inenergie; the existing intelligent mines remain unchanged.

function SimpleMineNew(Mine ref as TMine,ProtoMine ref as TProtoMine,World ref as TWorld,y as integer,Now as integer)
    // Reuse the existing mine dimensions, health, collision box and sprite setup.
    MineNew(Mine,ProtoMine,World,y,Now)
    // The supplied 11x11 sprite is white with transparent background.
    ColorSet(Mine.SpriteData.Color,255,255,255,255)
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
    // this mine's own white opaque color instead of the smart mine's green alpha.
    for i = 0 to MineList.Mine.Length
        if MineList.Mine[i].Enabled = TRUE
            if TimeGet(MineList.Mine[i].Health.RegenerationTimer,Now) > 0
                ColorSet(MineList.Mine[i].SpriteData.Color,255,255,255,255)
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
                for k = 0 to random(0,4)
                    Position.x = MineList.Mine[i].ObjectData.Position.x + random(0,20) - 10
                    Position.y = MineList.Mine[i].ObjectData.Position.y + random(0,20) - 10
                    EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,0,Position,Now)
                next k
                MineDestroy(MineList,i,Game.ExplosionList,Game.ProtoExplosion,Game,MineList.Mine[i].ObjectData.Position,Now)
            endif
        endif
    next i
endfunction
