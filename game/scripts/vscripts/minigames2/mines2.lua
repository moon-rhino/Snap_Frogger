local NUM_ROWS = 7
local NUM_COLS = 12
local TIME_TO_MEMORIZE

mines2 = class({})

--if too hard with mines
--replace with cookies and invis


function mines2:Run()

    Notifications:BottomToAll({text="MINES" , duration= 8.0, style={["font-size"] = "45px"}})
    Notifications:BottomToAll({text="MEMORIZE WHERE THEY ARE" , duration= 8.0, style={["font-size"] = "45px"}})
    
    GameMode.creeps["mines2"] = {}
    local techies_spawn_location = Vector(3039, 1286, 384)
    GameMode.creeps["mines2"].miner = CreateUnitByName("techies", techies_spawn_location, true, PlayerResource:GetSelectedHeroEntity(0), PlayerResource:GetSelectedHeroEntity(0), DOTA_TEAM_BADGUYS)
    TIME_TO_MEMORIZE = GameMode.creeps["mines2"].miner:FindAbilityByName("techies_land_mines_custom"):GetSpecialValueFor("activation_delay")
    GameMode.creeps["mines2"].miner:AddNewModifier(nil, nil, "modifier_invulnerable", {})

    mines2:SpawnMines()
    GameMode:FreezeAllPlayers2(TIME_TO_MEMORIZE)

    local goal_spawn_location = Vector(3039 + (6) * 300, 1286 + 500 + (9) * 300, 384)
    --spawn goal
    GameMode.creeps["mines2"].goal = CreateUnitByName("leaf", goal_spawn_location, true, nil, nil, DOTA_TEAM_CUSTOM_1)
    mines2:GoalThinker()
end

function mines2:SpawnMines()
    for row = 1, NUM_ROWS do
        for col = 1, NUM_COLS do
            local die = math.random(1, 10)
            if die < 8 then
                local spawn_location = Vector(3039 + (col) * 300, 1286 + 500 + (row) * 300, 384)
                GameMode.creeps["mines2"].miner:SetCursorPosition(spawn_location)
                GameMode.creeps["mines2"].miner:FindAbilityByName("techies_land_mines_custom"):OnSpellStart()
            end
        end
    end
end

function mines2:GoalThinker()
    Timers:CreateTimer("goal_reached", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            local unit = GameMode.creeps["mines2"].goal
            local allies = FindUnitsInRadius(unit:GetTeam(), 
            unit:GetAbsOrigin(), nil,
            200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
            FIND_ANY_ORDER, false)
            local allyCount = 0
            for _, ally in pairs(allies) do
              allyCount = allyCount + 1
            end
            if allyCount == 0 then
              return 1
            else
              mines2:End()
              return nil
            end
        end
    })
end

function mines2:End()
    EmitGlobalSound("next_episode")
    Notifications:BottomToAll({text = string.format("%s cleared!", GameMode.currentLevel), duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
    mines2:ClearCreeps()
    Timers:CreateTimer("next_level", {
        useGameTime = true,
        endTime = 5,
        callback = function()
            --set everyone back to the starting line
            for playerID = 0, 8 do
                if PlayerResource:IsValidPlayerID(playerID) then
                    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                    local start_location = GameMode:GetHammerEntityLocation(string.format("player_%s_start", playerID+1))
                    GameMode:SetPlayerOnLocation(hero, start_location)
                end
            end
            morty2:Run()
            GameMode.currentLevel = 'morty2'
            return nil
        end
    })
end


function mines2:ClearCreeps()
    --clear mines
    local cleaner_spawn_location = Vector(3039, 1286, 384)
    local cleaner = CreateUnitByName("cleaner", cleaner_spawn_location, true, nil, nil, DOTA_TEAM_GOODGUYS)
    cleaner:SetHullRadius(10000)
    Timers:CreateTimer("killCleaner", {
        useGameTime = true,
        endTime = 3,
        callback = function()
            cleaner:ForceKill(false)
            cleaner:RemoveSelf()
            return nil
        end
    })

    GameMode.creeps["mines2"].miner:ForceKill(false)
    GameMode.creeps["mines2"].miner:RemoveSelf()
end