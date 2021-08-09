

-- Cookie spell based on one by EarthSalamander42
-- see the reference at https://github.com/EarthSalamander42/dota_imba/blob/47d802f6718929726fb24dd4c5b140064f1dfd15/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/abilities/heroes/hero_snapfire.lua

--------------------------------------------------------------------------------
cookie_no_damage = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Custom KV
function cookie_no_damage:GetCastPoint()
	if IsServer() and self:GetCursorTarget()==self:GetCaster() then
		return self:GetSpecialValueFor( "self_cast_delay" )
	end
	return 0.2
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function cookie_no_damage:CastFilterResultTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return UF_FAIL_CUSTOM
    elseif IsServer() then
        local nResult
        local caster = self:GetCaster()
        nResult = UnitFilter(
            hTarget,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            0,
            self:GetCaster():GetTeamNumber()
        )
        if nResult ~= UF_SUCCESS then
            return nResult
        end

        return UF_SUCCESS
    end
end

function cookie_no_damage:GetCustomCastErrorTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return "#dota_hud_error_is_channeling"
	end

	return ""
end



--------------------------------------------------------------------------------
-- Ability Phase Start
function cookie_no_damage:OnAbilityPhaseInterrupted()

end
function cookie_no_damage:OnAbilityPhaseStart()
	if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end


	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function cookie_no_damage:OnSpellStart()

	-- unit identifier
    local caster = self:GetCaster()
    self.caster = caster
    local target = self:GetCursorTarget()
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
	EmitSoundOn( sound_cast, self.caster )
end

--------------------------------------------------------------------------------
-- Projectile
function cookie_no_damage:OnProjectileHit( target, location )
    --cast on enemy
    --jump in place
    --everyone around the target gets a cookie
        --friends jump forward
        --enemies hop in place

    --cast on friend
    --jump
    --on land, if caster has baker's dozen then
        --everyone around the friend gets a cookie
        --friends jump forward
        --enemies hop in place

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

    -- on landing
    local callback = function()

        -- find enemies
        local enemies = FindUnitsInRadius(
            target:GetTeamNumber(),	-- int, your team number
            target:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _,enemy in pairs(enemies) do

            -- stun
            enemy:AddNewModifier(
                target, -- player source
                self, -- ability source
                "modifier_stunned", -- modifier name
                { duration = stun } -- kv
            )

        end

        -- destroy trees
        GridNav:DestroyTreesAroundPoint( target:GetOrigin(), radius, true )

        -- play effects
        ParticleManager:DestroyParticle( effect_cast, false )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        self:PlayEffects3( target, radius )

    end

    --if target dies during jump, there will be no modifier to callback and it will cause an error
    if target:IsAlive() then
        knockback:SetEndCallback( callback )
    end

end

--------------------------------------------------------------------------------
function cookie_no_damage:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.caster )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function cookie_no_damage:PlayEffects2( target )
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

function cookie_no_damage:PlayEffects3( target, radius )
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