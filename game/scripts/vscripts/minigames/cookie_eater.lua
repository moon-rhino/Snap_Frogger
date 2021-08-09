LinkLuaModifier("modifier_ai_big_cookie", "libraries/modifiers/modifier_ai_big_cookie", LUA_MODIFIER_MOTION_NONE)

cookie_eater = class({})

function cookie_eater:WarmUp()
    --button mash
    --spawn players on the map
    --spawn a cookie in the center
    --press ability to eat it
    --decrease cookie size by small amount
    --when cookie is gone, spring cookies everywhere
    --players must run around to eat them for 10 seconds
    --cast same ability to eat
    --player with most points wins
    GameMode.warmUp = true
    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text="COOKIE EATER" , duration= 20, style={["font-size"] = "45px", color = "orange"}})
    Notifications:BottomToAll({text="WARM UP: Test your abilities" , duration= 20, style={["font-size"] = "45px", color = "white"}})
    GameMode.games["cookie_eater"].players = {}

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
            local cookie_ability = hero:AddAbility("eat_cookie")
            cookie_ability:SetLevel(1)
            local skipAbility = hero:AddAbility("skip")
            skipAbility:SetLevel(1)
            --score
            hero.cookiesEaten = 0
            hero.earnedScore = 0
            GameMode.games["cookie_eater"].players[playerID] = hero.cookiesEaten
            --remove particle
            ParticleManager:DestroyParticle( hero.score_effect, true )
          end
        end
    end

    --lay out some cookies to test
    for testCookieIndex = 1, 20 do
        local warmUpLocation = GameMode:GetHammerEntityLocation("warm_up_center")
        local warmUpLocationRandomized = Vector(warmUpLocation.x + math.random(-400, 400), warmUpLocation.y + math.random(-400, 400), warmUpLocation.z)
        GameMode.games["cookie_eater"].testCookies[testCookieIndex] = CreateUnitByName("cookie_test", warmUpLocationRandomized, true, nil, nil, DOTA_TEAM_GOODGUYS)
    end

    --rules
    cookie_eater:Rules()

    --Warm up timer
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
                cookie_eater:Start()
                GameMode:ResetSkipForAllPlayers()
                return nil
            else
                counter = counter - 1
                return 1
            end
        end
    })

end

function cookie_eater:Rules()
    Notifications:BottomToAll({text="Press Q to take a bite" , duration= 20, style={["font-size"] = "45px", color = "white"}})
    Notifications:BottomToAll({text="Whoever eats the most will win" , duration= 20, style={["font-size"] = "45px", color = "white"}})
end

function cookie_eater:Start()
    --sound
    GameMode.warmUp = false

    --spawn players
    for playerID = 0, GameMode.maxNumPlayers-1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            if GameMode.players[playerID] ~= nil then
                local hero = GameMode.players[playerID]

                local radius = 600

                local angleSpawn = math.rad(math.random(1, 360))
            
                local cookiePartyCenter = GameMode:GetHammerEntityLocation("cookie_party_2_center")
                local spawnLocation = Vector(cookiePartyCenter.x + math.cos(angleSpawn) * radius, 
                                            cookiePartyCenter.y + math.sin(angleSpawn) * radius, 
                                            cookiePartyCenter.z)
          

                --local randomizedGameLocation = Vector(gameLocation.x + math.random(-400, 400), gameLocation.y + math.random(-400, 400), gameLocation.z)
                --hero:SetRespawnPosition(randomizedGameLocation)
                hero:SetRespawnPosition(spawnLocation)
                hero:RespawnHero(false, false)
                GameMode:SetCamera(hero)
                --hero:AddNewModifier(nil, nil, "modifier_invulnerable", { duration = 2 })
            end
        end
    end

    --spawn cookie
    local bigCookieLocation = GameMode:GetHammerEntityLocation("cookie_party_2_center")
    GameMode.games["cookie_eater"].bigCookie = CreateUnitByName("cookie_big", bigCookieLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    GameMode.games["cookie_eater"].bigCookie:AddNewModifier(nil, nil, "modifier_attack_immune", {})
    GameMode.games["cookie_eater"].bigCookie:AddNewModifier(nil, nil, "modifier_magic_immune", {duration = 2})
    GameMode.games["cookie_eater"].bigCookie:SetHullRadius(500)
    GameMode.games["cookie_eater"].bigCookie:SetModelScale(2+0.4*PlayerResource:NumPlayers())
    GameMode.games["cookie_eater"].bigCookie:AddNewModifier(nil, nil, "modifier_ai_big_cookie", {})
    --if cookie reaches a certain size or time expires
        --cookie explodes into smaller cookies
        --set timer for 10 seconds

    --burp
    --grow bigger with each bite
    --explode on main one after it's gone

    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text="Ready..." , duration= 2, style={["font-size"] = "45px", color = "white"}})
    Timers:CreateTimer("start", {
        useGameTime = true,
        endTime = 2,
        callback = function()
            Notifications:BottomToAll({text="START!" , duration= 1, style={["font-size"] = "45px", color = "red"}})
            --run thinker
            cookie_eater:ThinkPhaseOne()
            return nil
        end
    })
