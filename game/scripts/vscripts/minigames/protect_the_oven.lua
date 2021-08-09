protect_the_oven = class({})

function protect_the_oven:Start()
    --announcement
    Notifications:BottomToAll({text = "Protect the Oven", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
    Notifications:BottomToAll({text = "Defend the oven from the thiefs", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
    Notifications:BottomToAll({text = "Level 1 will start in 10 seconds", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
    --spawn players
    for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if PlayerResource:IsValidPlayerID(playerID) then
                    if GameMode.teams[teamNumber][playerID] ~= nil then
                        
                            local heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
                            heroEntity:ForceKill(false)
                            --spawn
                            local protect_the_ovenStartEnt = Entities:FindByName(nil, "protect_the_oven_center")
                            local protect_the_ovenStartEntVector = protect_the_ovenStartEnt:GetAbsOrigin()
                            heroEntity:SetRespawnPosition(protect_the_ovenStartEntVector)
                            heroEntity:RespawnHero(false, false)
                            --set team
                            --2 == good_guys
                            heroEntity.originalTeam = heroEntity:GetTeam()
                            heroEntity:SetTeam(2)
                            --items
                            GameMode:RemoveAllItems(heroEntity)
                            --abilities
                            GameMode:RemoveAllAbilities(heroEntity)
                            --morty ends abruptly
                            GameMode:AddAllOriginalAbilities(heroEntity)
                            local abil = heroEntity:GetAbilityByIndex(0)
                            abil:SetLevel(0)
                            abil = heroEntity:GetAbilityByIndex(1)
                            abil:SetLevel(0)
                            abil = heroEntity:GetAbilityByIndex(2)
                            abil:SetLevel(0)
                            abil = heroEntity:GetAbilityByIndex(5)
                            abil:SetLevel(0)
                            --set camera
                            GameMode:SetCamera(heroEntity)

                    end
                end
            end
        end
    end

    --spawn oven
    local ovenLocation = GameMode:GetHammerEntityLocation("protect_the_oven_oven")
    GameMode.games["protect_the_oven"].oven = CreateUnitByName("oven", ovenLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)

    --thinker
    Timers:CreateTimer("start_level_1", {
        useGameTime = false,
        endTime = 10,
        callback = function()
            Notifications:BottomToAll({text = "Level 1", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
            protect_the_oven:Level1Think()
            return nil
        end
    })
    
end

--stages
--level 1, 2, 3, 4, boss

function protect_the_oven:Think()
    -------------
    -- Level 1 --
    -------------

    --spawn level 1 cookies from each of the 4 spawn spots
    --20 spawns
    local spawnCount = 0
    Timers:CreateTimer("think", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            if spawnCount == 20 then

                return nil
            else
                for spotIndex = 1, 4 do
                    local spawnLocation = GameMode:GetHammerEntityLocation(string.format("protect_the_oven_spawn_%s", spotIndex))
                    protect_the_oven:SpawnCookie("freshly_baked_cookie_axe", spawnLocation)
                end
                spawnCount = spawnCount + 1
                return 0.5
            end
        end
    })
end


function protect_the_oven:SpawnCookie(name, location)
    local cookie = CreateUnitByName(name, location, true, nil, nil, DOTA_TEAM_BADGUYS)
    local attackLocation = GameMode:GetHammerEntityLocation("protect_the_oven_oven")
    cookie:MoveToPositionAggressive()
end
