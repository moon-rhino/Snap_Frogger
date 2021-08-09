modifier_extra_health_morty = class({})
--------------------------------------------------------------------------------

function modifier_extra_health_morty:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_extra_health_morty:OnCreated( kv )
    self.extra_health_bonus = kv.extraHealth
	--self:GetParent():Heal(300000, nil)
end


--------------------------------------------------------------------------------

function modifier_extra_health_morty:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end


--------------------------------------------------------------------------------

--must use "GetModifierExtraHealthBonus" for creeps
function modifier_extra_health_morty:GetModifierHealthBonus( params )
	return self.extra_health_bonus
end

--------------------------------------------------------------------------------

--[[function modifier_extra_health_morty:OnRefresh( kv )

	self.extra_health_bonus = kv.extraHealth
	
end]]

--------------------------------------------------------------------------------

--if not done, effect will linger even after death
--[[function modifier_extra_health_morty:OnDeath( params )
	if IsServer() then
        if params.unit == self:GetParent() then
			self:GetParent():RemoveModifierByName("modifier_extra_health_morty")
		end
	end
	return 0
end]]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------