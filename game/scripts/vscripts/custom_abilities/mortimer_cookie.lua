--base cookie
--on cast
--if unit has baker's dozen then
--cast it on target

-- Cookie spell recreated by EarthSalamander42
-- see the reference at https://github.com/EarthSalamander42/dota_imba/blob/47d802f6718929726fb24dd4c5b140064f1dfd15/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/modifiers/generic/modifier_generic_knockback_lua.lua

--find target's position
--mark it
--after time based on distance,
--jump to position

--highlight spot where he will land
--longer time 

--players can dodge by jumping or using force staff
--------------------------------------------------------------------------------
mortimer_cookie = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mortimer_kisses_thinker_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Custom KV
function mortimer_cookie:GetCastPoint()
	--[[if IsServer() and self:GetCursorTarget()==self:GetCaster() then
		return self:GetSpecialValueFor( "self_cast_delay" )
	end]]
	return 1.0
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function mortimer_cookie:CastFilterResultTarget( hTarget )
	--[[if IsServer() and hTarget:IsChanneling() then
		return UF_FAIL_CUSTOM
    end
    
    --if unit has raisin firesnap then
        --cast to all
    --else
        --cast to friendly
    local nResult
    if self:GetCaster():HasAbility("cookie_raisin_firesnap") then

        nResult = UnitFilter(
            hTarget,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            0,
            self:GetCaster():GetTeamNumber()
        )
    else
        nResult = UnitFilter(
            hTarget,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            0,
            self:GetCaster():GetTeamNumber()
        )
    end
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS]]
end

function mortimer_cookie:GetCustomCastErrorTarget( hTarget )
	--[[if IsServer() and hTarget:IsChanneling() then
		return "#dota_hud_error_is_channeling"
	end

	return ""]]
end



--------------------------------------------------------------------------------
-- Ability Phase Start
function mortimer_cookie:OnAbilityPhaseInterrupted()

end
function mortimer_cookie:OnAbilityPhaseStart()
    print("[mortimer_cookie:OnAbilityPhaseStart()] called")
	--[[if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end]]
    self:PlayEffects1()

	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function mortimer_cookie:OnSpellStart()
    print("[mortimer_cookie:OnSpellStart()] called")
    self.secondary_projectiles = {}
	-- unit identifier
    local caster = self:GetCaster()
    self.caster = caster
    local target = self:GetCursorPosition()
    self.target = target


    

	-- load data
    --[[local projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf"
    self.projectile_name = projectile_name
    local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
    self.projectile_speed = projectile_speed]]

	--[[if caster:GetTeam() ~= target:GetTeam() then
		projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_enemy_projectile.vpcf"
	end]]

	-- create projectile
	--[[local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = false,                           -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)]]

	-- Play sound
	local sound_cast = "Hero_Snapfire.FeedCookie.Cast"
    EmitSoundOn( sound_cast, self:GetCaster() )
    
    -- load data
    local duration = self:GetSpecialValueFor( "jump_duration" )
    local height = self:GetSpecialValueFor( "jump_height" )
    --local distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
    local distance = (self:GetCaster():GetAbsOrigin() - target):Length()
    --leave marks on landing, then players have limited space to roam 

    local stun = self:GetSpecialValueFor( "impact_stun_duration" )
    local damage = self:GetSpecialValueFor( "impact_damage" )
    local radius = self:GetSpecialValueFor( "impact_radius" )

    --if not target then return end
    --receiving cookie effect
    -- play effects2
    local effect_cast = self:PlayEffects2( self:GetCaster() )

    -- knockback
    -- describes the "jumping" motion
    local direction = target - self:GetCaster():GetAbsOrigin()
    direction = direction:Normalized()
    local knockback = self:GetCaster():AddNewModifier(
        self:GetCaster(), -- player source
        self, -- ability source
        "modifier_knockback_custom", -- modifier name
        {
            distance = distance,
            height = height,
            duration = duration,

            direction_x = direction.x,
            direction_y = direction.y,
            IsStun = true,
        } -- kv
    )
    -- on landing
    local callback = function()
        print("[mortimer_cookie:OnSpellStart()] callback called")
        -- precache damage
        local damageTable = {
            -- victim = target,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self, --Optional.
        }

        -- find enemies
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _,enemy in pairs(enemies) do
            print("[mortimer_cookie:OnSpellStart()] enemy found")
            -- apply damage
            damageTable.victim = enemy
            ApplyDamage(damageTable)

                -- stun
                enemy:AddNewModifier(
                    self:GetCaster(), -- player source
                    self, -- ability source
                    "modifier_stunned", -- modifier name
                    { duration = stun } -- kv
                )
        end

        -- destroy trees
        GridNav:DestroyTreesAroundPoint( target, radius, true )

        -- play effects
        ParticleManager:DestroyParticle( effect_cast, false )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        self:PlayEffects3( self:GetCaster(), radius )
    end

    --returns when knockback is finished
    if not self:GetCaster():IsAlive() then
        --nothing
    else
        knockback:SetEndCallback( callback )
    end
end


--------------------------------------------------------------------------------
function mortimer_cookie:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function mortimer_cookie:PlayEffects2( target )
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

function mortimer_cookie:PlayEffects3( target, radius )
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
function mortimer_cookie:PlayEffectsKisses( loc, owner )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf"
	local sound_cast = "Hero_Snapfire.MortimerBlob.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, owner )
	ParticleManager:SetParticleControl( effect_cast, 3, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, owner )
	ParticleManager:SetParticleControl( effect_cast, 0, loc )
	ParticleManager:SetParticleControl( effect_cast, 1, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	local sound_location = "Hero_Snapfire.MortimerBlob.Impact"
	EmitSoundOnLocationWithCaster( loc, sound_location, owner )
end


--------------------------------------------------------------------------------
function mortimer_cookie:PlayEffectsCalldown( time, owner )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_CUSTOMORIGIN, owner, owner:GetTeamNumber() )
	ParticleManager:SetParticleControl( self.effect_cast, 0, owner:GetOrigin() )
    --ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius*(self.max_travel/time) ) )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 500, 0, -500*(2/time) ) )
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( time, 0, 0 ) )
end


--create projectile
--hit the spot the target lands at


