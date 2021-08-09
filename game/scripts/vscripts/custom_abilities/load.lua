load = class({})

LinkLuaModifier("load_modifier", "custom_abilities/load_modifier", LUA_MODIFIER_MOTION_NONE)

--on toggle, add modifier
--if player has modifier,
    --increase damage to 2x
    --add knockback
--on toggle off, remove modifier

--new: 1/1/2021
--cast: no target
--add modifier to caster
--on other spells, if caster has modifier,
--add cooldown, knockback to self and target, and damage on point blank
--cooldown on this spell too

function load:OnSpellStart()
	
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local cast_sound = "gauge"
	local load_modifier = "load_modifier"

    caster:AddNewModifier(caster, ability, load_modifier, { duration = self:GetCooldown(1) })
    
end