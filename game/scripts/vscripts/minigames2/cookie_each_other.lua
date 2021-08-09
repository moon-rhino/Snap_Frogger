cookie_each_other = class({})

function cookie_each_other:Run()
    Notifications:BottomToAll({text="LEVEL3: DODGE BALL" , duration= 8.0, style={["font-size"] = "45px"}})
    cookie_each_other.finished = false
    cookie_each_other:SpawnNPCs()
end

function cookie_each_other:SpawnNPCs()
    --projectile types
    --magnus shockwave
    --earthshaker fissure
    --lina fire slave

    --kite a monster
    
