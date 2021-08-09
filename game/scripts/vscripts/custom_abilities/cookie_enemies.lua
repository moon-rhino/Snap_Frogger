--base cookie
--on cast
--if unit has baker's dozen then
--cast it on target

-- Cookie spell recreated by EarthSalamander42
-- see the reference at https://github.com/EarthSalamander42/dota_imba/blob/47d802f6718929726fb24dd4c5b140064f1dfd15/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/abilities/heroes/hero_snapfire.lua

--secondary cookie search radius = 450
--secondary cookie jump distance ally = 450
--secondary cookie jump distance enemy = 0

--------------------------------------------------------------------------------
cookie_enemies = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mortimer_kisses_thinker_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Custom KV
function cookie_enemies:GetCastPoint()
	return 0
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function cookie_enemies:CastFilterResultTarget( hTarget )
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

function cookie_enemies:GetCustomCastErrorTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return "#dota_hud_error_is_channeling"
	end

	return ""
end



--------------------------------------------------------------------------------
-- Ability Phase Start
function cookie_enemies:OnAbilityPhaseInterrupted()

end
function cookie_enemies:OnAbilityPhaseStart()
	if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end


	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function cookie_enemies:OnSpellStart()

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
function cookie_enemies:OnProjectileHit( target, location )

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

    -- knockback
    -- describes the "jumping" motion
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
        -- precache damage
        local damageTable = {
            -- victim = target,
            attacker = self.caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self, --Optional.
        }

        -- find enemies
        local enemies = FindUnitsInRadius(
            self.caster:GetTeamNumber(),	-- int, your team number
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

            -- apply damage
            damageTable.victim = enemy
            ApplyDamage(damageTable)

            -- stun
            enemy:AddNewModifier(
                self.caster, -- player source
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

    knockback:SetEndCallback( callback )
        
	if target:IsChanneling() or target:IsOutOfGame() then return end

	-- If the target possesses a ready Linken's Sphere, do nothing
	if target:GetTeam() ~= self.caster:GetTeam() then
		if target:TriggerSpellAbsorb(self) then
			return nil
		end
	end

end

--------------------------------------------------------------------------------
function cookie_enemies:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.caster )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function cookie_enemies:PlayEffects2( target )
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

function cookie_enemies:PlayEffects3( target, radius )
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