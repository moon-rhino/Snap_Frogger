modifier_move_speed = class({})

function modifier_move_speed:OnCreated( kv )
    if not IsServer() then return end
    self.move_speed_bonus = kv.move_speed_bonus
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_move_speed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_move_speed:GetModifierMoveSpeedBonus_Percentage()
	return self.move_speed_bonus
end

