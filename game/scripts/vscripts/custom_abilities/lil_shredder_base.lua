--------------------------------------------------------------------------------
lil_shredder_base = class({})
LinkLuaModifier( "lil_shredder_base_modifier", "custom_abilities/lil_shredder_base_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lil_shredder_base_debuff_modifier", "custom_abilities/lil_shredder_base_debuff_modifier", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function lil_shredder_base:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetDuration()

	-- add buff
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"lil_shredder_base_modifier", -- modifier name
		{ duration = duration } -- kv
	)
end

function lil_shredder_base:OnProjectileHit(target, location)
    print("projectile hit")
    --tracks caster without "OnSpellStart()"
    print("caster: " .. self:GetCaster():GetTeamNumber())
    --damage
    local damageTable = {
        victim = target,
        attacker = self:GetCaster(),
        --change when talent for normal attack damage acquired
        damage = self:GetCaster():FindAbilityByName("lil_shredder_base"):GetSpecialValueFor("damage"),
        damage_type = self:GetAbilityDamageType(),
        ability = self, --Optional.
    }
    ApplyDamage(damageTable)
    --add modifier
    return
end