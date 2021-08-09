--shoots cookies in a circle

modifier_ai_stack = class({})

local AI_THINK_INTERVAL = 3

function modifier_ai_stack:OnCreated(params)
    if IsServer() then
        self.unit = self:GetParent()
        --self.shoot_interval = params.shoot_interval
        self:StartIntervalThink(AI_THINK_INTERVAL)
        --self.aggroRange = params.aggroRange
        --self.unit:FindAbilityByName("shoot_cookies"):StartCooldown(1000)
    end
end

function modifier_ai_stack:OnIntervalThink()
    if self.unit:IsStunned() then
        --nothing
    elseif self.unit:IsAlive() == false then
        --nothing
    else
        --shoot cookies
        local shoot_cookies_ability = self.unit:FindAbilityByName("shoot_cookies")
        shoot_cookies_ability:OnSpellStart()
        shoot_cookies_ability:StartCooldown(1)
        --give score to owner for every cookie hit
    end
end

--[[function modifier_ai_stack:OnDeath(params)
    self.unit:RemoveSelf()
end]]

--heap
--if enemy dies under its effect
--it gets bigger
--"eat" spell
--heal