end

function cookie_eater:ThinkPhaseOne()
    GameMode.games["cookie_eater"].finishedInitial = false
    local countdown = GameMode.games["cookie_eater"].lengthInitial
    Timers:CreateTimer("thinker_phase_one", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            --if it's below threshold then
                --end phase one
            --else
                --decrement count
                --continue
            if GameMode.games["cookie_eater"].finishedInitial == false then
                --check cookie's size
                if GameMode.games["cookie_eater"].bigCookie:GetModelScale() < 1.5 or countdown < 0 then
                    Notifications:TopToAll({text = "COOKIE BURST!", duration= 3.0, style={["font-size"] = "45px", color = "red"}}) 
                    GameMode.games["cookie_eater"].finishedInitial = true
                    return 1
                else
                    Notifications:TopToAll({text = countdown, duration= 1.0, style={["font-size"] = "45px", color = "white"}}) 
                    countdown = countdown - 1
                    return 1
                end
            else
                cookie_eater:ThinkPhaseTwo()
                return nil
            end
        end
    })
end

function cookie_eater:ThinkPhaseTwo()
    --local finished = false
    --local countdown = GameMode.games["cookie_eater"].lengthEnd
    Timers:CreateTimer("thinker_phase_two", {
        useGameTime = true,
        endTime = GameMode.games["cookie_eater"].lengthEnd,
        callback = function()
            Notifications:BottomToAll({text = "Finished!", duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
            --record score for all players
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.players[playerID] ~= nil then
                    if PlayerResource:IsValidPlayerID(playerID) then
                    local hero = GameMode.players[playerID]
                    cookie_eater:TakeScore(hero)
                    end
                end
            end
            cookie_eater:Rank()
            Timers:CreateTimer("end_game", {
                useGameTime = true,
                endTime = 5,
                callback = function()

                    GameMode:FlowKeeper()
                    return nil
                end
            })
        end
    })
end

function cookie_eater:TakeScore(hero)
    GameMode.games["cookie_eater"].players[hero:GetPlayerID()] = hero.cookiesEaten
end

function cookie_eater:Rank()
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
    for k,v in GameMode:spairs(GameMode.games["cookie_eater"].players, function(t,a,b) return t[b] < t[a] end) do
        
        rank = rank + 1
        GameMode.games["cookie_eater"].ranking[rank] = k
        local hero = PlayerResource:GetSelectedHeroEntity(k)
        --Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank, hero.playerName, hero.time, hero.score), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        
    end
  
    local rankWithOverlap = 1
    local score = PlayerResource:NumPlayers()
  
  
  
    --order it again, this time with overlap in ranks
    local rankingWithOverlap = {}
    local tiedPlayers = {}
    local tiedPlayerCount = 0
    for rank, playerID in ipairs(GameMode.games["cookie_eater"].ranking) do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local nextHero
        if GameMode.games["cookie_eater"].ranking[rank+1] ~= nil then
            nextHero = PlayerResource:GetSelectedHeroEntity(GameMode.games["cookie_eater"].ranking[rank+1])
        end
        tiedPlayers[playerID] = hero
        if nextHero == nil then
            --Notifications:BottomToAll({text = "reached the end of rankingWithOverlap", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
            rankingWithOverlap[rankWithOverlap] = {}
            for tiedPlayerPlayerID, tiedPlayer in pairs(tiedPlayers) do
                rankingWithOverlap[rankWithOverlap][tiedPlayerPlayerID] = tiedPlayer
                tiedPlayer.score = tiedPlayer.score + score
                tiedPlayer.earnedScore = score
                tiedPlayerCount = tiedPlayerCount + 1
            end
            rankWithOverlap = rankWithOverlap + tiedPlayerCount
            score = score - tiedPlayerCount
            tiedPlayers = {}
            tiedPlayerCount = 0
        --this is where the score for the specific game comes in
        elseif hero.cookiesEaten ~= nextHero.cookiesEaten then
            rankingWithOverlap[rankWithOverlap] = {}
            for tiedPlayerPlayerID, tiedPlayer in pairs(tiedPlayers) do
                rankingWithOverlap[rankWithOverlap][tiedPlayerPlayerID] = tiedPlayer
                tiedPlayer.score = tiedPlayer.score + score
                tiedPlayer.earnedScore = score
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
  
    --display
    --1, 2, 3, 4, 5
    --ipairs doesn't work if there are holes between the keys (e.g. 1, 3, 5)
    if GameMode.tieBreaker == false then
      for rank2, heroes in pairs(rankingWithOverlap) do
          --Notifications:BottomToAll({text = rank2, duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
          for playerID, hero in pairs(heroes) do
              --this is where the score for the specific game comes in
              Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank2, hero.playerName, hero.cookiesEaten, hero.earnedScore), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
          end
      end
    end
end



    --pushback: protect the oven
    --someone in the front line to create space
    --attack from only one direction