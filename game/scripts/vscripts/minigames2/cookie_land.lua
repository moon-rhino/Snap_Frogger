cookie_land = class({})

function cookie_land:Run()
    GameMode.creeps["cookie_land"] = {}
    local spawn_location = Vector(3039 + (6) * 300, 1286 + 500 + (5) * 300, 384)
    GameMode.creeps["cookie_land"].lion = CreateUnitByName("mortimer", morty_spawn_location, true, PlayerResource:GetSelectedHeroEntity(0), PlayerResource:GetSelectedHeroEntity(0), DOTA_TEAM_BADGUYS)
