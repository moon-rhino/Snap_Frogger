modifier_outgoing_damage = class({})

function modifier_outgoing_damage:IsHidden()
	return false
end

function modifier_outgoing_damage:OnCreated( kv )
    print("created")
    -- references
    self.outgoing_damage_percent = kv.outgoing_damage_percent
    
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_outgoing_damage:DeclareFunctions()
	local funcs = {
        --DamageOutgoing & BonusDamageOutgoing don't work
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}

	return funcs
end

--to increase, go above 100
function modifier_outgoing_damage:GetModifierTotalDamageOutgoing_Percentage()
    return self.outgoing_damage_percent
end
