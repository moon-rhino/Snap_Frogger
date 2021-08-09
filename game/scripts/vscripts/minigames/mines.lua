--players can mine
--spawn mines randomly
--last player standing wins
--cooldown

--score: by finish
--first to die = 1
--second to die = 2
--so on
--thinker on every frame, check if anyone's dead

mines = class({})

function mines:WarmUp()
    --set warm up flag
    GameMode.warmUp = true
    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text="MINES" , duration= 20, style={["font-size"] = "45px", color = "orange"}})
    Notifications:BottomToAll({text="WARM UP: Test your abilities" , duration= 20, style={["font-size"] = "45px", color = "white"}})
    --spawn players
    --set up their abilities
    --explain the game
    
    --player table
    GameMode.games["mines"].players = {}
    for playerID = 0, GameMode.maxNumPlayers-1 do
        if PlayerResource:IsValidPlayerID(playerID) then
          if GameMode.players[playerID] ~= nil then
            local hero = GameMode.players[playerID]
            local warmUpLocation = GameMode:GetHammerEntityLocation("warm_up_center")
            hero:SetRespawnPosition(warmUpLocation)
            hero:RespawnHero(false, false)
            GameMode:SetCamera(hero)
            --undo movement restriction from board
            hero:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
            --add abilities
            GameMode:RemoveAllAbilities(hero)
            --flag for checking dead
            hero.dead = false
            local cookie_no_damage_ability = hero:AddAbility("cookie_no_damage")
            cookie_no_damage_ability:SetLevel(1)
            local skipAbility = hero:AddAbility("skip")
            skipAbility:SetLevel(1)
            --score
            hero.time = 0
            hero.earnedScore = 0
            --offset index to account for lua counting indices from 1
            GameMode.games["mines"].players[playerID] = hero.time
            --remove particle
            ParticleManager:DestroyParticle( hero.score_effect, true )
          end
        end
    end
    mines:Rules()
    local counter = 20
    --start game in 20 seconds
    --unless everyone pressed "skip"
    Timers:CreateTimer("start_game", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            Notifications:ClearTopFromAll()
            Notifications:TopToAll({text=counter , duration= 1, style={["font-size"] = "45px", color = "white"}})
            if GameMode:CheckSkipForAllPlayers() or counter < 0 then
                mines:Start()
                GameMode:ResetSkipForAllPlayers()
                return nil
            else
                counter = counter - 1
                return 1
            end
        end
    })
end

function mines:Start()

    --set warm up flag
    GameMode.warmUp = false
    --techies sound

    --kill all players
    --spawn on mines
    for playerID = 0, GameMode.maxNumPlayers-1 do
        if PlayerResource:IsValidPlayerID(playerID) then
          if GameMode.players[playerID] ~= nil then
            local hero = GameMode.players[playerID]
            local gameLocation = GameMode:GetHammerEntityLocation("mines_center")
            hero:SetRespawnPosition(gameLocation)
            hero:RespawnHero(false, false)
            GameMode:SetCamera(hero)
            hero:AddNewModifier(nil, nil, "modifier_magic_immune", { duration = 2 })
            
            --add abilities
            --GameMode:RemoveAllAbilities(GameMode.players[playerID])
            --local cookie_no_damage_ability = GameMode.players[playerID]:AddAbility("cookie_no_damage")
            --cookie_no_damage_ability:SetLevel(1)
          end
        end
    end

    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text="Ready..." , duration= 2, style={["font-size"] = "45px", color = "white"}})
    Timers:CreateTimer("start", {
        useGameTime = true,
        endTime = 2,
        callback = function()
            Notifications:BottomToAll({text="START!" , duration= 1, style={["font-size"] = "45px", color = "red"}})
            --start miner
            local minerEnt = Entities:FindByName(nil, "mines_techies")
            local minerEntVector = minerEnt:GetAbsOrigin()
            --set an owner so it's visible when planted
            GameMode.games["mines"].miner = CreateUnitByName("techies", minerEntVector, true, PlayerResource:GetSelectedHeroEntity(3), PlayerResource:GetSelectedHeroEntity(3), DOTA_TEAM_BADGUYS)

            --run thinker
            mines:Think()
            return nil
        end
    })
end

