--NOTES
--MUST SPECIFY DURATION AND AMOUNT OF SLOW THROUGH PARAMETERS

modifier_slow = class({})

function modifier_slow:IsHidden()
    return false
end

function modifier_slow:OnCreated(params)
    if IsServer() then
        --Notifications:BottomToAll({text="slowed", duration=9, style={color="green"}})
        self.unit = self:GetParent()
        self.percentage = params.slowRate
    end
end

--have to declare functions to edit them
function modifier_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.percentage
end