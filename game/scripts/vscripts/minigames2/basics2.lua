basics2 = class({})


local ROW_SECTION_1_START = 2500
local NUM_ROWS_1 = 3
local ROW_SECTION_2_START = 4500
local NUM_ROWS_2 = 5
local NUM_COLS = 12
local WIDTH_ZOMBIES = 300

function basics2:Run() 
    Notifications:BottomToAll({text="BASICS 2" , duration= 8.0, style={["font-size"] = "45px"}})
    Notifications:BottomToAll({text="Check out your new ability: Q" , duration= 8.0, style={["font-size"] = "45px"}})
    --spawn creeps
    --left: 3039.959229
    --right: 6366.871582
    --bottom: 1286.002197
    --top: 8489.068359
    --z: 384.000000
    
    --(6366 - 3039) / 11 = about 300
    
    --width divided into 11 columns
    --section 1
    for rowId = 1, NUM_ROWS_1 do
        GameMode.creeps['basics2'][rowId] = {}
        for colId = 1, NUM_COLS do
            local creep_location = Vector(3039 + ((colId-1)* 300), ROW_SECTION_1_START + ((rowId-1) * 1000), 384)
            GameMode.creeps['basics2'][rowId][colId] = CreateUnitByName("zombie", creep_location, true, nil, nil, DOTA_TEAM_BADGUYS)
            --set angle
            --second parameter turns the unit by the z-axis
            --negative: counter clockwise
            GameMode.creeps['basics2'][rowId][colId]:SetAngles(0, -100, 0)
        end
    end

    --section 2
    for rowId = 1, NUM_ROWS_2 do
        GameMode.creeps['basics2'][rowId + NUM_ROWS_1] = {}
        for colId = 1, NUM_COLS do
            local creep_location = Vector(3039 + ((colId-1)* 300), ROW_SECTION_2_START + ((rowId) * 700), 384)
            GameMode.creeps['basics2'][rowId + NUM_ROWS_1][colId] = CreateUnitByName("zombie", creep_location, true, nil, nil, DOTA_TEAM_BADGUYS)
            --set angle
            --second parameter turns the unit by the z-axis
            --negative: counter clockwise
            GameMode.creeps['basics2'][rowId + NUM_ROWS_1][colId]:SetAngles(0, -100, 0)
        end
    end
end

function basics2:ClearCreeps()
    for rowId = 1, NUM_ROWS_1 + NUM_ROWS_2 do
        for colId = 1, NUM_COLS do
            if GameMode.creeps['basics2'][rowId][colId] ~= nil then
                --need to pass in the argument to "ForceKill"
                GameMode.creeps['basics2'][rowId][colId]:ForceKill(false)
                GameMode.creeps['basics2'][rowId][colId]:RemoveSelf()
            end
        end
    end
end