--step by step
--longer spaces
--more frequent spaces

--difficulty: hard
--decrease the space between the zombie bunches

LinkLuaModifier("modifier_dip", "libraries/modifiers/modifier_dip", LUA_MODIFIER_MOTION_NONE)

frogger4 = class({})

local NUM_ROWS_LOGS = 12
local NUM_ROWS_ZOMBIES = 10
local ZOMBIES_BUNCH_COUNT_MAX = 1
local ZOMBIES_SPACE_MIN = 5
local ZOMBIES_SPACE_MAX = 10
local LOGS_OBSTACLE_BUNCH_COUNT_MIN = 2
local LOGS_OBSTACLE_BUNCH_COUNT_MAX = 4
local LOGS_SPACE_COUNT_MIN = 3
local LOGS_SPACE_COUNT_MAX = 6
local TURTLE_SURFACE_LENGTH = 4
local TURTLE_DIP_LENGTH = 4
local TURTLE_BUNCH_NUM = 4
local WIDTH_ZOMBIES = 300

function frogger4:Run()
  --sound
  EmitGlobalSound("take_on_me")

  Notifications:ClearBottomFromAll()
  Notifications:BottomToAll({text="FROGGER" , duration= 8.0, style={["font-size"] = "45px"}})

  GameMode.creeps["frogger4"] = {}

  --flag for spawning creeps
  --you can set values on classes like tables
  frogger4.finished = false

  frogger4:SpawnZombies()
  frogger4:SpawnLogsAndTurtles()
  --frogger4:StartTimer()
end

