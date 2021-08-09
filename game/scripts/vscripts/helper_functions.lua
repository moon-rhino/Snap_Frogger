--[[ file: Helper Functions
    collection of functions that are used frequently.
    ]]

--[[ sets the player's camera to the hero. ]]
function GameMode:SetCamera(playerId, heroEntity)
    local playerID = heroEntity:GetPlayerID()
    PlayerResource:SetCameraTarget(playerID, heroEntity)
    Timers:CreateTimer({
      endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
      callback = function()            
        PlayerResource:SetCameraTarget(playerID, nil)
      end
    })
end

--[[ gets the location of the hammer entity as a vector. ]]
function GameMode:GetHammerEntityLocation(hammerEntityName)
    local ent = Entities:FindByName(nil, hammerEntityName)
    local entVector = ent:GetAbsOrigin()
    return entVector
end

--[[ remove all abilities on a hero. ]]
function GameMode:RemoveAllAbilities(hero)
    for abilityIndex = 0, 30 do
      local ability = hero:GetAbilityByIndex(abilityIndex)
      if ability ~= nil then
        hero:RemoveAbilityByHandle(ability)
      end
    end
end

--[[ sets a player to a given location.
    details: kills and respawns the player to avoid death zones. ]]
function GameMode:SetPlayerOnLocation(hero, location)
    hero:ForceKill(false)
    hero:SetRespawnPosition(location)
    hero:RespawnHero(false, false)
    GameMode:SetCamera(hero:GetPlayerID(), hero)
end

function GameMode:RemoveAllAbilities(hero)
  for abilityIndex = 0, 30 do
    local ability = hero:GetAbilityByIndex(abilityIndex)
    if ability ~= nil then
      hero:RemoveAbilityByHandle(ability)
    end
  end
end