
  --count how many winners there are
  --[[local lengthOfWinners = 0
  for _, winner in pairs(winners) do
    lengthOfWinners = lengthOfWinners + 1
  end]]








  --GameMode.games[gameName].active = false



  --give point to the winner
  --find winner
  --kill everyone
  --return them back to the warm up stage
  --print("[GameMode:EndGame(winners, gameName)] winners length: " .. #winners) -- 0
  --because playerID was 0, even though there was an element in the table, the length was 0
  --[[print("[GameMode:EndGame(winners, gameName)] winners length: " .. #winners)
  print("[GameMode:EndGame(winners, gameName)] winners: ")
  PrintTable(winners)]]



  --clear all flags
  --win related
  --for all conditions
  --[[for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID  = 0, GameMode.maxNumPlayers do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          if gameName == "frogger" then
            GameMode.teams[teamNumber][playerID].hero.froggerActive = false
          end
        end
      end
    end
  end]]




  --[[if lengthOfWinners == 0 then
    Notifications:BottomToAll({text="LOSERS!", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
    for teamNumber = 6, 13 do
      if GameMode.teams[teamNumber] ~= nil then
        for playerID  = 0, GameMode.maxNumPlayers do
          if GameMode.teams[teamNumber][playerID] ~= nil then
            --only difference between losers and winners is the score giving
          end
        end
      end
    end
  else
    for _, winner in pairs(winners) do
      Notifications:BottomToAll({text=string.format("WINNER! %s", PlayerResource:GetPlayerName(winner:GetPlayerID())), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
      for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
          for playerID  = 0, GameMode.maxNumPlayers do
            if GameMode.teams[teamNumber][playerID] ~= nil then
              if GameMode.teams[teamNumber][playerID] == winner then
                GameMode.teams[teamNumber].score = GameMode.teams[teamNumber].score + 1
              end
            end
          end
        end
      end
    end
  end

  --revert players to their original condition
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID  = 0, GameMode.maxNumPlayers do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          local heroEntity = GameMode.teams[teamNumber][playerID]
          --stat
          --move speed
          heroEntity:SetBaseMoveSpeed(400)
            --mana
            --health
            --magic resistance
            --base strength

          --for cookie duo, morty, battleship and feederAndEater
          



          --order of killing and switching heroes
          heroEntity:ForceKill(false)

          local start_center_ent = Entities:FindByName(nil, "start_center")
          local start_center_ent_vector = start_center_ent:GetAbsOrigin()
          heroEntity:SetRespawnPosition(start_center_ent_vector)
          GameMode:Restore(heroEntity)

          --for cookieDuo, return heroes to snap
          --return after respawning; no need to set team
          if gameName == "cookieDuo" or gameName == "feederAndEater2" then
            --local originalTeam = heroEntity.originalTeam
            PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_snapfire", PlayerResource:GetGold(playerID), 0)
            --heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
            --GameMode.teams[teamNumber][playerID].hero = heroEntity
            --heroEntity:SetTeam(originalTeam)
          end

          --abilities
          GameMode:RemoveAllAbilities(heroEntity)
          GameMode:AddAllOriginalAbilities(heroEntity)
          --items
          GameMode:RemoveAllItems(heroEntity)
          --GameMode:AddAllOriginalItems(GameMode.teams[teamNumber][playerID].hero)
          GameMode.teams[teamNumber][playerID].minigameActive = false
          --set camera
          PlayerResource:SetCameraTarget(playerID, heroEntity)
          Timers:CreateTimer({
            endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()            
              PlayerResource:SetCameraTarget(playerID, nil)
            end
          })

          --attack capability
          heroEntity:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
        end
      end
    end
  end]]