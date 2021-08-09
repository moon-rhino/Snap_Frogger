--stay still
--look for enemies in radius
--if enemy found, chase it
--if it's dead, return to its original position
    --during return, look for enemy

modifier_ai_chase = class({})

local AI_STATE_IDLE = 0
local AI_STATE_AGGRESSIVE = 1
local AI_STATE_RETURNING = 2

local AI_THINK_INTERVAL = 0.5
local RETURNING_MOVE_SPEED = 300

function modifier_ai_chase:OnCreated(params)
    -- Only do AI on server
    if IsServer() then
        -- Set initial state
        self.state = AI_STATE_IDLE

        -- Store parameters from AI creation:
        -- unit:AddNewModifier(caster, ability, "modifier_ai", { aggroRange = X, leashRange = Y })
        self.aggroRange = params.aggroRange
        self.baseMoveSpeed = params.base_move_speed

        -- Store unit handle so we don't have to call self:GetParent() every time
        --this is HScript
        self.unit = self:GetParent()
        self.unit.spawnVector = Vector(params.leashLocationX, params.leashLocationY, params.leashLocationZ)

        -- Set state -> action mapping
        self.stateActions = {
            [AI_STATE_IDLE] = self.IdleThink,
            [AI_STATE_AGGRESSIVE] = self.AggressiveThink,
            [AI_STATE_RETURNING] = self.ReturningThink,
        }

        -- Start thinking
        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function modifier_ai_chase:OnIntervalThink()
    -- Execute action corresponding to the current state
    self.stateActions[self.state](self)    
end

function modifier_ai_chase:IdleThink()
    self.unit:SetBaseMoveSpeed(self.baseMoveSpeed)
    -- Find any enemy units around the AI unit inside the aggroRange
    local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false)

    -- If one or more units were found, start attacking the first one
    if #units > 0 then
        self.aggroTarget = units[1] -- Remember who to attack
        --check self.unit is an HScript
        self.unit:MoveToTargetToAttack(self.aggroTarget) --Start attacking
        self.state = AI_STATE_AGGRESSIVE --State transition
        return -- Stop processing this state
    end

    -- Nothing else to do in Idle state
end

function modifier_ai_chase:AggressiveThink()
    self.unit:SetBaseMoveSpeed(self.baseMoveSpeed)
    -- Check if the target has died
    if not self.aggroTarget:IsAlive() then
        self.unit:MoveToPosition(self.unit.spawnVector) --Move back to the spawnpoint
        self.state = AI_STATE_RETURNING --Transition the state to the 'Returning' state(!)
        return -- Stop processing this state
    end
    
    -- Still in the aggressive state, so do some aggressive stuff.
    self.unit:MoveToTargetToAttack(self.aggroTarget)
end

function modifier_ai_chase:ReturningThink()
    self.unit:SetBaseMoveSpeed(RETURNING_MOVE_SPEED)
    -- Check if the AI unit has reached its spawn location yet
    if (self.unit.spawnVector - self.unit:GetAbsOrigin()):Length() < 10 then
        self.state = AI_STATE_IDLE -- Transition the state to the 'Idle' state(!)
        return -- Stop processing this state
    else
        -- Find any enemy units around the AI unit inside the aggroRange
        local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false)

        -- If one or more units were found, start attacking the first one
        if #units > 0 then
            self.aggroTarget = units[1] -- Remember who to attack
            --check self.unit is an HScript
            self.unit:MoveToTargetToAttack(self.aggroTarget) --Start attacking
            self.state = AI_STATE_AGGRESSIVE --State transition
            return -- Stop processing this state
        end
    end

    -- If not at return position yet, try to move there again
    self.unit:MoveToPosition(self.unit.spawnVector)
end