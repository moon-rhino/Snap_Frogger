LinkLuaModifier( "modifier_cookie_eaten", "libraries/modifiers/modifier_cookie_eaten", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_extra_mana", "libraries/modifiers/modifier_extra_mana", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stunned", "libraries/modifiers/modifier_stunned", LUA_MODIFIER_MOTION_NONE )

--[[
    rules:
    players feed a cookie one by one
    a player must feed at least 1 cookie
    there's a time limit of 5 seconds - set this after testing
    
    mechanics:
    signal the players when the limit is close
    
]]



jackpot = class({})

function jackpot:WarmUp()
    
    GameMode.warmUp = true
    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text="JACKPOT" , duration= 20, style={["font-size"] = "45px", color = "orange"}})
    Notifications:BottomToAll({text="WARM UP" , duration= 20, style={["font-size"] = "45px", color = "white"}})
    GameMode.games["jackpot"].players = {}
    GameMode.games["jackpot"].jackpot = math.random(7, 15)
    for playerID = 0, GameMode.maxNumPlayers-1 do
        if PlayerResource:IsValidPlayerID(playerID) then
          if GameMode.players[playerID] ~= nil then
            local hero = GameMode.players[playerID]
            local warmUpLocation = GameMode:GetHammerEntityLocation("warm_up_center")
            hero:SetRespawnPosition(warmUpLocation)
            hero:RespawnHero(false, false)
            GameMode:SetCamera(hero)
            --undo movement restriction from board
            hero:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
            --add abilities
            GameMode:RemoveAllAbilities(hero)
            local feed_one_cookie = hero:AddAbility("feed_one_cookie")
            feed_one_cookie:SetLevel(1)
            local feed_two_cookies = hero:AddAbility("feed_two_cookies")
            feed_two_cookies:SetLevel(1)
            local feed_three_cookies = hero:AddAbility("feed_three_cookies")
            feed_three_cookies:SetLevel(1)
            local skipAbility = hero:AddAbility("skip")
            skipAbility:SetLevel(1)
            --here is where to add the specific score for the game
            --hero.time = 0
            hero.earnedScore = 0
            GameMode.games["jackpot"].players[playerID] = 0
            --remove particle
            ParticleManager:DestroyParticle( hero.score_effect, true )
            GameMode.games["jackpot"].numAlive = GameMode.games["jackpot"].numAlive + 1
            --mana to limit casting
            hero:AddNewModifier(nil, nil, "modifier_extra_mana", { extraMana = -800, regen = 0 })
          end
        end
    end
    jackpot:Rules()
    local fattySpawnLocation = GameMode:GetHammerEntityLocation("warm_up_center")
    --spawn fatty to start
    jackpot:CreateFatty(fattySpawnLocation)
    --[[Timers:CreateTimer("spawn_fatty", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            if GameMode.warmUp then
                --feed it
                --if 
                --if it goes over threshold,
                    --kill the caster and fatty

                local cookie_eaten_modifier = GameMode.games["jackpot"].fatty:FindModifierByName("modifier_cookie_eaten")
                if cookie_eaten_modifier == nil then
                    local spawnLoc = GameMode:GetHammerEntityLocation("warm_up_center")
                    jackpot:CreateFatty(spawnLoc)
                    return 0.06
                end
                --if fatty already exists then
                if GameMode.games["jackpot"].fatty ~= nil then
                    --if stack count is over the threshold
                    if cookie_eaten_modifier:GetStackCount() > GameMode.games["jackpot"].jackpot then
                        Notifications:BottomToAll({text="BUSTED!" , duration= 20, style={["font-size"] = "45px", color = "orange"}})
                        --kill it
                        GameMode.games["jackpot"].fatty:EmitSound("explosion")
                        GameMode.games["jackpot"].fatty:EmitSound("ogre_death_1")
                        GameMode.games["jackpot"].fatty:ForceKill(false)
                        return 0.06
                    --else
                    elseif cookie_eaten_modifier:GetStackCount() == GameMode.games["jackpot"].jackpot then
                        --continue
                        --Notifications:BottomToAll({text="JACKPOT! (warm up)" , duration= 20, style={["font-size"] = "45px", color = "orange"}})
                        GameMode.games["jackpot"].fatty:EmitSound("jackpot")
                        GameMode.games["jackpot"].fatty:ForceKill(false)
                        return 0.06
                    else
                        return 0.06
                    end

                end
            else
                --don't spawn
                --end thinker
                return nil
            end
        end
    })]]
    
    local counter = GameMode.warmUpTime
    --start game in 20 seconds
    --unless everyone pressed "skip"
    Timers:CreateTimer("start_game", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            Notifications:ClearTopFromAll()
            Notifications:TopToAll({text=counter , duration= 1, style={["font-size"] = "45px", color = "white"}})
            if GameMode:CheckSkipForAllPlayers() or counter < 0 then
                GameMode.games["jackpot"].fatty:ForceKill(false)
                GameMode.games["jackpot"].fatty = nil
                jackpot:Start()
                GameMode:ResetSkipForAllPlayers()
                return nil
            else
                counter = counter - 1
                return 1
            end
        end
    })
