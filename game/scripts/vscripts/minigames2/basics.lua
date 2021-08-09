basics = class({})

local NUM_ROWS = 6
local NUM_COLS = 12

function basics:Run()
    Notifications:BottomToAll({text="BASICS" , duration= 8.0, style={["font-size"] = "45px"}})
    Notifications:BottomToAll({text="GET TO THE TOP" , duration= 8.0, style={["font-size"] = "45px"}})
    --spawn creeps
    --left: 3039.959229
    --right: 6366.871582
    --bottom: 1286.002197
    --top: 8489.068359
    --z: 384.000000
    
    --(6366 - 3039) / 11 = about 300
    
    --width divided into 11 columns
    for rowId = 1, NUM_ROWS do
        GameMode.creeps['basics'][rowId] = {}
        --pick a random number
        --both inclusive
        --edges are hard to tell; add 3
        local skip_id = math.random(1 + 3, NUM_COLS - 3)
        for colId = 1, NUM_COLS do
            --skip a creep
            if colId == skip_id then
                --skip
            else
                local creep_location = Vector(3039 + ((colId-1)* 300), 2500 + ((rowId-1) * 1000), 384)
                GameMode.creeps['basics'][rowId][colId] = CreateUnitByName("zombie", creep_location, true, nil, nil, DOTA_TEAM_BADGUYS)
                --set angle
                --second parameter turns the unit by the z-axis
                --negative: counter clockwise
                GameMode.creeps['basics'][rowId][colId]:SetAngles(0, -100, 0)
            end
        end
    end
end

function basics:ClearCreeps()
    for rowId = 1, NUM_ROWS do
        for colId = 1, NUM_COLS do
            if GameMode.creeps['basics'][rowId][colId] ~= nil then
                --need to pass in the argument to "ForceKill"
                GameMode.creeps['basics'][rowId][colId]:ForceKill(false)
                GameMode.creeps['basics'][rowId][colId]:RemoveSelf()
                
            end
        end
    end
end