function EndzoneTrigger(trigger)
    local ent = trigger.activator
    if not ent then return end
  
    --song
    EmitGlobalSound("next_episode")

    Notifications:BottomToAll({text = string.format("%s cleared!", GameMode.currentLevel), duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 

    Timers:CreateTimer("next_level", {
        useGameTime = true,
        endTime = 5,
        callback = function()
            --set everyone back to the starting line
            for playerID = 0, 8 do
                if PlayerResource:IsValidPlayerID(playerID) then
                    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                    local start_location = GameMode:GetHammerEntityLocation(string.format("player_%s_start", playerID+1))
                    GameMode:SetPlayerOnLocation(hero, start_location)
                end
            end
            --if GameMode.currentLevel == 'basics' then
                --clear creeps
                --basics:ClearCreeps()
                --run the next game
                --basics2:Run()
                --frogger2:Run()
                --GameMode.currentLevel = 'basics2'
                --GameMode.currentLevel = 'frogger2'
            --[[elseif GameMode.currentLevel == 'basics2' then
                basics2:ClearCreeps()
                frogger2:Run()
                GameMode.currentLevel = 'frogger2']]
            --elseif GameMode.currentLevel == 'frogger2' then
                --frogger2.finished = true
                --frogger2:ClearCreeps()
                --frogger3:Run()
                --GameMode.currentLevel = 'frogger3'  
            --elseif GameMode.currentLevel == 'frogger3' then
                --frogger3.finished = true
                --frogger3:ClearCreeps()
                --set up stage when the last one ends
                --GameMode.currentLevel = 'cookie_each_other'
                --mines2:run()
                --GameMode.currentLevel = 'mines2'
            --skip "mines2"; triggered by getting close to a creep
            --end
            if GameMode.currentLevel == 'frogger4' then
                frogger4.finished = true
                --frogger4:ClearCreeps()
                frogger5:Run()
                GameMode.currentLevel = 'frogger5'  
            elseif GameMode.currentLevel == 'frogger5' then
                frogger5.finished = true
                frogger5:ClearCreeps()
                pacman2:Run()
                --GameMode.currentLevel = 'pacman'  
            end
            return nil
        end
    })
end

function ShotgunTrigger(trigger)
    local ent = trigger.activator
    if not ent then return end
    Notifications:BottomToAll({text = "GUN GAME ACTIVATED", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
end