// Central reward dispatch. Object kinds are intentionally separate from energy types.
#constant REWARD_OBJECT_SMART_MINE 1
#constant REWARD_OBJECT_SIMPLE_MINE 2

// Preserve existing mine drops: random(0,4) inclusive => 1..5 energy items.
function RewardDrop(Game ref as TGame,ObjectType as integer,Origin as TPosition,Now as integer)
    local k as integer
    local EnergieType as integer
    local Position as TPosition

    select ObjectType
        case REWARD_OBJECT_SMART_MINE
            for k = 0 to random(0,4)
                EnergieType = 0
                Position.x = Origin.x + random(0,20) - 10
                Position.y = Origin.y + random(0,20) - 10
                EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,EnergieType,Position,Now)
            next k
        endcase
        case REWARD_OBJECT_SIMPLE_MINE
            for k = 0 to random(0,4)
                Position.x = Origin.x + random(0,20) - 10
                Position.y = Origin.y + random(0,20) - 10
                EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,0,Position,Now)
            next k
        endcase
    endselect
endfunction
