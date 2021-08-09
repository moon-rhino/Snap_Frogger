cookie_party = class({})

LinkLuaModifier( "modifier_set_max_move_speed", "custom_abilities/modifier_set_max_move_speed", LUA_MODIFIER_MOTION_NONE )

function cookie_party:Start()
    --set flag for score
    GameMode.games["cookieParty"].active = true
    --arrow cookie
    --bomb cookie
    --chain cookie
    --feed the most cookies to win
    --on projectile hit
    --increase count for caster

    --announce 
    Notifications:BottomToAll({text = "Cookie Party", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
    Notifications:BottomToAll({text = "Feed the most cookies before time ends", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 

    --song
    EmitGlobalSound("bang")
    
    --spawn players
    for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers-1 do
            if GameMode.teams[teamNumber][playerID] ~= nil then
                if PlayerResource:IsValidPlayerID(playerID) then
                    local heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
                    heroEntity:ForceKill(false)
                    GameMode:SpawnPlayerRandomlyAroundCenter(heroEntity, "cookie_party_center")
                    --set camera
                    GameMode:SetCamera(heroEntity)
                    --customize abilities
                    local abilitiesToAdd = {}
                    --animations built in to ability slots
                    abilitiesToAdd[1] = "arrow_cookie_2"
                    abilitiesToAdd[2] = "bomb_cookie"
                    abilitiesToAdd[3] = "chain_cookie"
                    abilitiesToAdd[4] = "bomb_cookie_effect"

                    --custom items
                    --local item = CreateItem("item_force_staff", heroEntity, heroEntity)
                    --heroEntity:AddItem(item)
                    --local item = CreateItem("item_phase_boots_custom", heroEntity, heroEntity)
                    --heroEntity:AddItem(item)

                    GameMode:CustomizeAbilities(heroEntity, abilitiesToAdd)
                    --attack
                    --to kill specific cookies
                    --heroEntity:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
                    --modifiers
                    --heroEntity:SetBaseMagicalResistanceValue(0)
                    heroEntity:AddNewModifier(nil, nil, "modifier_attack_immune", {})
                    heroEntity:AddNewModifier(nil, nil, "modifier_set_max_move_speed", { limit = 700 })
                    heroEntity:SetDayTimeVisionRange(3000)
                    heroEntity:SetNightTimeVisionRange(3000)
                    --score
                    heroEntity.score = 0
                end
            end
            end
        end
    end

    --thinker
    cookie_party:Think()
end

function cookie_party:Think()
    local finished = false
    Timers:CreateTimer("referee", {
        useGameTime = true,
        endTime = 60,
        callback = function()
            --print("referee executed")
            --take everyone's score
            --one with the most points wins
            local playerWithHighestScore = nil
            local highestScore = 0
            for teamNumber = 6, 13 do
                if GameMode.teams[teamNumber] ~= nil then
                for playerID = 0, GameMode.maxNumPlayers - 1 do
                    if GameMode.teams[teamNumber][playerID] ~= nil then
                        if PlayerResource:IsValidPlayerID(playerID) then
                            local heroEntity = GameMode.teams[teamNumber][playerID]
                            if heroEntity.score >= highestScore then
                                playerWithHighestScore = heroEntity
                                highestScore = heroEntity.score
                            end
                        end
                    end
                end
                end
            end
            --tie

            --declare winner
            Notifications:BottomToAll({text = "Winner! ", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
            Notifications:BottomToAll({text = GameMode.teamNames[playerWithHighestScore:GetTeamNumber()], duration= 5.0, style={["font-size"] = "45px", color = GameMode.teamColors[playerWithHighestScore:GetTeamNumber()]}, continue=true})
            Notifications:BottomToAll({text = string.format("  Fed %s cookies", highestScore), duration= 5.0, style={["font-size"] = "45px", color = "white"}})
            GameMode.teams[playerWithHighestScore:GetTeamNumber()].score = GameMode.teams[playerWithHighestScore:GetTeamNumber()].score + 1
            GameMode:EndGame()
            --kill all cookies
            GameMode:KillAllCookies(GameMode.cookies)
            GameMode.games["cookieParty"].active = false
            finished = true

            --cleaner to kill the remaining creeps
            --local cleaner = CreateUnitByName("cleaner2", GameMode:GetHammerEntityLocation("cookie_party_center"), true, nil, nil, DOTA_TEAM_BADGUYS)
            --cleaner:AddAbility("kill_radius_cleaner")
            --[[Timers:CreateTimer("cleaner_remove", {
                useGameTime = false,
                endTime = 5,
                callback = function()
                    cleaner:ForceKill(false)
                    return nil
                end
            })
            return nil]]
        end
    })

    --respawn players if they're dead
    Timers:CreateTimer("respawnIfDead", {
        useGameTime = false,
        endTime = 0,
        callback = function()
        if finished then
            return nil
        else
            for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
                for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                    local heroEntity = GameMode.teams[teamNumber][playerID]
                    if not heroEntity:IsAlive() then
                        GameMode:SpawnPlayerRandomlyAroundCenter(heroEntity, "cookie_party_center")
                        heroEntity:AddNewModifier(nil, nil, "modifier_attack_immune", {})
                    end
                end
                end
            end
            end
            --respawn timer
            --randomized so that people can't expect exactly when they will respawn
            return 3
        end
        end
    })
    
end

function cookie_party:SpawnCookie(caster, targets_hit)
    local min_spawn_distance = 50
    local max_spawn_distance = 200
    local max_height_distance = 150
    local cookie
    --on expire
    --count how many targets were hit
    --spawn a cookie based on that
    --or spawn a cookie on every hit
    if targets_hit == 0 then
        --nothing
    elseif targets_hit > 0 and targets_hit <= 2 then
        --create unit
        --set model by playerID
        local cookieHeroNameTable = {}
        cookieHeroNameTable[0] = "cm"
        cookieHeroNameTable[1] = "axe"
        cookieHeroNameTable[2] = "ogre"
        cookieHeroNameTable[3] = "lina"
        cookieHeroNameTable[4] = "jugg"
        cookieHeroNameTable[5] = "bristleback"
        cookieHeroNameTable[6] = "invoker"
        cookieHeroNameTable[7] = "morty"

        --specific cookie per playerID
        local heroName = cookieHeroNameTable[math.random(0, 7)]
        cookie = CreateUnitByName(string.format("freshly_baked_cookie_%s", heroName), caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
        
        --must set owner to control it
        cookie:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
        --set collision size
        cookie:SetHullRadius(50)

        -- negative or positive direction; RandomFloat doesn't take negative values
        local direction = math.random(2)
        if direction == 1 then
            direction = -1
        else
            direction = 1
        end
        -- "spring" to a random location
        local knockback = cookie:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = math.random(min_spawn_distance, max_spawn_distance),
                height = math.random(50, max_height_distance),
                duration = 0.5,
                direction_x = RandomFloat(0,1) * direction,
                direction_y = RandomFloat(0,1) * direction,
                IsStun = true,
            } -- kv
        )
    elseif targets_hit <= 4 then
        --print("four targets hit")
        --specific cookie per playerID
        local heroName = "oreo"
        cookie = CreateUnitByName(string.format("freshly_baked_cookie_%s", heroName), caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
        cookie:AddNewModifier(nil, nil, "modifier_ai_oreo", { aggroRange = 600 })

        --must set owner to control it
        cookie:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
        --set collision size
        cookie:SetHullRadius(50)
        

        -- negative or positive direction; RandomFloat doesn't take negative values
        local direction = math.random(2)
        if direction == 1 then
            direction = -1
        else
            direction = 1
        end
        -- "spring" to a random location
        local knockback = cookie:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = math.random(min_spawn_distance, max_spawn_distance),
                height = math.random(100, max_height_distance),
                duration = 0.5,
                direction_x = RandomFloat(0,1) * direction,
                direction_y = RandomFloat(0,1) * direction,
                IsStun = true,
            } -- kv
        )
    elseif targets_hit <= 6 then
        --specific cookie per playerID
        local heroName = "stack"
        cookie = CreateUnitByName(string.format("freshly_baked_cookie_%s", heroName), caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
        cookie:AddNewModifier(nil, nil, "modifier_ai_stack", {})
        --must set owner to control it
        cookie:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
        
        --set collision size
        cookie:SetHullRadius(50)

        -- negative or positive direction; RandomFloat doesn't take negative values
        local direction = math.random(2)
        if direction == 1 then
            direction = -1
        else
            direction = 1
        end
        -- "spring" to a random location
        local knockback = cookie:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = math.random(min_spawn_distance, max_spawn_distance),
                height = math.random(50, max_height_distance),
                duration = 0.5,
                direction_x = RandomFloat(0,1) * direction,
                direction_y = RandomFloat(0,1) * direction,
                IsStun = true,
            } -- kv
        )
    elseif targets_hit <= 8 then
        --specific cookie per playerID
        local heroName = "heap"
        cookie = CreateUnitByName(string.format("freshly_baked_cookie_%s", heroName), caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
        --cookie:SetModelScale(1.3)
        --must set owner to control it
        cookie:AddNewModifier(nil, nil, "modifier_ai_heap", {})
        
        cookie:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
        

        
        --set collision size
        cookie:SetHullRadius(150)

        -- negative or positive direction; RandomFloat doesn't take negative values
        local direction = math.random(2)
        if direction == 1 then
            direction = -1
        else
            direction = 1
        end
        -- "spring" to a random location
        local knockback = cookie:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = math.random(min_spawn_distance, max_spawn_distance),
                height = math.random(50, max_height_distance),
                duration = 0.5,
                direction_x = RandomFloat(0,1) * direction,
                direction_y = RandomFloat(0,1) * direction,
                IsStun = true,
            } -- kv
        )
        
    elseif targets_hit >= 9 then
        --specific cookie per playerID
        local heroName = "ginger_bread_man"
        cookie = CreateUnitByName(string.format("freshly_baked_cookie_%s", heroName), caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
        --cookie:SetModelScale(1.5)
        cookie:AddNewModifier(nil, nil, "modifier_ai_ginger_bread_man", {})
        --must set owner to control it
        cookie:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
        --set collision size
        cookie:SetHullRadius(100)

        -- negative or positive direction; RandomFloat doesn't take negative values
        local direction = math.random(2)
        if direction == 1 then
            direction = -1
        else
            direction = 1
        end
        -- "spring" to a random location
        local knockback = cookie:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = math.random(min_spawn_distance, max_spawn_distance),
                height = math.random(50, max_height_distance),
                duration = 0.5,
                direction_x = RandomFloat(0,1) * direction,
                direction_y = RandomFloat(0,1) * direction,
                IsStun = true,
            } -- kv
        )
    end
    if cookie ~= nil then
        cookie:SetDeathXP(0)
        GameMode.cookiesSpawned = GameMode.cookiesSpawned + 1
        cookie.index = GameMode.cookiesSpawned
        GameMode.cookies[cookie.index] = cookie
    end
end

--remove death xp from units in minigames