--three abilities: birdshot, buckshot, slug, cookie
--gauge on/off
  --double damage on shotguns; double damage on cookie; double distance and radius on cookie
  --knockback on shotgun
  --charges on scatterblast
--magic immune for first few seconds

shotgun_game = class({})

function shotgun_game:WarmUp()

  --set warm up flag
  GameMode.warmUp = true

    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text="SHOTGUN GAME" , duration= 20, style={["font-size"] = "45px", color = "orange"}})
    Notifications:BottomToAll({text="WARM UP: Test your abilities" , duration= 20, style={["font-size"] = "45px", color = "white"}})
    --spawn players
    --set up their abilities
    --explain the game
    
    --player table
    GameMode.games["shotgun_game"].players = {}
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
            --flag for checking dead
            hero.dead = false
            local birdshot_ability = hero:AddAbility("birdshot")
            birdshot_ability:SetLevel(1)
            local slug_ability = hero:AddAbility("slug")
            slug_ability:SetLevel(1)
            local load_ability = hero:AddAbility("load")
            load_ability:SetLevel(1)
            local empty_ability = hero:AddAbility("barebones_empty1")
            empty_ability:SetLevel(1)
            local empty_ability = hero:AddAbility("barebones_empty1")
            empty_ability:SetLevel(1)
            local cookie_ability = hero:AddAbility("cookie_shotgun")
            cookie_ability:SetLevel(1)
            local skipAbility = hero:AddAbility("skip")
            skipAbility:SetLevel(1)
            --score
            hero.time = 0
            hero.earnedScore = 0
            --offset index to account for lua counting indices from 1
            GameMode.games["shotgun"].players[playerID] = hero.time
            --remove particle
            ParticleManager:DestroyParticle( hero.score_effect, true )
          end
        end
    end
    shotgun:Rules()
    local counter = 20
    --start game in 20 seconds
    --unless everyone pressed "skip"
    Timers:CreateTimer("start_game", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            Notifications:ClearTopFromAll()
            Notifications:TopToAll({text=counter , duration= 1, style={["font-size"] = "45px", color = "white"}})
            if GameMode:CheckSkipForAllPlayers() or counter < 0 then
                shotgun:Start()
                GameMode:ResetSkipForAllPlayers()
                return nil
            else
                counter = counter - 1
                return 1
            end
        end
    })
end

function shotgun:Rules()
  --Notifications:BottomToAll({text="RULES" , duration= 20, style={["font-size"] = "45px", color = "white"}})
  Notifications:BottomToAll({text="Last man standing wins." , duration= 20, style={["font-size"] = "45px", color = "white"}})
  Notifications:BottomToAll({text="Q = scatterblast, W = AWP, E = power up, R = dodge" , duration= 20, style={["font-size"] = "35px", color = "white"}})
end

function shotgun:AddTimeToPlayers()
  for playerID = 0, GameMode.maxNumPlayers - 1 do
      if GameMode.players[playerID] ~= nil then
        if PlayerResource:IsValidPlayerID(playerID) then
          local hero = GameMode.players[playerID]
          if hero.dead == false then
              hero.time = hero.time + 0.06
          end
        end
      end
  end
end

function shotgun:Start()
  EmitGlobalSound("dont_like")
  GameMode.warmUp = false
  --kill all players
  --spawn
  for playerID = 0, GameMode.maxNumPlayers-1 do
      if PlayerResource:IsValidPlayerID(playerID) then
        if GameMode.players[playerID] ~= nil then
          local hero = GameMode.players[playerID]
          local gameLocation = GameMode:GetHammerEntityLocation("shotgun_center")
          local randomizedGameLocation = Vector(gameLocation.x + math.random(-400, 400), gameLocation.y + math.random(-400, 400), gameLocation.z)
          hero:SetRespawnPosition(randomizedGameLocation)
          hero:RespawnHero(false, false)
          GameMode:SetCamera(hero)
          hero:AddNewModifier(nil, nil, "modifier_invulnerable", { duration = 2 })
          
          --add abilities
          --[[GameMode:RemoveAllAbilities(GameMode.players[playerID])
          local cookie_no_damage_ability = GameMode.players[playerID]:AddAbility("cookie_no_damage")
          cookie_no_damage_ability:SetLevel(1)]]
        end
      end
  end

  Notifications:ClearBottomFromAll()
  Notifications:BottomToAll({text="Ready..." , duration= 1, style={["font-size"] = "45px", color = "white"}})
  Timers:CreateTimer("start", {
      useGameTime = true,
      endTime = 2,
      callback = function()
          Notifications:BottomToAll({text="START!" , duration= 1, style={["font-size"] = "45px", color = "red"}})
          --run thinker
          shotgun:Think()
          return nil
      end
  })
end



