--dynamic map building
--make grid
--delete walls


--cookie to jump over walls
--ghosts
--powerups

--level dimensions:
--top left
--Vector 00000000007E8878 [-4718.833496 8808.701172 525.002808]
--top right
--Vector 00000000007E89D8 [588.634583 8813.744141 525.002808]
--bottom left
--Vector 00000000007E8B38 [-4722.419922 3452.674805 525.003052]
--bottom right
--Vector 00000000007E8C98 [608.562988 3462.756348 525.002808]




--super dot locations:
--[0,18]
--[21,18]
--[0,3]
--[21,2]


LinkLuaModifier("modifier_blinky", "libraries/modifiers/modifier_blinky", LUA_MODIFIER_MOTION_NONE)

pacman = class({})

function pacman:Run()

    GameMode.settings["pacman"] = {}
    GameMode.settings["pacman"].playerStart = GameMode:GetHammerEntityLocation("pacman_player_start")
    GameMode.settings["pacman"].dotCount = 0
    --spawn 4 ghosts
        --stays in cage for 5 seconds
    pacman:SpawnGhosts()
    --spawn players together
    --set speed
    --80% player, 75% ghost
    pacman:SpawnPlayers()
    --spawn dots
        --dot
        --big dot
        --fruit
    --every time a dot is eaten,
        --update the dot counter
        --every 100 dot eaten = new life
        --if dot counter == 0
            --end game
    --if players die,
        --spawn them where they started
        --monitor how many times they die
    pacman:SpawnDots()
    --pacman:SetUpGrid()

end

function pacman:SpawnGhosts()
    local ghostHideout = GameMode:GetHammerEntityLocation("ghost_hideout")
    local blinky = CreateUnitByName("blinky", ghostHideout, true, nil, nil, DOTA_TEAM_BADGUYS)
    --blinky:SetControllableByPlayer(0, false)
    blinky:AddNewModifier(nil, nil, "modifier_blinky", {})
    local pinky = CreateUnitByName("pinky", ghostHideout, true, nil, nil, DOTA_TEAM_BADGUYS)
    pinky:AddNewModifier(nil, nil, "modifier_pinky", {})
    local inky = CreateUnitByName("inky", ghostHideout, true, nil, nil, DOTA_TEAM_BADGUYS)
    inky:AddNewModifier(nil, nil, "modifier_blinky", {})
    local clyde = CreateUnitByName("clyde", ghostHideout, true, nil, nil, DOTA_TEAM_BADGUYS)
    clyde:AddNewModifier(nil, nil, "modifier_blinky", {})
end

function pacman:SpawnPlayers()
    for playerID = 0, GameMode.numPlayers-1 do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local spawnLocation = GameMode:GetHammerEntityLocation("pacman_top_left_corner")
        --local spawnLocation = GameMode:GetHammerEntityLocation("pacman2_top_left_corner")
        GameMode:SetPlayerOnLocation(hero, spawnLocation)
        hero:AddNewModifier(nil, nil, "modifier_pacman_eater", {})
    end
end

--add these modifiers whenever a player spawns in game
function pacman:AddModifiers(hero)
    hero:AddNewModifier(nil, nil, "modifier_pacman_eater", {})
end


function pacman:SpawnDots()
    --place cookie in the middle of the square (four corners of a terrain tile)
    for col = 0, 21 do
        for row = 0, 21 do
            --top left:
            -- -4718.833496, 8808.701172, 525.002808
            --bottom right: 
            -- 608.562988, 3462.756348, 525.002808
            local spawnLocation = GameMode:GetHammerEntityLocation(string.format("pacman_%s_%s", col, row))
            if spawnLocation.z < 530 then
                local dot = CreateUnitByName("pacman_dot", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                GameMode.settings["pacman"].dotCount = GameMode.settings["pacman"].dotCount + 1
            end
        end
    end
end

--to close the ghosts in
function pacman:SpawnWall()
end


--grid
--22 x 22
--walls = orange boulders
--cookie can jump over 2 walls
--logic to remove walls
--wall to separate cookies
--randomly delete walls
--make sure there's no dead end
--center empty for ghosts

--[[function pacman:SetUpGrid()
    local topLeftCornerLocation = GameMode:GetHammerEntityLocation("pacman2_top_left_corner")
    --unit will get stuck if it spawns in the same location as another unit
    topLeftCornerLocation = Vector(topLeftCornerLocation.x, topLeftCornerLocation.y + 300, topLeftCornerLocation.z)
    for row = 0, 22 do
        for col = 0, 22 do
            --if it's a wall tile then
            if row % 2 == 1 and col % 2 == 1 then
                --spawn dot
                local spawnLocation = Vector(topLeftCornerLocation.x + col * 250, topLeftCornerLocation.y - row * 250, topLeftCornerLocation.z)
                local dot = CreateUnitByName("pacman_dot", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            else
                --spawn a third of the rest as dots
                local wallChance = math.random(1, 3)
                if wallChance ~= 1 then
                    --spawn wall
                    local spawnLocation = Vector(topLeftCornerLocation.x + col * 250, topLeftCornerLocation.y - row * 250, topLeftCornerLocation.z)
                    local wall = CreateUnitByName("pacman_wall", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                    --hitbox will not cause units to collide
                    wall:SetHullRadius(100)
                else
                    --spawn dot
                    local spawnLocation = Vector(topLeftCornerLocation.x + col * 250, topLeftCornerLocation.y - row * 250, topLeftCornerLocation.z)
                    local dot = CreateUnitByName("pacman_dot", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                end
            end
        end
    end
end]]

function pacman:AddModifiers(hero)
    hero:AddNewModifier(nil, nil, "modifier_pacman_eater", {})
end