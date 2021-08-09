--cowboy
--hard AF

--to do:
--test "no_landing_effect" ability
--place obstacles
--place shooters

level5 = class({})
LinkLuaModifier("modifier_immolation_no_cast", "libraries/modifiers/modifier_immolation_no_cast.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_unselectable", "libraries/modifiers/modifier_unselectable.lua", LUA_MODIFIER_MOTION_NONE)
--don't have to be linked in "gamemode.lua"
LinkLuaModifier("modifier_ai_chase", "libraries/modifiers/modifier_ai_chase.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_resistance", "libraries/modifiers/modifier_status_resistance.lua", LUA_MODIFIER_MOTION_NONE)

function level5:Start()
    Notifications:TopToAll({text = "LEVEL 5: THE PUSHA", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
    --place players
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("level_5_start")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            GameMode:RemoveAllAbilities(hero)
            --local cookieAbility = hero:AddAbility("cookie_selfcast_no_landing_effect")
            --cookieAbility:SetLevel(1)
            local cookieAbility = hero:AddAbility("jump_invulnerable")
            cookieAbility:SetLevel(1)
            --local shotgunAbility = hero:AddAbility("snapfire_shotgun_custom")
            --shotgunAbility:SetLevel(1)
            local shotgunAbility = hero:AddAbility("scatterblast_base")
            shotgunAbility:SetLevel(1)
            local knockbackAbility = hero:AddAbility("scatterblast_stopping_power")
            knockbackAbility:SetLevel(1)
            local item = CreateItem("item_aghanims_shard", hero, hero)
            hero:AddItem(item)

        end
    end

    --spawn obstacles
    GameMode.games["level5"] = {}
    GameMode.games["level5"].bossActivated = false
    GameMode.games["level5"].finished = false
    
    GameMode.games["level5"].shooters = {}
    GameMode.games["level5"].obstacles = {}
    GameMode.games["level5"].bosses = {}
    GameMode.games["level5"].shootingObstacles = {}
    GameMode.games["level5"].runnerSpawned = false
    level5:SpawnMovingObstacles()
    
    --level5:SpawnJumpRopes()
end

--push them into a cookie zone
--zombie turns into a happy kid
function level5:SpawnMovingObstacles()
    for obstacleId = 1, 11 do
        level5:SpawnMovingObstacle(obstacleId)
    end
    --twos
    --resistant
    --[[for obstacleId = 3, 6 do
        level5:SpawnMovingBigObstacle(obstacleId)
    end
    for obstacleId = 11, 11 do
        level5:SpawnMovingToughObstacle(obstacleId)
    end]]
end

function level5:SpawnRunner(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation("level_5_runner_1")
    GameMode.games["level5"].runner = CreateUnitByName("obstacle_runner", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level5"].runner:AddNewModifier(nil, nil, "modifier_immolation_no_cast", { 		
        immolation_damage = 4000,
        immolation_range = 100,
        immolation_interval = 0.1
    })
    GameMode.games["level5"].runner:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level5"].runner:AddNewModifier(nil, nil, "modifier_status_resistance", { resistance = -30 })
    GameMode.games["level5"].runner.id = id
    GameMode.games["level5"].runner:SetThink("RunnerThinker", self)
end

function level5:SpawnBossObstacle(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_5_obstacle_boss_%s", id))
    GameMode.games["level5"].bosses[id] = CreateUnitByName("obstacle_boss", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    --[[GameMode.games["level5"].obstacles[id]:AddNewModifier(nil, nil, "modifier_immolation_no_cast", { 		
        immolation_damage = 4000,
        immolation_range = 100,
        immolation_interval = 0.1
    })]]
    GameMode.games["level5"].bosses[id]:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level5"].bosses[id]:AddNewModifier(nil, nil, "modifier_ai_chase", { 
        aggroRange = 500,
        leashLocationX = GameMode.games["level5"].bosses[id]:GetAbsOrigin().x,
        leashLocationY = GameMode.games["level5"].bosses[id]:GetAbsOrigin().y,
        leashLocationZ = GameMode.games["level5"].bosses[id]:GetAbsOrigin().z,
     })
    GameMode.games["level5"].bosses[id]:AddNewModifier(nil, nil, "modifier_status_resistance", { resistance = 70 })
    GameMode.games["level5"].bosses[id].id = id
    GameMode.games["level5"].bosses[id]:SetThink("ObstacleThinker", self)
end

function level5:SpawnFinalBossObstacle()
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation("level_5_obstacle_boss_4")
    GameMode.games["level5"].bosses[4] = CreateUnitByName("obstacle_boss_final", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    --[[GameMode.games["level5"].obstacles[id]:AddNewModifier(nil, nil, "modifier_immolation_no_cast", { 		
        immolation_damage = 4000,
        immolation_range = 100,
        immolation_interval = 0.1
    })]]
    GameMode.games["level5"].bosses[4]:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level5"].bosses[4]:AddNewModifier(nil, nil, "modifier_ai_chase", { 
        aggroRange = 500,
        leashLocationX = GameMode.games["level5"].bosses[4]:GetAbsOrigin().x,
        leashLocationY = GameMode.games["level5"].bosses[4]:GetAbsOrigin().y,
        leashLocationZ = GameMode.games["level5"].bosses[4]:GetAbsOrigin().z,
        baseMoveSpeed = 500
     })
    GameMode.games["level5"].bosses[4]:AddNewModifier(nil, nil, "modifier_status_resistance", { resistance = 90 })
    GameMode.games["level5"].bosses[4].id = id
    --GameMode.games["level5"].finalBoss:SetThink("ObstacleThinker", self)
end

function level5:SpawnShootingObstacles()
    local id = 1
    Timers:CreateTimer("spawn_shooting_obstacle", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            if not GameMode.games["level5"].bossActivated then
                level5:SpawnShootingObstacle(id)
                id = id + 1
                return 3
            else
                return nil
            end
        end
      })