end

function jackpot:KillAllPlayers()
    for playerID = 0, GameMode.maxNumPlayers-1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            if GameMode.players[playerID] ~= nil then
                local hero = GameMode.players[playerID]
                hero:ForceKill(false)
            end
        end
    end
end

--let them move around
--put a monster in the middle
--set a random "bust" number
--on bust, respawn

function jackpot:Rules()
    Notifications:BottomToAll({text="Take turns feeding cookies." , duration= 20, style={["font-size"] = "35px", color = "white"}})
    Notifications:BottomToAll({text="It can eat between 7 to 15 cookies." , duration= 20, style={["font-size"] = "35px", color = "white"}})
    Notifications:BottomToAll({text="If it eats too much, it will kill you." , duration= 20, style={["font-size"] = "35px", color = "white"}})
end

--[[function jackpot:PickRandomPlayer()
    GameMode.games["jackpot"].turn = math.random(0, GameMode.maxNumPlayers-1)
    while not PlayerResource:IsValidPlayerID(GameMode.games["jackpot"].turn) 
    or not PlayerResource:GetSelectedHeroEntity(GameMode.games["jackpot"].turn):IsAlive() do
        GameMode.games["jackpot"].turn = GameMode.games["jackpot"].turn + 1
        if GameMode.games["jackpot"].turn == GameMode.maxNumPlayers then
            GameMode.games["jackpot"].turn = 0
        end
    end
end]]

function jackpot:Start()
    --set warm up flag
    GameMode.warmUp = false

    --kill all players
    jackpot:KillAllPlayers()

    --set random number, different from warm up
    GameMode.games["jackpot"].jackpot = math.random(7, 15)
    --GameMode.games["jackpot"].jackpot = 5

    local gameLocation = GameMode:GetHammerEntityLocation("cookie_party_2_center")

    --spawn fatty
    jackpot:CreateFatty(gameLocation)

    Notifications:ClearBottomFromAll()
    Notifications:TopToAll({text="Ready..." , duration= 2, style={["font-size"] = "55px", color = "white"}})
    Timers:CreateTimer("start", {
        useGameTime = true,
        endTime = 2,
        callback = function()
            Notifications:TopToAll({text="START!" , duration= 5, style={["font-size"] = "55px", color = "red"}})

            --spawn players
            for playerID = 0, GameMode.maxNumPlayers-1 do
                if PlayerResource:IsValidPlayerID(playerID) then
                    if GameMode.players[playerID] ~= nil then
                        local hero = GameMode.players[playerID]
                        local randomizedGameLocation = Vector(gameLocation.x + math.random(-400, 400), gameLocation.y + math.random(-400, 400), gameLocation.z)
                        hero:SetRespawnPosition(randomizedGameLocation)
                        hero:RespawnHero(false, false)
                        GameMode:SetCamera(hero)
                        --set "cast" flag; it was set from casting during warm up
                        hero.cast = false
                        hero:AddNewModifier(nil, nil, "modifier_stunned", { duration = 2 })
                        --hero.playing = true
                        hero:AddNewModifier(nil, nil, "modifier_extra_mana", { extraMana = -800, regen = 0 })
                        hero:ReduceMana(200)
                        --remove all abilities; will get them when it's their turn
                        --GameMode:RemoveAllAbilities(hero)
                    end
                end
            end

            --run thinker
            jackpot:Think()
            return nil
        end
    })

