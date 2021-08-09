-------------------------------------------
--				BLOOD RITE
-------------------------------------------
-- Visible Modifiers:
LinkLuaModifier( "modifier_blood_bath_debuff_silence", "custom_abilities/blood_bath", LUA_MODIFIER_MOTION_NONE )

blood_bath = blood_bath or class({})

function blood_bath:GetAbilityTextureName()
	return "bloodseeker_blood_bath"
end

function blood_bath:GetAOERadius()
	local radius = self:GetSpecialValueFor("radius")

	return radius
end
	
function blood_bath:OnSpellStart()
	local vPos = self:GetCursorPosition()
	local caster = self:GetCaster()
	self.caster_hero = self:GetCaster():GetOwner()

	-- Caster's position on cast
	local caster_pos = caster:GetAbsOrigin()

	-- Find position in front of the target point
	self:FormBloodRiteCircle(caster, vPos)

end

function blood_bath:FormBloodRiteCircle(caster, vPos)
	AddFOWViewer(caster:GetTeamNumber(),vPos,self:GetSpecialValueFor("vision_aoe"),self:GetSpecialValueFor("vision_duration"),true)   --gives ground vision
	local radius = self:GetSpecialValueFor("radius")
	EmitSoundOn("Hero_Bloodseeker.BloodRite.Cast", caster)
	EmitSoundOnLocationWithCaster( vPos, "Hero_Bloodseeker.BloodRite", caster )
	local bloodriteFX = ParticleManager:CreateParticle("particles/bloodseeker_bloodritual_ring_custom.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( bloodriteFX, 0, vPos )
	ParticleManager:SetParticleControl( bloodriteFX, 1, Vector(radius, radius, radius) )
	ParticleManager:SetParticleControl( bloodriteFX, 3, vPos )
	Timers:CreateTimer(self:GetSpecialValueFor("delay"), function()
		EmitSoundOnLocationWithCaster( vPos, "hero_bloodseeker.bloodRite.silence", caster )
		ParticleManager:DestroyParticle(bloodriteFX, false)
		ParticleManager:ReleaseParticleIndex(bloodriteFX)
		local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), vPos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

		for _,target in pairs(targets) do
			local damage = self:GetSpecialValueFor("damage")
			target:AddNewModifier(caster, self, "modifier_blood_bath_debuff_silence", {duration = self:GetSpecialValueFor("silence_duration") * (1 - target:GetStatusResistance())})

			ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = self:GetAbilityDamageType(), ability = self})
		end
	end)
end

modifier_blood_bath_debuff_silence = modifier_blood_bath_debuff_silence or class({})

if IsServer() then
	function modifier_blood_bath_debuff_silence:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_DEATH,
		}
		return funcs
	end
	function modifier_blood_bath_debuff_silence:OnDeath(params)
		if params.unit == self:GetParent() and params.unit:IsRealHero() then
			--heal caster
			print("owner of the caster: " .. self:GetAbility().caster_hero:GetUnitName())
			self:GetAbility().caster_hero:Heal(500, self:GetAbility())
		end
	end
end

function modifier_blood_bath_debuff_silence:IsHidden() return false end
function modifier_blood_bath_debuff_silence:IsPurgable()
	return true
end
function modifier_blood_bath_debuff_silence:IsDebuff() return true end

function modifier_blood_bath_debuff_silence:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_blood_bath_debuff_silence:GetEffectName()
	return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_blood_bath_debuff_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end