end


function level5:SpawnMovingObstacle(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_5_obstacle_%s", id))
    GameMode.games["level5"].obstacles[id] = CreateUnitByName("obstacle_tiny", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level5"].obstacles[id]:AddNewModifier(nil, nil, "modifier_immolation_no_cast", { 		
        immolation_damage = 4000,
        immolation_range = 100,
        immolation_interval = 0.1
    })
    GameMode.games["level5"].obstacles[id]:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level5"].obstacles[id]:AddNewModifier(nil, nil, "modifier_ai_chase", { aggroRange = 500, leashLocation = GameMode.games["level5"].obstacles[id]:GetAbsOrigin() })
    --GameMode.games["level5"].obstacles[id]:AddNewModifier(nil, nil, "modifier_status_resistance", { resistance = 50 })
    GameMode.games["level5"].obstacles[id].id = id
    GameMode.games["level5"].obstacles[id]:SetThink("ObstacleThinker", self)
end



function level5:SpawnShooter(id)
    local shooterSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_5_shooter_%s", id))
    GameMode.games["level5"].shooters[id] = CreateUnitByName("shooter", shooterSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level5"].shooters[id].shootAbilityName = "shoot_cookie_small"
    local shootAbility = GameMode.games["level5"].shooters[id]:AddAbility(GameMode.games["level5"].shooters[id].shootAbilityName)
    shootAbility:SetLevel(1)
    GameMode.games["level5"].shooters[id].shootLocation = GameMode:GetHammerEntityLocation(string.format("level_5_shooter_%s_target", id))
    GameMode.games["level5"].shooters[id].shootInterval = 7
    GameMode.games["level5"].shooters[id]:SetThink("ShooterThinker", self)
end

function level5:SpawnObstacle(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_5_obstacle_%s", id))
    GameMode.games["level5"].obstacles[id] = CreateUnitByName("obstacle", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level5"].obstacles[id]:AddNewModifier(nil, nil, "modifier_immolation_no_cast", { 		
        immolation_damage = 4000,
        immolation_range = 200,
        immolation_interval = 0.1
    })
    GameMode.games["level5"].obstacles[id]:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level5"].obstacles[id].id = id
    GameMode.games["level5"].obstacles[id]:SetThink("ObstacleThinker", self)
end

function level5:ShooterThinker(unit)
    local shootCookieAbility = unit:FindAbilityByName(unit.shootAbilityName)
    local castPos = unit.shootLocation
    unit:SetCursorPosition(castPos)
    shootCookieAbility:OnSpellStart()
    return unit.shootInterval
end

function level5:ObstacleThinker(unit)
    if unit:IsAlive() == false then
        if GameMode.games["level5"].finished == false then
            if unit.id >= 6 then
                --skip
                --[[Timers:CreateTimer(string.format("obstacle_spawn_delay_%s_level_5", unit.id), {
                    useGameTime = true,
                    endTime = 10,
                    callback = function()
                        level5:SpawnMovingObstacle(unit.id)
                        return nil
                    end
                })]]
            else
                Timers:CreateTimer(string.format("obstacle_spawn_delay_%s_level_5", unit.id), {
                    useGameTime = true,
                    endTime = 5,
                    callback = function()
                        level5:SpawnMovingObstacle(unit.id)
                        return nil
                    end
                })
            end
            return nil
        else
            --stop spawning
            return nil
        end
    else
        return 1
    end
end

function level5:ShootingObstacleThinker(unit)
    if (unit.destination - unit:GetAbsOrigin()):Length() < 20 then
        unit:ForceKill(false)
        return nil
    else
        return 1
    end
end

function level5:BigObstacleThinker(unit)
    if unit:IsAlive() == false then
        if GameMode.games["level5"].finished == false then
            Timers:CreateTimer(string.format("obstacle_spawn_delay_%s_level_5", unit.id), {
                useGameTime = true,
                endTime = 5,
                callback = function()
                    level5:SpawnMovingBigObstacle(unit.id)
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

function level5:ToughObstacleThinker(unit)
    if unit:IsAlive() == false then
        if GameMode.games["level5"].finished == false then
            Timers:CreateTimer(string.format("obstacle_spawn_delay_%s_level_5", unit.id), {
                useGameTime = true,
                endTime = 5,
                callback = function()
                    level5:SpawnMovingToughObstacle(unit.id)
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

function level5:RunnerThinker(unit)
    local target = PlayerResource:GetSelectedHeroEntity(0)
    if target:IsAlive() then
        unit:MoveToTargetToAttack(target)
        return 0.1
    else
        unit:ForceKill(false)
        GameMode.games["level5"].runnerSpawned = false
        return nil
    end
end

--[[function Level5Octarine(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:FindItemInInventory("item_octarine_core_custom") == nil then
        local item = CreateItem("item_octarine_core_custom", ent, ent)
        ent:AddItem(item)
    end
end]]

function Level5Shotgun2(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:FindAbilityByName("snapfire_shotgun_custom") == nil then
        local shotgunAbility = ent:AddAbility("snapfire_shotgun_custom")
        shotgunAbility:SetLevel(1)
        local item = CreateItem("item_octarine_core_custom", ent, ent)
        ent:AddItem(item)
    end
    if ent:FindAbilityByName("scatterblast_base") ~= nil then
        ent:RemoveAbility("scatterblast_base")
        ent:RemoveAbility("scatterblast_stopping_power")
    end
end

--[[function Level4Boots(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:FindItemInInventory("item_boots_custom") == nil then
        local item = CreateItem("item_boots_custom", ent, ent)
        ent:AddItem(item)
    end
end]]

function Level5Finish(trigger)
    local ent = trigger.activator
    if not ent then return end
    if GameMode.games["level5"].finished then --nothing; prevent from 2nd and 3rd place finish to trigger the end
    else
        if GameMode.games["level5"].numBossesKilled == 4 then
            --flag for game thinker
            GameMode.games["level5"].finished = true
        
            --announce
            Notifications:BottomToAll({text = "BOOM BOOM!", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
        
            --song
            EmitGlobalSound("next_episode")
        
            --[[frogger2:ClearStage(GameMode.games["frogger2"].leaves)
        
            Timers:CreateTimer("frogger_3_activate", {
                useGameTime = true,
                endTime = 5,
                callback = function()
                    frogger3:Start()
                    return nil
                end
            })]]
        else
            Notifications:BottomToAll({text = "YOU HAVEN'T KILLED ALL THE ROSHANS!", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
        end
    end
end



function Level5ShootingObstacleTrigger(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:GetUnitName() == "npc_dota_hero_snapfire" then
        level5:SpawnShootingObstacles()
    end
end

function Level5BossTrigger(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:GetUnitName() == "npc_dota_hero_snapfire" and GameMode.games["level5"].bossActivated == false then
        GameMode.games["level5"].bossActivated = true
        for obstacleId = 1, 3 do
            level5:SpawnBossObstacle(obstacleId)
        end
        level5:SpawnFinalBossObstacle()
        for shooterId = 1, 5 do
            level5:SpawnShooter(shooterId)
        end
    end
end

function Level5RunnerTrigger(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:GetUnitName() == "npc_dota_hero_snapfire" and GameMode.games["level5"].runnerSpawned == false then
        level5:SpawnRunner(13)
        GameMode.games["level5"].runnerSpawned = true
    end
end

function Level5RunnerEndTrigger(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:GetUnitName() == "npc_dota_hero_snapfire" and GameMode.games["level5"].runnerSpawned == true then
        GameMode.games["level5"].runner:ForceKill(false)
    end
end