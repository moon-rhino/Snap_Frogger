--spawn npcs
--zombies, leaves, logs
--all npcs immune to stuns
--kill them all when the game ends
--they have to be already walking when the players spawn
--walking at various speeds

--zombies
--spawns on the left or the right side
--each row has a side and distinct speed
--on spawn, walk to the opposite side
--spawn a random bunch of 1, 2, or 3 zombies at a time
--spawn a bunch every few seconds
--when they reach the opposite side, they die
--if players touch a zombie, they die

frogger = class({})

local COL_MAX = 13
local ROW_MAX = 45

function frogger:Start()
  --sound
  EmitGlobalSound("take_on_me")

  GameMode.level = 1
  GameMode.levelFinished = false
  GameMode.games["frogger"] = {}
  
  GameMode.games["frogger"].shooters = {}
  GameMode.games["frogger"].blocks = {}

  

  for playerID = 0, 7 do
    if PlayerResource:IsValidPlayerID(playerID) then
      local hero = PlayerResource:GetSelectedHeroEntity(playerID)
      GameMode:RemoveAllAbilities(hero)
      local jumpAbility = hero:AddAbility("jump")
      jumpAbility:SetLevel(1)
    end
  end

  GameMode.games["frogger"].originX = GameMode:GetHammerEntityLocation("frogger_bottom_right").x
  GameMode.games["frogger"].originY = GameMode:GetHammerEntityLocation("frogger_bottom_right").y
  GameMode.games["frogger"].leftX = GameMode:GetHammerEntityLocation("frogger_bottom_left").x
  GameMode.games["frogger"].rowHeight = (GameMode:GetHammerEntityLocation("frogger_top_right").y - GameMode:GetHammerEntityLocation("frogger_bottom_right").y) / ROW_MAX
  GameMode.games["frogger"].colWidth = (GameMode:GetHammerEntityLocation("frogger_top_right").x - GameMode:GetHammerEntityLocation("frogger_top_left").x) / COL_MAX

  frogger:SpawnObstacles()

end

