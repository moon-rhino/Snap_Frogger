function GameMode:Run()

    --turn starts with playerId 0
    --give player ability to roll
    
    --initialize info

    if GameMode.turnPlayerId == GameMode.adminPlayerId then
        GameMode.turnPlayerId = GameMode.turnPlayerId + 1
    end
    local turnHero = PlayerResource:GetSelectedHeroEntity(GameMode.turnPlayerId)
    local turnPlayerName = PlayerResource:GetPlayerName(GameMode.turnPlayerId)

    --notify current turn
    Notifications:ClearTopFromAll()
    Notifications:ClearBottomFromAll()
    Notifications:TopToAll({text="BOARD PHASE", duration= 100.0, style={["font-size"] = "35px", color = "orange"}})
    Notifications:TopToAll({text="TAKE TURNS TO ROLL", duration= 100.0, style={["font-size"] = "35px", color = "orange"}})
    Notifications:TopToAll({text="LAST PERSON TO PLAY SNAPFIRE GOES FIRST", duration= 100.0, style={["font-size"] = "35px", color = "orange"}})
    --Notifications:TopToAll({text=string.format("Turn: %s", turnPlayerName), duration= 30.0, style={["font-size"] = "35px", color = "white"}})
    --Notifications:TopToAll({text=string.format("PRESS 'Q' TO PICK A NUMBER."), duration= 30.0, style={["font-size"] = "35px", color = "white"}})

    --explain how this works
    --press 'q' to roll
    --press 'q' again to pick a number
    --advance that many steps on the board
    local rollAbility = turnHero:AddAbility('roll')
    rollAbility:SetLevel(1)
    local pickAbility = turnHero:AddAbility('pick')
    pickAbility:SetLevel(1)

    

    --what can happen when you're moving?
        --player passes a shop
            --buy items; have effect on board
        --player passes a star
            --if you have enough gold,
                --buy it
            --else,
                --skip
        --player passes nothing

    --when everyone's finished rolling, 
        --give coins according to the tile the player's standing on
        --
    --spawn a monster in the middle
    --kill it to start the minigame

    --set everyone's camera to the player
    --[[for playerId = 0, PlayerResource:NumPlayers()-1 do
        GameMode:SetCamera(playerId, turnHero)
    end]]
    
    --[[GameMode.turnPlayerId = GameMode.turnPlayerId + 1
    if GameMode.turnPlayerId == PlayerResource:NumPlayers() then
        GameMode.turnPlayerId = 0
    end

    while GameMode.turnPlayerId ~= PlayerResource:NumPlayers() do
        if not pauseLoop then



            
            --give ability to roll to player

            rollAbility:OnSpellStart()
            local pauseLoop = true
            Timers:CreateTimer("unpauseLoopAfterDelay", {
                useGameTime = true,
                endTime = 5,
                callback = function()
                  print ("Hello. I'm running after 2 minutes and then every second thereafter.")
                  return 1
                end
              })

            --pass turn to next player
            GameMode.turnPlayerId = GameMode.turnPlayerId + 1
        end
    end]]
end