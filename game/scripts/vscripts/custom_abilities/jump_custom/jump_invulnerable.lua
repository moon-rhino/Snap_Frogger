

-- Cookie spell recreated by EarthSalamander42
-- see the reference at https://github.com/EarthSalamander42/dota_imba/blob/47d802f6718929726fb24dd4c5b140064f1dfd15/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/modifiers/generic/modifier_generic_knockback_lua.lua

--------------------------------------------------------------------------------
jump_invulnerable = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mortimer_kisses_thinker_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Custom KV
function jump_invulnerable:GetCastPoint()
	if IsServer() and self:GetCursorTarget()==self:GetCaster() then
		return self:GetSpecialValueFor( "self_cast_delay" )
	end
	return 0.0
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function jump_invulnerable:CastFilterResultTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return UF_FAIL_CUSTOM
    end
    
    local nResult
    nResult = UnitFilter(
        hTarget,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        0,
        self:GetCaster():GetTeamNumber()
    )
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function jump_invulnerable:GetCustomCastErrorTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return "#dota_hud_error_is_channeling"
	end

	return ""
end



--------------------------------------------------------------------------------
-- Ability Phase Start
function jump_invulnerable:OnAbilityPhaseInterrupted()

end
function jump_invulnerable:OnAbilityPhaseStart()

	if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end


	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function jump_invulnerable:OnSpellStart()
    local caster = self:GetCaster()
    self.caster = caster
    --always cast to self
    local target = self:GetCaster()
    self.target = target
    

	-- load data
    local projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf"
    self.projectile_name = projectile_name
    local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
    self.projectile_speed = projectile_speed

	-- create projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = false,                           -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)

	-- Play sound
	local sound_cast = "Hero_Snapfire.FeedCookie.Cast"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

--------------------------------------------------------------------------------
-- Projectile
function jump_invulnerable:OnProjectileHit( target, location )

    -- load data
    local duration = self:GetSpecialValueFor( "jump_duration" )
    local height = self:GetSpecialValueFor( "jump_height" )
    local distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
    local stun = self:GetSpecialValueFor( "impact_stun_duration" )
    local damage = self:GetSpecialValueFor( "impact_damage" )
    local radius = self:GetSpecialValueFor( "impact_radius" )
    if not target then return end
    --receiving cookie effect
    -- play effects2
    local effect_cast = self:PlayEffects2( target )

    --dodge bullets
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invulnerable", {duration = duration})
    --play effect
    self:PlayInvulnerableEffect()

    -- knockback
    -- describes the "jumping" motion
    local knockback = target:AddNewModifier(
        self:GetCaster(), -- player source
        self, -- ability source
        "modifier_knockback_custom", -- modifier name
        {
            distance = distance,
            height = height,
            duration = duration,
            direction_x = target:GetForwardVector().x,
            direction_y = target:GetForwardVector().y,
            IsStun = true,
        } -- kv
    )

    -- play effects
    ParticleManager:DestroyParticle( effect_cast, false )
    ParticleManager:ReleaseParticleIndex( effect_cast )

	
end

--------------------------------------------------------------------------------
function jump_invulnerable:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function jump_invulnerable:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_buff.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_receive.vpcf"
	local sound_target = "Hero_Snapfire.FeedCookie.Consume"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, target )

	-- Create Sound
	EmitSoundOn( sound_target, target )

	return effect_cast
end

function jump_invulnerable:PlayEffects3( target, radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf"
	local sound_location = "Hero_Snapfire.FeedCookie.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_location, target )
end

--------------------------------------------------------------------------------
function jump_invulnerable:PlayInvulnerableEffect()

	-- Get Resources
    --local particle_cast = "particles/econ/taunts/snapfire/snapfire_taunt_bubble.vpcf"
    local particle_cast = "particles/snapfire_taunt_bubble_invulnerable_cookie_shotgun.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

    -- Destroy Particle after the spell ends
    Timers:CreateTimer({
        endTime = self.duration, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
            ParticleManager:DestroyParticle( effect_cast, true )
        end
    })
    ParticleManager:ReleaseParticleIndex( effect_cast )
end



