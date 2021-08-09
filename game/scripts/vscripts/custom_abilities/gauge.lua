gauge = class({})

LinkLuaModifier("gauge_modifier", "custom_abilities/gauge_modifier", LUA_MODIFIER_MOTION_NONE)

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

function gauge:OnToggle()
	
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local cast_sound = "gauge"
	local gauge_modifier = "gauge_modifier"

	-- Check toggle state
    local state = ability:GetToggleState()

	if state then
		-- Toggled on: add modifier
		caster:AddNewModifier(caster, ability, gauge_modifier, {})
	else
		-- Toggled off: remove modifier
		caster:RemoveModifierByName(gauge_modifier)
	end
end