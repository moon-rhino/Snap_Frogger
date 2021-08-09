--cowboy
--hard AF

--to do:
--test "no_landing_effect" ability
--place obstacles
--place shooters

level4 = class({})
LinkLuaModifier("modifier_immolation_no_cast", "libraries/modifiers/modifier_immolation_no_cast.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_unselectable", "libraries/modifiers/modifier_unselectable.lua", LUA_MODIFIER_MOTION_NONE)

function level4:Start()
    Notifications:TopToAll({text = "LEVEL 4: RUN AND GUN", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
    
    --place players
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("level_4_start")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            GameMode:RemoveAllAbilities(hero)
            --local cookieAbility = hero:AddAbility("cookie_selfcast_no_landing_effect")
            --cookieAbility:SetLevel(1)
            local jumpAbility = hero:AddAbility("jump")
            jumpAbility:SetLevel(1)
        end
    end

    --spawn obstacles
    GameMode.games["level4"] = {}
    GameMode.games["level4"].finished = false
    GameMode.games["level4"].shooters = {}
    GameMode.games["level4"].obstacles = {}
    level4:SpawnObstacles()
end

function level4:SpawnObstacles()
    --shooter 1, 2 and 3
    --[[for shooterId = 1, 10 do
        level4:SpawnShooter(shooterId)
    end]]

    --level4:SpawnShootersZigzag(3)
    
    --obstacles
    --patrol unit passive kills each other
    for obstacleId = 1, 23 do
        level4:SpawnObstacle(obstacleId)
    end
end

function level4:SpawnShootersZigzag(startId)
    local id = startId
    Timers:CreateTimer("create_zigzag_shooters", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            if id == 6 then
                return nil
            else
                local shooterSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s", id))
                GameMode.games["level4"].shooters[id] = CreateUnitByName("shooter", shooterSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                GameMode.games["level4"].shooters[id].shootAbilityName = "shoot_cookie_4"
                local shootAbility = GameMode.games["level4"].shooters[id]:AddAbility(GameMode.games["level4"].shooters[id].shootAbilityName)
                shootAbility:SetLevel(1)
                GameMode.games["level4"].shooters[id].shootLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s_target", id))
                GameMode.games["level4"].shooters[id].shootInterval = 15
                GameMode.games["level4"].shooters[id]:SetThink("ShooterThinker", self)
                id = id + 1
                return 2
            end
        end
    })
end

function level4:SpawnShooter(id)
    local shooterSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s", id))
    GameMode.games["level4"].shooters[id] = CreateUnitByName("shooter", shooterSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level4"].shooters[id].shootAbilityName = string.format("shoot_cookie_%s", id)
    local shootAbility = GameMode.games["level4"].shooters[id]:AddAbility(GameMode.games["level4"].shooters[id].shootAbilityName)
    shootAbility:SetLevel(1)
    GameMode.games["level4"].shooters[id].shootLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s_target", id))
    GameMode.games["level4"].shooters[id].shootInterval = 8
    GameMode.games["level4"].shooters[id]:SetThink("ShooterThinker", self)
end

function level4:SpawnObstacle(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_4_obstacle_%s", id))
    GameMode.games["level4"].obstacles[id] = CreateUnitByName("obstacle", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level4"].obstacles[id]:AddNewModifier(nil, nil, "modifier_immolation_no_cast", { 		
        immolation_damage = 4000,
        immolation_range = 200,
        immolation_interval = 0.1
    })
    GameMode.games["level4"].obstacles[id]:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level4"].obstacles[id].id = id
    GameMode.games["level4"].obstacles[id]:SetThink("ObstacleThinker", self)
end

function level4:ShooterThinker(unit)
    local shootCookieAbility = unit:FindAbilityByName(unit.shootAbilityName)
    local castPos = unit.shootLocation
    unit:SetCursorPosition(castPos)
    shootCookieAbility:OnSpellStart()
    return unit.shootInterval
end

function level4:ObstacleThinker(unit)
    if unit:IsAlive() == false then
        if GameMode.games["level4"].finished == false then
            Timers:CreateTimer(string.format("obstacle_spawn_delay_%s", unit.id), {
                useGameTime = true,
                endTime = 5,
                callback = function()
                    level4:SpawnObstacle(unit.id)
                    return nil
                end
            })
            return nil
        else
            --stop spawning
            return nil
        end
    else
        return 1
    end
end

function Level4Shotgun(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:FindAbilityByName("snapfire_shotgun_custom") == nil then
        local shotgunAbility = ent:AddAbility("snapfire_shotgun_custom")
        shotgunAbility:SetLevel(1)
    end
end

function Level4Boots(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:FindItemInInventory("item_boots_custom") == nil then
        local item = CreateItem("item_boots_custom", ent, ent)
        ent:AddItem(item)
    end
end

function level4:ClearStage()
    for shooterId = 1, 5 do
        GameMode.games["level4"].shooters[shooterId]:ForceKill(false)
        GameMode.games["level4"].shooters[shooterId]:RemoveSelf()
    end

    for obstacleId = 1, 20 do
        GameMode.games["level4"].obstacles[obstacleId]:ForceKill(false)
        GameMode.games["level4"].obstacles[obstacleId]:RemoveSelf()
    end
end

function Level4Finish(trigger)
    local ent = trigger.activator
    if not ent then return end
    if GameMode.games["level4"].finished then --nothing; prevent from 2nd and 3rd place finish to trigger the end
    else
  
      --flag for game thinker
      GameMode.games["level4"].finished = true
  
      --announce
      Notifications:BottomToAll({text = "BOSS!", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
  
      --song
      EmitGlobalSound("next_episode")
  
      --level4:ClearStage()
  
      Timers:CreateTimer("level_5_activate", {
        useGameTime = true,
        endTime = 5,
        callback = function()
            level5:Start()
            return nil
        end
      })
      
  
    end
end