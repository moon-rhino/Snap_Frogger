
modifier_earthshaker_effect = class({})

--------------------------------------------------------------------------------

function modifier_earthshaker_effect:IsHidden()
	return false
end

function modifier_earthshaker_effect:OnCreated( kv )
    print("effect created")
end

function modifier_earthshaker_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_earthshaker_arcana.vpcf"
end

function modifier_earthshaker_effect:StatusEffectPriority()
	return 15
end

--[[function modifier_teleport_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end]]