function frogger4:SpawnZombies()

  GameMode.creeps["frogger4"]['zombies'] = {}

  for row = 1, NUM_ROWS_ZOMBIES do
    GameMode.creeps["frogger4"]['zombies'][row] = {}
    GameMode.creeps["frogger4"]['zombies'][row].speed = math.random(200, 350)
    local leftLocation = Vector(3039, 1286 + 500 + (row * 300), 384)
    local rightLocation = Vector(6366, 1286 + 500 + (row * 300), 384)
    local space = RandomFloat(ZOMBIES_SPACE_MIN, ZOMBIES_SPACE_MAX)
    GameMode.creeps["frogger4"]['zombies'][row].side = math.random(2)
    
    --bunch
    Timers:CreateTimer(string.format("spawn_zombies_row_%s", row), {
      useGameTime = true,
      endTime = 0,
      callback = function()
        if frogger4.finished == false then
          local bunch = math.random(ZOMBIES_BUNCH_COUNT_MAX)
          local bunchCount = 0
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
                if GameMode.creeps["frogger4"]['zombies'][row].side == 1 then
                  GameMode.creeps["frogger4"]['zombies'][row][bunchCount] = CreateUnitByName("zombie", leftLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  GameMode.creeps["frogger4"]['zombies'][row][bunchCount].destination = rightLocation
                else
                  GameMode.creeps["frogger4"]['zombies'][row][bunchCount] = CreateUnitByName("zombie", rightLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  GameMode.creeps["frogger4"]['zombies'][row][bunchCount].destination = leftLocation
                end
                GameMode.creeps["frogger4"]['zombies'][row][bunchCount]:SetBaseMoveSpeed(GameMode.creeps["frogger4"]['zombies'][row].speed)
                --must be a member function
                GameMode.creeps["frogger4"]['zombies'][row][bunchCount]:SetThink("ZombieThinker", GameMode)
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
end

--same as zombies except very scarce space in between
--must jump into the space to cross
--consistent spaces in between
--consistent directions alternate between every row

--level 2:
--more speed
--less space between cookies

--time limit

--cars: slow
--one unit, wide spaces

--one row of safe space

--turtles: 3 safe, 1 unsafe, same speed
--some sections disappear
--logs: different spaces in each row
--different speed in each row
--long logs, short logs

--5 goal spaces
--occupy every space to finish the level

function frogger4:SpawnLogsAndTurtles()

  GameMode.creeps["frogger4"]['section2'] = {}

  for row = 1, NUM_ROWS_LOGS do
    GameMode.creeps["frogger4"]['section2'][row] = {}
    local rowType = math.random(1, 4)
    --[[--logs
    if rowType < 1 then
      frogger4:SpawnLogRow(row)
    
    --turtles
    else
      frogger4:SpawnTurtleRow(row)
    end]]
    frogger4:SpawnLogRow(row)
  end
end

function frogger4:SpawnLogRow(row)

  local side = math.random(2)
  if side == 1 then
    side = "left"
  else
    side = "right"
  end

  local leftSpawnLocation = Vector(3039, 5000 + (row * 300), 384)
  local rightSpawnLocation = Vector(6366, 5000 + (row * 300), 384)
  local bunch = math.random(LOGS_OBSTACLE_BUNCH_COUNT_MIN, LOGS_OBSTACLE_BUNCH_COUNT_MAX)
  local space = math.random(LOGS_SPACE_COUNT_MIN, LOGS_SPACE_COUNT_MAX)
  local speed = math.random(200, 300)

  Timers:CreateTimer(string.format("spawn_logs_row_%s", row), {
    useGameTime = true,
    endTime = 0,
    callback = function()
      if not frogger4.finished then
        
        local bunchCount = 0
        --local space = 8
        Timers:CreateTimer(string.format("spawn_log_component_row_%s", row), {
          useGameTime = true,
          endTime = 0,
          callback = function()
            bunchCount = bunchCount + 1
            if bunchCount == bunch+1 then
              bunchCount = 0
              return nil
            else
              if side == "left" then
                GameMode.creeps["frogger4"]['section2'][row][bunchCount] = CreateUnitByName("water", leftSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                GameMode.creeps["frogger4"]['section2'][row][bunchCount].destination = rightSpawnLocation
              else
                GameMode.creeps["frogger4"]['section2'][row][bunchCount] = CreateUnitByName("water", rightSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                GameMode.creeps["frogger4"]['section2'][row][bunchCount].destination = leftSpawnLocation
              end
              GameMode.creeps["frogger4"]['section2'][row][bunchCount]:SetBaseMoveSpeed(speed)
              --pass in object that has the thinker method
              --in this case, it's GameMode
              GameMode.creeps["frogger4"]['section2'][row][bunchCount]:SetThink("ZombieThinker", GameMode)
              return 1.0
            end
          end
        })
        return bunch+space
      else
        return nil
      end
    end
  })

end

--[[bunchCount = bunchCount + 1
if bunchCount == bunch+1 then
  bunchCount = 0
  spawnWater = false
else
  if side == "left" then
    GameMode.creeps["frogger4"]['section2'][row][bunchCount] = CreateUnitByName("water", leftSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.creeps["frogger4"]['section2'][row][bunchCount].destination = rightSpawnLocation
  else
    GameMode.creeps["frogger4"]['section2'][row][bunchCount] = CreateUnitByName("water", rightSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    GameMode.creeps["frogger4"]['section2'][row][bunchCount].destination = leftSpawnLocation
  end
  GameMode.creeps["frogger4"]['section2'][row][bunchCount]:SetBaseMoveSpeed(speed)
  --pass in object that has the thinker method
  --in this case, it's GameMode
  GameMode.creeps["frogger4"]['section2'][row][bunchCount]:SetThink("ZombieThinker", GameMode)
end
return 1]]

function frogger4:SpawnTurtleRow(row)

  local side = math.random(2)
  if side == 1 then
    side = "left"
  else
    side = "right"
  end

  local leftSpawnLocation = Vector(3039, 5000 + (row * 300), 384)
  local rightSpawnLocation = Vector(6366, 5000 + (row * 300), 384)
  local waterBunchNum = math.random(2, 3)
  local waterNum = 0
  local turtleBunchNum = 4
  local turtleNum = 0
  local speed = math.random(200, 300)
  local unitCount = 0
  local spawnWater = true
  local spawnLocation
  local destination

  if side == "left" then
    spawnLocation = leftSpawnLocation
    destination = rightSpawnLocation
  else
    spawnLocation = rightSpawnLocation
    destination = leftSpawnLocation
  end
  Timers:CreateTimer(string.format("spawn_turtles_row_%s", row), {
    useGameTime = true,
    endTime = 0,
    callback = function()
      
      if spawnWater then
        GameMode.creeps["frogger4"]['section2'][row][unitCount] = CreateUnitByName("water", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        GameMode.creeps["frogger4"]['section2'][row][unitCount].destination = destination
        GameMode.creeps["frogger4"]['section2'][row][unitCount]:SetBaseMoveSpeed(speed)
        GameMode.creeps["frogger4"]['section2'][row][unitCount]:SetThink("ZombieThinker", GameMode)

        unitCount = unitCount + 1
        if unitCount == (waterBunchNum + 1) then
          unitCount = 0
          spawnWater = false
        end
        
      else
        GameMode.creeps["frogger4"]['section2'][row][unitCount] = CreateUnitByName("leaf", spawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        GameMode.creeps["frogger4"]['section2'][row][unitCount].floating = true
        GameMode.creeps["frogger4"]['section2'][row][unitCount].destination = destination
        GameMode.creeps["frogger4"]['section2'][row][unitCount]:SetBaseMoveSpeed(speed)
        GameMode.creeps["frogger4"]['section2'][row][unitCount].row = row
        GameMode.creeps["frogger4"]['section2'][row][unitCount].unitCount = unitCount
        GameMode.creeps["frogger4"]['section2'][row][unitCount]:SetThink("ZombieThinker", GameMode)


        unitCount = unitCount + 1
        if unitCount == (turtleBunchNum + 1) then
          unitCount = 0
          spawnWater = true
        end

      end



      return 1

      end
  })

  frogger4:TurtleDipAndSurface(row)

end

function frogger4:TurtleDipAndSurface(row)
  local timeToSurface = TURTLE_SURFACE_LENGTH
  local timeToDip = TURTLE_DIP_LENGTH
  local float = true
  Timers:CreateTimer("dip_and_float", {
    useGameTime = true,
    endTime = 0,
    callback = function()
      if float then
        frogger4:TurtleDip(row)
        return timeToDip
      else
        frogger4:TurtleSurface(row)
        return timeToFloat
      end
    end
  })
end

function frogger4:TurtleDip(row)
  local countdown = 1
  for unitCount = 1, TURTLE_BUNCH_NUM do
    if GameMode.creeps["frogger4"]['section2'][row][unitCount] ~= nil then
      local turtle = GameMode.creeps["frogger4"]['section2'][row][unitCount]
      Timers:CreateTimer(string.format("turtle_dip_%s_%s", row, unitCount), {
        useGameTime = true,
        endTime = 1,
        callback = function()
          if countdown > 0.2 then
            turtle:SetModelScale(countdown)
            countdown = countdown - 0.1
            return 0.1
          else
            return nil
          end
        end
      })
    end
  end
end

function frogger4:TurtleSurface(row)
  local countdown = 0.2
  for unitCount = 1, TURTLE_BUNCH_NUM do
    if GameMode.creeps["frogger4"]['section2'][row][unitCount] ~= nil then
      local turtle = GameMode.creeps["frogger4"]['section2'][row][unitCount]
      Timers:CreateTimer(string.format("turtle_dip_%s_%s", row, unitCount), {
        useGameTime = true,
        endTime = 1,
        callback = function()
          if countdown < 1 then
            turtle:SetModelScale(countdown)
            countdown = countdown + 0.1
            return 0.1
          else
            return nil
          end
        end
      })
    end
  end
end





--[[function frogger2:ClearCreeps()
  --zombies
  for row = 1, NUM_ROWS_ZOMBIES do
    for bunchCount = 1, BUNCH_COUNT_MAX do
      if GameMode.creeps["frogger2"]['zombies'][row][bunchCount] ~= nil then
        GameMode.creeps["frogger2"]['zombies'][row][bunchCount]:ForceKill(false)
        GameMode.creeps["frogger2"]['zombies'][row][bunchCount]:RemoveSelf()
      end
    end
  end
  
  --logs
  for row = 1, NUM_ROWS_SECTION_1 do
    for bunchCount = 1, BUNCH_COUNT_MAX do
      if GameMode.creeps["frogger4"]['logs'][row][bunchCount] ~= nil then
        GameMode.creeps["frogger4"]['logs'][row][bunchCount]:ForceKill(false)
        GameMode.creeps["frogger4"]['logs'][row][bunchCount]:RemoveSelf()
      end
    end
  end
end]]

function FroggerEndTrigger(trigger)
    local ent = trigger.activator
    if not ent then return end
  
    --song
    EmitGlobalSound("next_episode")



    Timers:CreateTimer("next_level", {
        useGameTime = true,
        endTime = 5,
        callback = function()

            --start next game
            frogger4.finished = true
            frogger4:ClearCreeps()
            frogger5:Run()
            GameMode.currentLevel = 'frogger5'  
            
            --set everyone back to the starting line
            for playerID = 0, 8 do
                if PlayerResource:IsValidPlayerID(playerID) then
                    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                    local start_location = GameMode:GetHammerEntityLocation(string.format("player_%s_start", playerID+1))
                    GameMode:SetPlayerOnLocation(hero, start_location)
                end
            end
            return nil
        end
    })
end

--cookie each other
--hop on obstacles to disable them
