

frogger4 = class({})

LinkLuaModifier("modifier_no_unit_collision", "libraries/modifiers/modifier_no_unit_collision", LUA_MODIFIER_MOTION_NONE )

local COL_MAX = 30
local ROW_MAX = 6
local COL_WIDTH = 250
local ROW_HEIGHT = 250



function frogger4:Start()
    --[[ sets a player to a given location.
    details: kills and respawns the player to avoid death zones. ]]
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("frogger_4_start")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            GameMode:RemoveAllAbilities(hero)
            local cookieAbility = hero:AddAbility("cookie_frogger_channeled")
            cookieAbility:SetLevel(1)
            local cookieReleaseAbility = hero:AddAbility("cookie_frogger_channeled_release")
            cookieReleaseAbility:SetLevel(1)
            local noUnitCollisionAbility = hero:AddAbility("no_unit_collision")
            noUnitCollisionAbility:SetLevel(1)
            --give players cookie channel jump ability
        end
    end


    GameMode.games["frogger4"] = {}
    GameMode.games["frogger4"].finished = false
    GameMode.games["frogger4"].leaves = {}
    GameMode.games["frogger4"].shooters = {}
    GameMode.games["frogger4"].originX = GameMode:GetHammerEntityLocation("frogger_4_bottom_right").x
    GameMode.games["frogger4"].originY = GameMode:GetHammerEntityLocation("frogger_4_bottom_right").y
    GameMode.games["frogger4"].cookieNames = {
        "cookie_pad_cm",
        "cookie_pad_bb",
        "cookie_pad_jugg",
        "cookie_pad_ogre",
        "badLeaf",
    }
    GameMode.games["frogger4"].bulletStarts = {}
    GameMode.games["frogger4"].bulletEnds = {}
    local colStart = 1
    local colEnd = COL_MAX
    for row = 1, ROW_MAX do
        GameMode.games["frogger4"].bulletStarts[row] = Vector(GameMode.games["frogger4"].originX - colStart * COL_WIDTH, GameMode.games["frogger4"].originY + row * ROW_HEIGHT, 0)
        GameMode.games["frogger4"].bulletEnds[row] = Vector(GameMode.games["frogger4"].originX - colEnd * COL_WIDTH, GameMode.games["frogger4"].originY + row * ROW_HEIGHT, 0)
    end

    --initialize
    for col = 1, COL_MAX do
        GameMode.games["frogger4"].leaves[col] = {}
        for row = 1, ROW_MAX do
            GameMode.games["frogger4"].leaves[col][row] = "undefined"
        end
    end
    frogger4:SpawnCookies(GameMode.games["frogger4"].leaves)
    frogger4:SpawnShooters(GameMode.games["frogger4"].shooters)
    frogger4:ShooterThinker(GameMode.games["frogger4"].shooters)
end

function frogger4:SpawnCookies(leafTable)
    --randomly spawn between 4 cookies
    --pad unit
    for col = 2, #leafTable do
        if col < 20 and col % 6 == 0 then
            frogger4:SpawnBlockCol(leafTable, col)
        else
            for row = 1, #leafTable[col] do
                local randomIndex = math.random(1, #GameMode.games["frogger4"].cookieNames)
                --[[local nameDie = math.random(1, 11)
                local randomName
                if nameDie >= 1 and nameDie <= 5 then
                    randomName = GameMode.games["frogger4"].cookieNames[1]
                elseif nameDie >= 6 and nameDie <= 10 then
                    randomName = GameMode.games["frogger4"].cookieNames[2]
                else
                    randomName = GameMode.games["frogger4"].cookieNames[#GameMode.games["frogger4"].cookieNames]
                end]]
                local spawnLocation = Vector(GameMode.games["frogger4"].originX - col * COL_WIDTH, GameMode.games["frogger4"].originY + row * ROW_HEIGHT, 0)
                leafTable[col][row] = CreateUnitByName(
                    GameMode.games["frogger4"].cookieNames[randomIndex],
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
        end
    end
end

function frogger4:SpawnBlockCol(leafTable, col)
    for row = 1, #leafTable[col] do
        print("row: " .. row .. "col: " .. col)
        local spawnLocation = Vector(GameMode.games["frogger4"].originX - col * COL_WIDTH, GameMode.games["frogger4"].originY + row * ROW_HEIGHT, 0)
        leafTable[col][row] = CreateUnitByName(
            "badLeaf",
            spawnLocation, 
            true, 
            nil, 
            nil, 
            DOTA_TEAM_BADGUYS
        )
        --leafTable[col][row]:SetHullRadius(10)
        leafTable[col][row]:AddNewModifier(nil, nil, "modifier_no_health_bar", {})
    end
end

local SHOOT_ABILITY_NAMES = {
    "shoot_cookie_cm",
    "shoot_cookie_bb",
    "shoot_cookie_jugg",
    "shoot_cookie_ogre"
}

function frogger4:SpawnShooters(shooterTable)
    for col = 1, 1 do
        shooterTable[col] = {}
        for row = 1, ROW_MAX do
            local cookieSpawnLocation = Vector(GameMode.games["frogger4"].originX - col * COL_WIDTH, GameMode.games["frogger4"].originY + row * ROW_HEIGHT, 398)
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
function frogger4:ShooterThinker(shooterTable)
    Timers:CreateTimer("shooter_timer", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            for col = 1, 1 do
                local randomAbilityIndex = math.random(1, #SHOOT_ABILITY_NAMES)
                for row = 1, ROW_MAX do
                    local shooter = shooterTable[col][row]
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