-- Remnant state modifier
modifier_fire_remnant_effect = modifier_fire_remnant_effect or class ({})

function modifier_fire_remnant_effect:IsDebuff() return false end
function modifier_fire_remnant_effect:IsHidden() return false end
function modifier_fire_remnant_effect:IsPurgable() return false end

function modifier_fire_remnant_effect:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant.vpcf"
end

function modifier_fire_remnant_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_fire_remnant_effect:StatusEffectPriority()
	return 20
end

function modifier_fire_remnant_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end

function modifier_fire_remnant_effect:CheckState()
	if IsServer() then
		local state = {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true
		}

		return state
	end
end