--points for most kills
function shotgun:Think()
  local finished = false
  local numAlive = 0
  local start = true
  Timers:CreateTimer("checkDead", {
    useGameTime = false,
    endTime = 0,
    callback = function()
      if not start then
        shotgun:AddTimeToPlayers()
      end
      for playerID = 0, GameMode.maxNumPlayers - 1 do
          if GameMode.players[playerID] ~= nil then
            if PlayerResource:IsValidPlayerID(playerID) then
              local hero = GameMode.players[playerID]
              if hero.dead == false then
                  if hero:IsAlive() == false then
                      Notifications:BottomToAll({text = string.format("%s is out!", hero.playerName), duration= 1.0, style={["font-size"] = "45px", color = "white"}}) 
                      --hero.score = hero.score + score
                      --hero.rank = rank
                      hero.dead = true
                      GameMode.games["shotgun"].players[playerID] = hero.time
                      --score = score + 1
                      --rank = rank - 1
                      --numDead = numDead + 1
                      --deadPlayers[playerID] = hero
                  else
                      numAlive = numAlive + 1
                  end
              end
            end
          end
      end

      --if more than one person left
      if numAlive > 1 then 
          --continue
          start = false
          numAlive = 0
          return 0.06
      --if one left
      else
          --find the player that's alive
          for playerID = 0, GameMode.maxNumPlayers - 1 do
              if GameMode.players[playerID] ~= nil then
                if PlayerResource:IsValidPlayerID(playerID) then
                  local hero = GameMode.players[playerID]
                  if hero.dead == false then
                      --increase it slightly to make it more than that of the player who just died
                      hero.time = hero.time + 1
                      GameMode.games["shotgun"].players[playerID] = hero.time
                      --GameMode.games["mines"].topTime = hero.time
                  end
                  hero:ForceKill(false)
                end
              end
          end
          --"finished!"
          --display ranking
          --end game
          Notifications:BottomToAll({text = "Finished!", duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
          finished = true
          shotgun:Rank()
          Timers:CreateTimer("end_game", {
              useGameTime = true,
              endTime = 5,
              callback = function()
                  GameMode:FlowKeeper()
                  return nil
              end
          })
          return nil
      end
    end
  })
end
  
--[[function GameMode:ShotgunThinker()

  Timers:CreateTimer("checkDead", {
    useGameTime = false,
    endTime = 0,
    callback = function()
      local numAlive = 0
      local winner = {}
      --count how many dead
      for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
          for playerID = 0, GameMode.maxNumPlayers-1 do
            if GameMode.teams[teamNumber][playerID] ~= nil then
              if PlayerResource:IsValidPlayerID(playerID) then
                local heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
                if heroEntity:IsAlive() then
                  numAlive = numAlive + 1
                  --winner[playerID + 1] = heroEntity
                end
              end
            end
          end
        end
      end
      --if one player remaining, he's the winner
      if numAlive == 1 then
        print("shotgun ended")
        --assign score
        for teamNumber = 6, 13 do
          if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
              if PlayerResource:IsValidPlayerID(playerID) then
                if GameMode.teams[teamNumber][playerID] ~= nil then
                  local heroEntity = GameMode.teams[teamNumber][playerID]
                  if heroEntity:IsAlive() then
                    --declare winner
                    Notifications:BottomToAll({text = "Winner! ", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
                    Notifications:BottomToAll({text = GameMode.teamNames[teamNumber], duration= 5.0, style={["font-size"] = "45px", color = GameMode.teamColors[teamNumber]}, continue=true})
                    GameMode.teams[teamNumber].score = GameMode.teams[teamNumber].score + 1
                  end
                end
              end
            end
          end
        end
        GameMode:EndGame()
        return nil
      end
      return 0.06
    end
  })
end]]

function shotgun:Rank()
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
  for k,v in GameMode:spairs(GameMode.games["shotgun"].players, function(t,a,b) return t[b] < t[a] end) do
      
      rank = rank + 1
      GameMode.games["shotgun"].ranking[rank] = k
      local hero = PlayerResource:GetSelectedHeroEntity(k)
      --Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank, hero.playerName, hero.time, hero.score), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
      
  end

  local rankWithOverlap = 1
  local score = PlayerResource:NumPlayers()



  --order it again, this time with overlap in ranks
  local rankingWithOverlap = {}
  local tiedPlayers = {}
  local tiedPlayerCount = 0
  for rank, playerID in ipairs(GameMode.games["shotgun"].ranking) do
      local hero = PlayerResource:GetSelectedHeroEntity(playerID)
      local nextHero
      if GameMode.games["shotgun"].ranking[rank+1] ~= nil then
          nextHero = PlayerResource:GetSelectedHeroEntity(GameMode.games["shotgun"].ranking[rank+1])
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
      elseif hero.time ~= nextHero.time then
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
            Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank2, hero.playerName, hero.time, hero.earnedScore), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        end
    end
  else
    --rankingWithOverlap[1] is a table
    for playerID, hero in pairs(rankingWithOverlap[1]) do
        GameMode.overallWinner = hero
        break
    end
  end

  --finish game with tiebreaker
end