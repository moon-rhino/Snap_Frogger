modifier_set_min_move_speed = class({})

function modifier_set_min_move_speed:OnCreated( kv )
    if not IsServer() then return end
    self.min = kv.min
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_set_min_move_speed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
	}
	return funcs
end

function modifier_set_min_move_speed:GetModifierMoveSpeed_AbsoluteMin()
	return self.min
end
