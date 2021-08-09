modifier_extra_health = class({})
--------------------------------------------------------------------------------

function modifier_extra_health:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_extra_health:OnCreated( kv )
	self.extra_health_bonus = kv.extraHealth
	self:GetParent():Heal(100, nil)
end


--------------------------------------------------------------------------------

function modifier_extra_health:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
	}
	return funcs
end


--------------------------------------------------------------------------------

function modifier_extra_health:GetModifierExtraHealthBonus( params )
	return self.extra_health_bonus
end
