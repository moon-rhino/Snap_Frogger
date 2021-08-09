--players can mine
--spawn mines randomly
--last player standing wins
--cooldown

morty2 = class({})

function morty2:WarmUp()
    --set warm up flag
    GameMode.warmUp = true
    Notifications:ClearBottomFromAll()
    Notifications:BottomToAll({text="MORTY" , duration= 20, style={["font-size"] = "45px", color = "orange"}})
    Notifications:BottomToAll({text="WARM UP: Test your abilities" , duration= 20, style={["font-size"] = "45px", color = "white"}})
    --spawn players
    --set up their abilities
    --explain the game
    
    --player table
    GameMode.games["morty2"].players = {}
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
            local bkb = hero:AddAbility("life_stealer_rage")
            bkb:SetLevel(1)
            local skipAbility = hero:AddAbility("skip")
            skipAbility:SetLevel(1)
            --score
            hero.time = 0
            hero.earnedScore = 0
            --offset index to account for lua counting indices from 1
            GameMode.games["morty2"].players[playerID] = hero.time
            --remove particle
            ParticleManager:DestroyParticle( hero.score_effect, true )
          end
        end
    end
    morty2:Rules()
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
                morty2:Start()
                GameMode:ResetSkipForAllPlayers()
                return nil
            else
                counter = counter - 1
                return 1
            end
        end
    })
end

function morty2:Rules()
        Notifications:BottomToAll({text="Dodge mortimer's projectiles." , duration= 20, style={["font-size"] = "45px", color = "white"}})
        Notifications:BottomToAll({text="Q to cookie (enemies too), W to BKB." , duration= 20, style={["font-size"] = "45px", color = "white"}})
end
function morty2:Start()

    --set warm up flag
    GameMode.warmUp = false
    --techies sound

    --kill all players
    --spawn on mines
    for playerID = 0, GameMode.maxNumPlayers-1 do
        if PlayerResource:IsValidPlayerID(playerID) then
          if GameMode.players[playerID] ~= nil then
            local hero = GameMode.players[playerID]
            local gameLocation = GameMode:GetHammerEntityLocation("cookie_party_2_center")
            hero:SetRespawnPosition(gameLocation)
            hero:RespawnHero(false, false)
            GameMode:SetCamera(hero)
            --hero:AddNewModifier(nil, nil, "modifier_magic_immune", { duration = 2 })
            
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
            local mortyEnt = Entities:FindByName(nil, "cookie_party_2_center")
            local mortyEntVector = mortyEnt:GetAbsOrigin()
            --set an owner so it's visible when planted
            GameMode.games["morty2"].morty = CreateUnitByName("morty2", mortyEntVector, true, PlayerResource:GetSelectedHeroEntity(3), PlayerResource:GetSelectedHeroEntity(3), DOTA_TEAM_BADGUYS)
            GameMode.games["morty2"].morty:AddNewModifier(nil, nil, "modifier_invulnerable", {})
            --run thinker
            morty2:Think()
            return nil
        end
    })
end


function morty2:Think()

    local finished = false
    --think every frame
    --if anyone died
    --give them score
    --rank variable
    --local rank = PlayerResource:NumPlayers()
    --local score = 1
    local numAlive = 0
    --local numDead = 0

    --spit timer
    local countdown = 3

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
                GameMode:AddTimeToPlayers()
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
                            GameMode.games["morty2"].players[playerID] = hero.time
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
                            GameMode.games["morty2"].players[playerID] = hero.time
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
                GameMode:RankByTime("morty2")
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
                GameMode:RankByTime("morty2")
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

    Timers:CreateTimer("morty", {
        useGameTime = true,
        endTime = 1,
        callback = function()
            --pick a cast location
            local centerEnt = Entities:FindByName(nil, "cookie_party_2_center")
            local centerEntVector = centerEnt:GetAbsOrigin()

            --set cursor
            local kissAbility = GameMode.games["morty2"].morty:FindAbilityByName("mortimer_kisses_morty")
            local radius_min = kissAbility:GetSpecialValueFor("min_range")
            local radius_max = kissAbility:GetCastRange(Vector(0,0,0), nil)
            local radius = math.random(radius_min, radius_max)
            local angleShoot = math.rad(math.random(1, 360))
        
            local cookiePartyCenter = GameMode:GetHammerEntityLocation("cookie_party_2_center")
            local castLoc = Vector(cookiePartyCenter.x + math.cos(angleShoot) * radius, 
                                        cookiePartyCenter.y + math.sin(angleShoot) * radius, 
                                        cookiePartyCenter.z)

            GameMode.games["morty2"].morty:SetCursorPosition(castLoc)

            --cast ability
            
            kissAbility:OnSpellStart()
            
            if finished then
                GameMode.games["morty2"].morty:ForceKill(false)
                return nil
            else
                if countdown > 0.7 then
                    countdown = countdown - 0.2
                else
                    --skip
                end
                return countdown
            end
        end
    })

end