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

--difficulty: hard
--decrease the space between the zombie bunches

frogger2 = class({})

local NUM_ROWS = 12
local NUM_COLS = 12
local NUM_ROWS_ZOMBIES = 10
local BUNCH_COUNT_MAX = 3
local WIDTH_ZOMBIES = 300

function frogger2:Run()
  --sound
  EmitGlobalSound("take_on_me")

  Notifications:ClearBottomFromAll()
  Notifications:BottomToAll({text="LEVEL 1: FROGGER" , duration= 8.0, style={["font-size"] = "45px"}})

  GameMode.creeps["frogger2"] = {}

  --flag for spawning creeps
  --you can set values on classes like tables
  frogger2.finished = false

  frogger2:SpawnObstacles()
end

function frogger2:SpawnObstacles()
  
  -------------
  -- zombies --
  -------------
  GameMode.creeps["frogger2"]['zombies'] = {}

  for row = 1, NUM_ROWS_ZOMBIES do
    GameMode.creeps["frogger2"]['zombies'][row] = {}
    GameMode.creeps["frogger2"]['zombies'][row].speed = math.random(200, 350)
    local leftLocation = Vector(3039, 1286 + 500 + (row * 300), 384)
    local rightLocation = Vector(6366, 1286 + 500 + (row * 300), 384)
    --GameMode.creeps["frogger"]['zombies'][row].leftLocation = Vector(3039, 1286 + 2000, 384)
    --GameMode.creeps["frogger"]['zombies'][row].rightLocation = Vector(6366, 1286 + 2000, 384)
    GameMode.creeps["frogger2"]['zombies'][row].side = math.random(2)
    
    --bunch
    Timers:CreateTimer(string.format("spawn_zombies_row_%s", row), {
      useGameTime = true,
      endTime = 0,
      callback = function()
        --doesn't recognize change in GameMode.currentLevel
        if frogger2.finished == false then
          --Notifications:BottomToAll({text=string.format("current level: %s", GameMode.currentLevel) , duration= 8.0, style={["font-size"] = "45px"}})
          local bunch = math.random(BUNCH_COUNT_MAX)
          local bunchCount = 0
          local space = RandomFloat(2, 4)
          --individual
          Timers:CreateTimer(string.format("spawn_zombie_row_%s_bunch", row), {
            useGameTime = true,
            endTime = 0,
            callback = function()
              bunchCount = bunchCount + 1
              if bunchCount == bunch+1 then
                bunchCount = 0
                return nil
              else
                --spawns on the left or the right side
                --left
                if GameMode.creeps["frogger2"]['zombies'][row].side == 1 then
                  GameMode.creeps["frogger2"]['zombies'][row][bunchCount] = CreateUnitByName("zombie", leftLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  GameMode.creeps["frogger2"]['zombies'][row][bunchCount].destination = rightLocation
                else
                  GameMode.creeps["frogger2"]['zombies'][row][bunchCount] = CreateUnitByName("zombie", rightLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  GameMode.creeps["frogger2"]['zombies'][row][bunchCount].destination = leftLocation
                end
                GameMode.creeps["frogger2"]['zombies'][row][bunchCount]:SetBaseMoveSpeed(GameMode.creeps["frogger2"]['zombies'][row].speed)
                --must be a member function
                GameMode.creeps["frogger2"]['zombies'][row][bunchCount]:SetThink("ZombieThinker", GameMode)
                return 1.0
              end
            end
          })
          return bunch + space
        else
          Notifications:BottomToAll({text="LEVEL 1 ENDED" , duration= 8.0, style={["font-size"] = "45px"}})
          return nil
        end
      end
    })
  end

  ------------
  -- leaves --
  ------------
  --row start: 4786
  --top: 8489
  GameMode.creeps["frogger2"]['leaves'] = {}
  for leafRow = 1, NUM_ROWS do
    GameMode.creeps["frogger2"]['leaves'][leafRow] = {}
    for leafCol = 1, NUM_COLS do
      GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol] = {}
      local spawn_location = Vector(3039 + (leafCol - 1) * 300, 4786 + (leafRow) * 300, 384)
      local leafDie = math.random(1, 9)
      if leafDie == 1 or leafDie == 2 then
        GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol] = CreateUnitByName("leaf", spawn_location, true, nil, nil, DOTA_TEAM_BADGUYS)
      else
        GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol] = CreateUnitByName("badLeaf", spawn_location, true, nil, nil, DOTA_TEAM_BADGUYS)
      end
      GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol].location = spawn_location
    end
  end

  --replacing leaves
  --[[local leafRow = 1
  local leafCol = 1
  Timers:CreateTimer("spawnLeaves", {
    useGameTime = true,
    --delay in spawning new leaves
    endTime = 1,
    callback = function()
      --spawn leaf
      if GameMode.currentLevel == 'frogger2' then
        --for leafRow = 1, NUM_ROWS do
          --for leafCol = 1, NUM_COLS do
            local leaf = GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol]
            if frogger2:EnemyUnitNearBy(leaf, 150) then
              --stay
            else
              --replace
              leaf:ForceKill(false)
              leaf:RemoveSelf()
              frogger2:SpawnRandomLeaf(leafRow, leafCol, GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol].location)
            end
            leafCol = leafCol + 1
            if leafCol == NUM_COLS then
              leafCol = 1
              leafRow = leafRow + 1
              if leafRow == NUM_ROWS then
                leafRow = 1
              end
            end
          --end
        --end
        return 0.1
      else
        return nil
      end
    end
  })]]
end

function frogger2:EnemyUnitNearBy(unit, range)
  local enemies = FindUnitsInRadius(unit:GetTeam(), 
  unit:GetAbsOrigin(), nil,
  range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
  FIND_ANY_ORDER, false)
  local enemyCount = 0
  for _, enemy in pairs(enemies) do
    enemyCount = enemyCount + 1
    break
  end
  if enemyCount == 0 then
    return false
  else
    return true
  end
end

function frogger2:SpawnRandomLeaf(leafRow, leafCol, location)
  local leafDie = math.random(1, 9)
  if leafDie > 0 and leafDie < 4 then
    GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol] = CreateUnitByName("leaf", location, true, nil, nil, DOTA_TEAM_BADGUYS)
  else
    GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol] = CreateUnitByName("badLeaf", location, true, nil, nil, DOTA_TEAM_BADGUYS)
  end
  
  local particle_cast = "particles/ranged_goodguy_explosion_flash_custom.vpcf"
  local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol])
	ParticleManager:SetParticleControl( effect_cast, 3, location )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function frogger2:ClearCreeps()
  --zombies
  for row = 1, NUM_ROWS_ZOMBIES do
    for bunchCount = 1, BUNCH_COUNT_MAX do
      if GameMode.creeps["frogger2"]['zombies'][row][bunchCount] ~= nil then
        GameMode.creeps["frogger2"]['zombies'][row][bunchCount]:ForceKill(false)
        GameMode.creeps["frogger2"]['zombies'][row][bunchCount]:RemoveSelf()
      end
    end
  end
  
  --leaves
  for leafRow = 1, NUM_ROWS do
    for leafCol = 1, NUM_COLS do
      if GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol] ~= nil then
          --need to pass in the argument to "ForceKill"
          GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol]:ForceKill(false)
          GameMode.creeps["frogger2"]['leaves'][leafRow][leafCol]:RemoveSelf()
      end
    end
  end
end
