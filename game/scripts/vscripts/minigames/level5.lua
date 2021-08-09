
level5 = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_no_health_bar", "libraries/modifiers/modifier_no_health_bar", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invulnerable", "libraries/modifiers/modifier_invulnerable", LUA_MODIFIER_MOTION_NONE)

function level5:Start()
    Notifications:TopToAll({text = "LEVEL 5: PARTY TIME!", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
    GameRules:GetGameModeEntity():SetCameraDistanceOverride(1600)
    --place players
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("level_5_center")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            GameMode:RemoveAllAbilities(hero)
            local cookieAbility = hero:AddAbility("snapfire_firesnap_cookie")
            cookieAbility:SetLevel(1)
            hero:SetHullRadius(10)
            hero:AddNewModifier(nil, nil, "modifier_invulnerable", {})
        end
    end

    --spawn obstacles
    GameMode.games["level5"] = {}
    GameMode.games["level5"].snaps = {}
    GameMode.games["level5"].shotguns = {}
    GameMode.games["level5"].mortimers = {}
    GameMode.games["level5"].shredders = {}
    GameMode.games["level5"].cookiePads = {}
    GameMode.games["level5"].cakes = {}
    GameMode.games["level5"].finished = false
    --sequence (delay)

    level5:SpawnSnaps(GameMode.games["level5"].snaps)

    Timers:CreateTimer("celebrate! 1", {
        useGameTime = true,
        endTime = 1,
        callback = function()
            level5:SpawnShotguns(GameMode.games["level5"].shotguns)
            level5:SpawnCookiePads(GameMode.games["level5"].cookiePads)
            level5:SpawnMortimers(GameMode.games["level5"].mortimers)
            return nil
        end
    })

    Timers:CreateTimer("celebrate! 2", {
        useGameTime = true,
        endTime = 2,
        callback = function()
            level5:SpawnHeroSpring()
            level5:SpawnShredders(GameMode.games["level5"].shredders)
            level5:SpawnCakes(GameMode.games["level5"].cakes)
            return nil
        end
    })

end

function level5:SpawnSnaps(snapTable)
    for id = 1, 6 do
        snapTable[id] = level5:SpawnSnap(id)
    end
end

function level5:SpawnShotguns(shotgunTable)
    for id = 1, 6 do
        shotgunTable[id] = level5:SpawnShotgun(id)
    end
end

local NUM_MORTIMERS = 1
local NUM_MORTIMER_DIRECTIONS = 18
local FIREBALL_DISTANCE = 1000
function level5:SpawnMortimers(mortimerTable)
    for id = 1, NUM_MORTIMERS do
        mortimerTable[id] = level5:SpawnMortimer(id)
    end
end

--one shredder for each target
local NUM_SHREDDERS = 7
local SHREDDER_DISTANCE = 1700
function level5:SpawnShredders(shredderTable)
    for id = 1, NUM_SHREDDERS do
        shredderTable[id] = level5:SpawnShredder(id)
    end
end

function level5:SpawnCookiePads(cookiePadTable)
    for id = 1, NUM_MORTIMER_DIRECTIONS do
        cookiePadTable[id] = level5:SpawnCookiePad(id)
    end
end

local CAKE_DISTANCE = FIREBALL_DISTANCE+400
local NUM_CAKES = 10
function level5:SpawnCakes(cakeTable)
    for id = 1, NUM_CAKES do
        cakeTable[id] = level5:SpawnCake(id)
    end
end

function level5:SpawnSnap(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_5_snap_%s", id))
    local snap = CreateUnitByName("snap", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    snap:AddNewModifier(nil, nil, "modifier_no_health_bar", {})
    snap.id = id
    snap:SetThink("SnapThinker", self)
    return snap
end

function level5:SpawnShotgun(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation(string.format("level_5_snap_shotgun_%s", id))
    local shotgun = CreateUnitByName("shotgun", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    shotgun.id = id
    shotgun:SetThink("ShotgunThinker", self)
    return shotgun
end

--another mortimer
--scale for heroes
--more cookies than CM

function level5:SpawnMortimer(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation("level_5_center")
    local mortimer = CreateUnitByName("mortimer", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    mortimer.id = id
    mortimer:SetThink("MortimerThinker", self)
    return mortimer
end

function level5:SpawnHeroSpring()
    Timers:CreateTimer("HeroSpringTimer", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            level5:SpringHero()
            return 0.8
        end
    })
end

function level5:SpawnShredder(id)
    local obstacleSpawnLocation = GameMode:GetHammerEntityLocation("level_5_center")
    local shredder = CreateUnitByName("shredder", obstacleSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    shredder.id = id

    local spawnAngle = (360 / NUM_SHREDDERS)
    local angleRad = math.rad(spawnAngle * id)
    local targetSpawnLocation = Vector(
        shredder:GetAbsOrigin().x + (math.cos(angleRad)*SHREDDER_DISTANCE),
        shredder:GetAbsOrigin().y + (math.sin(angleRad)*SHREDDER_DISTANCE),
        shredder:GetAbsOrigin().z
    )

    --spawn target
    local cookieNameTable = {
        "invisible_unit",
    }
    local randomName = cookieNameTable[math.random(1, #cookieNameTable)]
    local target = CreateUnitByName(randomName, targetSpawnLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    target:AddNewModifier(nil, nil, "modifier_no_health_bar", {})
    --target.id = id
    --GameMode.games["level5"].shredderTargets[id] = target
    --target:SetThink("ShredderTargetThinker", self)
    shredder.target = target
    shredder:SetThink("ShredderThinker", self)
    return shredder
end

function level5:SpawnCookiePad(id)
    local spawnAngle = (360 / NUM_MORTIMER_DIRECTIONS)
    local angleRad = math.rad(spawnAngle * id)
    local center = GameMode:GetHammerEntityLocation("level_5_center")
    local targetSpawnLocation = Vector(
        center.x + (math.cos(angleRad) * FIREBALL_DISTANCE),
        center.y + (math.sin(angleRad) * FIREBALL_DISTANCE),
        center.z
    )
    local padNames = {
        "cm_cookie_pad",
        "bb_cookie_pad",
        "invoker_cookie_pad",
        "axe_cookie_pad",
        "lina_cookie_pad",
        "ogre_cookie_pad",
        "jugg_cookie_pad",
        "morty_cookie_pad"
    }
    local randomPadName = padNames[math.random(1, #padNames)]
    local target = CreateUnitByName(randomPadName, targetSpawnLocation, true, nil, nil, DOTA_TEAM_CUSTOM_1)
    target:AddNewModifier(nil, nil, "modifier_invulnerable", {})
    return cookiePad
end

function level5:SpawnCake(id)
    local center = GameMode:GetHammerEntityLocation("level_5_center")

    local spawnAngle = (360 / NUM_CAKES)
    local angleRad = math.rad(spawnAngle * id)
    local targetSpawnLocation = Vector(
        center.x + (math.cos(angleRad)*CAKE_DISTANCE),
        center.y + (math.sin(angleRad)*CAKE_DISTANCE),
        center.z
    )

    --spawn target
    local cake = CreateUnitByName("cake", targetSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    cake:AddNewModifier(nil, nil, "modifier_no_health_bar", {})
    cake.id = id
    cake:SetThink("CakeThinker", self)
    return cake
end

function level5:SpringHero()

    local cookieHeroNameTable = {}
    cookieHeroNameTable[0] = "cm"
    cookieHeroNameTable[1] = "axe"
    cookieHeroNameTable[2] = "ogre"
    cookieHeroNameTable[3] = "lina"
    cookieHeroNameTable[4] = "jugg"
    --add an effect to make it different from the event one
    cookieHeroNameTable[5] = "bristleback"
    cookieHeroNameTable[6] = "invoker"
    cookieHeroNameTable[7] = "morty"
    cookieHeroNameTable[8] = "freshly_baked_cookie_ginger_bread_man"
    cookieHeroNameTable[9] = "stack"
    cookieHeroNameTable[10] = "heap"
    cookieHeroNameTable[11] = "oreo"
    --cookieHeroNameTable[12] = "am"
    --cookieHeroNameTable[13] = "tidehunter"
    cookieHeroNameTable[14] = "mars"
    cookieHeroNameTable[15] = "phoenix"
    cookieHeroNameTable[16] = "juggernaut"
    --local randomHeroNameIndex = math.random(1, #cookieHeroNameTable)
    local randomHeroNameIndex = math.random(14, 16)
    local randomCookieName = cookieHeroNameTable[randomHeroNameIndex]
    
    local spawnLocation = GameMode:GetHammerEntityLocation("level_5_center")
    local heroUnit = CreateUnitByName(
        randomCookieName, spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS
    )
    heroUnit:AddNewModifier(nil, nil, "modifier_no_health_bar", {})
    if randomHeroNameIndex < 8 then
        heroUnit:SetModelScale(2)
    --else
    --    heroUnit:SetModelScale(1)
    end
    --knock it back
    local min_spawn_distance = 1200
    local max_spawn_distance = 1400
    local min_height_distance = 400
    local max_height_distance = 500
    local duration = RandomFloat(1, 1.5)
    local direction = math.random(2)
    if direction == 1 then
        direction = -1
    else
        direction = 1
    end
    -- "spring" to a random location
    local knockback = heroUnit:AddNewModifier(
        nil, -- player source
        nil, -- ability source
        "modifier_knockback_custom", -- modifier name
        {
            distance = math.random(min_spawn_distance, max_spawn_distance),
            height = math.random(0, max_height_distance),
            duration = duration,
            direction_x = RandomFloat(0,1) * direction,
            direction_y = RandomFloat(0,1) * direction,
            IsStun = true,
        } -- kv
    )
    local callback = function()
        heroUnit:ForceKill(false)
        heroUnit:RemoveSelf()
    end
    knockback:SetEndCallback( callback )
end


function level5:SnapThinker(snap)
    local targetId = snap.id+1
    if targetId == (#GameMode.games["level5"].snaps + 1) then
        targetId = 1
    end
    local target = GameMode.games["level5"].snaps[targetId]
    snap:SetCursorCastTarget(target)
    local cookieAbility = snap:FindAbilityByName("snapfire_firesnap_cookie_custom")
    snap:CastAbilityOnTarget(target, cookieAbility, 0)
    return 1.2
end

function level5:ShotgunThinker(shotgun)
    local center = GameMode:GetHammerEntityLocation("level_5_center")
    local direction = center - shotgun:GetAbsOrigin()
    --shotgun model direction
    local castPosition = Vector(shotgun:GetAbsOrigin().x - direction.x, shotgun:GetAbsOrigin().y - direction.y, shotgun:GetAbsOrigin().z)
    --castPosition = castPosition:Normalized()
    local shotgunAbility = shotgun:FindAbilityByName("snapfire_shotgun_custom")
    shotgun:SetCursorPosition(castPosition)
    shotgunAbility:OnSpellStart()
    --shotgun:CastAbilityOnPosition(castPosition, shotgunAbility, 0)
    return 0.7
end

function level5:MortimerThinker(mortimer)
    local targetId = 1
    local center = GameMode:GetHammerEntityLocation("level_5_center")
    local numDirections = NUM_MORTIMER_DIRECTIONS
    local angle = 360 / NUM_MORTIMERS
    local firstRound = true
    Timers:CreateTimer(string.format("mortimer_%s_shoot_fireball", mortimer.id), {
        useGameTime = true,
        endTime = 0,
        callback = function()
            level5:ShootFireball(mortimer, angle)
            angle = angle + (360 / numDirections)
            if angle >= 360 then
                angle = 0
                firstRound = false
            end
            return 0.5
        end
    })
end

function level5:ShredderThinker(shredder)
    --shoot it
    local shredderAbility = shredder:FindAbilityByName("snapfire_lil_shredder_custom")
    shredderAbility:OnSpellStart()
    shredder:MoveToTargetToAttack(shredder.target)
    return 3
end

function level5:CakeThinker(cake)
    local targetId = cake.id+1
    if targetId == (NUM_CAKES + 1) then
        targetId = 1
    end
    local target = GameMode.games["level5"].cakes[targetId]
    cake:SetCursorCastTarget(target)
    local cookieAbility = cake:FindAbilityByName("snapfire_firesnap_cookie_custom_cake")
    cake:CastAbilityOnTarget(target, cookieAbility, 0)
    return 1.5
end

function level5:ShredderTargetThinker(target)
    local targetToCookieId = target.id+1
    if targetToCookieId == (#GameMode.games["level5"].shredderTargets + 1) then
        targetToCookieId = 1
    end
    local targetToCookie = GameMode.games["level5"].shredderTargets[targetToCookieId]
    target:SetCursorCastTarget(targetToCookie)
    local cookieAbility = target:FindAbilityByName("snapfire_firesnap_cookie_custom")
    target:CastAbilityOnTarget(targetToCookie, cookieAbility, 0)
    return 1.2
end

function level5:ShootFireball(mortimer, angle)
    local angleRad = math.rad(angle)
    local castPosition = Vector(
        mortimer:GetAbsOrigin().x + (math.cos(angleRad)*FIREBALL_DISTANCE),
        mortimer:GetAbsOrigin().y + (math.sin(angleRad)*FIREBALL_DISTANCE),
        mortimer:GetAbsOrigin().z
    )
    mortimer:SetCursorPosition(castPosition)
    local fireballAbility = mortimer:FindAbilityByName("snapfire_mortimer_kisses_custom")
    fireballAbility:OnSpellStart()
end