frogger3_perp = class({})

LinkLuaModifier("modifier_axe", "libraries/modifiers/modifier_axe", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_set_max_move_speed", "libraries/modifiers/modifier_set_max_move_speed", LUA_MODIFIER_MOTION_NONE )

local COL_MAX = 11
local ROW_MIN = 24
local ROW_MAX = 45

function frogger3_perp:Start()
    --Notifications:TopToAll({text = "LEVEL 3: CROSS THE RIVER", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 

    GameMode.games["frogger3_perp"] = {}
    GameMode.levelFinished = false
    GameMode.games["frogger3_perp"].cookies = {}
    GameMode.games["frogger3_perp"].shooters = {}
    GameMode.games["frogger3_perp"].originX = GameMode:GetHammerEntityLocation("frogger_bottom_right").x
    GameMode.games["frogger3_perp"].originY = GameMode:GetHammerEntityLocation("frogger_bottom_right").y
    GameMode.games["frogger3_perp"].leftX = GameMode:GetHammerEntityLocation("frogger_bottom_left").x
    GameMode.games["frogger3_perp"].rowHeight = (GameMode:GetHammerEntityLocation("frogger_top_right").y - GameMode:GetHammerEntityLocation("frogger_bottom_right").y) / ROW_MAX
    GameMode.games["frogger3_perp"].colWidth = (GameMode:GetHammerEntityLocation("frogger_top_right").x - GameMode:GetHammerEntityLocation("frogger_top_left").x) / COL_MAX

    for playerID = 0, 7 do
        if PlayerResource:IsValidPlayerID(playerID) then
            GameMode.testSpawnLoc = Vector(
                GameMode.games["frogger3_perp"].originX-500, 
                GameMode.games["frogger3_perp"].originY + ROW_MIN * GameMode.games["frogger3_perp"].rowHeight, 
                398
            )

            --don't need to spawn; part of level 2


            --local hero = PlayerResource:GetSelectedHeroEntity(0)
            --hero:SetAbsOrigin(GameMode.testSpawnLoc)
            --[[local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            local spawnLocation = GameMode:GetHammerEntityLocation("level_3_start")
            hero.respawnLocation = spawnLocation
            GameMode:SetPlayerOnLocation(hero, spawnLocation)
            GameMode:RemoveAllAbilities(hero)
            local cookieAbility = hero:AddAbility("cookie_frogger_channeled")
            cookieAbility:SetLevel(1)
            local cookieReleaseAbility = hero:AddAbility("cookie_frogger_channeled_release")
            cookieReleaseAbility:SetLevel(1)]]
            --give players cookie channel jump ability
        end
    end




    
    frogger3_perp:SpawnCookies()
    frogger3_perp:SpawnCookieShooters(GameMode.games["frogger3_perp"].shooters)
end

function frogger3_perp:SpawnCookies()

  ----------
  -- logs --
  ----------
  --same as zombies except very scarce space in between
  --must jump into the space to cross
  --consistent spaces in between
  --consistent directions alternate between every row
  for row = ROW_MIN+1, ROW_MAX-1 do
    GameMode.games["frogger3_perp"].cookies[row] = {}
    --GameMode.games["frogger3_perp"].cookies[col] = {}
    --local speed = math.random(150, 200)
    local speed = math.random(50, 75)
    local cookieRightLocation = Vector(
        GameMode.games["frogger3_perp"].originX, 
        GameMode.games["frogger3_perp"].originY + row * GameMode.games["frogger3_perp"].rowHeight, 
        398
    )
    local cookieLeftLocation = Vector(
        GameMode.games["frogger3_perp"].leftX, 
        GameMode.games["frogger3_perp"].originY + row * GameMode.games["frogger3_perp"].rowHeight, 
        398
    )
    local side = math.random(2)

    --bunch
    Timers:CreateTimer(string.format("spawn_logs_row_%s", row), {
      useGameTime = true,
      endTime = 0,
      callback = function()
        if not GameMode.levelFinished and GameMode.level == 2 then
          local bunch = math.random(3, 5)
          local bunchCount = 0
          local space
          space = 17
          Timers:CreateTimer(string.format("spawn_log_component_row_%s", row), {
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
                    GameMode.games["frogger3_perp"].cookies[row][bunchCount] = CreateUnitByName("redPanda", cookieRightLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                    GameMode.games["frogger3_perp"].cookies[row][bunchCount]:AddNewModifier(nil, nil, "modifier_axe", {aggroRange = 500})
                  else
                    GameMode.games["frogger3_perp"].cookies[row][bunchCount] = CreateUnitByName("water", cookieRightLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  end
                  GameMode.games["frogger3_perp"].cookies[row][bunchCount].row = row
                  GameMode.games["frogger3_perp"].cookies[row][bunchCount].destination = cookieLeftLocation
                else
                  if redDie == 1 then
                    GameMode.games["frogger3_perp"].cookies[row][bunchCount] = CreateUnitByName("redPanda", cookieLeftLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                    GameMode.games["frogger3_perp"].cookies[row][bunchCount]:AddNewModifier(nil, nil, "modifier_axe", {aggroRange = 500})
                  else
                    GameMode.games["frogger3_perp"].cookies[row][bunchCount] = CreateUnitByName("water", cookieLeftLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
                  end
                  GameMode.games["frogger3_perp"].cookies[row][bunchCount].row = row
                  GameMode.games["frogger3_perp"].cookies[row][bunchCount].destination = cookieRightLocation
                end
                GameMode.games["frogger3_perp"].cookies[row][bunchCount]:SetBaseMoveSpeed(speed)
                GameMode.games["frogger3_perp"].cookies[row][bunchCount]:SetThink("ZombieThinker", self)
                --use this to set the movement speed
                GameMode.games["frogger3_perp"].cookies[row][bunchCount].row = row
                GameMode.games["frogger3_perp"].cookies[row][bunchCount]:AddNewModifier(nil, nil, "modifier_set_max_move_speed", {
                  limit = speed
                })
                --rate the cookie spawns within each log
                return 3.5
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

function frogger3_perp:ZombieThinker(unit)
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
function frogger3_perp:SpawnCookieShooters(shooterTable)
    for row = ROW_MAX, ROW_MAX do
        shooterTable[row] = {}
        for col = 1, COL_MAX do
            local cookieSpawnLocation = Vector(
                GameMode.games["frogger3_perp"].originX - col * GameMode.games["frogger3_perp"].colWidth, 
                GameMode.games["frogger3_perp"].originY + row * GameMode.games["frogger3_perp"].rowHeight, 
                398
            )
            shooterTable[row][col] = CreateUnitByName("shooter", cookieSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
            GameMode.games["frogger3_perp"].shooters[row][col].shootAbilityName = "shoot_cookie_level_3"
            local shootAbility = GameMode.games["frogger3_perp"].shooters[row][col]:AddAbility(GameMode.games["frogger3_perp"].shooters[row][col].shootAbilityName)
            shootAbility:SetLevel(1)
            GameMode.games["frogger3_perp"].shooters[row][col].shootLocation = Vector(cookieSpawnLocation.x, cookieSpawnLocation.y - 1000, cookieSpawnLocation.z)
            GameMode.games["frogger3_perp"].shooters[row][col].shootInterval = 13
            GameMode.games["frogger3_perp"].shooters[row][col]:SetThink("ShooterThinker", self)
        end
    end
end

function frogger3_perp:ShooterThinker(unit)
  local shootCookieAbility = unit:FindAbilityByName(unit.shootAbilityName)
  local castPos = unit.shootLocation
  unit:SetCursorPosition(castPos)
  shootCookieAbility:OnSpellStart()
  return unit.shootInterval
end

function frogger3_perp:ClearStage(cookieTable, shooterTable)
    for row = ROW_MIN+1, ROW_MAX-1 do
        for cookieId, cookie in pairs(cookieTable[row]) do
            cookie:ForceKill(false)
            cookie:RemoveSelf()
        end
    end

    for row = ROW_MAX, ROW_MAX do
        for col = 1, COL_MAX do
            shooterTable[row][col]:ForceKill(false)
        end
    end
end

function frogger3_perpEnd(trigger)
  local ent = trigger.activator
  if not ent then return end
  if GameMode.games["frogger3_perp"].finished then --nothing; prevent from 2nd and 3rd place finish to trigger the end
  else

    --flag for game thinker
    GameMode.games["frogger3_perp"].finished = true

    --announce
    Notifications:BottomToAll({text = "YOU MADE IT!", duration= 5.0, style={["font-size"] = "45px", color = "orange"}}) 

    --song
    EmitGlobalSound("next_episode")

    frogger3_perp:ClearStage()

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