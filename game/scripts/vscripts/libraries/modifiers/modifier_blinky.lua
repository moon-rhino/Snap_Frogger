modifier_blinky = class({})

local AI_STATE_IDLE = 0
local AI_STATE_CHASE = 1
local AI_STATE_SCATTER = 2
local AI_STATE_FRIGHTENED = 3

local AI_THINK_INTERVAL = 1

local SCATTER_TIME = {}
SCATTER_TIME[1] = 20
SCATTER_TIME[2] = 20
SCATTER_TIME[3] = 20
SCATTER_TIME[4] = 20
local CHASE_TIME = {}
CHASE_TIME[1] = 20
CHASE_TIME[2] = 20
CHASE_TIME[3] = 20
CHASE_TIME[4] = 20

function modifier_blinky:IsHidden()
    return false
end

function modifier_blinky:OnCreated(params)
    -- Only do AI on server
    if IsServer() then
        -- Set initial state
        self.state = AI_STATE_IDLE

        -- Store parameters from AI creation:
        -- unit:AddNewModifier(caster, ability, "modifier_blinky", { aggroRange = X, leashRange = Y })

        -- Store unit handle so we don't have to call self:GetParent() every time
        --this is HScript
        self.unit = self:GetParent()
        
        self.unit.scatterDestination = GameMode:GetHammerEntityLocation("pacman_top_right_corner")

        --unit initializations
        self.unit.level = 1
        self.unit.scatterCountdown = SCATTER_TIME[self.unit.level]
        self.unit.chaseCountdown = CHASE_TIME[self.unit.level]

        -- Set state -> action mapping
        self.stateActions = {
            [AI_STATE_IDLE] = self.IdleThink,
            [AI_STATE_CHASE] = self.ChaseThink,
            [AI_STATE_SCATTER] = self.ScatterThink,
            [AI_STATE_FRIGHTENED] = self.FrightenedThink
        }

        -- Start thinking
        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function modifier_blinky:OnIntervalThink()
    -- Execute action corresponding to the current state
    self.stateActions[self.state](self)    
end

function modifier_blinky:IdleThink()
    --for one player first

    --start moving after a delay
    Timers:CreateTimer("chase_delay", {
        useGameTime = true,
        endTime = 1,
        callback = function()
          local heroTarget = PlayerResource:GetSelectedHeroEntity(0)
          self.target = heroTarget
          --after making a change to the script, you have to call the program twice
          self.unit:MoveToPosition(heroTarget:GetAbsOrigin())
          self.state = AI_STATE_CHASE
          return nil
        end
    })
end

function modifier_blinky:ChaseThink()
    self.unit:MoveToPosition(self.target:GetAbsOrigin())
    --[[if (self.unit.spawnVector - self.unit:GetAbsOrigin()):Length() > self.leashRange then
        self.unit:MoveToPosition(self.unit.spawnVector) --Move back to the spawnpoint
        self.state = AI_STATE_SCATTER --Transition the state to the 'SCATTER' state(!)
        return -- Stop processing this state
    end]]
    
    -- Check if the target has died
    --[[if not self.target:IsAlive() then
        self.unit:MoveToPosition(self.unit.scatterDestination) --Move back to the spawnpoint
        --find another target
        --self.state = AI_STATE_SCATTER --Transition the state to the 'Running' state(!)
        return -- Stop processing this state
    end]]
    
    -- Still in the aggressive state, so do some aggressive stuff.
    self.unit.chaseCountdown = self.unit.chaseCountdown - 1
    if self.unit.chaseCountdown == 0 then
        self.state = AI_STATE_SCATTER
        self.unit.scatterCountdown = SCATTER_TIME[self.unit.level]
        return
    end
    self.unit:MoveToPosition(self.target:GetAbsOrigin())
end

function modifier_blinky:ScatterThink()
    Notifications:BottomToAll({text="scatter", duration=9, style={color="green"}})
    self.unit:MoveToPosition(self.unit.scatterDestination) 
    --four corners
    --top right
    --top left
    --bottom left
    --bottom right
    --head to the top right first
    --boolean 
    --if you're at top right
    --go to the top left
    --lasts for 7 seconds
    self.unit.scatterCountdown = self.unit.scatterCountdown - 1
    if self.unit.scatterCountdown == 0 then
        self.state = AI_STATE_CHASE
        self.unit.level = self.unit.level + 1
        self.unit.chaseCountdown = CHASE_TIME[self.unit.level]
        return
    end
    
end

function modifier_blinky:FrightenedThink()
end