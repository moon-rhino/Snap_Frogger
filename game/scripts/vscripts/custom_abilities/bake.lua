bake = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_ai_oreo", "libraries/modifiers/modifier_ai_oreo", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_ai_stack", "libraries/modifiers/modifier_ai_stack", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_ai_heap", "libraries/modifiers/modifier_ai_heap", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_ai_ginger_bread_man", "libraries/modifiers/modifier_ai_ginger_bread_man", LUA_MODIFIER_MOTION_BOTH)

local cookie_index = 0

function bake:OnSpellStart()

    --randomize the randomness
    math.randomseed(Time())

    --load parameters
    local caster = self:GetCaster()
    local min_spawn_distance = self:GetSpecialValueFor("min_spawn_distance")
    local max_spawn_distance = self:GetSpecialValueFor("max_spawn_distance")
    local max_height_distance = self:GetSpecialValueFor("max_height_distance")

    --create unit
    --set model by playerID
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
    cookieHeroNameTable[8] = "ginger_bread_man"
    cookieHeroNameTable[9] = "stack"
    cookieHeroNameTable[10] = "heap"
    cookieHeroNameTable[11] = "oreo"
    --specific cookie per playerID
    --local heroName = cookieHeroNameTable[math.random(0, 11)]
    --testing
    --local heroName = "heap"
    local heroName = cookieHeroNameTable[cookie_index]
    cookie_index = cookie_index + 1
    if cookie_index == 12 then
        cookie_index = 0
    end
    local cookie = CreateUnitByName(string.format("freshly_baked_cookie_%s", heroName), caster:GetAbsOrigin(), true, caster:GetOwnerEntity(), caster:GetOwnerEntity(), caster:GetTeam())
    
    --add index to cookie
    GameMode.cookiesSpawned = GameMode.cookiesSpawned + 1
    cookie.index = GameMode.cookiesSpawned 
    GameMode.cookies[cookie.index] = cookie



    --must set owner to control it
    --caster is not the player; must get caster's owner
    cookie:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
    --set collision size
    cookie:SetHullRadius(50)
    if heroName == "ginger_bread_man" then
        cookie:SetHullRadius(100)
    end

    -- negative or positive direction; RandomFloat doesn't take negative values
    local direction = math.random(2)
    if direction == 1 then
        direction = -1
    else
        direction = 1
    end
    -- "spring" to a random location
    local knockback = cookie:AddNewModifier(
        self:GetCaster(), -- player source
        self, -- ability source
        "modifier_knockback_custom", -- modifier name
        {
            distance = math.random(min_spawn_distance, max_spawn_distance),
            height = math.random(0, max_height_distance),
            duration = 0.5,
            direction_x = RandomFloat(0,1) * direction,
            direction_y = RandomFloat(0,1) * direction,
            IsStun = true,
        } -- kv
    )

    -- on landing
    local callback = function()
        --local shoot_interval = cookie:FindAbilityByName("shoot_cookies"):GetSpecialValueFor("shoot_interval")
        --local call_interval = cookie:FindAbilityByName("axe_berserkers_call_custom"):GetSpecialValueFor("shoot_interval")
        --cookie:AddNewModifier(nil, nil, "modifier_ai_ginger_bread_man", {})
        --modifiers for cookies
        if heroName == "oreo" then
            cookie:AddNewModifier(nil, nil, "modifier_ai_oreo", { aggroRange = 600 })
        elseif heroName == "stack" then
            cookie:AddNewModifier(nil, nil, "modifier_ai_stack", {})
        elseif heroName == "heap" then
            cookie:AddNewModifier(nil, nil, "modifier_ai_heap", {})
        elseif heroName == "ginger_bread_man" then
            cookie:AddNewModifier(nil, nil, "modifier_ai_ginger_bread_man", {})
        end
    end
    --returns when knockback is finished
    if cookie:IsAlive() then
        knockback:SetEndCallback( callback )
    end

end