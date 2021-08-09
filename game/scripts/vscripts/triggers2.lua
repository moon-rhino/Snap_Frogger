function levelFinishTrigger(trigger)
    local ent = trigger.activator
    if not ent then return end
    if GameMode.levelFinished then --nothing; prevent from 2nd and 3rd place finish to trigger the end
    else
  
      --flag for game thinker
      GameMode.levelFinished = true
  
      --announce
      Notifications:BottomToAll({text = "LET IT BANG!", duration= 5.0, style={["font-size"] = "45px", color = "red"}}) 
    
  
      --song
      EmitGlobalSound("next_episode")
    
      Timers:CreateTimer("next_stage", {
        useGameTime = true,
        endTime = 5,
        callback = function()
          if GameMode.level == 1 then
            frogger:ClearStage(GameMode.games["frogger"].blocks, GameMode.games["frogger"].shooters)
            frogger2_perp:Start()
            frogger3_perp:Start()
          elseif GameMode.level == 2 then
            frogger2_perp:ClearStage(GameMode.games["frogger2_perp"].leaves, GameMode.games["frogger2_perp"].shooters)
            frogger3_perp:ClearStage(GameMode.games["frogger3_perp"].cookies, GameMode.games["frogger3_perp"].shooters)
            frogger5_perp:Start()
          elseif GameMode.level == 3 then
            frogger5_perp:ClearStage(GameMode.games["frogger5_perp"].leaves, GameMode.games["frogger5_perp"].shooters)
            level4_2:Start()
          --[[elseif GameMode.level == 4 then
            level4_2:ClearStage()
            level5:Start()]]
          end
          return nil
        end
      })


  
    end
end