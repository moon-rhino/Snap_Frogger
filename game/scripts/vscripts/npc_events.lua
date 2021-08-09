--lasts 20 seconds
--create for loop to get entities in hammer
    --at every entity, spawn an npc
    --npc does something every few seconds
    --at the start of a minigame, kill the npcs


function GameMode:MiranaEvent()
    Notifications:BottomToAll({text="Mirana Event Activated" , duration = 15, style={["font-size"] = "45px"}})
    for i = 1, 12 do
        local npcEnt = Entities:FindByName(nil, string.format("npc_%s", i))
        local npcEntVector = npcEnt:GetAbsOrigin()
        GameMode.games["normal"].npcs[i] = CreateUnitByName("mirana", npcEntVector, true, nil, nil, DOTA_TEAM_BADGUYS)
        GameMode.games["normal"].npcs[i].index = i
        GameMode.games["normal"].npcs[i]:SetThink("MiranaThinker", self)
    end
end

function GameMode:MiranaThinker(mirana)
    --shoot an arrow in a random direction every few seconds
    local randomInterval = RandomFloat(3, 9)
    Timers:CreateTimer(randomInterval, function()
        local arrow = mirana:FindAbilityByName("mirana_arrow_custom") 
        local pos = mirana:GetAbsOrigin()
        local r = 1000
        if mirana:IsAlive() then
            math.randomseed(GameRules:GetGameTime())
            randomInterval = RandomFloat(3, 9)
            --bottom 
            if mirana.index >= 1 and mirana.index < 4  then
                --calculates in circles
                --0 or 2pi radians faces to the right (positive x-axis)
                --local anglerad = math.rad(RandomFloat(70, 110))
                local anglerad = math.rad(RandomFloat(70, 110))
                local castpos = Vector(pos.x + r*math.cos(anglerad), pos.y + r*math.sin(anglerad), pos.z)
                mirana:CastAbilityOnPosition(castpos, arrow, -1)
            --right
            elseif mirana.index >= 4 and mirana.index < 7 then
                local anglerad = math.rad(RandomFloat(160,200))
                local castpos = Vector(pos.x + r*math.cos(anglerad), pos.y + r*math.sin(anglerad), pos.z)
                mirana:CastAbilityOnPosition(castpos, arrow, -1)
            --top
            elseif mirana.index >= 7 and mirana.index < 10 then
                local anglerad = math.rad(RandomFloat(250, 290))
                local castpos = Vector(pos.x + r*math.cos(anglerad), pos.y + r*math.sin(anglerad), pos.z)
                mirana:CastAbilityOnPosition(castpos, arrow, -1)
            --left
            else
                local anglerad = math.rad(RandomFloat(340, 380))
                local castpos = Vector(pos.x + r*math.cos(anglerad), pos.y + r*math.sin(anglerad), pos.z)
                mirana:CastAbilityOnPosition(castpos, arrow, -1)
            end
            return randomInterval
        else
          return nil
        end
    end)
end

function GameMode:KillAllNpcs()
    for _, npc in pairs(GameMode.games["normal"].npcs) do
        if npc ~= nil then
            print("[GameMode:KillAllNpcs()] killing an npc")
            npc:ForceKill(false)
            npc:RemoveSelf()
        end
    end
end


function GameMode:MortimerMiniEvent()
    Notifications:BottomToAll({text="Mortimer Event Activated" , duration = 15, style={["font-size"] = "45px"}})
    for i = 1, 12 do
        local npcEnt = Entities:FindByName(nil, string.format("npc_%s", i))
        local npcEntVector = npcEnt:GetAbsOrigin()
        GameMode.games["normal"].npcs[i] = CreateUnitByName("mortimer_mini", npcEntVector, true, nil, nil, DOTA_TEAM_BADGUYS)
        GameMode.games["normal"].npcs[i].index = i
        GameMode.games["normal"].npcs[i]:SetThink("MortimerMiniThinker", self)
    end
end

