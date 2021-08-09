modifier_status_resistance = class({})

function modifier_status_resistance:OnCreated( kv )
    if not IsServer() then return end
    self.resistance = kv.resistance
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_status_resistance:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
	}
	return funcs
end

function modifier_status_resistance:GetModifierStatusResistance()
	return self.resistance
end

