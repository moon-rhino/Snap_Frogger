--memory game
--memorize what each cookie does

frogger2 = class({})

function frogger2:Start()
    --[[ sets a player to a given location.
    details: kills and respawns the player to avoid death zones. ]]
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("level_2_start")
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

    GameMode.games["frogger2"] = {}
    GameMode.games["frogger2"].finished = false
    GameMode.games["frogger2"].leaves = {}
    GameMode.games["frogger2"].shooters = {}
    GameMode.games["frogger2"].originX = GameMode:GetHammerEntityLocation("level_2_bottom_right").x
    GameMode.games["frogger2"].originY = GameMode:GetHammerEntityLocation("level_2_bottom_right").y
    --initialize
    for col = 1, 40 do
        GameMode.games["frogger2"].leaves[col] = {}
        for row = 1, 6 do
            GameMode.games["frogger2"].leaves[col][row] = "undefined"
        end
    end
    frogger2:SpawnCookies()
    --frogger2:SpawnCookieShooters()
end

local ROW_HEIGHT = 250
local COL_WIDTH = 250
local ROW_MAX = 6
local COL_MAX = 40

--make them into a straight line
function frogger2:SpawnCookieShooters()
    for col = 28, 28 do
        GameMode.games["frogger2"].shooters[col] = {}
        for row = 1, ROW_MAX do
            local cookieSpawnLocation = Vector(GameMode.games["frogger2"].originX - col * COL_WIDTH, GameMode.games["frogger2"].originY + row * ROW_HEIGHT, 398)
            GameMode.games["frogger2"].shooters[col][row] = CreateUnitByName("shooter", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            GameMode.games["frogger2"].shooters[col][row].shootAbilityName = "shoot_cookie_level_2"
            local shootAbility = GameMode.games["frogger2"].shooters[col][row]:AddAbility(GameMode.games["frogger2"].shooters[col][row].shootAbilityName)
            shootAbility:SetLevel(1)
            GameMode.games["frogger2"].shooters[col][row].shootLocation = Vector(cookieSpawnLocation.x + 1000, cookieSpawnLocation.y, cookieSpawnLocation.z)
            GameMode.games["frogger2"].shooters[col][row].shootInterval = 15
            GameMode.games["frogger2"].shooters[col][row]:SetThink("ShooterThinker", self)
        end
    end
end

function frogger2:ShooterThinker(unit)
    local shootCookieAbility = unit:FindAbilityByName(unit.shootAbilityName)
    local castPos = unit.shootLocation
    unit:SetCursorPosition(castPos)
    shootCookieAbility:OnSpellStart()
    return unit.shootInterval
end


function frogger2:SpawnCookies()

    --first col: one col
    --second col: two cols
    --third col: three cols
    --fourth col: 20 cols

    --for col == 1
    --origin: bottom_right, goes up and left
    --for safe spots, don't spawn a cookie
    --[[local col = 1
    GameMode.games["frogger2"].leaves[col] = {}
    for row = 1, ROW_MAX do
        local cookieSpawnLocation = Vector(GameMode.games["frogger2"].originX - col * COL_WIDTH, GameMode.games["frogger2"].originY + row * ROW_HEIGHT, 398)
        GameMode.games["frogger2"].leaves[col][row] = CreateUnitByName("badLeaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    end]]

    for col = 2, 3 do
        GameMode.games["frogger2"].leaves[col] = {}
        for row = 1, ROW_MAX do
            local cookieSpawnLocation = Vector(GameMode.games["frogger2"].originX - col * COL_WIDTH, GameMode.games["frogger2"].originY + row * ROW_HEIGHT, 398)
            GameMode.games["frogger2"].leaves[col][row] = CreateUnitByName("badLeaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        end
    end

    --[[col = 5
    GameMode.games["frogger2"].leaves[col] = {}
    for row = 1, ROW_MAX do
        local cookieSpawnLocation = Vector(GameMode.games["frogger2"].originX - col * COL_WIDTH, GameMode.games["frogger2"].originY + row * ROW_HEIGHT, 398)
        GameMode.games["frogger2"].leaves[col][row] = CreateUnitByName("badLeaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    end

    for col = 9, 10 do
        GameMode.games["frogger2"].leaves[col] = {}
        for row = 1, ROW_MAX do
            local cookieSpawnLocation = Vector(GameMode.games["frogger2"].originX - col * COL_WIDTH, GameMode.games["frogger2"].originY + row * ROW_HEIGHT, 398)
            GameMode.games["frogger2"].leaves[col][row] = CreateUnitByName("badLeaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        end
    end

    for col = 14, 16 do
        GameMode.games["frogger2"].leaves[col] = {}
        for row = 1, ROW_MAX do
            local cookieSpawnLocation = Vector(GameMode.games["frogger2"].originX - col * COL_WIDTH, GameMode.games["frogger2"].originY + row * ROW_HEIGHT, 398)
            GameMode.games["frogger2"].leaves[col][row] = CreateUnitByName("badLeaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        end
    end]]

    for col = 7, 27 do
        GameMode.games["frogger2"].leaves[col] = {}
        for row = 1, ROW_MAX do
            local cookieSpawnLocation = Vector(GameMode.games["frogger2"].originX - col * COL_WIDTH, GameMode.games["frogger2"].originY + row * ROW_HEIGHT, 398)
            local leafDie = math.random(1, 10)
            if leafDie < 3 then
                GameMode.games["frogger2"].leaves[col][row] = CreateUnitByName("leaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            else
                GameMode.games["frogger2"].leaves[col][row] = CreateUnitByName("badLeaf", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            end
        end
    end

    frogger2:LeafSpawner(GameMode.games["frogger2"].leaves)
end

function frogger2:LeafSpawner(leaves)
    local leafRow = 1
    local leafCol = 7
    Timers:CreateTimer("spawnLeaves", {
        useGameTime = true,
        --delay in spawning new leaves
        endTime = 0,
        callback = function()
            --spawn leaf
            if GameMode.games["frogger2"].finished == false then
                --for leafRow = 1, 8 do
                --for leafColumn = 1, 8 do
                local leaf = leaves[leafCol][leafRow]
                if leaf ~= nil then
                    if frogger2:EnemyUnitNearBy(leaf, 150) then
                        --stay
                    else
                        --replace
                        leaf:ForceKill(false)
                        leaf:RemoveSelf()
                        leaves[leafCol][leafRow] = "undefined"
                        local spawnLocation = Vector(GameMode.games["frogger2"].originX - leafCol * COL_WIDTH, GameMode.games["frogger2"].originY + leafRow * ROW_HEIGHT, 398)
                        frogger2:SpawnRandomLeaf(leafCol, leafRow, leaves, spawnLocation)
                    end
                    leafRow = leafRow + 1
                    if leafRow == (ROW_MAX + 1) then
                        leafRow = 1
                        leafCol = leafCol + 1
                    end
                    if leafCol == (COL_MAX + 1) then
                        leafCol = 7
                    end
                end
                return 0.1
            else
                return nil
            end
        end
    })
end


function frogger2:EnemyUnitNearBy(unit, range)
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

function frogger2:SpawnRandomLeaf(col, row, leaves, location)
    local leafDie = math.random(1, 10)
    if leafDie < 3 then
        leaves[col][row] = CreateUnitByName("leaf", location, true, nil, nil, DOTA_TEAM_BADGUYS)
    else
        leaves[col][row] = CreateUnitByName("badLeaf", location, true, nil, nil, DOTA_TEAM_BADGUYS)
    end

    local particle_cast = "particles/ranged_goodguy_explosion_flash_custom.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, leaves[col][row])
    ParticleManager:SetParticleControl( effect_cast, 3, location )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function frogger2:SpawnLevel2Cookies()
end

function frogger2:ClearStage(leaves, baskets)
    --leaves
    for col = 1, 40 do
        for row = 1, 6 do
            if leaves[col][row] ~= "undefined" then
                leaves[col][row]:ForceKill(false)
                leaves[col][row]:RemoveSelf()
            end
        end
    end
    --shooters
    for col = 41, 41 do
        for row = 1, 6 do
            GameMode.games["frogger2"].shooters[col][row]:ForceKill(false)
            GameMode.games["frogger2"].shooters[col][row]:RemoveSelf()
        end
    end
end

function Frogger2End(trigger)
    local ent = trigger.activator
    if not ent then return end
    if GameMode.games["frogger2"].finished then --nothing; prevent from 2nd and 3rd place finish to trigger the end
    else
  
      --flag for game thinker
      GameMode.games["frogger2"].finished = true
  
      --announce
      Notifications:BottomToAll({text = "GOOD JOB!", duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
  
      --song
      EmitGlobalSound("next_episode")
  
      frogger2:ClearStage(GameMode.games["frogger2"].leaves)

      Timers:CreateTimer("frogger_3_activate", {
        useGameTime = true,
        endTime = 5,
        callback = function()
            frogger3:Start()
            return nil
        end
      })
      
  
    end
end