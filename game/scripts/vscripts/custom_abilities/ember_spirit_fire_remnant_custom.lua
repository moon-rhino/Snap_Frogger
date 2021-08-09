ember_spirit_fire_remnant_custom = class({})

LinkLuaModifier("ember_spirit_fire_remnant_custom_state", "custom_abilities/ember_spirit_fire_remnant_custom_state", LUA_MODIFIER_MOTION_NONE)

function ember_spirit_fire_remnant_custom:OnSpellStart()
    --point target
    --send a remnant to that location
    --create unit
    --invulnerable, no collision, 
end

-- Remnant state modifier
ember_spirit_fire_remnant_custom_state = ember_spirit_fire_remnant_custom_state or class ({})

function ember_spirit_fire_remnant_custom_state:IsDebuff() return false end
function ember_spirit_fire_remnant_custom_state:IsHidden() return false end
function ember_spirit_fire_remnant_custom_state:IsPurgable() return false end

function ember_spirit_fire_remnant_custom_state:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant.vpcf"
end

function ember_spirit_fire_remnant_custom_state:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function ember_spirit_fire_remnant_custom_state:StatusEffectPriority()
	return 20
end

function ember_spirit_fire_remnant_custom_state:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end

function ember_spirit_fire_remnant_custom_state:CheckState()
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