function GameMode:MortimerMiniThinker(mortimer)
    --spit a kiss in a random location every few seconds
    local randomInterval = RandomFloat(3, 9)
    Timers:CreateTimer(randomInterval, function()
        local kissLocationX = math.random(-10258, -5998)
        local kissLocationY = math.random(-8879, -4874)
        local kissLocationZ = math.random(128, 256)
        mortimer:SetCursorPosition(Vector(kissLocationX, kissLocationY, kissLocationZ))
        if mortimer:IsAlive() then
            local kiss = mortimer:FindAbilityByName("mortimer_kisses_morty_mini") 
            math.randomseed(GameRules:GetGameTime())
            randomInterval = RandomFloat(3, 9)
            kiss:OnSpellStart()
            return randomInterval
        else
          return nil
        end
    end)
end

function GameMode:HordeEvent()
    Notifications:BottomToAll({text="Horde Event Activated" , duration = 15, style={["font-size"] = "45px"}})
    --spawn cookies every few seconds
    --each grants gold
    --axe cookie: can't normal attack
    --jugg: immune to magic
    --bristleback: quill spray
    local wave = -1
    Timers:CreateTimer(1, function()
        wave = wave + 1
        if not GameMode.event then
            return nil
        else
            for i = 1, 4 do
                local hordeEnt = Entities:FindByName(nil, string.format("horde_%s", i))
                local hordeEntVector = hordeEnt:GetAbsOrigin()
                GameMode.games["normal"].npcs[wave * 4 + i] = CreateUnitByName("bristleback_cookie", hordeEntVector, true, nil, nil, DOTA_TEAM_BADGUYS)
                GameMode.games["normal"].npcs[wave * 4 + i].index = wave * 4 + i
                GameMode.games["normal"].npcs[wave * 4 + i]:SetThink("BristlebackCookieThinker", self)
            end
            return 2
        end
    end)
end

function GameMode:BristlebackCookieThinker(bristlebackCookie)
    --quill spray every few seconds
    --move to attack to the center
    local randomInterval = RandomFloat(3, 9)
    local startCenterEnt = Entities:FindByName(nil, "start_center")
    local startCenterEntVector = startCenterEnt:GetAbsOrigin()
    bristlebackCookie:MoveToPositionAggressive(startCenterEntVector)
    Timers:CreateTimer(randomInterval, function()
        if GameMode.games["normal"].npcs[bristlebackCookie.index] ~= nil then
            local quillSpray = bristlebackCookie:FindAbilityByName("bristleback_quill_spray") 
            math.randomseed(GameRules:GetGameTime())
            randomInterval = RandomFloat(3, 9)
            quillSpray:OnSpellStart()
            bristlebackCookie:MoveToPositionAggressive(startCenterEntVector)
            return randomInterval
        else
          return nil
        end
    end)
end

require('libraries/modifiers/modifier_ai_immortal_morty')
LinkLuaModifier("modifier_ai_immortal_morty", "libraries/modifiers/modifier_ai_immortal_morty.lua", LUA_MODIFIER_MOTION_NONE)

function GameMode:ImmortalMortyEvent()
    Notifications:BottomToAll({text="Immortal Morty Event Activated" , duration = 10, style={["font-size"] = "45px"}})
    --spawn morties throughout the map
    for creepIndex = 1, 4 do
        local spawn_location_x = math.random(-8835, -7062)
        local spawn_location_y = math.random(-7729, -6140)
        local spawn_location_z = math.random(128, 256)
        local spawn_location = Vector(spawn_location_x, spawn_location_y, spawn_location_z)
        GameMode.games["normal"].npcs[creepIndex] = CreateUnitByName("immortal_morty", spawn_location, true, nil, nil, DOTA_TEAM_BADGUYS)
        GameMode.games["normal"].npcs[creepIndex].index = creepIndex
        GameMode.games["normal"].npcs[creepIndex]:AddNewModifier(nil, nil, "modifier_ai_immortal_morty", {aggroRange = 5000, leashRange = 5000})
    end
    --cookie to move
    --single charge ults
    --spit each other out
end



--event thinker
--end event after few seconds