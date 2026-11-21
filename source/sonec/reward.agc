// Central reward dispatch. Object kinds are intentionally separate from energy types.
#constant REWARD_OBJECT_SMART_MINE 1
#constant REWARD_OBJECT_SIMPLE_MINE 2
#constant REWARD_OBJECT_WALKER 3
#constant REWARD_OBJECT_ORB 4
#constant REWARD_OBJECT_CHEST 5
#constant REWARD_OBJECT_DRONE 6
#constant REWARD_OBJECT_BOMBER 7

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
        case REWARD_OBJECT_WALKER
            // Preserve the Walker's 1..13 drops and per-item type roll.
            for k = 0 to random(0,12)
                EnergieType = 0
                if random(0,8) > 5
                    EnergieType = random(0,Game.ProtoEnergie.AnimEnergie.Length)
                endif
                Position.x = Origin.x + random(0,20) - 10
                Position.y = Origin.y + random(0,20) - 10
                EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,EnergieType,Position,Now)
            next k
        endcase
        case REWARD_OBJECT_ORB
            // Preserve the Orb's existing 1..13 drops and per-item type roll.
            for k = 0 to random(0,12)
                EnergieType = 0
                if random(0,8) > 5
                    EnergieType = random(0,Game.ProtoEnergie.AnimEnergie.Length)
                endif
                Position.x = Origin.x + random(0,20) - 10
                Position.y = Origin.y + random(0,20) - 10
                EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,EnergieType,Position,Now)
            next k
        endcase
        case REWARD_OBJECT_CHEST
            // First-pass rewards: 3..6 pickups; energy remains the most common type.
            for k = 1 to random(3,6)
                EnergieType = 0
                if random(0,8) > 5
                    EnergieType = random(0,Game.ProtoEnergie.AnimEnergie.Length)
                endif
                Position.x = Origin.x + random(0,20) - 10
                Position.y = Origin.y + random(0,20) - 10
                EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,EnergieType,Position,Now)
            next k
        endcase
        case REWARD_OBJECT_DRONE
            // First-pass rewards: 4..8 pickups.
            for k = 1 to random(4,8)
                EnergieType = 0
                if random(0,8) > 5
                    EnergieType = random(0,Game.ProtoEnergie.AnimEnergie.Length)
                endif
                Position.x = Origin.x + random(0,20) - 10
                Position.y = Origin.y + random(0,20) - 10
                EnergieAdd(Game.EnergieList,Game.ProtoEnergie,Game.World,EnergieType,Position,Now)
            next k
        endcase
        case REWARD_OBJECT_BOMBER
            // First-pass rewards: 8..15 pickups.
            for k = 1 to random(8,15)
                EnergieType = 0
                if random(0,8) > 5
                    EnergieType = random(0,Game.ProtoEnergie.AnimEnergie.Length)
                endif
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
