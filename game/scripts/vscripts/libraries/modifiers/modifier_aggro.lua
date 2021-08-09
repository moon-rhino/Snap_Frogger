modifier_aggro = class({})

function modifier_aggro:GetStatusEffectName()
	return "particles/status_fx/status_effect_battle_hunger.vpcf"
end

function modifier_aggro:OnCreated( params )

	
	if not IsServer() then return end
	
	
	self.enemy_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_battle_hunger.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.enemy_particle, 2, Vector(0, 0, 0))
	self:AddParticle(self.enemy_particle, false, false, -1, false, false)
end