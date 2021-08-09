--on lil shredder hit, fire a lil_shredder to a nearby enemy
--tracking projectile
--add to lil shredder - OnProjectileHit

lil_shredder_fragments = class({})

--------------------------------------------------------------------------------
-- Ability Start
--[[function fragments:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
    self.proc_chance = self:GetSpecialValueFor( "proc_chance" )
    self.enemy_find_radius = self:GetSpecialValueFor( "enemy_find_radius" )

end]]

function lil_shredder_fragments:OnProjectileHit(target, location)
    --[[print("projectile hit")
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
    --add modifier
    return]]
end