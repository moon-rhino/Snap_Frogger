--memory game
--memorize what each cookie does

frogger2_perp = class({})

local COL_MAX = 12
local ROW_MAX = 23

function frogger2_perp:Start()
    Notifications:TopToAll({text = "CHANNELED JUMPZ", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
    
    --[[ sets a player to a given location.
    details: kills and respawns the player to avoid death zones. ]]
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("frogger_start")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            GameMode:RemoveAllAbilities(hero)
            local cookieAbility = hero:AddAbility("cookie_frogger_channeled")
            cookieAbility:SetLevel(1)
            local cookieReleaseAbility = hero:AddAbility("cookie_frogger_channeled_release")
            cookieReleaseAbility:SetLevel(1)
            --give players cookie channel jump ability
        end
    end

    GameMode.level = 2
    GameMode.levelFinished = false

    GameMode.games["frogger2_perp"] = {}
    GameMode.games["frogger2_perp"].leaves = {}
    GameMode.games["frogger2_perp"].shooters = {}
    GameMode.games["frogger2_perp"].originX = GameMode:GetHammerEntityLocation("frogger_bottom_right").x
    GameMode.games["frogger2_perp"].originY = GameMode:GetHammerEntityLocation("frogger_bottom_right").y
    GameMode.games["frogger2_perp"].rowHeight = (GameMode:GetHammerEntityLocation("frogger_top_right").y - GameMode:GetHammerEntityLocation("frogger_bottom_right").y) / ROW_MAX
    GameMode.games["frogger2_perp"].rowHeight  = GameMode.games["frogger2_perp"].rowHeight / 2
    GameMode.games["frogger2_perp"].colWidth = (GameMode:GetHammerEntityLocation("frogger_top_right").x - GameMode:GetHammerEntityLocation("frogger_top_left").x) / COL_MAX
    
    --initialize
    for row = 1, ROW_MAX-1 do
        GameMode.games["frogger2_perp"].leaves[row] = {}
        for col = 1, COL_MAX do
            GameMode.games["frogger2_perp"].leaves[row][col] = "undefined"
        end
    end
    frogger2_perp:SpawnCookies(GameMode.games["frogger2_perp"].leaves)
    frogger2_perp:SpawnCookieShooters(GameMode.games["frogger2_perp"].shooters)
    frogger2_perp:ShooterThinker(GameMode.games["frogger2_perp"].shooters)
end



--make them into a straight line
function frogger2_perp:SpawnCookieShooters(shooterTable)
    for row = ROW_MAX, ROW_MAX do
        shooterTable[row] = {}
        for col = 1, COL_MAX do

            local cookieSpawnLocation = Vector(
                GameMode.games["frogger2_perp"].originX - col * GameMode.games["frogger2_perp"].colWidth, 
                GameMode.games["frogger2_perp"].originY + row * GameMode.games["frogger2_perp"].rowHeight, 
                398
            )
            shooterTable[row][col] = CreateUnitByName("shooter", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            shooterTable[row][col].shootAbilityName = "shoot_cookie_level_2"
            local shootAbility = shooterTable[row][col]:AddAbility(shooterTable[row][col].shootAbilityName)
            shootAbility:SetLevel(1)
            shooterTable[row][col].shootLocation = Vector(
                cookieSpawnLocation.x, 
                cookieSpawnLocation.y-1000, 
                cookieSpawnLocation.z
            )
            shooterTable[row][col].shootInterval = 15
            --shooterTable[row][col]:SetThink("ShooterThinker", self)
        end
    end
end

--shoot all together at once
local SHOOT_INTERVAL = 5
function frogger2_perp:ShooterThinker(shooterTable)
    Timers:CreateTimer("shooter_timer", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            for row = ROW_MAX, ROW_MAX do
                for col = 1, COL_MAX do
                    local shooter = shooterTable[row][col]
                    local shootCookieAbility = shooter:FindAbilityByName(shooter.shootAbilityName)
                    local castPos = shooter.shootLocation
                    shooter:SetCursorPosition(castPos)
                    shootCookieAbility:OnSpellStart()
                end
            end
            return SHOOT_INTERVAL
        end
    })
end

--[[function frogger2_perp:ShooterThinker(unit)
    local shootCookieAbility = unit:FindAbilityByName(unit.shootAbilityName)
    local castPos = unit.shootLocation
    unit:SetCursorPosition(castPos)
    shootCookieAbility:OnSpellStart()
    return unit.shootInterval
end]]

local LEVEL_START_ROW = 5
function frogger2_perp:SpawnCookies(leafTable)

    for row = 1, 2 do
        for col = 1, COL_MAX do
            local cookieSpawnLocation = Vector(
                GameMode.games["frogger2_perp"].originX - col * GameMode.games["frogger2_perp"].colWidth, 
                GameMode.games["frogger2_perp"].originY + row * GameMode.games["frogger2_perp"].rowHeight, 
                398
            )
            leafTable[row][col] = CreateUnitByName("badLeaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        end
    end

    for row = LEVEL_START_ROW, math.floor(ROW_MAX / 2) do
        for col = 1, COL_MAX do
            local cookieSpawnLocation = Vector(
                GameMode.games["frogger2_perp"].originX - col * GameMode.games["frogger2_perp"].colWidth, 
                GameMode.games["frogger2_perp"].originY + row * GameMode.games["frogger2_perp"].rowHeight, 
                398
            )
            local leafDie = math.random(1, 10)
            if leafDie < 3 then
                leafTable[row][col] = CreateUnitByName("leaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            else
                leafTable[row][col] = CreateUnitByName("badLeaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            end
        end
    end

    for row = math.floor(ROW_MAX / 2) + 1, ROW_MAX-1 do
        for col = 1, COL_MAX do
            local cookieSpawnLocation = Vector(
                GameMode.games["frogger2_perp"].originX - col * GameMode.games["frogger2_perp"].colWidth, 
                GameMode.games["frogger2_perp"].originY + row * GameMode.games["frogger2_perp"].rowHeight, 
                398
            )
            local leafDie = math.random(1, 10)
            if leafDie < 3 then
                leafTable[row][col] = CreateUnitByName("leaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            else
                leafTable[row][col] = CreateUnitByName("badLeaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            end
        end
    end

    --frogger2_perp:LeafSpawner(leafTable)
end


function frogger2_perp:LeafSpawner(leaves)
    local row = LEVEL_START_ROW
    local col = 1
    Timers:CreateTimer("spawnLeaves", {
        useGameTime = true,
        --delay in spawning new leaves
        endTime = 0,
        callback = function()
            --spawn leaf
            if GameMode.levelFinished == false then
                local leaf = leaves[row][col]
                print("row: " .. row .. ", col: " .. col)
                if leaf ~= "undefined" then
                    if frogger2_perp:EnemyUnitNearBy(leaf, 150) then
                        --stay
                    else
                        --replace
                        leaf:ForceKill(false)
                        leaf:RemoveSelf()
                        leaves[row][col] = "undefined"
                        local spawnLocation = Vector(
                            GameMode.games["frogger2_perp"].originX - col * GameMode.games["frogger2_perp"].colWidth, 
                            GameMode.games["frogger2_perp"].originY + row * GameMode.games["frogger2_perp"].rowHeight, 
                            398
                        )
                        frogger2_perp:SpawnRandomLeaf(row, col, leaves, spawnLocation)
                    end
                    col = col + 1
                    if col == (COL_MAX + 1) then
                        col = 1
                        row = row + 1
                    end
                    if row == ROW_MAX then
                        row = LEVEL_START_ROW
                    end
                end
                return 0.1
            else
                return nil
            end
        end
    })
end


function frogger2_perp:EnemyUnitNearBy(unit, range)
    local enemies = FindUnitsInRadius(unit:GetTeam(), 
    unit:GetAbsOrigin(), nil,
    range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
    FIND_ANY_ORDER, false)
    local enemyCount = 0
    for _, enemy in pairs(enemies) do
      enemyCount = enemyCount + 1
      break
    end
    if enemyCount == 0 then
      return false
    else
      return true
    end
end

function frogger2_perp:SpawnRandomLeaf(row, col, leaves, location)
    local leafDie = math.random(1, 10)
    if leafDie < 3 then
        leaves[row][col] = CreateUnitByName("leaf", location, true, nil, nil, DOTA_TEAM_BADGUYS)
    else
        leaves[row][col] = CreateUnitByName("badLeaf", location, true, nil, nil, DOTA_TEAM_BADGUYS)
    end

    local particle_cast = "particles/ranged_goodguy_explosion_flash_custom.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, leaves[row][col])
    ParticleManager:SetParticleControl( effect_cast, 3, location )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function frogger2_perp:ClearStage(leaves, baskets)
    --leaves
    --units must stay within bounds
    for row = 1, ROW_MAX-1 do
        for col = 1, COL_MAX do
            print("row: " .. row .. ", col: " .. col)
            if leaves[row][col] ~= "undefined" then
                leaves[row][col]:ForceKill(false)
                leaves[row][col]:RemoveSelf()
            end
        end
    end

    --shooters
    for row = ROW_MAX, ROW_MAX do
        for col = 1, COL_MAX do
            GameMode.games["frogger2_perp"].shooters[row][col]:ForceKill(false)
            GameMode.games["frogger2_perp"].shooters[row][col]:RemoveSelf()
        end
    end
end

--[[function frogger2_perpEnd(trigger)
    local ent = trigger.activator
    if not ent then return end
    if GameMode.games["frogger2_perp"].finished then --nothing; prevent from 2nd and 3rd place finish to trigger the end
    else
  
      --flag for game thinker
      GameMode.games["frogger2_perp"].finished = true
  
      --announce
      Notifications:BottomToAll({text = "GOOD JOB!", duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
  
      --song
      EmitGlobalSound("next_episode")
  
      frogger2_perp:ClearStage(GameMode.games["frogger2_perp"].leaves)

      Timers:CreateTimer("frogger_3_activate", {
        useGameTime = true,
        endTime = 5,
        callback = function()
            frogger5_perp:Start()
            return nil
        end
      })
      
  
    end
end]]