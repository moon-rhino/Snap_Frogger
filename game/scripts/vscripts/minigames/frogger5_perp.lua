frogger5_perp = class({})


local COL_MAX = 13
local ROW_MAX_1 = 20
local ROW_MAX_2 = 45


function frogger5_perp:Start()
    GameMode.level = 3
    GameMode.levelFinished = false

    GameMode.games["frogger5_perp"] = {}
    GameMode.games["frogger5_perp"].leaves = {}
    GameMode.games["frogger5_perp"].shooters = {}
    GameMode.games["frogger5_perp"].originX = GameMode:GetHammerEntityLocation("frogger_bottom_right").x
    GameMode.games["frogger5_perp"].originY = GameMode:GetHammerEntityLocation("frogger_bottom_right").y
    GameMode.games["frogger5_perp"].rowHeight = (GameMode:GetHammerEntityLocation("frogger_top_right").y - GameMode:GetHammerEntityLocation("frogger_bottom_right").y) / ROW_MAX_2
    GameMode.games["frogger5_perp"].colWidth = (GameMode:GetHammerEntityLocation("frogger_top_right").x - GameMode:GetHammerEntityLocation("frogger_top_left").x) / COL_MAX
    GameMode.games["frogger5_perp"].cookieNames = {
        "cookie_pad_cm",
        "cookie_pad_bb",
        "cookie_pad_jugg",
        "cookie_pad_ogre",
        --"badLeaf",
    }

    GameMode.games["frogger5_perp"].cookieNamesPart2 = {
        "cookie_pad_cm",
        "cookie_pad_bb",
        "cookie_pad_jugg",
        "cookie_pad_ogre",
        "cookie_pad_axe", -- must avoid
        "cookie_pad_lina",
        --"cookie_pad_morty",
    }
    GameMode.cookieShootDistancePart1 = 5000
    GameMode.cookieShootDistancePart2 = 6000

    --[[ sets a player to a given location.
    details: kills and respawns the player to avoid death zones. ]]
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("frogger_start")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            --[[GameMode.testSpawnLoc = Vector(
                GameMode.games["frogger5_perp"].originX-500, 
                GameMode.games["frogger5_perp"].originY + (ROW_MAX_1+1) * GameMode.games["frogger5_perp"].rowHeight, 
                398
            )]]
            --GameMode:SetPlayerOnLocation(hero, GameMode.testSpawnLoc)
            GameMode:RemoveAllAbilities(hero)
            local noUnitCollisionAbility = hero:AddAbility("no_unit_collision")
            noUnitCollisionAbility:SetLevel(1)
        end
    end




    --initialize
    for row = 1, ROW_MAX_2 do
        GameMode.games["frogger5_perp"].leaves[row] = {}
        for col = 1, COL_MAX do
            GameMode.games["frogger5_perp"].leaves[row][col] = "undefined"
        end
    end

    frogger5_perp:SpawnCookies(GameMode.games["frogger5_perp"].leaves)
    frogger5_perp:SpawnShooters(GameMode.games["frogger5_perp"].shooters)
    frogger5_perp:ShooterThinker(GameMode.games["frogger5_perp"].shooters)

    frogger5_perp:SpawnCookiesPart2(GameMode.games["frogger5_perp"].leaves)
    frogger5_perp:SpawnShootersPart2(GameMode.games["frogger5_perp"].shooters)
    frogger5_perp:ShooterThinkerPart2(GameMode.games["frogger5_perp"].shooters)
end

