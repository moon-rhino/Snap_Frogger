--burns cookies around owner and absorbs them if killed

modifier_ai_heap = class({})

function modifier_ai_heap:OnCreated(params)
    if IsServer() then
        self.unit = self:GetParent()
        local ability = self.unit:FindAbilityByName("absorb")
        ability:OnSpellStart()
        ability:StartCooldown(1)
    end
end

--[[function modifier_ai_heap:OnDeath( params )
    if IsServer() then
        
        --explode
        local particle_cast = "particles/alchemist_smooth_criminal_unstable_concoction_explosion_custom.vpcf"
        --PATTACH_ABSORIGIN_FOLLOW to create effect at unit's location
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.unit )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        self.unit:RemoveModifier
        self.unit:RemoveSelf()


        --shoot out cookies
	end
	return 0
end]]