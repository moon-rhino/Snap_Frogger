--cowboy
--hard AF

--to do:
--test "no_landing_effect" ability
--place obstacles
--place shooters

level4_2 = class({})
LinkLuaModifier("modifier_immolation_no_cast", "libraries/modifiers/modifier_immolation_no_cast.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_unselectable", "libraries/modifiers/modifier_unselectable.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_extra_health", "libraries/modifiers/modifier_extra_health.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_resistance", "libraries/modifiers/modifier_status_resistance.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ai_chase", "libraries/modifiers/modifier_ai_chase.lua", LUA_MODIFIER_MOTION_NONE)

function level4_2:Start()
    Notifications:TopToAll({text = "LEVEL 4: RUN AND GUN", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
    
    --place players
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("level_4_start")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            GameMode:RemoveAllAbilities(hero)
            local jumpAbility = hero:AddAbility("jump")
            jumpAbility:SetLevel(1)
        end
    end

    --spawn obstacles
    GameMode.games["level4_2"] = {}
    GameMode.games["level4_2"].finished = false
    GameMode.games["level4_2"].shooters = {}
    GameMode.games["level4_2"].obstacles = {}
    GameMode.games["level4_2"].bosses = {}
    GameMode.games["level4_2"].numBossesKilled = 0
    GameMode.games["level4_2"].movingObstacles = {}
    GameMode.games["level4_2"].preventPasses = {}
    level4_2:SpawnObstacles()
end

function level4_2:SpawnObstacles()
    --obstacles
    --shooter
    --obstacles
    --shooter
    --obstacles
    --shooter
    --zigzag
        --obstacles
        --shooter - 4
    --shotgun2
    --roshan
    --part the sea
    --roshan 2
    --finish

    for obstacleId = 1, 32 do
        level4_2:SpawnObstacle(obstacleId)
    end
    for obstacleId = 33, 39 do
        level4_2:SpawnStrongObstacle(obstacleId)
    end
    for obstacleId = 40, 40 do
        level4_2:SpawnObstacle(obstacleId)
    end

    Timers:CreateTimer("shoot_cookie_1_timer", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            level4_2:SpawnShooter(1)
            return nil
        end
    })
    Timers:CreateTimer("shoot_cookie_2_timer", {
        useGameTime = true,
        endTime = 2,
        callback = function()
            level4_2:SpawnShooter(2)
            return nil
        end
    })
    --mines
    Timers:CreateTimer("shoot_cookie_3_timer", {
        useGameTime = true,
        endTime = 6,
        callback = function()
            level4_2:SpawnShooter(3)
            return nil
        end
    })
    --zigzag
    Timers:CreateTimer("shoot_cookie_zigzag_timer", {
        useGameTime = true,
        endTime = 10,
        callback = function()
            print("shoot cookie timer triggered")
            level4_2:SpawnShootersZigzag(5, 8)
            return nil
        end
    })
    --roshans
    --reversed
    level4_2:SpawnPreventPasses(1, 5, 1)
    level4_2:SpawnPreventPasses(6, 13, 2)
    level4_2:SpawnPreventPasses(14, 19, 3)
    level4_2:SpawnBossObstacle(1, 30)
    level4_2:SpawnBossObstacle(2, 50)
    level4_2:SpawnBossObstacle(3, 60)
    level4_2:SpawnPartTheSeaObstacles()
end

function level4_2:SpawnPreventPasses(numMin, numMax, set)
    GameMode.games["level4_2"].preventPasses[set] = {}
    for id = numMin, numMax do
        level4_2:SpawnPreventPass(id, set)
    end
end

function level4_2:SpawnPreventPass(id, set)
    local location = GameMode:GetHammerEntityLocation(string.format("level_4_prevent_pass_%s", id))
    GameMode.games["level4_2"].preventPasses[set][id] = CreateUnitByName("badLeaf", location, true, nil, nil, DOTA_TEAM_BADGUYS)
end

function level4_2:SpawnShootersZigzag(startId, endId)
    local id = startId
    Timers:CreateTimer("create_zigzag_shooters", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            if id == endId then
                local shooterSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s", id))
                GameMode.games["level4_2"].shooters[id] = CreateUnitByName("shooter", shooterSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                GameMode.games["level4_2"].shooters[id].shootAbilityName = "shoot_cookie_5"
                local shootAbility = GameMode.games["level4_2"].shooters[id]:AddAbility(GameMode.games["level4_2"].shooters[id].shootAbilityName)
                shootAbility:SetLevel(1)
                GameMode.games["level4_2"].shooters[id].shootLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s_target", id))
                GameMode.games["level4_2"].shooters[id].shootInterval = 10
                GameMode.games["level4_2"].shooters[id]:SetThink("ShooterThinker", self)
                return nil
            else
                local shooterSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s", id))
                GameMode.games["level4_2"].shooters[id] = CreateUnitByName("shooter", shooterSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                GameMode.games["level4_2"].shooters[id].shootAbilityName = "shoot_cookie_4"
                local shootAbility = GameMode.games["level4_2"].shooters[id]:AddAbility(GameMode.games["level4_2"].shooters[id].shootAbilityName)
                shootAbility:SetLevel(1)
                GameMode.games["level4_2"].shooters[id].shootLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s_target", id))
                GameMode.games["level4_2"].shooters[id].shootInterval = 10
                GameMode.games["level4_2"].shooters[id]:SetThink("ShooterThinker", self)
                id = id + 1
                return 2.2
            end
        end
    })
end

function level4_2:SpawnShooter(id)
    local shooterSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s", id))
    GameMode.games["level4_2"].shooters[id] = CreateUnitByName("shooter", shooterSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level4_2"].shooters[id].shootAbilityName = string.format("shoot_cookie_%s", id)
    local shootAbility = GameMode.games["level4_2"].shooters[id]:AddAbility(GameMode.games["level4_2"].shooters[id].shootAbilityName)
    shootAbility:SetLevel(1)
    GameMode.games["level4_2"].shooters[id].shootLocation = GameMode:GetHammerEntityLocation(string.format("level_4_shooter_%s_target", id))
    --space in between each set of shoots
    GameMode.games["level4_2"].shooters[id].shootInterval = 8
    GameMode.games["level4_2"].shooters[id]:SetThink("ShooterThinker", self)
end

function level4_2:SpawnObstacle(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_4_obstacle_%s", id))
    GameMode.games["level4_2"].obstacles[id] = CreateUnitByName("obstacle", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level4_2"].obstacles[id]:AddNewModifier(nil, nil, "modifier_immolation_no_cast", { 		
        immolation_damage = 4000,
        immolation_range = 150,
        immolation_interval = 0.1
    })
    GameMode.games["level4_2"].obstacles[id]:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level4_2"].obstacles[id].id = id
    GameMode.games["level4_2"].obstacles[id]:SetThink("ObstacleThinker", self)
end

function level4_2:SpawnStrongObstacle(id)
    print(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_4_obstacle_%s", id))
    GameMode.games["level4_2"].obstacles[id] = CreateUnitByName("obstacle", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level4_2"].obstacles[id]:AddNewModifier(nil, nil, "modifier_immolation_no_cast", { 		
        immolation_damage = 4000,
        immolation_range = 150,
        immolation_interval = 0.1
    })
    GameMode.games["level4_2"].obstacles[id]:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level4_2"].obstacles[id]:AddNewModifier(nil, nil, "modifier_extra_health", { extraHealth = 100})
    GameMode.games["level4_2"].obstacles[id].id = id
    GameMode.games["level4_2"].obstacles[id]:SetThink("ObstacleThinker", self)
end

function level4_2:SpawnBossObstacle(id, status_resistance)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_5_obstacle_boss_%s", id))
    GameMode.games["level4_2"].bosses[id] = CreateUnitByName("obstacle_boss", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level4_2"].bosses[id]:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level4_2"].bosses[id]:AddNewModifier(nil, nil, "modifier_ai_chase", { 
        aggroRange = 500,
        leashLocationX = GameMode.games["level4_2"].bosses[id]:GetAbsOrigin().x,
        leashLocationY = GameMode.games["level4_2"].bosses[id]:GetAbsOrigin().y,
        leashLocationZ = GameMode.games["level4_2"].bosses[id]:GetAbsOrigin().z,
        base_move_speed = 500
     })
    GameMode.games["level4_2"].bosses[id]:AddNewModifier(nil, nil, "modifier_status_resistance", { resistance = status_resistance })
    GameMode.games["level4_2"].bosses[id].id = id
    GameMode.games["level4_2"].bosses[id]:SetThink("BossObstacleThinker", self)
end

function level4_2:SpawnPartTheSeaObstacles()
    for id = 1, 40 do
        local top_left_x = GameMode:GetHammerEntityLocation("level_4_part_the_sea_top_left").x
        local top_left_y = GameMode:GetHammerEntityLocation("level_4_part_the_sea_top_left").y
        local bottom_right_x = GameMode:GetHammerEntityLocation("level_4_part_the_sea_bottom_right").x
        local bottom_right_y = GameMode:GetHammerEntityLocation("level_4_part_the_sea_bottom_right").y
        local random_x = RandomFloat(top_left_x, bottom_right_x)
        local random_y = RandomFloat(top_left_y, bottom_right_y)
        local location = Vector(random_x, random_y, 0)
        level4_2:SpawnMovingObstacle(id, location)
    end
    for id = 41, 70 do
        local top_left_x = GameMode:GetHammerEntityLocation("level_4_part_the_sea_2_top_left").x
        local top_left_y = GameMode:GetHammerEntityLocation("level_4_part_the_sea_2_top_left").y
        local bottom_right_x = GameMode:GetHammerEntityLocation("level_4_part_the_sea_2_bottom_right").x
        local bottom_right_y = GameMode:GetHammerEntityLocation("level_4_part_the_sea_2_bottom_right").y
        local random_x = RandomFloat(top_left_x, bottom_right_x)
        local random_y = RandomFloat(top_left_y, bottom_right_y)
        local location = Vector(random_x, random_y, 0)
        level4_2:SpawnMovingObstacle(id, location)
    end
end

function level4_2:SpawnMovingObstacle(id, location)
    GameMode.games["level4_2"].movingObstacles[id] = CreateUnitByName("obstacle_tiny", location, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["level4_2"].movingObstacles[id]:AddNewModifier(nil, nil, "modifier_immolation_no_cast", { 		
        immolation_damage = 300,
        immolation_range = 120,
        immolation_interval = 0.5
    })
    GameMode.games["level4_2"].movingObstacles[id]:AddNewModifier(nil, nil, "modifier_unselectable", {})
    GameMode.games["level4_2"].movingObstacles[id]:AddNewModifier(nil, nil, "modifier_ai_chase", { 
        aggroRange = 500, 
        leashLocationX = GameMode.games["level4_2"].movingObstacles[id]:GetAbsOrigin().x,
        leashLocationY = GameMode.games["level4_2"].movingObstacles[id]:GetAbsOrigin().y,
        leashLocationZ = GameMode.games["level4_2"].movingObstacles[id]:GetAbsOrigin().z,
        base_move_speed = 100
    })
    GameMode.games["level4_2"].movingObstacles[id]:AddNewModifier(nil, nil, "modifier_status_resistance", { resistance = -20 })
    GameMode.games["level4_2"].movingObstacles[id].id = id
    GameMode.games["level4_2"].movingObstacles[id].location = location
    GameMode.games["level4_2"].movingObstacles[id]:SetThink("MovingObstacleThinker", self)
end

function level4_2:ShooterThinker(unit)
    local shootCookieAbility = unit:FindAbilityByName(unit.shootAbilityName)
    local castPos = unit.shootLocation
    unit:SetCursorPosition(castPos)
    shootCookieAbility:OnSpellStart()
    return unit.shootInterval
end

function level4_2:ObstacleThinker(unit)
    if unit:IsAlive() == false then
        if GameMode.games["level4_2"].finished == false then
            Timers:CreateTimer(string.format("obstacle_spawn_delay_%s", unit.id), {
                useGameTime = true,
                endTime = 5,
                callback = function()
                    if unit.id < 33 then
                        level4_2:SpawnObstacle(unit.id)
                    else 
                        level4_2:SpawnStrongObstacle(unit.id)
                    end
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

--prevent from advancing unless roshan is in the basket
function level4_2:BossObstacleThinker(unit)
    if unit:IsAlive() == false then
        if GameMode.games["level4_2"].finished == false then
            Timers:CreateTimer(string.format("boss_obstacle_spawn_delay_%s", unit.id), {
                useGameTime = true,
                endTime = 5,
                callback = function()
                    level4_2:SpawnBossObstacle(unit.id)
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

function level4_2:MovingObstacleThinker(unit)
    if unit:IsAlive() == false then
        if GameMode.games["level4_2"].finished == false then
            Timers:CreateTimer(string.format("moving_obstacle_spawn_delay_%s", unit.id), {
                useGameTime = true,
                endTime = 1,
                callback = function()
                    level4_2:SpawnMovingObstacle(unit.id, unit.location)
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

function level4_2Shotgun(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:FindAbilityByName("snapfire_shotgun_custom") == nil then
        local shotgunAbility = ent:AddAbility("snapfire_shotgun_custom")
        shotgunAbility:SetLevel(1)
    end
end

function Level4_2Shotgun2(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:FindAbilityByName("snapfire_shotgun_custom") ~= nil then
        ent:RemoveAbility("snapfire_shotgun_custom")
    end
    if ent:FindAbilityByName("scatterblast_base") == nil then
        local shotgunAbility = ent:AddAbility("scatterblast_base")
        shotgunAbility:SetLevel(1)
        local knockbackAbility = ent:AddAbility("scatterblast_stopping_power")
        knockbackAbility:SetLevel(1)
    end
end


function level4_2:ClearStage()
    for shooterId = 1, #GameMode.games["level4_2"].shooters do
        if shooterId ~= 4 then
            GameMode.games["level4_2"].shooters[shooterId]:ForceKill(false)
            GameMode.games["level4_2"].shooters[shooterId]:RemoveSelf()
        end
    end

    for obstacleId = 1, #GameMode.games["level4_2"].obstacles do
        GameMode.games["level4_2"].obstacles[obstacleId]:ForceKill(false)
        GameMode.games["level4_2"].obstacles[obstacleId]:RemoveSelf()
    end

    for movingObstacleId = 1, #GameMode.games["level4_2"].movingObstacles do
        GameMode.games["level4_2"].movingObstacles[movingObstacleId]:ForceKill(false)
        GameMode.games["level4_2"].movingObstacles[movingObstacleId]:RemoveSelf()
    end
end

function Level4_2Finish(trigger)
    local ent = trigger.activator
    if not ent then return end
    if GameMode.games["level4_2"].finished then --nothing; prevent from 2nd and 3rd place finish to trigger the end
    else
  
      --flag for game thinker
      GameMode.games["level4_2"].finished = true
  
      --announce
      Notifications:BottomToAll({text = "LET'S GO!", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
  
      --song
      --"SATISFACTION"
      EmitGlobalSound("next_episode")
  
      level4_2:ClearStage()
  
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

--part 3: 1 - 5
--part 2: 6 - 13
--part 1: 14 - 19
function Level4_2Basket(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:GetUnitName() == "npc_dota_hero_snapfire" then
        --skip
    else
        if ent:GetUnitName() == "obstacle_boss" or ent:GetUnitName() == "obstacle_final_boss" then
            local set = ent.id
            for passId, pass in pairs(GameMode.games["level4_2"].preventPasses[set]) do
                pass:RemoveSelf()
            end
        end
        ent:EmitSound("burp")
        ent:AddNewModifier(nil, nil, "modifier_stunned", {})
    end
end