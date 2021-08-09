modifier_set_max_move_speed = class({})

function modifier_set_max_move_speed:OnCreated( kv )
    if not IsServer() then return end
    self.limit = kv.limit
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_set_max_move_speed:DeclareFunctions()
	local funcs = {
		--MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}
	return funcs
end

--[[function modifier_set_max_move_speed:GetModifierMoveSpeed_AbsoluteMax()
	return self.moveSpeed
end]]

function modifier_set_max_move_speed:GetModifierMoveSpeed_Limit()
	return self.limit
end

