require('./internal/util')

-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  DebugPrint("[BAREBONES] GameRules State Changed")
  DebugPrintTable(keys)

  local newState = GameRules:State_Get()
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)
  --print("[GameMode:OnNPCSpawned] keys: ")
  --PrintTable(keys)
  local npc = EntIndexToHScript(keys.entindex)
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --DebugPrint("[BAREBONES] Entity Hurt")
  --DebugPrintTable(keys)

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)

    -- The ability/item used to damage, or nil if not damaged by an item/ability
    local damagingAbility = nil

    if keys.entindex_inflictor ~= nil then
      damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
    end
  end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
  DebugPrint( '[BAREBONES] OnItemPickedUp' )
  DebugPrintTable(keys)

  local unitEntity = nil
  if keys.UnitEntitIndex then
    unitEntity = v(keys.UnitEntitIndex)
  elseif keys.HeroEntityIndex then
    unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
  end

  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  DebugPrintTable(keys) 
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  DebugPrint( '[BAREBONES] OnItemPurchased' )
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityname = keys.abilityname
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  DebugPrint('[BAREBONES] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  DebugPrint('[BAREBONES] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  --level 2 - 4 = basic upgrade
  --level 5 = ult upgrade
  --level 6 - 8 = basic upgrade
  --level 9 = ult upgrade
  --level 10 - 12 = basic upgrade
  --level 13 = ult upgrade

  --for beta: any upgrade for any level
  DebugPrint('[BAREBONES] OnPlayerLevelUp')
  DebugPrintTable(keys)
  local player = EntIndexToHScript(keys.player)
  local level = keys.level
  local hero = PlayerResource:GetSelectedHeroEntity(keys.player_id)

  --[[if GameMode.gameActive then
    --nothing
  elseif level > 4 then
    --move 2nd to last ability to last
    --move 3rd to last ability to 2nd to last
    --add new ability to 3rd to last
    --17
    --18
    --19


    
    local firstAbilityName = hero:GetAbilityByIndex(15):GetAbilityName()
    local firstAbilityLevel = hero:GetAbilityByIndex(15):GetLevel()
    hero:RemoveAbility(firstAbilityName)
    --hero:RemoveAbilityByHandle(firstAbility)
    local secondAbilityName = hero:GetAbilityByIndex(16):GetAbilityName()
    local secondAbilityLevel = hero:GetAbilityByIndex(16):GetLevel()
    hero:RemoveAbility(secondAbilityName)
    --secondAbility:SetAbilityIndex(17)
    local thirdAbilityName = hero:GetAbilityByIndex(17):GetAbilityName()
    local thirdAbilityLevel = hero:GetAbilityByIndex(17):GetLevel()
    hero:RemoveAbility(thirdAbilityName)
    --thirdAbility:SetAbilityIndex(18)

    local firstAbility = hero:AddAbility(secondAbilityName)
    firstAbility:SetLevel(secondAbilityLevel)
    local secondAbility = hero:AddAbility(thirdAbilityName)
    secondAbility:SetLevel(thirdAbilityLevel)

    local randomAbilityUpgradeIndex = math.random(1,11)
    local randomAbilityName = GameMode.abilityUpgrades.basic[randomAbilityUpgradeIndex]
    --if hero has that ability,
      --pick again
    while hero:HasAbility(randomAbilityName) do
      local randomAbilityUpgradeIndex = math.random(1,11)
      randomAbilityName = GameMode.abilityUpgrades.basic[randomAbilityUpgradeIndex]
    end
    
    local thirdAbility = hero:AddAbility(randomAbilityName)
    thirdAbility:SetLevel(1)
    Notifications:Bottom(hero:GetPlayerID(), {text=string.format("upgrade gained: %s", randomAbilityName), duration=5, style={color="white"}})
    --randomAbility:SetAbilityIndex(17)
    --if it's machine gun or double barreled, 
      --replace the original spell
    if randomAbilityName == "lil_shredder_machine_gun" then 
      hero:SwapAbilities("lil_shredder_base", "lil_shredder_machine_gun", true, true)
    elseif randomAbilityName == "scatterblast_double_barreled" then
      hero:SwapAbilities("scatterblast_base", "scatterblast_double_barreled", true, true)
    end
  else
    --any ability
    local abilityUpgradeIndex = math.random(1,11)
    abilityName = GameMode.abilityUpgrades.basic[abilityUpgradeIndex]
    --if hero already has that upgrade, pick another one
    while hero:HasAbility(abilityName) do
      local abilityUpgradeIndex = math.random(1,11)
      abilityName = GameMode.abilityUpgrades.basic[abilityUpgradeIndex]
    end
    --hero has all abilities
    --on level up,
    --active and hidden=false
    local upgrade = hero:AddAbility(abilityName)
    upgrade:SetLevel(1)
    
    --print(abilityName)
    --if ability is machine gun or double barreled then
    if abilityName == "lil_shredder_machine_gun" then 
      hero:SwapAbilities("lil_shredder_base", "lil_shredder_machine_gun", true, true)
    elseif abilityName == "scatterblast_double_barreled" then
      hero:SwapAbilities("scatterblast_base", "scatterblast_double_barreled", true, true)
    end
    --announce which ability was gained
    Notifications:Bottom(hero:GetPlayerID(), {text=string.format("upgrade gained: %s", abilityName), duration=5, style={color="white"}})
  end]]
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  DebugPrint('[BAREBONES] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  DebugPrint('[BAREBONES] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  DebugPrint('[BAREBONES] OnRuneActivated')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_BOUNTY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('[BAREBONES] OnPlayerPickHero')
  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
  --playerID is based on the order the player joined the game
  local playerID = player:GetPlayerID()
  --player id for the first player = 0
  --once game starts (0:00), this doesn't run anymore
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  DebugPrint('[BAREBONES] OnTeamKillCredit')
  DebugPrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died (an entity killed an entity)
function GameMode:OnEntityKilled( keys )
  DebugPrint( '[BAREBONES] OnEntityKilled Called' )
  DebugPrintTable( keys )

  -- The Killing entity
  local killerEntity = nil

  -- Indexes:
  local killed_entity_index = keys.entindex_killed
  local attacker_entity_index = keys.entindex_attacker
  local inflictor_index = keys.entindex_inflictor -- it can be nil if not killed by an item or ability

  -- Find the entity that was killed
  local killed_unit
  if killed_entity_index then
    killed_unit = EntIndexToHScript(killed_entity_index)
  end

  -- Find the entity (killer) that killed the entity mentioned above
  local killer_unit
  if attacker_entity_index then
    killer_unit = EntIndexToHScript(attacker_entity_index)
  end

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  -- Find the ability/item used to kill, or nil if not killed by an item/ability
  local killing_ability
  if inflictor_index then
    killing_ability = EntIndexToHScript(inflictor_index)
  end

  if keys.entindex_inflictor ~= nil then
    killerAbility = EntIndexToHScript( keys.entindex_inflictor )
  end

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless

  if killed_unit:IsRealHero() then
    if GameMode.test then
      killed_unit:SetRespawnPosition(GameMode.testSpawnLoc)
    else
      killed_unit:SetRespawnPosition(killed_unit.respawnLocation)
    end
  end
  
end

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  DebugPrint('[BAREBONES] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
-- doesn't get called for bots
function GameMode:OnConnectFull(keys)
  DebugPrint('[BAREBONES] OnConnectFull')
  DebugPrintTable(keys)
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
  local teamNum = PlayerResource:GetTeam(playerID)

  --[[if GameMode.teams[teamNum] == nil then
    print("[GameMode:OnHeroInGame] making a new entry in the 'teams' table")
    GameMode.teams[teamNum] = {}
    GameMode.teams[teamNum]["players"] = {}
    GameMode.teams[teamNum].score = 0
    GameMode.teams[teamNum].remaining = true
    GameMode.teams[teamNum].totalDamageDealt = 0
    GameMode.teams[teamNum].sentry = nil
    --deprecate
    GameMode.teams[teamNum].wanted = false
  end
  GameMode.teams[teamNum]["players"][playerID] = {}
  GameMode.teams[teamNum]["players"][playerID].hero = PlayerResource:GetSelectedHeroEntity(playerID)
  GameMode.teams[teamNum]["players"][playerID].totalDamageDealt = 0
  GameMode.teams[teamNum]["players"][playerID].totalKills = 0

  GameMode.numPlayers = GameMode.numPlayers + 1]]
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
  DebugPrint('[BAREBONES] OnItemCombined')
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  local player = PlayerResource:GetPlayer(plyID)

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
  DebugPrint('[BAREBONES] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
  DebugPrint('[BAREBONES] OnNPCGoalReached')
  DebugPrintTable(keys)

  local goalEntity = EntIndexToHScript(keys.goal_entindex)
  local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
  local npc = EntIndexToHScript(keys.npc_entindex)
end

-- This function is called whenever any player sends a chat message to team or All
function GameMode:OnPlayerChat(keys)
  local teamonly = keys.teamonly
  local userID = keys.userid
  --local playerID = self.vUserIds[userID]:GetPlayerID()
  local text = keys.text
end


-- This function turns the "name" table into vector table
function GameMode:InitializeVectors()
  for i,list in pairs(MultPatrol) do
    MultVector[i] = {}
    for j,entloc in pairs(list) do
      local pos = Entities:FindByName(nil, entloc):GetAbsOrigin()
      MultVector[i][j] = pos
    end
  end
  --[[for i,list in pairs(Bounds) do
    BoundsVector[i] = {}
    for j,entloc in pairs(list) do
      local pos = Entities:FindByName(nil, entloc):GetAbsOrigin()
      BoundsVector[i][j] = pos
    end
  end]]
end


