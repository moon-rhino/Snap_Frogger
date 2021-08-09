--players play one lane per player
--big golem: step twice

ddr = class({})
local NUM_COLS = 5
local SPAWN_INTERVAL = 1
local SONG_NAME

function ddr:Run()
    Notifications:BottomToAll({text="DDR" , duration= 8.0, style={["font-size"] = "45px"}})
    Notifications:BottomToAll({text="JUMP TO THE BEAT" , duration= 8.0, style={["font-size"] = "45px"}})
    GameMode.creeps["ddr"] = {}
    --line up players to the column
    --randomize spawns on every beat
    ddr:SetUp()
end

function ddr:SetUp()
    EmitGlobalSound("dust")
    ddr:SpawnCreeps()
end

function ddr:SpawnCreeps()
    for lane = 1, 2 do
    Timers:CreateTimer(string.format("spawn_creep_lane_%s", lane), {
        useGameTime = true,
        endTime = 0,
        callback = function()
            ddr:SpawnCreep(lane)
            return SPAWN_INTERVAL
        end
    })
    end
end

function ddr:SpawnCreep(lane)
    local spawnLocation = Vector(3039 + (lane * 500), 8000, 384)
    GameMode.creeps["ddr"][lane] = CreateUnitByName("npc_dota_neutral_mud_golem", spawnLocation, true, hero, hero, DOTA_TEAM_BADGUYS)
    GameMode.creeps["ddr"][lane]:SetControllableByPlayer(0, false)
    Timers:CreateTimer(string.format("move_delay_%s", lane), {
        useGameTime = true,
        endTime = 0.2,
        callback = function()
            GameMode.creeps["ddr"][lane]:MoveToPosition(Vector(3039 + (lane * 500), 1300, 384))
            return nil
        end
    })
end

function ddr:SpawnOneLineOfCreeps()
    local spawnLocation
    local hero = PlayerResource:GetSelectedHeroEntity(0)
    local counter = 0
    GameMode.creeps["ddr"][1] = {}
    GameMode.creeps["ddr"][2] = {}
    GameMode.creeps["ddr"][3] = {}
    GameMode.creeps["ddr"][4] = {}
    Timers:CreateTimer("spawn_creeps", {
        useGameTime = true,
        endTime = 0,
        callback = function()
                counter = counter + 1
                spawnLocation = Vector(3039, 8000, 384)
                GameMode.creeps["ddr"][1][counter] = CreateUnitByName("npc_dota_neutral_mud_golem", spawnLocation, true, hero, hero, DOTA_TEAM_BADGUYS)
                GameMode.creeps["ddr"][1][counter]:SetControllableByPlayer(0, false)
                Timers:CreateTimer(string.format("move_delay_%s", 1), {
                    useGameTime = true,
                    endTime = 0.2,
                    callback = function()
                        GameMode.creeps["ddr"][1][counter]:MoveToPosition(Vector(3039, 1300, 384))
                        return nil
                    end
                })
            return 1
        end
    })
end


function ddr:End()
end