frogger5 = class({})

LinkLuaModifier("modifier_no_unit_collision", "libraries/modifiers/modifier_no_unit_collision", LUA_MODIFIER_MOTION_NONE )

local COL_MAX = 30
local ROW_MAX = 6
local COL_WIDTH = 250
local ROW_HEIGHT = 250


function frogger5:Start()
    --[[ sets a player to a given location.
    details: kills and respawns the player to avoid death zones. ]]
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("frogger_4_start")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            GameMode:RemoveAllAbilities(hero)
            --[[local cookieAbility = hero:AddAbility("cookie_frogger_channeled")
            cookieAbility:SetLevel(1)
            local cookieReleaseAbility = hero:AddAbility("cookie_frogger_channeled_release")
            cookieReleaseAbility:SetLevel(1)]]
            local noUnitCollisionAbility = hero:AddAbility("no_unit_collision")
            noUnitCollisionAbility:SetLevel(1)
            --give players cookie channel jump ability
        end
    end


    GameMode.games["frogger5"] = {}
    GameMode.games["frogger5"].finished = false
    GameMode.games["frogger5"].leaves = {}
    GameMode.games["frogger5"].shooters = {}
    GameMode.games["frogger5"].originX = GameMode:GetHammerEntityLocation("frogger_4_bottom_right").x
    GameMode.games["frogger5"].originY = GameMode:GetHammerEntityLocation("frogger_4_bottom_right").y
    GameMode.games["frogger5"].cookieNames = {
        "cookie_pad_cm",
        "cookie_pad_bb",
        "cookie_pad_jugg",
        "cookie_pad_ogre",
        --"badLeaf",
    }
    GameMode.games["frogger5"].bulletStarts = {}
    GameMode.games["frogger5"].bulletEnds = {}
    local colStart = 1
    local colEnd = COL_MAX
    for row = 1, ROW_MAX do
        GameMode.games["frogger5"].bulletStarts[row] = Vector(GameMode.games["frogger5"].originX - colStart * COL_WIDTH, GameMode.games["frogger5"].originY + row * ROW_HEIGHT, 0)
        GameMode.games["frogger5"].bulletEnds[row] = Vector(GameMode.games["frogger5"].originX - colEnd * COL_WIDTH, GameMode.games["frogger5"].originY + row * ROW_HEIGHT, 0)
    end

    --initialize
    for col = 1, COL_MAX do
        GameMode.games["frogger5"].leaves[col] = {}
        for row = 1, ROW_MAX do
            GameMode.games["frogger5"].leaves[col][row] = "undefined"
        end
    end
    frogger5:SpawnCookies(GameMode.games["frogger5"].leaves)
    frogger5:SpawnShooters(GameMode.games["frogger5"].shooters)
    frogger5:ShooterThinker(GameMode.games["frogger5"].shooters)
end

function frogger5:SpawnCookies(leafTable)
    --randomly spawn between 4 cookies
    --pad unit
    for col = 2, #leafTable do
        --if col < 20 and col % 6 == 0 then
        --    frogger5:SpawnBlockCol(leafTable, col)
        --else
            for row = 1, #leafTable[col] do
                local randomIndex = math.random(1, #GameMode.games["frogger5"].cookieNames)
                --[[local nameDie = math.random(1, 11)
                local randomName
                if nameDie >= 1 and nameDie <= 5 then
                    randomName = GameMode.games["frogger5"].cookieNames[1]
                elseif nameDie >= 6 and nameDie <= 10 then
                    randomName = GameMode.games["frogger5"].cookieNames[2]
                else
                    randomName = GameMode.games["frogger5"].cookieNames[#GameMode.games["frogger5"].cookieNames]
                end]]
                frogger5:SpawnCookie(leafTable, col, row, false)
            end
        --end
    end
end

function frogger5:SpawnCookie(leafTable, col, row, isBlockCol)
    local randomIndex = math.random(1, #GameMode.games["frogger5"].cookieNames)
    --[[if isBlockCol then
        while randomIndex == 5 do
            randomIndex = math.random(1, #GameMode.games["frogger5"].cookieNames)
        end
    end]]
    local spawnLocation = Vector(GameMode.games["frogger5"].originX - col * COL_WIDTH, GameMode.games["frogger5"].originY + row * ROW_HEIGHT, 0)
    leafTable[col][row] = CreateUnitByName(
        GameMode.games["frogger5"].cookieNames[randomIndex],
        --randomName,
        spawnLocation, 
        true, 
        nil, 
        nil, 
        DOTA_TEAM_BADGUYS
    )
    leafTable[col][row]:SetHullRadius(100)
    leafTable[col][row]:AddNewModifier(nil, nil, "modifier_no_health_bar", {})
end

function frogger5:SpawnBlockCol(leafTable, col)
    math.randomseed(Time())
    for row = 1, #leafTable[col] do
        local skipDie = math.random(1, 6)
        if skipDie > 2 then
            local spawnLocation = Vector(GameMode.games["frogger5"].originX - col * COL_WIDTH, GameMode.games["frogger5"].originY + row * ROW_HEIGHT, 0)
            leafTable[col][row] = CreateUnitByName(
                "badLeaf",
                spawnLocation, 
                true, 
                nil, 
                nil, 
                DOTA_TEAM_BADGUYS
            )
            leafTable[col][row]:AddNewModifier(nil, nil, "modifier_no_health_bar", {})
        else
            frogger5:SpawnCookie(leafTable, col, row, false)
        end
    end
end

local SHOOT_ABILITY_NAMES = {
    "shoot_cookie_cm",
    "shoot_cookie_bb",
    "shoot_cookie_jugg",
    "shoot_cookie_ogre"
}

function frogger5:SpawnShooters(shooterTable)
    for col = 1, 1 do
        shooterTable[col] = {}
        for row = 1, ROW_MAX do
            local cookieSpawnLocation = Vector(GameMode.games["frogger5"].originX - col * COL_WIDTH, GameMode.games["frogger5"].originY + row * ROW_HEIGHT, 398)
            shooterTable[col][row] = CreateUnitByName("shooter", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            for shootAbilityId = 1, #SHOOT_ABILITY_NAMES do
                local shootAbility = shooterTable[col][row]:AddAbility(SHOOT_ABILITY_NAMES[shootAbilityId])
                shootAbility:SetLevel(1)
            end
            shooterTable[col][row].shootLocation = Vector(cookieSpawnLocation.x - 1000, cookieSpawnLocation.y, cookieSpawnLocation.z)
        end
    end
end

--shoot all together at once
local SHOOT_INTERVAL = 5
function frogger5:ShooterThinker(shooterTable)
    Timers:CreateTimer("shooter_timer", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            for col = 1, 1 do
                for row = 1, ROW_MAX do
                    local shooter = shooterTable[col][row]
                    local randomAbilityIndex = math.random(1, #SHOOT_ABILITY_NAMES)
                    local shootCookieAbility = shooter:FindAbilityByName(SHOOT_ABILITY_NAMES[randomAbilityIndex])
                    local castPos = shooter.shootLocation
                    shooter:SetCursorPosition(castPos)
                    shootCookieAbility:OnSpellStart()
                end
            end
            return SHOOT_INTERVAL
        end
    })
end

--modifier no collision
--new units for bullets
--color code if necessary