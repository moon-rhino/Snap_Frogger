frogger3 = class({})

LinkLuaModifier("modifier_axe", "libraries/modifiers/modifier_axe", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_set_max_move_speed", "libraries/modifiers/modifier_set_max_move_speed", LUA_MODIFIER_MOTION_NONE )

function frogger3:Start()
    Notifications:TopToAll({text = "LEVEL 3: CROSS THE RIVER", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 
    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("level_3_start")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            GameMode:RemoveAllAbilities(hero)
            local cookieAbility = hero:AddAbility("cookie_frogger_channeled")
            cookieAbility:SetLevel(1)
            local cookieReleaseAbility = hero:AddAbility("cookie_frogger_channeled_release")
            cookieReleaseAbility:SetLevel(1)
            --give players cookie channel jump ability
        end
    end

    GameMode.games["frogger3"] = {}
    GameMode.games["frogger3"].finished = false
    GameMode.games["frogger3"].cookies = {}
    GameMode.games["frogger3"].shooters = {}
    frogger3:SpawnCookies()
    frogger3:SpawnCookieShooters()
end

local ORIGIN_X = 1
local ORIGIN_Y = 1
local ROW_TOP = 11200
local ROW_BOTTOM = 8500
local COL_WIDTH = 300
local ROW_MAX = 7
local COL_MAX = 20
function frogger3:SpawnCookies()
    --get coordinates
    local bottomLeftEnt = Entities:FindByName(nil, "level_3_bottom_left")
    local bottomLeftEntVector = bottomLeftEnt:GetAbsOrigin()
    print(bottomLeftEntVector)
    --Vector 00000000007B67C0 [-8162.253418 9348.376953 397.002563]

    local bottomRightEnt = Entities:FindByName(nil, "level_3_bottom_right")
    local bottomRightEntVector = bottomRightEnt:GetAbsOrigin()
    print(bottomRightEntVector)
    --Vector 00000000007B6920 [-2677.027832 9412.630859 397.002808]
    
    local topLeftEnt = Entities:FindByName(nil, "level_3_top_left")
    local topLeftEntVector = topLeftEnt:GetAbsOrigin()
    print(topLeftEntVector)
    --Vector 00000000007B6A80 [-8216.516602 10784.974609 397.002808]

    local topRightEnt = Entities:FindByName(nil, "level_3_top_right")
    local topRightEntVector = topRightEnt:GetAbsOrigin()
    print(topRightEntVector)
    --Vector 00000000007B6BE0 [-2769.366211 10787.500977 397.002808]

  ----------
  -- logs --
  ----------
  --same as zombies except very scarce space in between
  --must jump into the space to cross
  --consistent spaces in between
  --consistent directions alternate between every row
  for col = 1, 24 do
    GameMode.games["frogger3"].cookies[col] = {}
    --GameMode.games["frogger3"].cookies[col] = {}
    --local speed = math.random(150, 200)
    local speed = math.random(50, 100)
    local cookieTopLocation = Vector(ORIGIN_X - col * COL_WIDTH, ROW_TOP, 398)
    local cookieBottomLocation = Vector(ORIGIN_X - col * COL_WIDTH, ROW_BOTTOM, 398)
    local side = math.random(2)

    --bunch
    Timers:CreateTimer(string.format("spawn_logs_col_%s", col), {
      useGameTime = true,
      endTime = 0,
      callback = function()
        if not GameMode.games["frogger3"].finished then
          local bunch = math.random(3, 5)
          local bunchCount = 0
          local space
          if speed < 60 then
            space = 12
          else
            space = 10
          end
          Timers:CreateTimer(string.format("spawn_log_component_col_%s", col), {
            useGameTime = true,
            endTime = 0,
            callback = function()
              bunchCount = bunchCount + 1
              if bunchCount == bunch+1 then
                bunchCount = 0
                return nil
              else
                local redDie = math.random(1, 15)
                if side == 1 then
                  if redDie == 1 then
                    GameMode.games["frogger3"].cookies[col][bunchCount] = CreateUnitByName("redPanda", cookieTopLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                    GameMode.games["frogger3"].cookies[col][bunchCount]:AddNewModifier(nil, nil, "modifier_axe", {aggroRange = 500})
                  else
                    GameMode.games["frogger3"].cookies[col][bunchCount] = CreateUnitByName("water", cookieTopLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  end
                  GameMode.games["frogger3"].cookies[col][bunchCount].col = col
                  GameMode.games["frogger3"].cookies[col][bunchCount].destination = cookieBottomLocation
                else
                  if redDie == 1 then
                    GameMode.games["frogger3"].cookies[col][bunchCount] = CreateUnitByName("redPanda", cookieBottomLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                    GameMode.games["frogger3"].cookies[col][bunchCount]:AddNewModifier(nil, nil, "modifier_axe", {aggroRange = 500})
                  else
                    GameMode.games["frogger3"].cookies[col][bunchCount] = CreateUnitByName("water", cookieBottomLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  end
                  GameMode.games["frogger3"].cookies[col][bunchCount].col = col
                  GameMode.games["frogger3"].cookies[col][bunchCount].destination = cookieTopLocation
                end
                GameMode.games["frogger3"].cookies[col][bunchCount]:SetBaseMoveSpeed(speed)
                GameMode.games["frogger3"].cookies[col][bunchCount]:SetThink("ZombieThinker", self)
                --use this to set the movement speed
                GameMode.games["frogger3"].cookies[col][bunchCount].col = col
                GameMode.games["frogger3"].cookies[col][bunchCount]:AddNewModifier(nil, nil, "modifier_set_max_move_speed", {
                  limit = speed
                })
                --rate the cookie spawns within each log
                return 1.5
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

  --shoot cookies down the row
  --different colored mobs
end

function frogger3:ZombieThinker(unit)
  print((unit.destination - unit:GetAbsOrigin()):Length())
  --if it's within 50 units of the destination,
  if (unit.destination - unit:GetAbsOrigin()):Length() < 300 then
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

--make them into a straight line
local ROW_HEIGHT = 250
function frogger3:SpawnCookieShooters()
  for col = 25, 25 do
      GameMode.games["frogger3"].shooters[col] = {}
      for row = 1, 11 do
          local cookieSpawnLocation = Vector(ORIGIN_X - col * COL_WIDTH, (ROW_BOTTOM - 200) + row * ROW_HEIGHT, 398)
          GameMode.games["frogger3"].shooters[col][row] = CreateUnitByName("shooter", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
          GameMode.games["frogger3"].shooters[col][row].shootAbilityName = "shoot_cookie_level_3"
          local shootAbility = GameMode.games["frogger3"].shooters[col][row]:AddAbility(GameMode.games["frogger3"].shooters[col][row].shootAbilityName)
          shootAbility:SetLevel(1)
          GameMode.games["frogger3"].shooters[col][row].shootLocation = Vector(cookieSpawnLocation.x + 1000, cookieSpawnLocation.y, cookieSpawnLocation.z)
          GameMode.games["frogger3"].shooters[col][row].shootInterval = 13
          GameMode.games["frogger3"].shooters[col][row]:SetThink("ShooterThinker", self)
      end
  end
end

function frogger3:ShooterThinker(unit)
  local shootCookieAbility = unit:FindAbilityByName(unit.shootAbilityName)
  local castPos = unit.shootLocation
  unit:SetCursorPosition(castPos)
  shootCookieAbility:OnSpellStart()
  return unit.shootInterval
end

function frogger3:ClearStage()
  for col = 25, 25 do
    for row = 1, 11 do
      GameMode.games["frogger3"].shooters[col][row]:ForceKill(false)
    end
  end
end

function Frogger3End(trigger)
  local ent = trigger.activator
  if not ent then return end
  if GameMode.games["frogger3"].finished then --nothing; prevent from 2nd and 3rd place finish to trigger the end
  else

    --flag for game thinker
    GameMode.games["frogger3"].finished = true

    --announce
    Notifications:BottomToAll({text = "YOU MADE IT!", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 

    --song
    EmitGlobalSound("next_episode")

    frogger3:ClearStage()

    --[[frogger2:ClearStage(GameMode.games["frogger2"].leaves)]]

    Timers:CreateTimer("level_4_activate", {
      useGameTime = true,
      endTime = 5,
      callback = function()
          level4_2:Start()
          return nil
      end
    })
    

  end
end