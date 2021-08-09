

-- Cookie spell recreated by EarthSalamander42
-- see the reference at https://github.com/EarthSalamander42/dota_imba/blob/47d802f6718929726fb24dd4c5b140064f1dfd15/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/modifiers/generic/modifier_generic_knockback_lua.lua

--------------------------------------------------------------------------------
cookie_selfcast_no_landing_effect = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mortimer_kisses_thinker_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Ability Cast Filter
function cookie_selfcast_no_landing_effect:CastFilterResultTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return UF_FAIL_CUSTOM
    end
    
    --if unit has raisin firesnap then
        --cast to all
    --else
        --cast to friendly
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

function cookie_selfcast_no_landing_effect:GetCustomCastErrorTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return "#dota_hud_error_is_channeling"
	end

	return ""
end



--------------------------------------------------------------------------------
-- Ability Phase Start
function cookie_selfcast_no_landing_effect:OnAbilityPhaseInterrupted()

end
function cookie_selfcast_no_landing_effect:OnAbilityPhaseStart()

	if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end


	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function cookie_selfcast_no_landing_effect:OnSpellStart()
    local caster = self:GetCaster()
    self.caster = caster
    local target = self:GetCaster()
    self.target = target
    

	-- load data
    local projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf"
    self.projectile_name = projectile_name
    local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
    self.projectile_speed = projectile_speed

	--[[if caster:GetTeam() ~= target:GetTeam() then
		projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_enemy_projectile.vpcf"
	end]]

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
function cookie_selfcast_no_landing_effect:OnProjectileHit( target, location )

    -- load data
    local duration = self:GetSpecialValueFor( "jump_duration" )
    local height = self:GetSpecialValueFor( "jump_height" )
    local distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
    local distance_secondary
    if self:GetCaster():HasAbility("cookie_bakers_dozen") then
        local distance_secondary = self:GetCaster():FindAbilityByName("cookie_bakers_dozen"):GetSpecialValueFor( "horizontal_jump_distance" )
    end
    local stun = self:GetSpecialValueFor( "impact_stun_duration" )
    local damage = self:GetSpecialValueFor( "impact_damage" )
    local radius = self:GetSpecialValueFor( "impact_radius" )
    if not target then return end
    --receiving cookie effect
    -- play effects2
    local effect_cast = self:PlayEffects2( target )

    -- knockback
    -- describes the "jumping" motion
    if IsServer() then
        local knockback = target:AddNewModifier(
            self.caster, -- player source
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

		if self.caster:IsAlive() then
			ParticleManager:DestroyParticle( effect_cast, false )
			ParticleManager:ReleaseParticleIndex( effect_cast )
		end

	    if target:IsChanneling() or target:IsOutOfGame() then return end
    end
	
end

--------------------------------------------------------------------------------
function cookie_selfcast_no_landing_effect:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function cookie_selfcast_no_landing_effect:PlayEffects2( target )
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

function cookie_selfcast_no_landing_effect:PlayEffects3( target, radius )
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


--create projectile
--hit the spot the target lands at