function mines:Rules()
    --Notifications:BottomToAll({text="RULES" , duration= 20, style={["font-size"] = "45px", color = "white"}})
    Notifications:BottomToAll({text="Mines will randomly appear." , duration= 20, style={["font-size"] = "45px", color = "white"}})
    Notifications:BottomToAll({text="You can cast a cookie to push yourself or others." , duration= 20, style={["font-size"] = "45px", color = "white"}})
end

function mines:AddTimeToPlayers()
    for playerID = 0, GameMode.maxNumPlayers - 1 do
        if GameMode.players[playerID] ~= nil then
          if PlayerResource:IsValidPlayerID(playerID) then
            local hero = GameMode.players[playerID]
            if hero.dead == false then
                hero.time = hero.time + 0.06
            end
          end
        end
    end
end
  
function mines:Think()

    local finished = false
    --think every frame
    --if anyone died
    --give them score
    --rank variable
    --local rank = PlayerResource:NumPlayers()
    --local score = 1
    local numAlive = 0
    --local numDead = 0

    --bomb timer
    local countdown = 5

    --local deadPlayers = {}

    --rank players by dead time
    --if players have same dead time then
    --they have the same rank

    --assign dead time
    --rank them

    --player table
    --for every player, alive flag
    --if flag is false, stop counting


    local start = true
    Timers:CreateTimer("checkDead", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            if not start then
                mines:AddTimeToPlayers()
            end
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if GameMode.players[playerID] ~= nil then
                  if PlayerResource:IsValidPlayerID(playerID) then
                    local hero = GameMode.players[playerID]
                    if hero.dead == false then
                        if hero:IsAlive() == false then
                            Notifications:BottomToAll({text = string.format("%s is out!", hero.playerName), duration= 1.0, style={["font-size"] = "45px", color = "white"}}) 
                            --hero.score = hero.score + score
                            --hero.rank = rank
                            hero.dead = true
                            GameMode.games["mines"].players[playerID] = hero.time
                            --score = score + 1
                            --rank = rank - 1
                            --numDead = numDead + 1
                            --deadPlayers[playerID] = hero
                        else
                            numAlive = numAlive + 1
                        end
                    end
                  end
                end
            end

            --if more than one person left
            if numAlive > 1 then 
                --continue
                start = false
                numAlive = 0
                return 0.06
            --if one left
            elseif numAlive == 1 then
                --find the player that's alive
                for playerID = 0, GameMode.maxNumPlayers - 1 do
                    if GameMode.players[playerID] ~= nil then
                      if PlayerResource:IsValidPlayerID(playerID) then
                        local hero = GameMode.players[playerID]
                        if hero.dead == false then
                            --increase it slightly to make it more than that of the player who just died
                            hero.time = hero.time + 1
                            GameMode.games["mines"].players[playerID] = hero.time
                            --GameMode.games["mines"].topTime = hero.time
                        end
                        hero:ForceKill(false)
                      end
                    end
                end
                --"finished!"
                --display ranking
                --end game
                Notifications:BottomToAll({text = "Finished! Last man standing", duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
                finished = true
                mines:Rank()
                Timers:CreateTimer("end_game", {
                    useGameTime = true,
                    endTime = 5,
                    callback = function()
                        --GameMode:EndGame2()
                        --GameMode:BoardTurn()
                        GameMode:FlowKeeper()
                      return nil
                    end
                  })
                  return nil
                
            --none left
            else
                Notifications:BottomToAll({text = "Finished! Tie", duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
                finished = true
                mines:Rank()
                Timers:CreateTimer("end_game", {
                    useGameTime = true,
                    endTime = 5,
                    callback = function()
                        --GameMode:EndGame2()
                        --GameMode:BoardTurn()
                        GameMode:FlowKeeper()
                      return nil
                    end
                  })
                  return nil
            end
        end
    })

    Timers:CreateTimer("miner", {
        useGameTime = true,
        endTime = 1,
        callback = function()
            --pick a cast location
            local centerEnt = Entities:FindByName(nil, "mines_center")
            local centerEntVector = centerEnt:GetAbsOrigin()

            --set cursor
            local castLoc = Vector(math.random(-4950, -3170), math.random(-3720, -2100), z)
            --x = -4950 to -3170, y = -3720 to -2100

            GameMode.games["mines"].miner:SetCursorPosition(castLoc)

            --cast ability
            local mineAbility = GameMode.games["mines"].miner:FindAbilityByName("techies_land_mines_custom")
            mineAbility:OnSpellStart()
            
            if finished then
                mines:ClearMines()
                return nil
            else
                if countdown > 1 then
                    countdown = countdown - 0.3
                else
                    --skip
                end
                return countdown
            end
        end
    })

end

function mines:ClearMines()
    --kill miner
    GameMode.games["mines"].miner:ForceKill(false)
    --if miner is removed, then the mines won't go off
    --GameMode.games["mines"].miner:RemoveSelf()
    --spawn huge ogre
    --kill after a few seconds
    local centerEnt = Entities:FindByName(nil, "mines_center")
    local centerEntVector = centerEnt:GetAbsOrigin()
    local cleaner = CreateUnitByName("cleaner", centerEntVector, true, nil, nil, DOTA_TEAM_GOODGUYS)
    cleaner:SetControllableByPlayer(0, false)
    cleaner:SetHullRadius(3000)
    Timers:CreateTimer("killCleaner", {
        useGameTime = true,
        endTime = 5,
        callback = function()
          cleaner:ForceKill(false)
          return nil
        end
      })
    
end

function mines:Rank()
    local rank = 0
    --GameMode.games["mines"].players stores the times
    --local ranking = {}
    --go through list from left to right
    --if number is bigger than the next number, swap
    --else, continue
    --when reaching the end, start again from the left in the index + 1



    --if notification overflows, it stops displaying new messages
    --Notifications:ClearBottomFromAll()
    --order
    for k,v in GameMode:spairs(GameMode.games["mines"].players, function(t,a,b) return t[b] < t[a] end) do
        
        rank = rank + 1
        GameMode.games["mines"].ranking[rank] = k
        local hero = PlayerResource:GetSelectedHeroEntity(k)
        --Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank, hero.playerName, hero.time, hero.score), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        
    end

    local rankWithOverlap = 1
    local score = PlayerResource:NumPlayers()



    --order it again, this time with overlap in ranks
    local rankingWithOverlap = {}
    local tiedPlayers = {}
    local tiedPlayerCount = 0
    for rank, playerID in ipairs(GameMode.games["mines"].ranking) do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local nextHero
        if GameMode.games["mines"].ranking[rank+1] ~= nil then
            nextHero = PlayerResource:GetSelectedHeroEntity(GameMode.games["mines"].ranking[rank+1])
        end
        tiedPlayers[playerID] = hero
        if nextHero == nil then
            --Notifications:BottomToAll({text = "reached the end of rankingWithOverlap", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
            rankingWithOverlap[rankWithOverlap] = {}
            for tiedPlayerPlayerID, tiedPlayer in pairs(tiedPlayers) do
                rankingWithOverlap[rankWithOverlap][tiedPlayerPlayerID] = tiedPlayer
                tiedPlayer.score = tiedPlayer.score + score
                tiedPlayer.earnedScore = score
                tiedPlayerCount = tiedPlayerCount + 1
            end
            rankWithOverlap = rankWithOverlap + tiedPlayerCount
            score = score - tiedPlayerCount
            tiedPlayers = {}
            tiedPlayerCount = 0
        elseif hero.time ~= nextHero.time then
            rankingWithOverlap[rankWithOverlap] = {}
            for tiedPlayerPlayerID, tiedPlayer in pairs(tiedPlayers) do
                rankingWithOverlap[rankWithOverlap][tiedPlayerPlayerID] = tiedPlayer
                tiedPlayer.score = tiedPlayer.score + score
                tiedPlayer.earnedScore = score
                tiedPlayerCount = tiedPlayerCount + 1
            end
            rankWithOverlap = rankWithOverlap + tiedPlayerCount
            score = score - tiedPlayerCount
            tiedPlayers = {}
            tiedPlayerCount = 0
        else
            --continue
        end
    end

    --display
    --1, 2, 3, 4, 5
    --ipairs doesn't work if there are holes between the keys (e.g. 1, 3, 5)
    for rank2, heroes in pairs(rankingWithOverlap) do
        --Notifications:BottomToAll({text = rank2, duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        for playerID, hero in pairs(heroes) do
            Notifications:BottomToAll({text = string.format("%s: %s, %s, %s points", rank2, hero.playerName, hero.time, hero.earnedScore), duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
        end
    end
end
