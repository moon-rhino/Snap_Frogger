--snapfire
--kill mobs to get abilities

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
--increase attack power for all players


pacman2 = class({})

function pacman2:Run()
    GameMode.settings["pacman2"] = {}
    GameMode.settings["pacman2"].playerStart = GameMode:GetHammerEntityLocation("pacman_center")
    pacman2:SpawnPlayers()
    pacman2:SpawnSuperDots()
    pacman2:SpawnMobs()
end

function pacman2:SpawnPlayers()
    for playerID = 0, GameMode.numPlayers-1 do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local spawnLocation = GameMode:GetHammerEntityLocation("pacman_center")
        GameMode:SetPlayerOnLocation(hero, spawnLocation)
    end
end

function pacman2:SpawnSuperDots()
end

function pacman2:SpawnMonster(location)
    local monster = CreateUnitByName("pinky", location, true, nil, nil, DOTA_TEAM_BADGUYS)
    monster:MoveToPositionAggressive()
    --attach ai
    --attack towards the center of the map
    --simple spell like charge on q
end