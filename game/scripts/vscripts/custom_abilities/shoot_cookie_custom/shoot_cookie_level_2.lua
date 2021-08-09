--only hurts creeps (team bad guys)

shoot_cookie_level_2 = class({})
LinkLuaModifier("shoot_cookie_modifier", "libraries/modifiers/shoot_cookie_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)

local SHOOT_DISTANCE = 3500
local SHOOT_SPEED = 500

--on level up, when it hits a target, split into smaller cookies
--switch which cookie you throw
--oreo: high jump
--something else: far jump
function shoot_cookie_level_2:OnSpellStart()
    if IsServer() then
        self.caster = self:GetCaster()
        --A Liner Projectile must have a table with projectile info
        local cursorPt = self:GetCursorPosition()
        local casterPt = self.caster:GetAbsOrigin()
        local direction = cursorPt - casterPt
        direction = direction:Normalized()
        local speed = self:GetSpecialValueFor( "projectile_speed" )
        self.horizontal_jump_distance = self:GetSpecialValueFor( "horizontal_jump_distance")
        self.jump_height = self:GetSpecialValueFor( "jump_height")
        --must declare correct type for number
        self.jump_duration = self:GetSpecialValueFor( "jump_duration" )
        self.abilityDamageType = self:GetAbilityDamageType()
        local info = 
        { 
            Ability = self,
            EffectName = "particles/hero_snapfire_cookie_projectile_linear_small.vpcf", --particle effect
            --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
            vSpawnOrigin = self.caster:GetAbsOrigin(),
            fDistance = SHOOT_DISTANCE,
            fStartRadius = 70,
            fEndRadius = 70,
            Source = self.caster,
            --bHasFrontalCone = false,
            --bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 10.0,
            bDeleteOnHit = false,
            vVelocity = direction * SHOOT_SPEED,
            bProvidesVision = true,
            iVisionRadius = 500,
            iVisionTeamNumber = self.caster:GetTeamNumber()
        }
        projectile = ProjectileManager:CreateLinearProjectile(info)

        --play sounds
        self.caster:EmitSound("cookie_cast_linear_projectile")
        --projectile sound
        self.caster:EmitSound("cookie_projectile_linear_projectile")
    end
end

function shoot_cookie_level_2:OnProjectileHit(hTarget, vLocation)
    local radius = self:GetSpecialValueFor("impact_radius")
    local stun_duration = self:GetSpecialValueFor("impact_stun_duration")
    if hTarget == nil then
        return false
        --skip
    elseif hTarget == self:GetCaster() then
        return false
        --skip
    else
        print("hit")
        local damageTable = {
            victim = hTarget,
            attacker = self.caster,
            damage = 50000,
            damage_type = self:GetAbilityDamageType(),
            ability = self, --Optional.
        }
        ApplyDamage(damageTable)
    end
end

function shoot_cookie_level_2:PlayEffects3( target, radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf"
	local sound_landing = "cookie_landing"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_landing, target )
end