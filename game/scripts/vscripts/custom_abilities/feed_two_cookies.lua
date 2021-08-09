--------------------------------------------------------------------------------
feed_two_cookies = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)

--------------------------------------------------------------------------------
-- Ability Cast Filter
function feed_two_cookies:CastFilterResultTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return UF_FAIL_CUSTOM
    end
    
    --if unit has raisin firesnap then
        --cast to all
    --else
        --cast to friendly
    local nResult
    local caster = self:GetCaster()

    nResult = UnitFilter(
        hTarget,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY + DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        0,
        self:GetCaster():GetTeamNumber()
    )
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end


--------------------------------------------------------------------------------
-- Ability Phase Start
function feed_two_cookies:OnAbilityPhaseInterrupted()
end

function feed_two_cookies:OnAbilityPhaseStart()
	if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end


	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function feed_two_cookies:OnSpellStart()

    GameMode.games["jackpot"].pause = true

	-- unit identifier
    local caster = self:GetCaster()
    self.caster = caster
    local target = GameMode.games["jackpot"].fatty
    self.target = target
    self.cookieCount = 0
    
	-- load data
    local projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf"
    self.projectile_name = projectile_name
    local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
    self.projectile_speed = projectile_speed

    -- create projectile
    --first
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
    
    --after a delay, second
    --make timer name different so it won't stop when someone else casts the same spell
        Timers:CreateTimer(string.format("feed_second_cookie_%s", self.caster:GetPlayerID()), {
            useGameTime = false,
            endTime = 0.5,
            callback = function()
                if self.caster:IsAlive() then
                    local info = {
                        Target = target,
                        Source = caster,
                        Ability = self,	
                        
                        EffectName = projectile_name,
                        iMoveSpeed = projectile_speed,
                        bDodgeable = false,                           -- Optional
                    }
                    ProjectileManager:CreateTrackingProjectile(info)

                    -- Play sound second time
                    local sound_cast = "Hero_Snapfire.FeedCookie.Cast"
                    EmitSoundOn( sound_cast, self:GetCaster() )
                    
                    return nil
                end
            end
        })

end

--------------------------------------------------------------------------------
-- Projectile
function feed_two_cookies:OnProjectileHit( target, location )

    self.cookieCount = self.cookieCount + 1

    

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
    --local effect_cast = self:PlayEffects2( target )

    --knockback
    --update modifier stack
    local cookie_eaten_modifier = target:FindModifierByName("modifier_cookie_eaten")
    if cookie_eaten_modifier == nil then
        --nothing
        --the monster is dead
        --kill the caster
        self.caster:ForceKill(false)
    else
        local cookiesEaten = cookie_eaten_modifier:GetStackCount()
        cookie_eaten_modifier:SetStackCount(cookiesEaten + 1)
        GameMode:ShowScore(GameMode.games["jackpot"].fatty, cookie_eaten_modifier:GetStackCount(), 9)
        GameMode.games["jackpot"].fatty.scale = GameMode.games["jackpot"].fatty.scale + 0.1
        GameMode.games["jackpot"].fatty:SetModelScale(GameMode.games["jackpot"].fatty.scale)
    end

    if self.cookieCount == 2 then
        --flag for preventing death
        --set this after casting the last cookie
        --GameMode.games["jackpot"].pause = false
        self.caster.cast = true
        if GameMode.warmUp then
            self.caster:GiveMana(200)
        end
    end

    return true
    
end

--------------------------------------------------------------------------------
function feed_two_cookies:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function feed_two_cookies:PlayEffects2( target )
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

function feed_two_cookies:PlayEffects3( target, radius )
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
