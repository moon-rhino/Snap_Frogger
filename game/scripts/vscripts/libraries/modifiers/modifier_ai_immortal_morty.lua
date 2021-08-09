--baby morties
--smaller kisses
--attack range = 400
--bomb cookie

modifier_ai_immortal_morty = class({})

local AI_STATE_IDLE = 0
local AI_STATE_AGGRESSIVE = 1
--local AI_STATE_RETURNING = 2

--time it takes to jump
local AI_THINK_INTERVAL = 3

--local moveDelay = 0
--local executingMove = false
--local moveIndex

function modifier_ai_immortal_morty:OnCreated(params)
    -- Only do AI on server
    if IsServer() then
        -- Set initial state
        self.state = AI_STATE_IDLE

        -- Store parameters from AI creation:
        -- unit:AddNewModifier(caster, ability, "modifier_ai", { aggroRange = X, leashRange = Y })
        self.aggroRange = params.aggroRange
        self.leashRange = params.leashRange

        -- Store unit handle so we don't have to call self:GetParent() every time
        --this is HScript
        self.unit = self:GetParent()

        -- Set state -> action mapping
        self.stateActions = {
            [AI_STATE_IDLE] = self.IdleThink,
            [AI_STATE_AGGRESSIVE] = self.AggressiveThink,
            --[AI_STATE_RETURNING] = self.ReturningThink,
        }

        -- Start thinking
        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function modifier_ai_immortal_morty:OnIntervalThink()

    --if stunned,
        --state action = returning
    if self.unit:IsStunned() then
        self.state = AI_STATE_AGGRESSIVE
    else
        -- Execute action corresponding to the current state
        self.stateActions[self.state](self)    
    end
end

function modifier_ai_immortal_morty:IdleThink()
    -- Find any enemy units around the AI unit inside the aggroRange
    --change spell to cast based on range of enemy
    local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false)

    -- If one or more units were found, start attacking the first one
    -- could return 0 even if unit was found
    if #units > 0 then
        self.aggroTarget = units[1] -- Remember who to attack
        self.state = AI_STATE_AGGRESSIVE --State transition
        return -- Stop processing this state
    end

    --if no target, stay in this state
    -- Nothing else to do in Idle state
end

function modifier_ai_immortal_morty:AggressiveThink()
    print("[modifier_ai_immortal_morty:AggressiveThink()] called")

    --move towards target
    --attack or throw a bomb cookie

    local hop = self.unit:FindAbilityByName("cookie_hop")
    local babyKiss = self.unit:FindAbilityByName("baby_kiss")
    --different hop times and distances for every target
    local cookieBomb = self.unit:FindAbilityByName("cookie_bomb")
    --block
    local block = self.unit:FindAbilityByName("block")


    self.unit:MoveToPosition(self.aggroTarget:GetAbsOrigin())
    --does it have a melee attack animation?
    if (self.unit:GetAbsOrigin() - self.aggroTarget:GetAbsOrigin()):Length() > 600 then
        hop:OnSpellStart()
    else
        --stop movement
        self.unit:Stop()
        self.unit:SetCursorPosition(self.aggroTarget:GetAbsOrigin())
        --perhaps bomb cookie on self
        --chance
        math.randomseed(Time())
        local alternateSpell = math.random(7)
        --local alternateSpell = 7
        if alternateSpell <= 5 then
            babyKiss:CastAbility()
        elseif alternateSpell == 6 then
            cookieBomb:CastAbility()
        elseif alternateSpell == 7 then
            block:CastAbility()
        end
    end
            



    --if target is dead then
    if not self.aggroTarget:IsAlive() then
        --return to idle think
        self.state = AI_STATE_IDLE
    end
    --end this thought
    return
end

function modifier_ai_immortal_morty:RestingThink()
    print("[modifier_ai_immortal_morty:RestingThink()] called")
    self.state = AI_STATE_IDLE -- Transition the state to the 'Idle' state(!)
    return -- Stop processing this state
end