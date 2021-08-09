--run from him

--abilities: cookie

LinkLuaModifier("modifier_ai_it", "libraries/modifiers/modifier_ai_it.lua", LUA_MODIFIER_MOTION_NONE)

morty2 = class({})

local COUNTDOWN = 20

function morty2:Run()

    Notifications:BottomToAll({text="MORTY" , duration= 8.0, style={["font-size"] = "45px"}})
    Notifications:BottomToAll({text="RUN!" , duration= 8.0, style={["font-size"] = "45px"}})
    --go into negative countdown

    GameMode.creeps["morty2"] = {}
    
    local morty_spawn_location = Vector(3039 + (6) * 300, 1286 + 500 + (5) * 300, 384)
    GameMode.creeps["morty2"].morty = CreateUnitByName("mortimer", morty_spawn_location, true, PlayerResource:GetSelectedHeroEntity(0), PlayerResource:GetSelectedHeroEntity(0), DOTA_TEAM_BADGUYS)
    GameMode.creeps["morty2"].morty:AddNewModifier(nil, nil, "modifier_ai_it", { aggroRange = 10000 })
    
    --give everyone ability
    for playerID = 0, 8 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            --this is so that the new ability can be placed into a hotkey
            GameMode:RemoveAllAbilities(hero)
            local jump_channeled = hero:AddAbility("cookie_frogger_channeled"):SetLevel(1)
            --when it stuns, add "stun" indicator on morty
            local jump_ability = hero:AddAbility("snapfire_firesnap_cookie_custom"):SetLevel(4)
            local jump_channeled_release = hero:AddAbility("cookie_frogger_channeled_release"):SetLevel(1)
        end
    end

    morty2:Countdown()
end

function morty2:Countdown()
    local countdown = COUNTDOWN
    Timers:CreateTimer("count_down", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            Notifications:TopToAll({text=string.format("%s", countdown), duration= 1.0, style={["font-size"] = "45px"}})
            countdown = countdown - 1
            if countdown == -3 then
                EmitGlobalSound("next_episode")
                Notifications:BottomToAll({text = string.format("%s cleared!", GameMode.currentLevel), duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
                morty2:ClearCreeps()
                --set everyone back to the starting line
                for playerID = 0, 8 do
                    if PlayerResource:IsValidPlayerID(playerID) then
                        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                        local start_location = GameMode:GetHammerEntityLocation(string.format("player_%s_start", playerID+1))
                        GameMode:SetPlayerOnLocation(hero, start_location)
                    end
                end
                ddr:Run()
                return nil
            else
                return 1
            end
        end
    })
end

function morty2:ClearCreeps()
    GameMode.creeps["morty2"].morty:ForceKill(false)
    GameMode.creeps["morty2"].morty:RemoveSelf()
end