end

function jackpot:AddTimeToPlayers()
    for playerID = 0, GameMode.maxNumPlayers - 1 do
        if GameMode.players[playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            local hero = GameMode.players[playerID]
            if hero:IsAlive() then
                --hero.time = hero.time + 0.06
                GameMode.games["jackpot"].players[playerID] = GameMode.games["jackpot"].players[playerID] + 0.06
            end
          end
        end
    end
end

--"cast" flag
--player casts "feed"
--after feeding
--if fatty's stack count is equal to the jackpot then
    --player wins
--else
    --if fatty's stack count is over the jackpot then
        --player busts
        --if only one player left then
            --remaining player wins
        --else
            --switch turns
    --if fatty's stack count is less than the jackpot then
        --switch turns


function jackpot:Rank()
    --something
end

function jackpot:Bust(hero)
    Notifications:BottomToAll({text = string.format("%s BUSTED!", hero.playerName), duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
    hero:ForceKill(false)
    GameMode.games["jackpot"].numAlive = GameMode.games["jackpot"].numAlive - 1
end

function jackpot:Finish(case)
    --clear all notifications
    Notifications:ClearBottomFromAll()
    local winner = GameMode.games["jackpot"].winner
    if case == "jackpot" then
        Notifications:BottomToAll({text = "JACKPOT!", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
        --kill remaining players
        for playerID = 0, GameMode.maxNumPlayers - 1 do
            if GameMode.players[playerID] ~= nil then
              if PlayerResource:IsValidPlayerID(playerID) then
                local hero = GameMode.players[playerID]
                if hero:IsAlive() and hero ~= GameMode.games["jackpot"].winner then
                    hero:ForceKill(false)
                end
              end
            end
        end
        --give extra score for hitting jackpot
        winner.earnedScore = winner.earnedScore + 2
    else
        --last one standing
        Notifications:BottomToAll({text = string.format("LAST MAN STANDING! %s", GameMode.players[winner:GetPlayerID()].playerName), duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
    end

    --extra second to make him rank first
    GameMode.games["jackpot"].players[winner:GetPlayerID()] = GameMode.games["jackpot"].players[winner:GetPlayerID()] + 1

    --rank
    jackpot:Rank()
    --call flowkeeper
    Timers:CreateTimer("end_game", {
        useGameTime = true,
        endTime = 5,
        callback = function()
            GameMode:FlowKeeper()
            return nil
        end
    })
end

function jackpot:Think()
    local finished = false
    local countdown = GameMode.games["jackpot"].countdown

    --set random player to start
    --jackpot:PickRandomPlayer()
    jackpot:SwitchTurn()

    --"cast" flag
    --player casts "feed"
    --after feeding
    --if fatty's stack count is equal to the jackpot then
        --player wins; earns rank 1
        --remaining players earn rank 2
    --else
        --if fatty's stack count is over the jackpot then
            --player busts
            --if only one player left then
                --remaining player wins
            --else
                --switch turns
        --if fatty's stack count is less than the jackpot then
            --switch turns

    --count score by timer
    --if you hit jackpot,
    --winning player gets a little more time

    --don't randomize jackpot every time
    --set it once per game

    --add countdown

    local pause_between_bust = 2
    Timers:CreateTimer("take_turns", {
        useGameTime = true,
        endTime = 1,
        callback = function()
            
            --if fatty is dead, the modifier is nil
            local cookie_eaten_modifier = GameMode.games["jackpot"].fatty:FindModifierByName("modifier_cookie_eaten")
            local fattySpawnLocation = GameMode:GetHammerEntityLocation("cookie_party_2_center")
            if cookie_eaten_modifier == nil then
                pause_between_bust = pause_between_bust - 0.06
                if pause_between_bust < 0 then
                    jackpot:CreateFatty(fattySpawnLocation)
                    jackpot:SwitchTurn()
                    pause_between_bust = 2
                end
                return 0.06
            end

            local hero = PlayerResource:GetSelectedHeroEntity(GameMode.games["jackpot"].turn)
            if hero.cast == false then
                --continue
                jackpot:AddTimeToPlayers()
                return 0.06
            elseif hero.cast == true then
                if cookie_eaten_modifier:GetStackCount() == GameMode.games["jackpot"].jackpot then
                    GameMode.games["jackpot"].fatty:ForceKill(false)
                    GameMode.games["jackpot"].winner = hero
                    jackpot:Finish("jackpot")
                    return nil
                elseif cookie_eaten_modifier:GetStackCount() > GameMode.games["jackpot"].jackpot then
                    jackpot:Bust(hero)
                    GameMode.games["jackpot"].fatty:ForceKill(false)
                    if GameMode.games["jackpot"].numAlive == 1 then
                        jackpot:SwitchTurn()
                        GameMode.games["jackpot"].winner = PlayerResource:GetSelectedHeroEntity(GameMode.games["jackpot"].turn)
                        jackpot:Finish("last_man_standing")
                        return nil
                    else
                        jackpot:AddTimeToPlayers()
                        --jackpot:CreateFatty(fattySpawnLocation)
                        --jackpot:SwitchTurn()
                        return 0.06
                    end
                else
                    jackpot:SwitchTurn()
                    jackpot:AddTimeToPlayers()
                    return 0.06
                end
            end
            --if guy is dead
            --wait 2 seconds
            --respawn guy and switch turn
            --else
            --switch turn
        end
    })


end


function jackpot:CreateFatty(location)
    --spawn fatty
    GameMode.games["jackpot"].fatty = CreateUnitByName("fatty", location, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.games["jackpot"].fatty:SetForwardVector(Vector(0, -1, 0))
    --GameMode.games["jackpot"].fatty:AddNewModifier(nil, nil, "modifier_cookie_eaten", { cookiesToBust = math.random(5, 12)})
    GameMode.games["jackpot"].fatty:AddNewModifier(nil, nil, "modifier_cookie_eaten", {})
    GameMode.games["jackpot"].fatty.scale = 2
    GameMode.games["jackpot"].fatty:SetModelScale(GameMode.games["jackpot"].fatty.scale)
    GameMode.games["jackpot"].fatty:SetDeathXP(0)
    GameMode:ShowScore(GameMode.games["jackpot"].fatty, 0, 9)
end


function jackpot:SwitchTurn()
    --remove abilities from previous turn
    local previousTurn = PlayerResource:GetSelectedHeroEntity(GameMode.games["jackpot"].turn)
    --remove effect
    ParticleManager:DestroyParticle( previousTurn.score_effect, true )

    GameMode.games["jackpot"].turn = GameMode.games["jackpot"].turn + 1
    if GameMode.games["jackpot"].turn == GameMode.maxNumPlayers then
        GameMode.games["jackpot"].turn = 0
    end
    while not PlayerResource:IsValidPlayerID(GameMode.games["jackpot"].turn) 
    or not PlayerResource:GetSelectedHeroEntity(GameMode.games["jackpot"].turn):IsAlive() do
        GameMode.games["jackpot"].turn = GameMode.games["jackpot"].turn + 1
        if GameMode.games["jackpot"].turn == GameMode.maxNumPlayers then
            GameMode.games["jackpot"].turn = 0
        end
    end
    --PlayerResource:GetSelectedHeroEntity and PlayerResource:GetPlayer return two different values
    local hero = PlayerResource:GetSelectedHeroEntity(GameMode.games["jackpot"].turn)

    --add effect
    GameMode:ShowScore(hero, -1, 4)

    --add all abilities for the turn
    --doesn't work; abilities don't always work as intended
    --alternative: take away mana from players, and add it to player whose turn it is
    --[[local feed_one_cookie = hero:AddAbility("feed_one_cookie")
    feed_one_cookie:SetLevel(1)
    local feed_two_cookies = hero:AddAbility("feed_two_cookies")
    feed_two_cookies:SetLevel(1)
    local feed_three_cookies = hero:AddAbility("feed_three_cookies")
    feed_three_cookies:SetLevel(1)]]

    --player doesn't get abilities

    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text = string.format("%s's turn", GameMode.players[hero:GetPlayerID()].playerName), duration= 20.0, style={["font-size"] = "45px", color = "white"}})
    --add abilities
    hero.cast = false
    hero:GiveMana(200)
    --reset countdown
    --GameMode.games["jackpot"].countdown = 0
end

function jackpot:Rank()
    local rank = 0
    --GameMode.games["mines"].players stores the times
    --local ranking = {}
    --go through list from left to right
    --if number is bigger than the next number, swap
    --else, continue
    --when reaching the end, start again from the left in the index + 1
  
  
  
    --if notification overflows, it stops displaying new messages
    --Notifications:ClearBottomFromAll()
    --order
    for k,v in GameMode:spairs(GameMode.games["jackpot"].players, function(t,a,b) return t[b] < t[a] end) do
        
        rank = rank + 1
        GameMode.games["jackpot"].ranking[rank] = k
        local hero = PlayerResource:GetSelectedHeroEntity(k)
        --Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank, hero.playerName, hero.time, hero.score), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        
    end
  
    local rankWithOverlap = 1
    local score = PlayerResource:NumPlayers()
  
    --order it again, this time with overlap in ranks
    local rankingWithOverlap = {}
    local tiedPlayers = {}
    local tiedPlayerCount = 0
    for rank, playerID in ipairs(GameMode.games["jackpot"].ranking) do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local nextHero
        if GameMode.games["jackpot"].ranking[rank+1] ~= nil then
            nextHero = PlayerResource:GetSelectedHeroEntity(GameMode.games["jackpot"].ranking[rank+1])
        end
        tiedPlayers[playerID] = hero
        if nextHero == nil then
            --Notifications:BottomToAll({text = "reached the end of rankingWithOverlap", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
            rankingWithOverlap[rankWithOverlap] = {}
            for tiedPlayerPlayerID, tiedPlayer in pairs(tiedPlayers) do
                rankingWithOverlap[rankWithOverlap][tiedPlayerPlayerID] = tiedPlayer
                --tiedPlayer.score = tiedPlayer.score + score
                tiedPlayer.earnedScore = tiedPlayer.earnedScore + score
                tiedPlayerCount = tiedPlayerCount + 1
            end
            rankWithOverlap = rankWithOverlap + tiedPlayerCount
            score = score - tiedPlayerCount
            tiedPlayers = {}
            tiedPlayerCount = 0
        elseif GameMode.games["jackpot"].players[hero:GetPlayerID()] ~= GameMode.games["jackpot"].players[nextHero:GetPlayerID()] then
            rankingWithOverlap[rankWithOverlap] = {}
            for tiedPlayerPlayerID, tiedPlayer in pairs(tiedPlayers) do
                rankingWithOverlap[rankWithOverlap][tiedPlayerPlayerID] = tiedPlayer
                --tiedPlayer.score = tiedPlayer.score + score
                tiedPlayer.earnedScore = tiedPlayer.earnedScore + score
                tiedPlayerCount = tiedPlayerCount + 1
            end
            rankWithOverlap = rankWithOverlap + tiedPlayerCount
            score = score - tiedPlayerCount
            tiedPlayers = {}
            tiedPlayerCount = 0
        else
            --continue
        end
    end

    --give extra score to the winner
    --GameMode.games["jackpot"].winner.earnedScore = GameMode.games["jackpot"].winner.earnedScore + 2
  
    --display
    --1, 2, 3, 4, 5
    --ipairs doesn't work if there are holes between the keys (e.g. 1, 3, 5)
    if GameMode.tieBreaker == false then
      for rank2, heroes in pairs(rankingWithOverlap) do
          --Notifications:BottomToAll({text = rank2, duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
          for playerID, hero in pairs(heroes) do
              --earned score is the score from the minigame
              Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank2, hero.playerName, GameMode.games["jackpot"].players[hero:GetPlayerID()], hero.earnedScore), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
              hero.score = hero.score + hero.earnedScore
          end
      end
    else
      --rankingWithOverlap[1] is a table
      --[[for playerID, hero in pairs(rankingWithOverlap[1]) do
          GameMode.overallWinner = hero
          break
      end]]
    end
  
    --finish game with tiebreaker
end