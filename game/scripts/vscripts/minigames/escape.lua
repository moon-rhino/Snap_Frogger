
escape = class({})

function escape:Start()
    --notification
    Notifications:BottomToAll({text = "Escape", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
    

    --spawn players
    for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers-1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                    if PlayerResource:IsValidPlayerID(playerID) then
                        local heroEntity = GameMode.teams[teamNumber][playerID]


                        --respawn location at the start
                        --GameMode.games["escape"].checkpointHammerEntity = "escape_start"
                        --for testing
                        heroEntity:ForceKill(false)
                        GameMode.games["escape"].checkpointHammerEntity = "escape_start"
                        GameMode.games["escape"].checkpointActivated = 0
                        GameMode:SpawnPlayerRandomlyAroundCenter(heroEntity, GameMode.games["escape"].checkpointHammerEntity)
                        
                        --items
                        GameMode:RemoveAllItems(heroEntity)
            
                        --abilities
                        --remove all abilities
                        GameMode:RemoveAllAbilities(heroEntity)
                        --add specific abilities
                        local arrow_cookie = heroEntity:AddAbility("arrow_cookie_fae")
                        arrow_cookie:SetLevel(1)
            
                        --set camera
                        GameMode:SetCamera(heroEntity)
            
                        --modifiers
                        heroEntity:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)

                    end
                end
            end
        end
    end

    --set number of lives
    GameMode.games["escape"].numLives = 55
    Notifications:BottomToAll({text = "Number of lives = 55", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
    
    --spawn npcs
    --checkpoint zero
    escape:CheckpointZeroThinker()
    --timbersaw 1
    --depends on what checkpoint has been reached
    --for position = 1, 1 do
    --    escape:SpawnTimbersaw(position)
    --end

    escape:ReviveDeadThinker()

    --if anyone reaches the next checkpoint, set the group's checkpoint to that


    --triggers
end

function escape:TimbersawThinker(timbersaw)
    --go to destination
    --get destination
    --local destination = GameMode:GetHammerEntityLocation("timbersaw_end_1")
    timbersaw:MoveToPosition(timbersaw.destination)
    --once reached, die
    --think -- has he reached his destination yet?
    --make name dynamic so it doesn't overlap with other timers
    Timers:CreateTimer(string.format("destination_reached_check_%s", GameMode.games["escape"].timbersawsSpawned), {
        useGameTime = true,
        endTime = 0,
        callback = function()
            if (timbersaw:GetAbsOrigin() - timbersaw.destination):Length2D() < 100 then
                timbersaw:ForceKill(false)
                return nil
            else
                return 1
            end
        end
    })
end

--no need to set a timer in thinker with SetThink
function escape:Timbersaw2Thinker(timbersaw)
    --go to destination
    --get destination
    --local destination = GameMode:GetHammerEntityLocation("timbersaw_end_1")
    timbersaw:MoveToPosition(timbersaw.destination)
    --once reached, die
    --think -- has he reached his destination yet?
    --make name dynamic so it doesn't overlap with other timers
    --[[Timers:CreateTimer(string.format("destination_reached_check_%s", GameMode.games["escape"].timbersawsSpawned), {
        useGameTime = true,
        endTime = 0,
        callback = function()]]
    if (timbersaw:GetAbsOrigin() - timbersaw.destination):Length2D() < 100 then
        timbersaw:ForceKill(false)
        --spawn another timbersaw
        --if checkpoint progressed, don't respawn
        --escape:SpawnTimbersaw(timbersaw.position)
        --it will be respawned by thinker
        --timbersaw:RemoveSelf()
        return nil
    else
        return 0.3
    end
        --end
    --})
end

function escape:TimbersawSpecialThinker(timbersaw)
    --go to destination
    --first destination = "timbersaw_destination_3_1"
    local destination = 1
    timbersaw.destination = GameMode:GetHammerEntityLocation(string.format("timbersaw_destination_3_%s", destination))
    --second destination = "timbersaw_destination_3_2"
    --.. upto 5
    --last destination = "timbersaw_end_3"

    --get destination
    --local destination = GameMode:GetHammerEntityLocation("timbersaw_end_1")
    timbersaw:MoveToPosition(timbersaw.destination)
    --once reached, die
    --think -- has he reached his destination yet?
    --make name dynamic so it doesn't overlap with other timers
    Timers:CreateTimer(string.format("destination_reached_check_%s", GameMode.games["escape"].timbersawsSpawned), {
        useGameTime = true,
        endTime = 0,
        callback = function()
            if (timbersaw:GetAbsOrigin() - timbersaw.destination):Length2D() < 100 then
                --set next destination
                destination = destination + 1
                --checkpoint 2, checkpoint 5
                if destination == 7 then
                    timbersaw:ForceKill(false)
                    return nil
                else
                    timbersaw.destination = GameMode:GetHammerEntityLocation(string.format("timbersaw_destination_3_%s", destination))
                    timbersaw:MoveToPosition(timbersaw.destination)
                    return 0.5
                end
            else
                return 0.5
            end
        end
    })
end

function escape:TimbersawSpecialThinker2(timbersaw)

    --move to position
    timbersaw.destination = GameMode:GetHammerEntityLocation(string.format("timbersaw_destination_%s_%s", timbersaw.position, timbersaw.destination_counter))
    timbersaw:MoveToPosition(timbersaw.destination)
    if (timbersaw:GetAbsOrigin() - timbersaw.destination):Length2D() < 100 then
        --set next destination
        timbersaw.destination_counter = timbersaw.destination_counter + 1
        if timbersaw.destination_counter == 3 then
            timbersaw:ForceKill(false)
            return nil
        else
            return 0.5
        end
    else
        return 0.5
    end
end

function escape:SpawnTimbersaw(position)
    local spawnLocation = GameMode:GetHammerEntityLocation(string.format("timbersaw_start_%s", position))
    local timbersaw = CreateUnitByName("fae_runner", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["escape"].timbersaws[position] = timbersaw
    --kill_radius kills each other
    --undo invulnerability and magic immunity, and add immolation
    if position > 13 and position < 26 then
        local steam = timbersaw:FindAbilityByName("steam_3")
        steam:OnSpellStart()
    else
        local steam = timbersaw:FindAbilityByName("steam_2")
        steam:OnSpellStart()
    end
    --timbersaw:SetHullRadius(300)
    GameMode.games["escape"].timbersawsSpawned = GameMode.games["escape"].timbersawsSpawned + 1
    timbersaw.position = position
    --[[if GameMode.games["escape"].checkpointActivated == 2 then
        timbersaw:SetBaseMoveSpeed(400)
    end]]
    if position == 3 then
        timbersaw:SetThink("TimbersawSpecialThinker", self)
    elseif position == 26 or position == 27 then
        timbersaw.destination_counter = 1
        timbersaw:SetThink("TimbersawSpecialThinker2", self)
    elseif position > 3 and position < 26 then
        if position > 13 and position < 26 then
            timbersaw:SetModelScale(1)
        end
        timbersaw.destination = GameMode:GetHammerEntityLocation(string.format("timbersaw_end_%s", position))
        timbersaw:SetThink("Timbersaw2Thinker", self)
    else
        timbersaw.destination = GameMode:GetHammerEntityLocation(string.format("timbersaw_end_%s", position))
        timbersaw:SetThink("TimbersawThinker", self)
    end
    
end

function escape:SpawnBadCookie(zone, position)
    local spawnLocation = GameMode:GetHammerEntityLocation(string.format("bad_cookie_%s_%s", zone, position))
    local badCookie = CreateUnitByName("badLeaf", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
end

function escape:SpawnBadCookiePair(zone, position)
    --side 1
    local spawnLocation = GameMode:GetHammerEntityLocation(string.format("bad_cookie_%s_%s_%s", zone, 1, position))
    local badCookie = CreateUnitByName("badLeaf", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    --side 2
    local spawnLocation = GameMode:GetHammerEntityLocation(string.format("bad_cookie_%s_%s_%s", zone, 2, position))
    local badCookie = CreateUnitByName("badLeaf", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
end

function escape:CheckpointZeroThinker()
    --keep spawning timbersaw
    local timbersawSpawn = 15
    Timers:CreateTimer("spawnTimbersaw", {
        useGameTime = true,
        endTime = 0,
        callback = function()

            if GameMode.games["escape"].checkpointActivated == 0 then
                if timbersawSpawn == 15 then
                    escape:SpawnTimbersaw(1)
                    timbersawSpawn = timbersawSpawn - 1
                    return 1
                else
                    timbersawSpawn = timbersawSpawn - 1
                    if timbersawSpawn == 0 then
                        timbersawSpawn = 15
                    end
                    --continue
                    return 1
                end
            else
                --can't have function that's not defined, even if it's not called
                escape:CheckpointOneThinker()
                return nil
            end
        end
    })

    --spawn bad cookies
    local numberOfCookiesInZone1 = 12

    for cookiePosition = 1, numberOfCookiesInZone1 do
        escape:SpawnBadCookie(1, cookiePosition)
    end

end

function EscapeCheckpointOneTrigger(trigger)
    --update checkpoint
    --end checkpointzero thinker
    --only activate when players come from checkpoint 0
    if GameMode.games["escape"].checkpointActivated == 0 then
        --notification
        Notifications:BottomToAll({text = "Checkpoint 1 triggered", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        GameMode.games["escape"].checkpointActivated = 1
        GameMode.games["escape"].checkpointHammerEntity = "escape_checkpoint_1_center"
        GameMode.games["escape"].numLives = GameMode.games["escape"].numLives + 5
        Notifications:BottomToAll({text = "gained 5 lives", duration= 5.0, style={["font-size"] = "25px", color = "white"}}) 
        --kill all
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                --disconnect check
                if PlayerResource:IsValidPlayerID(playerID) then
                    local heroEntity = GameMode.teams[teamNumber][playerID]
                    if heroEntity:IsAlive() then
                        heroEntity:ForceKill(false)
                    end
                end
                end
            end
            end
        end
        --will be revived by "reviveDeadthinker"
    else
        --nothing
    end

end

function escape:CheckpointOneThinker()
    --keep spawning timbersaw
    local timbersawSpawn = 20
    Timers:CreateTimer("spawnTimbersaw", {
        useGameTime = true,
        endTime = 1,
        callback = function()
            if GameMode.games["escape"].checkpointActivated == 1 then
                if timbersawSpawn == 20 then
                    escape:SpawnTimbersaw(2)
                    timbersawSpawn = timbersawSpawn - 1
                    return 1
                else
                    timbersawSpawn = timbersawSpawn - 1
                    if timbersawSpawn == 0 then
                        timbersawSpawn = 20
                    end
                    --continue
                    return 1
                end
            else
                --can't have function that's not defined, even if it's not called
                escape:CheckpointTwoThinker()
                return nil
            end
        end
    })

    --spawn bad cookies
    local numberOfCookiesInZone2 = 12
    
    for cookiePosition = 1, numberOfCookiesInZone2 do
        escape:SpawnBadCookie(2, cookiePosition)
    end

end

function EscapeCheckpointTwoTrigger(trigger)

    --update checkpoint
    --end checkpointzero thinker
    --only activate when players come from checkpoint 0
    if GameMode.games["escape"].checkpointActivated == 1 then
        --notification
        Notifications:BottomToAll({text = "Checkpoint 2 triggered", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        GameMode.games["escape"].checkpointActivated = 2
        GameMode.games["escape"].checkpointHammerEntity = "escape_checkpoint_2_center"
        GameMode.games["escape"].numLives = GameMode.games["escape"].numLives + 5
        Notifications:BottomToAll({text = "gained 5 lives", duration= 5.0, style={["font-size"] = "25px", color = "white"}}) 
        --kill all
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                --disconnect check
                if PlayerResource:IsValidPlayerID(playerID) then
                    local heroEntity = GameMode.teams[teamNumber][playerID]
                    if heroEntity:IsAlive() then
                        heroEntity:ForceKill(false)
                    end
                end
                end
            end
            end
        end
        --will be revived by "reviveDeadthinker"
    else
        --nothing
    end

end

function escape:CheckpointTwoThinker()
    --keep spawning timbersaw
    local timbersawSpawn = 30
    Timers:CreateTimer("spawnTimbersaw", {
        useGameTime = true,
        endTime = 1,
        callback = function()
            if GameMode.games["escape"].checkpointActivated == 2 then
                if timbersawSpawn == 30 then
                    escape:SpawnTimbersaw(3)
                    timbersawSpawn = timbersawSpawn - 1
                    return 1
                else
                    timbersawSpawn = timbersawSpawn - 1
                    if timbersawSpawn == 0 then
                        timbersawSpawn = 30
                    end
                    --continue
                    return 1
                end
            else
                --can't have function that's not defined, even if it's not called
                escape:CheckpointThreeThinker()
                return nil
            end
        end
    })

    --spawn bad cookies
    local numberOfCookiesInZone3 = 13
    
    for cookiePosition = 1, numberOfCookiesInZone3 do
        escape:SpawnBadCookie(3, cookiePosition)
    end
end

function EscapeCheckpointThreeTrigger(trigger)

    --update checkpoint
    --end checkpointzero thinker
    --only activate when players come from checkpoint 0
    if GameMode.games["escape"].checkpointActivated == 2 then
        --notification
        Notifications:BottomToAll({text = "Checkpoint 3 triggered", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
        Notifications:BottomToAll({text = "Stun range increased", duration= 5.0, style={["font-size"] = "45px", color = "white"}})  
        GameMode.games["escape"].checkpointActivated = 3
        GameMode.games["escape"].checkpointHammerEntity = "escape_checkpoint_3_center"
        GameMode.games["escape"].numLives = GameMode.games["escape"].numLives + 5
        Notifications:BottomToAll({text = "gained 5 lives", duration= 5.0, style={["font-size"] = "25px", color = "white"}}) 
        --kill all
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                --disconnect check
                if PlayerResource:IsValidPlayerID(playerID) then
                    local heroEntity = GameMode.teams[teamNumber][playerID]
                    if heroEntity:IsAlive() then
                        heroEntity:ForceKill(false)
                    end
                end
                end
            end
            end
        end
        --will be revived by "reviveDeadthinker"
    else
        --nothing
    end

end

function escape:CheckpointThreeThinker()
    --spawn timbersaw once
    for position = 4, 13 do
        escape:SpawnTimbersaw(position)
    end

    Timers:CreateTimer("check_level_finished", {
        useGameTime = false,
        endTime = 1,
        callback = function()
            if GameMode.games["escape"].checkpointActivated == 3 then
                for position = 4, 13 do
                    if GameMode.games["escape"].timbersaws[position]:IsAlive() == false then
                        GameMode.games["escape"].timbersaws[position]:RemoveSelf()
                        escape:SpawnTimbersaw(position)
                    end
                end
                return 1
            else
                --can't have function that's not defined, even if it's not called
                escape:CheckpointFourThinker()
                return nil
            end
            return 1
        end
    })
    
end

function EscapeCheckpointFourTrigger(trigger)
    if GameMode.games["escape"].checkpointActivated == 3 then
        --notification
        Notifications:BottomToAll({text = "Checkpoint 4 triggered", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        
        GameMode.games["escape"].checkpointActivated = 4
        GameMode.games["escape"].checkpointHammerEntity = "escape_checkpoint_4_center"
        GameMode.games["escape"].numLives = GameMode.games["escape"].numLives + 5
        Notifications:BottomToAll({text = "gained 5 lives", duration= 5.0, style={["font-size"] = "25px", color = "white"}}) 
        --set fog of war
        --taken from internal/gamemode.lua
        --GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
        --kill all
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                --disconnect check
                if PlayerResource:IsValidPlayerID(playerID) then
                    local heroEntity = GameMode.teams[teamNumber][playerID]
                    if heroEntity:IsAlive() then
                        heroEntity:ForceKill(false)
                        --set vision
                        heroEntity:SetDayTimeVisionRange(10000)
                        heroEntity:SetNightTimeVisionRange(10000)
                    end
                end
                end
            end
            end
        end
        --will be revived by "reviveDeadthinker"
    else
        --nothing
    end
end

function escape:CheckpointFourThinker()
    --spawn timbersaw once
    for position = 14, 25 do
        escape:SpawnTimbersaw(position)
    end

    Timers:CreateTimer("check_level_5_finished", {
        useGameTime = false,
        endTime = 1,
        callback = function()
            if GameMode.games["escape"].checkpointActivated == 4 then
                for position = 14, 25 do
                    if GameMode.games["escape"].timbersaws[position]:IsAlive() == false then
                        GameMode.games["escape"].timbersaws[position]:RemoveSelf()
                        escape:SpawnTimbersaw(position)
                    end
                end
                return 1
            else
                --can't have function that's not defined, even if it's not called
                escape:CheckpointFiveThinker()
                return nil
            end
            return 1
        end
    })
end

function LoseCookieAbilityTrigger(trigger)
    local ent = trigger.activator
    if not ent then return end

    if ent:HasAbility("arrow_cookie_fae") then
        ent:RemoveAbility("arrow_cookie_fae")
    end
end

function EscapeCheckpointFiveTrigger(trigger)
    --print("triggered")
    if GameMode.games["escape"].checkpointActivated == 4 then
        GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
        --notification
        Notifications:BottomToAll({text = "Checkpoint 5 triggered", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        
        GameMode.games["escape"].checkpointActivated = 5
        GameMode.games["escape"].checkpointHammerEntity = "escape_checkpoint_5_center"
        GameMode.games["escape"].numLives = GameMode.games["escape"].numLives + 5
        Notifications:BottomToAll({text = "gained 5 lives", duration= 5.0, style={["font-size"] = "25px", color = "white"}}) 
        --kill all
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                --disconnect check
                if PlayerResource:IsValidPlayerID(playerID) then
                    local heroEntity = GameMode.teams[teamNumber][playerID]
                    if heroEntity:IsAlive() then
                        heroEntity:ForceKill(false)
                    end
                end
                end
            end
            end
        end
        --will be revived by "reviveDeadthinker"
    else
        --nothing
    end
end

function escape:CheckpointFiveThinker()
    --spawn timbersaw
    --one in each lane
    --start, destination 1, destination 2
    local timbersawSpawn = 30
    Timers:CreateTimer("spawnTimbersaw", {
        useGameTime = true,
        endTime = 1,
        callback = function()
            if GameMode.games["escape"].checkpointActivated == 5 then
                if timbersawSpawn == 30 then
                    --position
                    escape:SpawnTimbersaw(26)
                    escape:SpawnTimbersaw(27)
                    timbersawSpawn = timbersawSpawn - 1
                    return 1
                else
                    timbersawSpawn = timbersawSpawn - 1
                    if timbersawSpawn == 0 then
                        timbersawSpawn = 30
                    end
                    --continue
                    return 1
                end
            else
                --game finished
                return nil
            end
        end
    })
    
    --spawn bad cookies
    local numberOfCookiePairsInZone6 = 4
        
    for cookiePosition = 1, numberOfCookiePairsInZone6 do
        escape:SpawnBadCookiePair(6, cookiePosition)
    end

    --ends when both triggers are triggered; each trigger resets in 5 seconds
    --thinker to check if both triggers have been triggered

end

function EscapeCheckpointSixOneTrigger(trigger)
    --print("six one triggered")
    local ent = trigger.activator
    if not ent then return end

    GameMode.games["escape"].checkpointSixOneActivated = true
    Notifications:BottomToAll({text = "Checkpoint 6 - 1 triggered", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
    Notifications:BottomToAll({text = "You must activate the other trigger within 5 seconds", duration= 5.0, style={["font-size"] = "45px", color = "white"}})  

    if GameMode.games["escape"].checkpointSixOneActivated and GameMode.games["escape"].checkpointSixTwoActivated then
        Notifications:BottomToAll({text = "Winner! All of you", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        --give score
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                --disconnect check
                if PlayerResource:IsValidPlayerID(playerID) then
                    GameMode.teams[teamNumber].score = GameMode.teams[teamNumber].score + 1
                end
            end
            end
            end
        end
        GameMode:EndGame()
    end

    Timers:CreateTimer("deactivate_checkpoint_six_one", {
        useGameTime = false,
        endTime = 5,
        callback = function()
            GameMode.games["escape"].checkpointSixOneActivated = false
            return nil
        end
    })
    
    
end

function EscapeCheckpointSixTwoTrigger(trigger)
    --print("six two triggered")
    local ent = trigger.activator
    if not ent then return end

    GameMode.games["escape"].checkpointSixTwoActivated = true
    Notifications:BottomToAll({text = "Checkpoint 6 - 2 triggered", duration= 5.0, style={["font-size"] = "45px", color = "white"}})
    Notifications:BottomToAll({text = "You must activate the other trigger within 5 seconds", duration= 5.0, style={["font-size"] = "45px", color = "white"}})  

    if GameMode.games["escape"].checkpointSixOneActivated and GameMode.games["escape"].checkpointSixTwoActivated then
        Notifications:BottomToAll({text = "Winner! All of you", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        --give score
        for teamNumber = 6, 13 do
            if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.teams[teamNumber][playerID] ~= nil then
                --disconnect check
                if PlayerResource:IsValidPlayerID(playerID) then
                    GameMode.teams[teamNumber].score = GameMode.teams[teamNumber].score + 1
                end
                end
            end
            end
        end
        GameMode:EndGame()
    end
    
    Timers:CreateTimer("deactivate_checkpoint_six_two", {
        useGameTime = false,
        endTime = 5,
        callback = function()
            GameMode.games["escape"].checkpointSixTwoActivated = false
            return nil
        end
    })
end



function escape:ReviveDeadThinker()
    Timers:CreateTimer("revive_dead", {
        useGameTime = false,
        endTime = 0,
        callback = function()
            if GameMode.games["escape"].checkpointSixOneActivated and GameMode.games["escape"].checkpointSixTwoActivated then
                return nil
            else
                for teamNumber = 6, 13 do
                    if GameMode.teams[teamNumber] ~= nil then
                    for playerID = 0, GameMode.maxNumPlayers - 1 do
                        if GameMode.teams[teamNumber][playerID] ~= nil then
                        --disconnect check
                        if PlayerResource:IsValidPlayerID(playerID) then
                            local heroEntity = GameMode.teams[teamNumber][playerID]
                            if not heroEntity:IsAlive() then
                                GameMode.games["escape"].numLives = GameMode.games["escape"].numLives - 1
                                Notifications:BottomToAll({text = string.format("lives left: " .. GameMode.games["escape"].numLives), duration= 5.0, style={["font-size"] = "25px", color = "white"}}) 
                                if GameMode.games["escape"].numLives == 0 then
                                    Notifications:BottomToAll({text = "Losers! Back to herald", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
                                    GameMode:EndGame()
                                    return nil
                                else
                                    GameMode:SpawnPlayerRandomlyAroundCenter(heroEntity, GameMode.games["escape"].checkpointHammerEntity)
                                    --set camera
                                    GameMode:SetCamera(heroEntity)
                                    --for checkpoint 4 where ability gets removed
                                    if heroEntity:HasAbility("arrow_cookie_fae") == false then
                                        local ability = heroEntity:AddAbility("arrow_cookie_fae")
                                        ability:SetLevel(1)
                                    end
                                end
                            end
                        end
                        end
                    end
                    end
                end
                return 1
            end
        end
    })
    
end