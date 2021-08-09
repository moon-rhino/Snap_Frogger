modifier_cookie_eaten = class({})

local AI_THINK_INTERVAL = 0.06

function modifier_cookie_eaten:IsHidden()
	return false
end

function modifier_cookie_eaten:IsDebuff()
	return false
end

function modifier_cookie_eaten:IsStunDebuff()
	return false
end

function modifier_cookie_eaten:IsPurgable()
	return false
end



--------------------------------------------------------------------------------
-- Initializations
function modifier_cookie_eaten:OnCreated( params )
    if not IsServer() then return end
	self:SetStackCount( 0 )
	self:StartIntervalThink(AI_THINK_INTERVAL)
	self.unit = self:GetParent()
end

function modifier_cookie_eaten:OnIntervalThink()
    if IsServer() then
		--[[if self:GetStackCount() > GameMode.games["jackpot"].jackpot then
			--explosion
			local particle_cast = "particles/alchemist_smooth_criminal_unstable_concoction_explosion_custom.vpcf"
			--PATTACH_ABSORIGIN_FOLLOW to create effect at unit's location
			local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, GameMode.games["jackpot"].fatty )
			ParticleManager:ReleaseParticleIndex( effect_cast )

			--sound
			self.unit:EmitSound("explosion")
			self.unit:EmitSound("ogre_death_1")

			self.unit:ForceKill(false)
			ParticleManager:DestroyParticle( self.unit.score_effect, true )
			if GameMode.warmUp == false then
				--kill whoever's turn it was
			end
		end]]
    end
end

function modifier_cookie_eaten:OnDestroy()
	if IsServer() then
		--explosion
		local particle_cast = "particles/alchemist_smooth_criminal_unstable_concoction_explosion_custom.vpcf"
		--PATTACH_ABSORIGIN_FOLLOW to create effect at unit's location
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, GameMode.games["jackpot"].fatty )
		ParticleManager:ReleaseParticleIndex( effect_cast )

		--sound
		self.unit:EmitSound("explosion")
		self.unit:EmitSound("ogre_death_1")

		self.unit:ForceKill(false)
		ParticleManager:DestroyParticle( self.unit.score_effect, true )
		if GameMode.warmUp == false then
			--kill whoever's turn it was
		end
	end
end