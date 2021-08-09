--tiles
--jump with channeled cookie
--more tiles
    --leaf
    --bad leaf
    --trap --replace bad leaf
      --lina: light strike array
      --morty: cookie
      --bristleback: quill everyone around you
      --earthshaker: fissure in a line; random per unit
      
    

--summon cookies to fight for you

frogger5 = class({})

local NUM_ROWS = 22
local NUM_COLS = 12

function frogger5:Run()
    GameMode.creeps["frogger5"] = {}
    frogger5:SpawnLeaves()
    frogger5:GrantAbilities()
end

function frogger5:GrantAbilities()
  for playerID = 0, GameMode.numPlayers do
    if PlayerResource:IsValidPlayerID(playerID) then
      local hero = PlayerResource:GetSelectedHeroEntity(playerID)
      GameMode:RemoveAllAbilities(hero)
      local frogger_cookie = hero:AddAbility("cookie_frogger_channeled")
      local frogger_cookie_release = hero:AddAbility("cookie_frogger_channeled_release")
      frogger_cookie:SetLevel(1)
      frogger_cookie_release:SetLevel(1)
    end
  end
end


function frogger5:SpawnLeaves()
  ------------
  -- leaves --
  ------------
  --row start: 4786
  --top: 8489
  GameMode.creeps["frogger5"]['leaves'] = {}
  for leafRow = 1, NUM_ROWS do
    GameMode.creeps["frogger5"]['leaves'][leafRow] = {}
    for leafCol = 1, NUM_COLS do
      print(leafCol .. " " .. leafRow)
      GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol] = {}
      local spawn_location = Vector(3039 + (leafCol - 1) * 300, 1786 + (leafRow) * 300, 384)
      local leafDie = math.random(1, 9)
      if leafDie < 4 then
        GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol] = CreateUnitByName("leaf", spawn_location, true, nil, nil, DOTA_TEAM_BADGUYS)
      else
        --section 2
        if leafRow > 12 then
          local trapLeafDie = math.random(1, 2)
          if trapLeafDie == 1 then
            GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol] = CreateUnitByName("badLeaf", spawn_location, true, nil, nil, DOTA_TEAM_BADGUYS)
          elseif trapLeafDie == 2 then
            GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol] = CreateUnitByName("earthshakerLeaf", spawn_location, true, nil, nil, DOTA_TEAM_BADGUYS)
            local orientationDie = math.random(1,4)
            if orientationDie == 1 then
              --down
              GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol]:SetAngles(0, -90, 0)
            elseif orientationDie == 2 then
              --left
              GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol]:SetAngles(0, -180, 0)
            elseif orientationDie == 3 then
              --up
              GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol]:SetAngles(0, -270, 0)
            else
              --right
              GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol]:SetAngles(0, 0, 0)
            end
            GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol]:AddNewModifier(nil, nil, "modifier_earthshaker_leaf", {trigger_range = 200, orientation = orientationDie, cooldown = 5})
          --elseif trapLeafDie == 3 then
            --GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol] = CreateUnitByName("bristlebackLeaf", spawn_location, true, nil, nil, DOTA_TEAM_BADGUYS)
            
            --GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol]:AddNewModifier(nil, nil, "modifier_bristleback_leaf", {trigger_range = 200})
          end
        else
          GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol] = CreateUnitByName("badLeaf", spawn_location, true, nil, nil, DOTA_TEAM_BADGUYS)
        end
      end
      GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol].location = spawn_location
    end
  end
end

function frogger5:ClearCreeps()
  --leaves
  for leafRow = 1, NUM_ROWS do
    for leafCol = 1, NUM_COLS do
      if GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol] ~= nil then
          --need to pass in the argument to "ForceKill"
          GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol]:ForceKill(false)
          GameMode.creeps["frogger5"]['leaves'][leafRow][leafCol]:RemoveSelf()
      end
    end
  end
end