function frogger5_perp:SpawnCookies(leafTable)
    --randomly spawn between 4 cookies
    --pad unit
    for row = 1, ROW_MAX_1 - 4 do
        for col = 1, #leafTable[row] do
            local randomIndex = math.random(1, #GameMode.games["frogger5_perp"].cookieNames)
            frogger5_perp:SpawnCookie(leafTable, row, col, GameMode.games["frogger5_perp"].cookieNames)
        end
    end
end

function frogger5_perp:SpawnCookiesPart2(leafTable)
    --randomly spawn between 4 cookies
    --pad unit
    for row = ROW_MAX_1 + 3, ROW_MAX_2 - 4 do
        for col = 1, #leafTable[row] do
            local randomIndex = math.random(1, #GameMode.games["frogger5_perp"].cookieNamesPart2)
            frogger5_perp:SpawnCookie(leafTable, row, col, GameMode.games["frogger5_perp"].cookieNamesPart2)
        end
    end
end

function frogger5_perp:SpawnCookie(leafTable, row, col, cookieNameTable)

    local randomIndex = math.random(1, #cookieNameTable)

    local spawnLocation = Vector(
        GameMode.games["frogger5_perp"].originX - col * GameMode.games["frogger5_perp"].colWidth, 
        GameMode.games["frogger5_perp"].originY + row * GameMode.games["frogger5_perp"].rowHeight, 
        0
    )

    leafTable[row][col] = CreateUnitByName(
        cookieNameTable[randomIndex],
        spawnLocation, 
        true, 
        nil, 
        nil, 
        DOTA_TEAM_BADGUYS
    )

    leafTable[row][col]:SetHullRadius(100)
    leafTable[row][col]:AddNewModifier(nil, nil, "modifier_no_health_bar", {})

end

function frogger5_perp:SpawnBlockCol(leafTable, row)
    math.randomseed(Time())
    for col = 1, #leafTable[row] do
        local skipDie = math.random(1, 6)
        if skipDie > 2 then
            local spawnLocation = Vector(
                GameMode.games["frogger5_perp"].originX - col * GameMode.games["frogger5_perp"].colWidth, 
                GameMode.games["frogger5_perp"].originY + row * GameMode.games["frogger5_perp"].rowHeight,
                0
            )
            leafTable[row][col] = CreateUnitByName(
                "badLeaf",
                spawnLocation, 
                true, 
                nil, 
                nil, 
                DOTA_TEAM_BADGUYS
            )
            leafTable[row][col]:AddNewModifier(nil, nil, "modifier_no_health_bar", {})
        else
            frogger5_perp:SpawnCookie(leafTable, row, col, false)
        end
    end
end

local SHOOT_ABILITY_NAMES = {
    "shoot_cookie_cm",
    "shoot_cookie_bb",
    "shoot_cookie_jugg",
    "shoot_cookie_ogre"
}

local SHOOT_ABILITY_NAMES_PART_2 = {
    "shoot_cookie_cm",
    "shoot_cookie_bb",
    "shoot_cookie_jugg",
    "shoot_cookie_lina",
    --"shoot_cookie_morty",
    "shoot_cookie_ogre",
    "shoot_cookie_axe"
}

function frogger5_perp:SpawnShooters(shooterTable)
    for row = ROW_MAX_1, ROW_MAX_1 do
        shooterTable[row] = {}
        for col = 1, COL_MAX do
            local cookieSpawnLocation = Vector(
                GameMode.games["frogger5_perp"].originX - col * GameMode.games["frogger5_perp"].colWidth, 
                GameMode.games["frogger5_perp"].originY + row * GameMode.games["frogger5_perp"].rowHeight, 
                398
            )
            shooterTable[row][col] = CreateUnitByName("shooter", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            for shootAbilityId = 1, #SHOOT_ABILITY_NAMES do
                local shootAbility = shooterTable[row][col]:AddAbility(SHOOT_ABILITY_NAMES[shootAbilityId])
                shootAbility:SetLevel(1)
            end
            shooterTable[row][col].shootLocation = Vector(
                cookieSpawnLocation.x, 
                cookieSpawnLocation.y - 1000, 
                cookieSpawnLocation.z
            )
        end
    end
end

function frogger5_perp:SpawnShootersPart2(shooterTable)
    for row = ROW_MAX_2, ROW_MAX_2 do
        shooterTable[row] = {}
        for col = 1, COL_MAX do
            local cookieSpawnLocation = Vector(
                GameMode.games["frogger5_perp"].originX - col * GameMode.games["frogger5_perp"].colWidth, 
                GameMode.games["frogger5_perp"].originY + row * GameMode.games["frogger5_perp"].rowHeight, 
                398
            )
            shooterTable[row][col] = CreateUnitByName("shooter", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            for shootAbilityId = 1, #SHOOT_ABILITY_NAMES_PART_2 do
                local shootAbility = shooterTable[row][col]:AddAbility(SHOOT_ABILITY_NAMES_PART_2[shootAbilityId])
                shootAbility:SetLevel(1)
                --special
                shootMortyAbility = shooterTable[row][col]:AddAbility("shoot_cookie_morty")
                shootAbility:SetLevel(1)
            end
            shooterTable[row][col].shootLocation = Vector(
                cookieSpawnLocation.x, 
                cookieSpawnLocation.y - 1000, 
                cookieSpawnLocation.z
            )
        end
    end
end

--shoot all together at once
local SHOOT_INTERVAL = 5
function frogger5_perp:ShooterThinker(shooterTable)
    Timers:CreateTimer("shooter_timer", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            for row = ROW_MAX_1, ROW_MAX_1 do
                for col = 1, COL_MAX do
                    local shooter = shooterTable[row][col]
                    shooter.part = 1
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

local SHOOT_INTERVAL_PART_2 = 5
local SHOOT_INTERVAL_PART_2_MORTY = 3
function frogger5_perp:ShooterThinkerPart2(shooterTable)
    Timers:CreateTimer("shooter_timer_part_2", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            local mortyDie = math.random(1, 4)
            if mortyDie == 1 then
                for row = ROW_MAX_2, ROW_MAX_2 do
                    --pick the number of morty entrances before
                    --make morty more scarce in regular row
                    local numMorty1 = math.random(1, math.floor(COL_MAX/3))
                    local numMorty2 = math.random(math.floor(COL_MAX/3)+1, math.floor(COL_MAX/3*2))
                    local numMorty3 = math.random(math.floor(COL_MAX/3*2)+1, COL_MAX)
                    for col = 1, COL_MAX do
                        local shootCookieAbility
                        local shooter = shooterTable[row][col]
                        if col == numMorty1 or col == numMorty2 or col == numMorty3 then
                            shootCookieAbility = shooter:FindAbilityByName("shoot_cookie_morty")
                        else
                            shootCookieAbility = shooter:FindAbilityByName("shoot_cookie_axe")
                        end
                        --distance
                        shooter.part = 2
                        local castPos = shooter.shootLocation
                        shooter:SetCursorPosition(castPos)
                        shootCookieAbility:OnSpellStart()
                    end
                end
                return SHOOT_INTERVAL_PART_2_MORTY
            else
                for row = ROW_MAX_2, ROW_MAX_2 do
                    for col = 1, COL_MAX do
                        local shooter = shooterTable[row][col]
                        shooter.part = 2
                        local randomAbilityIndex = math.random(1, #SHOOT_ABILITY_NAMES_PART_2)
                        local shootCookieAbility = shooter:FindAbilityByName(SHOOT_ABILITY_NAMES_PART_2[randomAbilityIndex])
                        local castPos = shooter.shootLocation
                        shooter:SetCursorPosition(castPos)
                        shootCookieAbility:OnSpellStart()
                    end
                end
                return SHOOT_INTERVAL_PART_2
            end
            
        end
    })
end

function frogger5_perp:ClearStage(cookieTable, shooterTable)
    for cookieTableRowId, cookieTableRow in pairs(cookieTable) do
        for cookieTableCookieId, cookieTableCookie in pairs(cookieTableRow) do
            if cookieTableCookie ~= "undefined" then
                cookieTableCookie:ForceKill(false)
                cookieTableCookie:RemoveSelf()
            end
        end
    end

    for shooterTableRowId, shooterTableRow in pairs(shooterTable) do
        for shooterTableShooterId, shooterTableShooter in pairs(shooterTableRow) do
            shooterTableShooter:ForceKill(false)
            shooterTableShooter:RemoveSelf()
        end
    end


end