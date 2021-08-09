--one of the players is morty
--the rest try to take him down
--if morty kills everyone, morty's player wins
--if everyone kills morty, winner is based on damage dealt
function GameMode:Morty()
    --set seed for mortyPlayerID picking
    math.randomseed(Time())



    --play sound
    EmitGlobalSound('snack_time')      

    --notification
    Notifications:BottomToAll({text = "Morty", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
    Notifications:BottomToAll({text = "Deal the most damage to win", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
  


    --spawn everyone
    local numHunters = GameMode.numPlayers 
    --pick a playerID at random to be morty
    local mortyPlayerID = math.random(0, 7)
    while PlayerResource:IsValidPlayerID(mortyPlayerID) == false do
        --pick again
        --don't use "local" again
        mortyPlayerID = math.random(0, 7)
    end
    GameMode.games["morty"].mortyID = mortyPlayerID
    

    --numHunters = numHunters - 1
    --assign morty randomly first

    -----------
    -- Morty --
    -----------

    --spawn
    local mortySpawnEnt = Entities:FindByName(nil, "morty_center")
    local mortySpawnEntVector = mortySpawnEnt:GetAbsOrigin()
    --to make a custom hero, its ID and name has to match

    --save player's current xp
    local mortyPlayer = PlayerResource:GetSelectedHeroEntity(mortyPlayerID)
    mortyPlayer:ForceKill(false)
    GameMode.games["morty"].mortyLevel = mortyPlayer:GetLevel()
    GameMode.teams[mortyPlayer:GetTeam()].xp = mortyPlayer:GetCurrentXP()
    local morty = PlayerResource:ReplaceHeroWith(mortyPlayerID, "npc_dota_hero_tidehunter", PlayerResource:GetGold(mortyPlayerID), 0)
    GameMode.games["morty"].morty = morty
    morty:SetDeathXP(0)
    --will spawn at the board; set him on the morty board
    --SetAbsOrigin() moves hero across the board
    --morty spawned on the board, and then was moved across the trigger_hurt zone to the morty board
    --morty:ForceKill(false)
    morty:SetRespawnPosition(mortySpawnEntVector)
    morty:RespawnHero(false, false)

    --level up abilities
    --0 based index
    local abil = morty:GetAbilityByIndex(0)
    abil:SetLevel(1)
    abil = morty:GetAbilityByIndex(1)
    abil:SetLevel(1)
    abil = morty:GetAbilityByIndex(2)
    abil:SetLevel(1)
    --in hero_custom.txt, the ability is on "Ability6"
    abil = morty:GetAbilityByIndex(5)
    abil:SetLevel(1)
    --ravage is added by default
    --morty:RemoveAbility("tidehunter_ravage")

    --modifiers
    morty:AddNewModifier(nil, nil, "modifier_extra_health_morty", { extraHealth = 1500 * (GameMode.numPlayers - 1) })

    -------------
    -- Hunters --
    -------------

    local mortyStartEnt = Entities:FindByName(nil, "morty_start")
    local mortyStartEntVector = mortyStartEnt:GetAbsOrigin()

    for teamNumber = 6, 13 do
        if GameMode.teams[teamNumber] ~= nil then
            
            for playerID = 0, GameMode.maxNumPlayers - 1 do
                if PlayerResource:IsValidPlayerID(playerID) then
                    
                    --if playerID matches morty player's id then



                    if playerID == mortyPlayerID then
                        --skip
                    elseif GameMode.teams[teamNumber][playerID] ~= nil then
                        
                        
                        --local heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
                        if numHunters == 0 then
                            --break
                        else
                            local heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
                            heroEntity:ForceKill(false)
                            --spawn
                            --local mortyStartEnt = Entities:FindByName(nil, "morty_start")
                            --local mortyStartEntVector = mortyStartEnt:GetAbsOrigin()
                            heroEntity:SetRespawnPosition(mortyStartEntVector)
                            heroEntity:RespawnHero(false, false)
                            --set team
                            --2 == good_guys
                            heroEntity.originalTeam = heroEntity:GetTeam()
                            heroEntity:SetTeam(2)
                            --items
                            GameMode:RemoveAllItems(heroEntity)
                            --abilities
                            GameMode:RemoveAllAbilities(heroEntity)
                            --morty ends abruptly
                            GameMode:AddAllOriginalAbilities(heroEntity)
                            --set camera
                            GameMode:SetCamera(heroEntity)
                            --set numHunters to 1 less
                            numHunters = numHunters - 1
                            --xp
                            heroEntity:SetDeathXP(0)

                        end
                    end
                end
            end
        end
    end




    --record damage done by hunters to morty player
    for attackerID = 0, GameMode.maxNumPlayers-1 do
        if attackerID == mortyPlayerID then
            --skip
        elseif PlayerResource:IsValidPlayerID(attackerID) then
            local attackerEntity = PlayerResource:GetSelectedHeroEntity(attackerID)
            local attackerDamageDonePrev = PlayerResource:GetDamageDoneToHero(attackerID, GameMode.games["morty"].morty:GetPlayerID())
            attackerEntity.damageDonePrev = attackerDamageDonePrev
        end
    end
  
    GameMode:MortyThinker()
    --drop loot --rapier
end
  
--if all hunters dead,
    --morty wins
--else if morty dead,
    --whoever dealt the most damage to morty wins
function GameMode:MortyThinker()
  
    local finished = false

    --vision
    Timers:CreateTimer("fow_vision", {
        useGameTime = false,
        endTime = 0,
        callback = function()
            local mortyStartEnt = Entities:FindByName(nil, "morty_start")
            local mortyStartEntVector = mortyStartEnt:GetAbsOrigin()
            for teamNumber = 2, 13 do
                AddFOWViewer(teamNumber, mortyStartEntVector, 10000, 10, false)
            end
            if not finished then
                return 9
            else
                return nil
            end
        end
    })

    --thinker
    Timers:CreateTimer("checkFinished", {
        useGameTime = false,
        endTime = 1,
        callback = function()

            local morty = GameMode.games["morty"].morty
            
            --check how many players are alive
            local numHuntersAlive = GameMode.numPlayers - 1
            for attackerID = 0, GameMode.maxNumPlayers-1 do
                if attackerID == morty:GetPlayerID() then
                    --skip
                elseif PlayerResource:IsValidPlayerID(attackerID) then
                    local attackerEntity = PlayerResource:GetSelectedHeroEntity(attackerID)
                    if not attackerEntity:IsAlive() then
                        numHuntersAlive = numHuntersAlive - 1
                    end
                end
            end

  
            --if morty is dead,
            if not morty:IsAlive() then
                --whoever dealt the most damage to morty wins
                --record damage done by hunters to morty player
                for attackerID = 0, GameMode.maxNumPlayers-1 do
                    if attackerID == morty:GetPlayerID() then
                        --skip
                    elseif PlayerResource:IsValidPlayerID(attackerID) then
                        local attackerEntity = PlayerResource:GetSelectedHeroEntity(attackerID)
                        local attackerDamageDoneFinal = PlayerResource:GetDamageDoneToHero(attackerID, morty:GetPlayerID())
                        
                        attackerEntity.damageDoneFinal = attackerDamageDoneFinal - attackerEntity.damageDonePrev
                    end
                end

                --find hunter who did the most damage
                local mostDamage = 0
                --will be set to some value
                local mostDamageAttacker = nil

                for attackerID = 0, GameMode.maxNumPlayers-1 do
                    if attackerID == morty:GetPlayerID() then
                        --skip
                    elseif PlayerResource:IsValidPlayerID(attackerID) then
                        local attackerEntity = PlayerResource:GetSelectedHeroEntity(attackerID)
                        if attackerEntity.damageDoneFinal > mostDamage then
                            mostDamage = attackerEntity.damageDoneFinal
                            mostDamageAttacker = attackerEntity
                        end
                    end
                end


                --if morty died before getting attacked, winner will be nil
                if mostDamageAttacker == nil then
                    --assign a random winner
                    --playerID gets assigned in increasing order of 1 -> 7 players = playerIDs from 0 to 6
                    local randomHunterID = math.random(0, GameMode.maxNumPlayers) - 1
                    --if ID is the same as morty player's, 
                    while randomHunterID == morty:GetPlayerID() do
                        --pick again
                        local randomHunterID = math.random(0, GameMode.maxNumPlayers) - 1
                    end
                    mostDamageAttacker = PlayerResource:GetSelectedHeroEntity(randomHunterID)
                end
          
                --that hunter wins
                local winner = mostDamageAttacker

                --set team back to original
                for hunterID = 0, GameMode.maxNumPlayers-1 do
                    if hunterID == morty:GetPlayerID() then
                        --skip
                    elseif PlayerResource:IsValidPlayerID(hunterID) then
                        local hunterEntity = PlayerResource:GetSelectedHeroEntity(hunterID)
                        hunterEntity:SetTeam(hunterEntity.originalTeam)
                    end
                end

                --announce winner
                Notifications:BottomToAll({text = "Winner! ", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
                Notifications:BottomToAll({text = GameMode.teamNames[winner:GetTeam()], duration= 5.0, style={["font-size"] = "45px", color = GameMode.teamColors[winner:GetTeam()]}, continue=true})
          
                --assign score
                GameMode.teams[winner:GetTeam()].score = GameMode.teams[winner:GetTeam()].score + 1

                --drop rapier / bubble shield
                local rapier = CreateItem("item_rapier", nil, nil)
                --even if player is dead, you should be able to get his location
                local spawnLoc = GameMode.games["morty"].morty:GetAbsOrigin()
                --destroy item if not picked up?
                local itemPhysical = CreateItemOnPositionSync(spawnLoc, rapier)
                local containedItem = itemPhysical:GetContainedItem()
                --GameMode.mortyLoot = containedItem

                --after 20 seconds, destroy it

                --disable rapier in shop
                --done
                
                --endgame in 7 seconds
                --announce
                Notifications:BottomToAll({text = "7 seconds until returning to the board", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
                Timers:CreateTimer({
                    endTime = 7, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                    callback = function()
                        --revert mortyPlayer back to snapfire
                        local mortyPlayerID = GameMode.games["morty"].morty:GetPlayerID()
                        --player will respawn at the location of death
                        PlayerResource:ReplaceHeroWith(mortyPlayerID, "npc_dota_hero_snapfire", PlayerResource:GetGold(mortyPlayerID), PlayerResource:GetTotalEarnedXP(mortyPlayerID))
                        --GameMode.teams[PlayerResource:GetSelectedHeroEntity(mortyPlayerID)][mortyPlayerID]:SetRespawnLocation
                        
                        --check if anyone picked up the loot
                        --it could have been the morty player
                        for playerID = 0, GameMode.maxNumPlayers-1 do
                            if PlayerResource:IsValidPlayerID(playerID) then
                                local heroEntity = PlayerResource:GetSelectedHeroEntity(playerID)
                                --loop through the inventory
                                for itemSlot = 0, 9 do
                                    if heroEntity:GetItemInSlot(itemSlot) == containedItem then
                                        GameMode.teams[heroEntity:GetTeam()].items[10] = heroEntity:TakeItem(heroEntity:GetItemInSlot(itemSlot))
                                    end
                                end
                            end
                        end


                        GameMode:EndGame()
                        finished = true
                    end
                })

                --stop thinker
                return nil
  
            --if all the hunters are dead,
            elseif numHuntersAlive == 0 then
                --morty wins
                local winner = GameMode.games["morty"].morty

                --announce winner
                Notifications:BottomToAll({text = "Winner! ", duration= 5.0, style={["font-size"] = "45px", color = "white"}}) 
                Notifications:BottomToAll({text = GameMode.teamNames[winner:GetTeam()], duration= 5.0, style={["font-size"] = "45px", color = GameMode.teamColors[winner:GetTeam()]}, continue=true})
          
                --morty player's team will not change
                --assign score
                GameMode.teams[winner:GetTeam()].score = GameMode.teams[winner:GetTeam()].score + 1

                --set team back to original
                for hunterID = 0, GameMode.maxNumPlayers-1 do
                    if hunterID == morty:GetPlayerID() then
                        --skip
                    elseif PlayerResource:IsValidPlayerID(hunterID) then
                        local hunterEntity = PlayerResource:GetSelectedHeroEntity(hunterID)
                        hunterEntity:SetTeam(hunterEntity.originalTeam)
                    end
                end
  
                --revert morty player back to snapfire
                local winnerID = winner:GetPlayerID()
                --when hero was replaced, it was calling "OnHeroInGame" in which the score was being reset
                --tidehunter's xp will be 0 
                local newSnapfire = PlayerResource:ReplaceHeroWith(winnerID, "npc_dota_hero_snapfire", PlayerResource:GetGold(winnerID), PlayerResource:GetTotalEarnedXP(winnerID))

                for abilityIndex = 0, 21 do
                    if newSnapfire:GetAbilityByIndex(abilityIndex) ~= nil then
                        newSnapfire:RemoveAbilityByHandle(newSnapfire:GetAbilityByIndex(abilityIndex))
                    end
                end
                GameMode:EndGame()
                finished = true
                --stop thinker
                return nil
            end
        return 1
        end
    })
    --declare him as the winner
    --else, if morty's dead
    --check how much damage was dealt by players
    --player with top damage wins
    --on death, drop rapier / bubble shield
end