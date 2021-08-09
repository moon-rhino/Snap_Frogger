cookie_party_2 = class({})

--shoot cookies to yourself or others
--stun a player to score a point
--the one with the highest score wins
--if anyone goes out of bounds, kill him and spawn him back in the center
--time limit = 60 seconds

function cookie_party_2:WarmUp()
    GameMode.warmUp = true
    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text="COOKIE PARTY 2" , duration= 20, style={["font-size"] = "45px", color = "orange"}})
    Notifications:BottomToAll({text="WARM UP: Test your abilities" , duration= 20, style={["font-size"] = "45px", color = "white"}})
    GameMode.games["cookie_party_2"].players = {}
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
            local cookie_ability = hero:AddAbility("cookie_base_cookie_party_2")
            cookie_ability:SetLevel(1)
            --replace with "ready"
            local skipAbility = hero:AddAbility("skip")
            skipAbility:SetLevel(1)
            --score
            hero.targetsHit = 0
            hero.earnedScore = 0
            GameMode.games["cookie_party_2"].players[playerID] = hero.targetsHit
            --remove particle
            ParticleManager:DestroyParticle( hero.score_effect, true )
          end
        end
    end
    cookie_party_2:Rules()
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
                cookie_party_2:Start()
                GameMode:ResetSkipForAllPlayers()
                return nil
            else
                counter = counter - 1
                return 1
            end
        end
    })
end

function cookie_party_2:Rules()
    --Notifications:BottomToAll({text="RULES" , duration= 20, style={["font-size"] = "45px", color = "white"}})
    Notifications:BottomToAll({text="Jump on other players." , duration= 20, style={["font-size"] = "45px", color = "white"}})
    Notifications:BottomToAll({text="If you die, you will respawn" , duration= 20, style={["font-size"] = "35px", color = "white"}})
end

--score = number of enemies hit
--add "ability" flag in "cookie base"
--respawn think
--at the end, count score

function cookie_party_2:Start()
    --sound
    GameMode.warmUp = false
    --display scoreboard
    --[[local player = PlayerResource:GetPlayer(0)
    if player ~= nil then
      CustomGameEventManager:Send_ServerToPlayer(player, "pick_game", {})
    end]]

    --spawn
    for playerID = 0, GameMode.maxNumPlayers-1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            if GameMode.players[playerID] ~= nil then
                local hero = GameMode.players[playerID]
                local gameLocation = GameMode:GetHammerEntityLocation("cookie_party_center")
                local randomizedGameLocation = Vector(gameLocation.x + math.random(-400, 400), gameLocation.y + math.random(-400, 400), gameLocation.z)
                hero:SetRespawnPosition(randomizedGameLocation)
                hero:RespawnHero(false, false)
                GameMode:SetCamera(hero)
                hero:AddNewModifier(nil, nil, "modifier_invulnerable", { duration = 2 })
                
            end
        end
    end

    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text="Ready..." , duration= 2, style={["font-size"] = "45px", color = "white"}})
    Timers:CreateTimer("start", {
        useGameTime = true,
        endTime = 2,
        callback = function()
            Notifications:BottomToAll({text="START!" , duration= 1, style={["font-size"] = "45px", color = "red"}})
            --run thinker
            cookie_party_2:Think()
            return nil
        end
    })
end

function cookie_party_2:Think()
    local finished = false
    local countdown = GameMode.games["cookie_party_2"].length
    Timers:CreateTimer("checkDead", {
        useGameTime = false,
        endTime = 0,
        callback = function()
            if finished then
                return nil
            else
                for playerID = 0, GameMode.maxNumPlayers - 1 do
                    if GameMode.players[playerID] ~= nil then
                        if PlayerResource:IsValidPlayerID(playerID) then
                            local hero = GameMode.players[playerID]
                            if hero:IsAlive() == false then
                                --respawn
                                local gameLocation = GameMode:GetHammerEntityLocation("cookie_party_center")
                                local randomizedGameLocation = Vector(gameLocation.x + math.random(-400, 400), gameLocation.y + math.random(-400, 400), gameLocation.z)
                                hero:SetRespawnPosition(randomizedGameLocation)
                                hero:RespawnHero(false, false)
                                GameMode:SetCamera(hero)
                                --spawn buff
                                hero:AddNewModifier(nil, nil, "modifier_invulnerable", { duration = 1 })
                            end
                        end
                    end
                end
                Notifications:TopToAll({text = countdown, duration= 1.0, style={["font-size"] = "45px", color = "white"}}) 
                countdown = countdown - 1
                return 1
            end
        end
    })

    
    Timers:CreateTimer("end_game", {
        useGameTime = true,
        endTime = GameMode.games["cookie_party_2"].length,
        callback = function()
            finished = true
            Notifications:BottomToAll({text = "Finished!", duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
            --record scores
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.players[playerID] ~= nil then
                  if PlayerResource:IsValidPlayerID(playerID) then
                    local hero = GameMode.players[playerID]
                    GameMode.games["cookie_party_2"].players[playerID] = hero.targetsHit
                  end
                end
            end
            cookie_party_2:Rank()
            Timers:CreateTimer("end_game_2", {
                useGameTime = true,
                endTime = 5,
                callback = function()
                    GameMode:FlowKeeper()
                    return nil
                end
            })
            return nil
        end
    })
end

function cookie_party_2:Rank()
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
    for k,v in GameMode:spairs(GameMode.games["cookie_party_2"].players, function(t,a,b) return t[b] < t[a] end) do
        
        rank = rank + 1
        GameMode.games["cookie_party_2"].ranking[rank] = k
        local hero = PlayerResource:GetSelectedHeroEntity(k)
        --Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank, hero.playerName, hero.time, hero.score), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        
    end
  
    local rankWithOverlap = 1
    local score = PlayerResource:NumPlayers()
  
  
  
    --order it again, this time with overlap in ranks
    local rankingWithOverlap = {}
    local tiedPlayers = {}
    local tiedPlayerCount = 0
    for rank, playerID in ipairs(GameMode.games["cookie_party_2"].ranking) do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local nextHero
        if GameMode.games["cookie_party_2"].ranking[rank+1] ~= nil then
            nextHero = PlayerResource:GetSelectedHeroEntity(GameMode.games["cookie_party_2"].ranking[rank+1])
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
        elseif hero.targetsHit ~= nextHero.targetsHit then
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
              Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank2, hero.playerName, hero.targetsHit, hero.earnedScore), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
          end
      end
    else
      --rankingWithOverlap[1] is a table
      for playerID, hero in pairs(rankingWithOverlap[1]) do
          GameMode.overallWinner = hero
          break
      end
    end
    --rankingWithOverlap[1] is a table
    --[[for playerID, hero in pairs(rankingWithOverlap[1]) do
        GameMode.overallWinner = hero
        break
    end]]
  
end