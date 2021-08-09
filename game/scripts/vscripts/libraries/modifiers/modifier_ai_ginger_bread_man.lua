--casts berserker's call

modifier_ai_ginger_bread_man = class({})

local AI_THINK_INTERVAL = 3

function modifier_ai_ginger_bread_man:OnCreated(params)
    if IsServer() then
        self.unit = self:GetParent()
        self:StartIntervalThink(AI_THINK_INTERVAL)
        --self.aggroRange = params.aggroRange
        local call_ability = self.unit:FindAbilityByName("axe_berserkers_call_custom")
        call_ability:OnSpellStart()
        --call_ability:StartCooldown(10000)
    end
end

function modifier_ai_ginger_bread_man:OnIntervalThink()
    if self.unit:IsStunned() then
        --nothing
    elseif self.unit:IsAlive() == false then
        --nothing
    else
        --cast call
        local call_ability = self.unit:FindAbilityByName("axe_berserkers_call_custom")
        call_ability:OnSpellStart()
        call_ability:StartCooldown(1)
    end
end

--[[function modifier_ai_ginger_bread_man:OnDeath()
    self.unit:RemoveSelf()
end]]

--heap
--if enemy dies under its effect
--it gets bigger
--"eat" spell
--heal

