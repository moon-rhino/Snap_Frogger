--logs

--mine stage
--at the start when everyone's together
--spawn all mines at once
--reveal for several seconds
--everyone gets to reveal a section once
--no one respawns until everyone's dead
--reset mines on respawn



frogger3 = class({})

local NUM_ROWS_SECTION_1 = 22
local NUM_ROWS_SECTION_2 = 10
local BUNCH_COUNT_MIN = 7
local BUNCH_COUNT_MAX = 12

function frogger3:Run()
  --sound
  EmitGlobalSound("take_on_me")

  Notifications:ClearBottomFromAll()
  Notifications:BottomToAll({text="LEVEL 2: FROGGERRRRRRR" , duration= 8.0, style={["font-size"] = "45px"}})

  GameMode.creeps["frogger3"] = {}

  frogger3.finished = false

  frogger3:SpawnObstacles()
end

function frogger3:SpawnObstacles()
  GameMode.creeps["frogger3"]['logs'] = {}

  ----------
  -- logs --
  ----------
  --same as zombies except very scarce space in between
  --must jump into the space to cross
  --consistent spaces in between
  --consistent directions alternate between every row

  --section 1
  for row = 1, NUM_ROWS_SECTION_1 do
    --level 2:
    --more speed
    --less space between cookies

    GameMode.creeps["frogger3"]['logs'][row] = {}
    --GameMode.creeps["frogger3"]['logs'][row].speed = math.random(100, 150)
    GameMode.creeps["frogger3"]['logs'][row].speed = 100
    if row > 10 then
      --GameMode.creeps["frogger3"]['logs'][row].speed = math.random(150, 200)
      GameMode.creeps["frogger3"]['logs'][row].speed = math.random(150)
    end
    local leftLocation = Vector(3039, 1286 + 500 + (row * 300), 384)
    local rightLocation = Vector(6366, 1286 + 500 + (row * 300), 384)
    --1 = left
    --2 = right
    GameMode.creeps["frogger3"]['logs'][row].side = math.random(2)
    --bunch
    Timers:CreateTimer(string.format("spawn_logs_row_%s", row), {
      useGameTime = true,
      endTime = 0,
      callback = function()
        if not frogger3.finished then
          local bunch = math.random(BUNCH_COUNT_MIN, BUNCH_COUNT_MAX)
          local bunchCount = 0
          --local space = math.random(4, 6)
          local space = 8
          if row > 10 then
            space = math.random(5, 7)
          end
          Timers:CreateTimer(string.format("spawn_log_component_row_%s", row), {
            useGameTime = true,
            endTime = 0,
            callback = function()
              bunchCount = bunchCount + 1
              if bunchCount == bunch+1 then
                bunchCount = 0
                return nil
              else
                if GameMode.creeps["frogger3"]['logs'][row].side == 1 then
                  GameMode.creeps["frogger3"]['logs'][row][bunchCount] = CreateUnitByName("water", leftLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  GameMode.creeps["frogger3"]['logs'][row][bunchCount].destination = rightLocation
                else
                  GameMode.creeps["frogger3"]['logs'][row][bunchCount] = CreateUnitByName("water", rightLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  GameMode.creeps["frogger3"]['logs'][row][bunchCount].destination = leftLocation
                end
                GameMode.creeps["frogger3"]['logs'][row][bunchCount]:SetBaseMoveSpeed(GameMode.creeps["frogger3"]['logs'][row].speed)
                --pass in object that has the thinker method
                --in this case, it's GameMode
                GameMode.creeps["frogger3"]['logs'][row][bunchCount]:SetThink("ZombieThinker", GameMode)
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

  --section 2
  --[[for row = (NUM_ROWS_SECTION_1 +1), (NUM_ROWS_SECTION_1 +1 + NUM_ROWS_SECTION_2) do
    
    GameMode.creeps["frogger3"]['logs'][row] = {}
    GameMode.creeps["frogger3"]['logs'][row].speed = math.random(170, 220)
    local leftLocation = Vector(3039, 6286 + (row * 300), 384)
    local rightLocation = Vector(6366, 6286 + (row * 300), 384)
    --1 = left
    --2 = right
    GameMode.creeps["frogger3"]['logs'][row].side = math.random(2)
    --bunch
    Timers:CreateTimer(string.format("spawn_logs_row_%s", row), {
      useGameTime = true,
      endTime = 0,
      callback = function()
        if not frogger3.finished then
          
          local bunch = math.random(9, 14)
          local bunchCount = 0
          local space = math.random(2, 4)
          Timers:CreateTimer(string.format("spawn_log_component_row_%s", row), {
            useGameTime = true,
            endTime = 0,
            callback = function()
              bunchCount = bunchCount + 1
              Notifications:BottomToAll({text=string.format("spawning mobs on row %s", row) , duration= 8.0, style={["font-size"] = "45px"}})
              if bunchCount == bunch+1 then
                bunchCount = 0
                return nil
              else
                if GameMode.creeps["frogger3"]['logs'][row].side == 1 then
                  GameMode.creeps["frogger3"]['logs'][row][bunchCount] = CreateUnitByName("water", leftLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  GameMode.creeps["frogger3"]['logs'][row][bunchCount].destination = rightLocation
                else
                  GameMode.creeps["frogger3"]['logs'][row][bunchCount] = CreateUnitByName("water", rightLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  GameMode.creeps["frogger3"]['logs'][row][bunchCount].destination = leftLocation
                end
                GameMode.creeps["frogger3"]['logs'][row][bunchCount]:SetBaseMoveSpeed(GameMode.creeps["frogger3"]['logs'][row].speed)
                --pass in object that has the thinker method
                --in this case, it's GameMode
                GameMode.creeps["frogger3"]['logs'][row][bunchCount]:SetThink("ZombieThinker", GameMode)
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
  end]]
end

function frogger3:ClearCreeps()
  for row = 1, NUM_ROWS_SECTION_1 do
    for bunchCount = 1, BUNCH_COUNT_MAX do
      if GameMode.creeps["frogger3"]['logs'][row][bunchCount] ~= nil then
        GameMode.creeps["frogger3"]['logs'][row][bunchCount]:ForceKill(false)
        GameMode.creeps["frogger3"]['logs'][row][bunchCount]:RemoveSelf()
      end
    end
  end
end