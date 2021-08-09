--gameplay
  --set damage to 1
  --set players facing each other, very close
--bug
  --one of the players end stun early and don't retain the extra health modifier

function GameMode:ButtonMash() 
  Notifications:BottomToAll({text = "Button Mash", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  Notifications:BottomToAll({text = "QQQQQQQQQQQQQ", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  
  --randomized start time
  local tMinus = RandomFloat(3, 4)

  --for emitting starting sound
  local centerEnt
  local centerPt

  --song
  EmitGlobalSound("rap_god")

  --spawn players
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers-1 do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            local heroEntity = GameMode.teams[teamNumber][playerID]
            heroEntity:ForceKill(false)
            --flag for player
            --GameMode.teams[teamNumber][playerID].minigameActive = true
            --GameMode.teams[teamNumber][playerID].hero.froggerActive = true
            --when a player dies, respawn back at the start
            local mashEnt = Entities:FindByName(nil, string.format("mash_spawn_%s", playerID + 1))
            local mashEntVector = mashEnt:GetAbsOrigin()
            --to remember where to spawn when the player is dead
            heroEntity.respawnPosition = mashEntVector
            GameMode.teams[teamNumber][playerID]:SetRespawnPosition(mashEntVector)
            heroEntity:RespawnHero(false, false)
            --set hero to face the center
            centerEnt = Entities:FindByName(nil, "mash_center")
            centerPt = centerEnt:GetAbsOrigin()
            local heroEntityPt = heroEntity:GetAbsOrigin()
            local direction = centerPt - heroEntityPt
            direction = direction:Normalized()
            heroEntity:SetForwardVector(direction)
            
            --items
            --GameMode:RemoveAllItems(heroEntity)

            --abilities
            --remove all abilities
            --GameMode:RemoveAllAbilities(heroEntity)
            --add specific abilities
            local scatterblast = heroEntity:AddAbility("scatterblast_button_mash")
            scatterblast:SetLevel(1)

            --set camera
            GameMode:SetCamera(heroEntity)

            --stop movement to prevent turning
            heroEntity:Stop()

            --modifiers
            heroEntity:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
            heroEntity:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
            heroEntity:AddNewModifier(nil, nil, "modifier_extra_health_morty", {extraHealth = 100000})
            heroEntity:SetModelScale(0.5)

          end
        end
      end
    end
  end

  --randomized start
  for teamNumber = 6, 13 do
    if GameMode.teams[teamNumber] ~= nil then
      for playerID = 0, GameMode.maxNumPlayers-1 do
        if GameMode.teams[teamNumber][playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            local heroEntity = GameMode.teams[teamNumber][playerID]
            heroEntity:AddNewModifier(nil, nil, "modifier_stunned", {duration = tMinus})
          end
        end
      end
    end
  end

  --notify the start
  Timers:CreateTimer({
    endTime = tMinus, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      centerEnt:EmitSound("starter_gun")
    end
  })

  --thinker
  GameMode:ButtonMashThinker()
end

function GameMode:ButtonMashThinker()
  --end game after 20 seconds
  --must use a timer with a unique string; the one without a name will not overlap with any other timer without a name
  Timers:CreateTimer("end", {
    useGameTime = true,
    endTime = 20,
    callback = function()
      --find player with highest health
      local mostHealth = 0
      local teamNumWithMostHealth = nil
      local winner = nil
      for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
          for playerID = 0, GameMode.maxNumPlayers - 1 do
            if GameMode.teams[teamNumber][playerID] ~= nil then
              local heroEntity = GameMode.teams[teamNumber][playerID]
              --if player's health is higher than mostHealth
              if heroEntity:GetHealth() > mostHealth then
                mostHealth = heroEntity:GetHealth()
                teamNumWithMostHealth = heroEntity:GetTeam()
                --set winner
                winner = heroEntity
              end
            end
          end
        end
      end

      --declare winner
      Notifications:BottomToAll({text = "Winner! ", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
      Notifications:BottomToAll({text = GameMode.teamNames[winner:GetTeam()], duration= 5.0, style={["font-size"] = "45px", color = GameMode.teamColors[winner:GetTeam()]}, continue=true})
      
      --assign score
      GameMode.teams[winner:GetTeam()].score = GameMode.teams[winner:GetTeam()].score + 1

      --end game
      GameMode:EndGame()
    end
  })
end