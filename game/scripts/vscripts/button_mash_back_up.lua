--[[ --game specific ability
  --after 15 seconds
  --record players' health
  --one with the most wins
  --spawn
  --face center
    PlayerResource:SetCameraTarget(playerID, heroEntity)
    Timers:CreateTimer({
      endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
      callback = function()            
        PlayerResource:SetCameraTarget(playerID, nil)
      end
    })
    local spawn_ent = Entities:FindByName(nil, string.format("mash_spawn_%s", playerID+1))
    local spawn_ent_vector = spawn_ent:GetAbsOrigin()
    heroEntity:SetRespawnPosition(spawn_ent_vector)
    GameMode:Restore(heroEntity)
    local mash_center_ent = Entities:FindByName(nil, "mash_center")
    local mash_center_ent_vector = mash_center_ent:GetAbsOrigin()
    local forwardVector = mash_center_ent_vector - spawn_ent_vector
    forwardVector = forwardVector:Normalized()
    heroEntity:SetForwardVector(forwardVector)

    --stat changes
    --heroEntity:SetBaseMagicalResistanceValue(0)
    --heroEntity:SetBaseStrength(0)
    --abilities
    GameMode:RemoveAllAbilities(heroEntity)
    heroEntity:AddAbility("snapfire_scatterblast_button_mash")
    local abil = heroEntity:GetAbilityByIndex(0)
    abil:SetLevel(1)
    --items
    GameMode:RemoveAllItems(heroEntity)
    --modifiers
    heroEntity:AddNewModifier(nil, nil, "modifier_extra_health_morty", { extraHealth = 50000 * PlayerResource:NumPlayers() })
    heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
    heroEntity:AddNewModifier(nil, nil, "modifier_attack_immune", {})
    heroEntity:Heal(300000, nil)
    
    print("[GameMode:Mash()] playerID: " .. playerID)
    print("[GameMode:Mash()] teamNumber: " .. teamNumber)
    PrintTable(heroEntity)
              
  
    -----------------------------------------------------
    -- game logic
  
    --record everyone's damage
    --19 seconds later (15 + 4 stun duration)
    --record everyone's damage against each other
    Timers:CreateTimer({
      endTime = 19, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
      callback = function()
        --EmitGlobalSound("duel_end")
        --rank by damage dealt in this game
        local damageList = {}
        local damageRanking = {}
        for teamNumber = 6, 13 do
          if GameMode.teams[teamNumber] ~= nil then
            for playerID = 0, GameMode.maxNumPlayers - 1 do
              if GameMode.teams[teamNumber][playerID] ~= nil then
                local playerDamageDoneTotal = 0
                local playerDamageDonePrev = 0 
                local playerDamageDoneThisRound = 0
                playerDamageDonePrev = GameMode.teams[teamNumber][playerID].totalDamageDealt
                --calculate the damage dealt for every team against each other
                --damage dealt for pregame
                for victimTeamNumber = 6, 13 do
                    if GameMode.teams[victimTeamNumber] ~= nil then
                        if victimTeamNumber == teamNumber then goto continue
                        else
                            for victimID = 0, GameMode.maxNumPlayers do
                                if GameMode.teams[victimTeamNumber][victimID] ~= nil then
                                    playerDamageDoneTotal = playerDamageDoneTotal + PlayerResource:GetDamageDoneToHero(playerID, victimID)
                                end
                            end
                        end
                        ::continue::
                    end
                end
                playerDamageDoneThisRound = playerDamageDoneTotal - playerDamageDonePrev
                damageList[playerID] = playerDamageDoneThisRound
              end
            end    
          end
        end]]
  
        --save the top damage
        --if there's other entries with the same value, give them scores too
        -- this uses a custom sorting function ordering by damageDone, descending
--[[       local rank = 1
        for k,v in GameMode:spairs(damageList, function(t,a,b) return t[b] < t[a] end) do
            damageRanking[rank] = k 
            rank = rank + 1
        end]]
        --local topDamage = damageList[damageRanking[1]]
--[[        local winningPlayerID
        for playerID = 0, GameMode.maxNumPlayers - 1 do
          if damageList[playerID] == topDamage then
            local winner = {}
            --it doesn't matter what you put in the key
            winner[1] = GameMode.teams[PlayerResource:GetTeam(playerID)][playerID].hero
            GameMode:EndGame(winner, "mash")
          end
        end
      end
    })
  
    --set up
    --record how much damage was dealt before 
    for teamNumber = 6, 13 do
      if GameMode.teams[teamNumber] ~= nil then
        GameMode.numTeams = GameMode.numTeams + 1
        local teamDamageDoneTotal = 0
        for playerID = 0, GameMode.maxNumPlayers do
          if GameMode.teams[teamNumber][playerID] ~= nil then
            print("[GameMode:OnAllPlayersLoaded] playerID: " .. playerID)
            local playerDamageDoneTotal = 0
            for victimTeamNumber = 6, 13 do
              if GameMode.teams[victimTeamNumber] ~= nil then
                print("[GameMode:OnAllPlayersLoaded] victimTeamNumber: " .. victimTeamNumber)
                if victimTeamNumber == teamNumber then goto continue
                else
                  for victimID = 0, 7 do
                    if GameMode.teams[victimTeamNumber][victimID] ~= nil then
                      print("[GameMode:OnAllPlayersLoaded] victimID: " .. victimID)
                      playerDamageDoneTotal = playerDamageDoneTotal + PlayerResource:GetDamageDoneToHero(playerID, victimID)
                    end
                  end
                end
                ::continue::
              end
            end
            GameMode.teams[teamNumber][playerID].totalDamageDealt = playerDamageDoneTotal
            teamDamageDoneTotal = teamDamageDoneTotal + playerDamageDoneTotal
          end
        end
        GameMode.teams[teamNumber].totalDamageDealt = teamDamageDoneTotal
      end
    end
    
    --add custom scatterblast ability
    --on end game, remove all abilities and add original ones
  
    --spawn everyone
    --remove their items
  
    for teamNumber = 6, 13 do
      if GameMode.teams[teamNumber] ~= nil then
        for playerID = 0, GameMode.maxNumPlayers-1 do
          if GameMode.teams[teamNumber][playerID] ~= nil then
            if PlayerResource:IsValidPlayerID(playerID) then
              heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
              for itemIndex = 0, 10 do
                if heroEntity:GetItemInSlot(itemIndex) ~= nil then
                  heroEntity:RemoveItem(heroEntity:GetItemInSlot(itemIndex))
                end
              end
              --spawn
              --face center
              PlayerResource:SetCameraTarget(playerID, heroEntity)
              Timers:CreateTimer({
                endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                callback = function()            
                  PlayerResource:SetCameraTarget(playerID, nil)
                end
              })
              local spawn_ent = Entities:FindByName(nil, string.format("mash_spawn_%s", playerID+1))
              local spawn_ent_vector = spawn_ent:GetAbsOrigin()
              heroEntity:SetRespawnPosition(spawn_ent_vector)
              GameMode:Restore(heroEntity)
              local mash_center_ent = Entities:FindByName(nil, "mash_center")
              local mash_center_ent_vector = mash_center_ent:GetAbsOrigin()
              local forwardVector = mash_center_ent_vector - spawn_ent_vector
              forwardVector = forwardVector:Normalized()
              heroEntity:SetForwardVector(forwardVector)
  
              --stat changes
              --heroEntity:SetBaseMagicalResistanceValue(0)
              --heroEntity:SetBaseStrength(0)
              --abilities
              GameMode:RemoveAllAbilities(heroEntity)
              heroEntity:AddAbility("snapfire_scatterblast_button_mash")
              local abil = heroEntity:GetAbilityByIndex(0)
              abil:SetLevel(1)
              --items
              GameMode:RemoveAllItems(heroEntity)
              --modifiers
              heroEntity:AddNewModifier(nil, nil, "modifier_extra_health_morty", { extraHealth = 50000 * PlayerResource:NumPlayers() })
              heroEntity:AddNewModifier(nil, nil, "modifier_stunned", { duration = 4})
              heroEntity:AddNewModifier(nil, nil, "modifier_attack_immune", {})
              heroEntity:Heal(300000, nil)
              
              print("[GameMode:Mash()] playerID: " .. playerID)
              print("[GameMode:Mash()] teamNumber: " .. teamNumber)
              PrintTable(heroEntity)
              
            end
          end
        end
      end
    end
  end
end]]