function frogger:SpawnObstacles()

  --two sections
  --second section: one row of shooters each
  --more rows of baskets


  --divide zone into 47 rows and 11 columns
  --take one row as width of 200 and 1 column as width of 200
  --on every row, there's a 70% it's a zombie, 20% it's a block, and 10% that it's a shooter
  --level 1 and level 2 -- on level 2, there're more shooters

  -------------
  -- level 1 --
  -------------

  -------------
  -- zombies --
  -------------

  --[[local bottomLeftEnt = Entities:FindByName(nil, "level_1_bottom_left")
  local bottomLeftEntVector = bottomLeftEnt:GetAbsOrigin()
  print(bottomLeftEntVector)
  --6649, -7585
  local bottomRightEnt = Entities:FindByName(nil, "level_1_bottom_right")
  local bottomRightEntVector = bottomRightEnt:GetAbsOrigin()
  print(bottomRightEntVector)
  --9587, -7577
  local topLeftEnt = Entities:FindByName(nil, "level_1_top_left")
  local topLeftEntVector = topLeftEnt:GetAbsOrigin()
  print(topLeftEntVector)
  --6524, 4775
  local topRightEnt = Entities:FindByName(nil, "level_1_top_right")
  local topRightEntVector = topRightEnt:GetAbsOrigin()
  print(topRightEntVector)
  --9640, 4829]]

  --maze game
  --cookie pads in the paths
  

  --column width = 160; 11 columns
  --row height = 250; 45 rows
  --start from bottom left; [6649, -7585]
  --zombies go to the other side; bottom right = [9587, -7577]

  local ROW_HEIGHT = 250
  local COL_WIDTH = 320
  for row = 0, 19 do
    local speed = math.random(200, 350)
    local zombieLeftSpawnLocation = Vector(
      GameMode.games["frogger"].leftX, 
      GameMode.games["frogger"].originY + row * GameMode.games["frogger"].rowHeight,
      0
    )
    local zombieRightSpawnLocation = Vector(
      GameMode.games["frogger"].originX, 
      GameMode.games["frogger"].originY + row * GameMode.games["frogger"].rowHeight,
      0
    )
    local side = math.random(2)
    
    --bunch
    Timers:CreateTimer(string.format("spawn_zombies_row_%s", row), {
      useGameTime = true,
      endTime = 0,
      callback = function()
        if not GameMode.levelFinished then
          local bunch = math.random(3)
          local bunchCount = 0
          local space = RandomFloat(4, 7)
          --individual
          Timers:CreateTimer(string.format("spawn_zombie_row_%s_%s", row, Time()), {
            useGameTime = true,
            endTime = 0,
            callback = function()
              bunchCount = bunchCount + 1
              if bunchCount == bunch+1 then
                bunchCount = 0
                return nil
              else
                local zombie
                --spawns on the left or the right side
                --left
                if side == 1 then
                  zombie = CreateUnitByName("zombie", zombieLeftSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  zombie.destination = zombieRightSpawnLocation
                else
                  zombie = CreateUnitByName("zombie", zombieRightSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  zombie.destination = zombieLeftSpawnLocation
                end
                zombie:SetBaseMoveSpeed(speed)
                --must be a member function
                zombie:SetThink("ZombieThinker", self)
                return 1.0
              end
            end
          })
          return bunch + space
        else
          return nil
        end
          
      end
    })
  end

  -------------
  -- level 2 --
  -------------

  local rowInfo = {}
  local blocks = {}
  local shooters = {}
  for row = 23, 49 do
    local typeDie = math.random(1, 10)
    if typeDie <= 4 then
      rowInfo[row] = "zombie"
      --zombie
      frogger:SpawnZombie(row, ROW_HEIGHT)
    elseif typeDie <= 6 and row > 23 and rowInfo[row-1] ~= "wall" and rowInfo[row-1] ~= "shooter" and rowInfo[row-2] ~= "wall"then
      --wall
      rowInfo[row] = "wall"
      GameMode.games["frogger"].blocks[row] = {}
      for col = 0, 10 do
        --local blockDie = math.random(1, 11)
        --if blockDie < 4 then
          local blockSpawnLocation = Vector(
            GameMode.games["frogger"].originX - col * COL_WIDTH,
            GameMode.games["frogger"].originY + row * ROW_HEIGHT,
            0
          )
          GameMode.games["frogger"].blocks[row][col] = CreateUnitByName("block", blockSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
          GameMode.games["frogger"].blocks[row][col]:SetHullRadius(150)
          --end
      end
    else
      --shooter
      rowInfo[row] = "shooter"
      if rowInfo[row-1] == "shooter" then
        --replace with zombie
        rowInfo[row] = "zombie"
        frogger:SpawnZombie(row, ROW_HEIGHT)
      else
        local shooterSpawnLocation = Vector(
          GameMode.games["frogger"].leftX,
          GameMode.games["frogger"].originY + row * ROW_HEIGHT,
          0
        )
        GameMode.games["frogger"].shooters[row] = CreateUnitByName("shooter", shooterSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        local shootAbilityNames = {
          "shoot_cookie_slow",
          "shoot_cookie_medium",
          "shoot_cookie_fast"
        }
        GameMode.games["frogger"].shooters[row].shootAbility = shootAbilityNames[math.random(1, #shootAbilityNames)]
        GameMode.games["frogger"].shooters[row]:SetThink("ShooterThinker", self)
      end
    end
  end



end

function frogger:SpawnZombie(row, rowHeight)
  local speed = math.random(200, 350)
  local zombieLeftSpawnLocation = Vector(
    GameMode.games["frogger"].leftX, 
    GameMode.games["frogger"].originY + row * rowHeight,
    0
  )
  local zombieRightSpawnLocation = Vector(
    GameMode.games["frogger"].originX, 
    GameMode.games["frogger"].originY + row * rowHeight,
    0
  )
  local side = math.random(2)
  
  --bunch
  Timers:CreateTimer(string.format("spawn_zombies_row_%s", row), {
    useGameTime = true,
    endTime = 0,
    callback = function()
      if not GameMode.levelFinished and GameMode.level == 1 then
        local bunch = math.random(3)
        local bunchCount = 0
        local space = RandomFloat(4, 7)
        --individual
        Timers:CreateTimer(string.format("spawn_zombie_row_%s_%s", row, Time()), {
          useGameTime = true,
          endTime = 0,
          callback = function()
            bunchCount = bunchCount + 1
            if bunchCount == bunch+1 then
              bunchCount = 0
              return nil
            else
              local zombie
              --spawns on the left or the right side
              --left
              if side == 1 then
                zombie = CreateUnitByName("zombie", zombieLeftSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                zombie.destination = zombieRightSpawnLocation
              else
                zombie = CreateUnitByName("zombie", zombieRightSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                zombie.destination = zombieLeftSpawnLocation
              end
              zombie:SetBaseMoveSpeed(speed)
              --must be a member function
              zombie:SetThink("ZombieThinker", self)
              return 1.0
            end
          end
        })
        return bunch + space
      else
        return nil
      end
    end
  })
end

function frogger:SpawnRandomLeaf(row, col, location)
  local leafDie = math.random(1, 9)
  if leafDie > 0 and leafDie < 4 then
    GameMode.games["frogger"].leaves[row][col].unit = CreateUnitByName("leaf", location, true, nil, nil, DOTA_TEAM_BADGUYS)
  else
    GameMode.games["frogger"].leaves[row][col].unit = CreateUnitByName("badLeaf", location, true, nil, nil, DOTA_TEAM_BADGUYS)
  end
  
  local particle_cast = "particles/ranged_goodguy_explosion_flash_custom.vpcf"
  local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, GameMode.games["frogger"].leaves[row][col].unit )
	ParticleManager:SetParticleControl( effect_cast, 3, location )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end
  
--moved to "gamemode.lua" because it cannot access "GameMode" here
function frogger:ZombieThinker(unit)
  --if it's within 50 units of the destination,
  if GridNav:FindPathLength(unit.destination, unit:GetAbsOrigin()) < 100 then
    print(GridNav:FindPathLength(unit.destination, unit:GetAbsOrigin()))
    --kill it
    unit:ForceKill(false)
    unit:RemoveSelf()
    --return nil
    return nil
  --else, 
  else
    --MoveToPosition(destination)
    unit:MoveToPosition(unit.destination)
    --return 0.5
    return 0.5
  end
end

function frogger:ShooterThinker(unit)
  local shootCookieAbility = unit:FindAbilityByName(unit.shootAbility)
  local castPos = Vector(unit:GetAbsOrigin().x + 100, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z)
  unit:SetCursorPosition(castPos)
  shootCookieAbility:OnSpellStart()
  return 2
end

function frogger:ClearStage(blocks, shooters)
  for blockRow, blocksInRow in pairs(blocks) do
    for blockCol, block in pairs(blocksInRow) do
      block:ForceKill(false)
      block:RemoveSelf()
    end
  end
  for shooterRow, shooter in pairs(shooters) do
    shooter:ForceKill(false)
    shooter:RemoveSelf()
  end
end


--[[function FroggerEnd(trigger)
  local ent = trigger.activator
  if not ent then return end
  if GameMode.levelFinished then --nothing; prevent from 2nd and 3rd place finish to trigger the end
  else

    --flag for game thinker
    GameMode.levelFinished = true

    --announce
    Notifications:BottomToAll({text = "NICE!", duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
    
    --assign score
    --GameMode.teams[winner:GetTeam()].score = GameMode.teams[winner:GetTeam()].score + 1

    --end game
    --GameMode:EndGame()

    --song
    EmitGlobalSound("next_episode")

    frogger:ClearStage(GameMode.games["frogger"].blocks, GameMode.games["frogger"].shooters)

    --after 3 seconds
    --shoot everyone to the next stage
      --shoot finisher to the next stage
      --spawn everyone around him when he lands
    Timers:CreateTimer("frogger_2_activate", {
      useGameTime = true,
      endTime = 5,
      callback = function()
        frogger2_perp:Start()
        return nil
      end
    })

  end
end]]

--[[function FroggerJump(trigger)
  local ent = trigger.activator
  if not ent then return end
  if ent:FindAbilityByName("jump") == nil then
    local jumpAbility = ent:AddAbility("jump")
    jumpAbility:SetLevel(1)
  end
end]]