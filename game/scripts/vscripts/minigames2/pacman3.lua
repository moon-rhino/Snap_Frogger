--pick up cookies
--ghost that roams around
--limited vision
--pick up all the cookies to beat the level

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

--level 1: roshan
--level 2: mega creeps
--level 3: crystal maidens

--game 2: shoot the bad guy
--button mash scatter blast

--multiplayer modes



--super dot locations:
--[0,18]
--[21,18]
--[0,3]
--[21,2]


LinkLuaModifier("modifier_blinky", "libraries/modifiers/modifier_blinky", LUA_MODIFIER_MOTION_NONE)

pacman = class({})

function pacman3:Run()

    GameMode.settings["pacman3"] = {}
    GameMode.settings["pacman3"].playerStart = GameMode:GetHammerEntityLocation("pacman_player_start]")
    GameMode.settings["pacman3"].dotCount = 0
    pacman3:SpawnGhosts()
    pacman3:SpawnPlayers()
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
        --set an 'x' on that location
        --another player has to go there to revive him
    pacman3:SpawnDots()
    --pacman:SetUpGrid()

end

function pacman3:SpawnGhosts()
    local ghostHideout = GameMode:GetHammerEntityLocation("ghost_hideout")
    local blinky = CreateUnitByName("blinky", ghostHideout, true, nil, nil, DOTA_TEAM_BADGUYS)
    --blinky:SetControllableByPlayer(0, false)
    blinky:AddNewModifier(nil, nil, "modifier_blinky", {})
    -- "evil" dot: if you pick it up, blinky moves faster
    --jump over it using cookie
end

function pacman3:SpawnPlayers()
    for playerID = 0, GameMode.numPlayers-1 do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local spawnLocation = GameMode:GetHammerEntityLocation("pacman_player_start")
        GameMode:SetPlayerOnLocation(hero, spawnLocation)
        hero:AddNewModifier(nil, nil, "modifier_pacman_eater", {})
    end
end

--add these modifiers whenever a player spawns in game
function pacman3:AddModifiers(hero)
    hero:AddNewModifier(nil, nil, "modifier_pacman_eater", {})
end


function pacman3:SpawnDots()
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
                GameMode.settings["pacman3"].dotCount = GameMode.settings["pacman3"].dotCount + 1
            end
        end
    end
end

--to close the ghosts in
--[[function pacman3:SpawnWall()
end]]