--has to damage
--cast spell
--point to target
--charge cookie
--on release, send a cookie out
--on projectile hit, jump based on how long it was channeled

arrow_cookie_fae_2 = class({})
arrow_cookie_fae_2_release = class({})
modifier_arrow_cookie_fae_2_thinker = class({}) -- Custom class for attempting non-channel logic

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arrow_cookie_fae_2_thinker", "custom_abilities/arrow_cookie_fae_2", LUA_MODIFIER_MOTION_NONE)

--channeling flag
local channeling = false
local channeledTime = 0

--------------------------------------------------------------------------------
-- ability gets replaced when cast
function arrow_cookie_fae_2:GetAssociatedSecondaryAbilities()
	return "arrow_cookie_fae_2_release"
end

function arrow_cookie_fae_2:GetAssociatedPrimaryAbilities()
	return "arrow_cookie_fae_2_channeled"
end

--------------------------------------------------------------------------------
-- Channel Time
-- this has to run in order to start the channel bar
function arrow_cookie_fae_2:GetChannelTime()
	return self:GetSpecialValueFor( "max_channel_time" )
end

--------------------------------------------------------------------------------
-- Ability Phase Start
function arrow_cookie_fae_2:OnAbilityPhaseInterrupted()

end
function arrow_cookie_fae_2:OnAbilityPhaseStart()

	if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end


	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function arrow_cookie_fae_2:OnSpellStart()
	local release_ability = self:GetCaster():FindAbilityByName("arrow_cookie_fae_2_release")
	if not release_ability:IsTrained() then
		release_ability:SetLevel(1)
	end

	self:GetCaster():SwapAbilities("arrow_cookie_fae_2", "arrow_cookie_fae_2_release", false, true)

	print("[arrow_cookie_fae_2:OnSpellStart()] called")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_arrow_cookie_fae_2_thinker", {duration = self:GetSpecialValueFor("max_channel_time")})

end

function arrow_cookie_fae_2:OnProjectileHit(hTarget, vLocation)
    print("hTarget:")
    PrintTable(hTarget)
    local channelTime = self.channelTime
    if hTarget == nil then
        print("arrow expired")
    elseif hTarget.role == "feeder" then
        --skip
    elseif hTarget:GetUnitName() == "npc_dota_hero_snapfire" then
        if hTarget == self:GetCaster() then
            --skip
        else
            local max_jump_duration = self:GetSpecialValueFor( "max_jump_duration" )
            local min_jump_duration = self:GetSpecialValueFor( "min_jump_duration" )
            local max_distance = self:GetSpecialValueFor( "max_distance" )
            local max_channel_time = self:GetSpecialValueFor( "max_channel_time" )
            local jump_duration = (max_jump_duration - min_jump_duration) * (channelTime / max_channel_time) + min_jump_duration
            local distance = max_distance * (channelTime / max_channel_time)
            local height = self:GetSpecialValueFor( "jump_height" )
            local stun = self:GetSpecialValueFor( "impact_stun_duration" )
            local damage = self:GetSpecialValueFor( "impact_damage" )
            local radius = self:GetSpecialValueFor( "impact_radius" )

            --play effects
            local effect_cast = self:PlayEffects2( hTarget )

            --jumping motion
            local knockback = hTarget:AddNewModifier(
                self:GetCaster(), -- player source
                self, -- ability source
                "modifier_knockback_custom", -- modifier name
                {
                    distance = distance,
                    height = height,
                    duration = jump_duration,
                    direction_x = hTarget:GetForwardVector().x,
                    direction_y = hTarget:GetForwardVector().y,
                    IsStun = true,
                } -- kv
            )

            -- on landing
            local callback = function()
                print("[cookie_base:OnProjectileHit] callback called")

                -- precache damage
                local damageTable = {
                    -- victim = target,
                    attacker = hTarget,
                    damage = damage,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self, --Optional.
                }

                -- find enemies
                local enemies = FindUnitsInRadius(
                    hTarget:GetTeamNumber(),	-- int, your team number
                    hTarget:GetOrigin(),	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                    DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                    0,	-- int, flag filter
                    0,	-- int, order filter
                    false	-- bool, can grow cache
                )

                --stun target's friends; not the target itself
                for _,enemy in pairs(enemies) do
                    if enemy == hTarget then
                        --nothing
                    else
                        print("[cookie_base:OnProjectileHit] enemy found")
                        -- apply damage
                        damageTable.victim = enemy
                        ApplyDamage(damageTable)

                        -- stun
                        enemy:AddNewModifier(
                            hTarget, -- player source
                            self, -- ability source
                            "modifier_stunned", -- modifier name
                            { duration = stun } -- kv
                        )
                    end
                end

                -- destroy trees
                --rescue your teammates by destroying trees
                --trees = temporary obstacles
                GridNav:DestroyTreesAroundPoint( hTarget:GetOrigin(), radius, true )

                -- play effects
                ParticleManager:DestroyParticle( effect_cast, false )
                ParticleManager:ReleaseParticleIndex( effect_cast )
                self:PlayEffects3( hTarget, radius )

            end
            knockback:SetEndCallback( callback )
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- Release Ability
function arrow_cookie_fae_2_release:OnSpellStart()
	print("[arrow_cookie_fae_2_release:OnSpellStart()] called")
	local arrow_cookie_fae_2_thinker = self:GetCaster():FindModifierByName("modifier_arrow_cookie_fae_2_thinker")
	

	-- If so, destroy it (which will make snap jump)
	if arrow_cookie_fae_2_thinker then
		arrow_cookie_fae_2_thinker:Destroy()
	end
end

---------------------------------------
-- MODIFIER THINKER WHILE CHANNELING --
---------------------------------------

function modifier_arrow_cookie_fae_2_thinker:IsHidden()
	return false
end

--for GetAbility()
function modifier_arrow_cookie_fae_2_thinker:IsDebuff()
	return false
end

function modifier_arrow_cookie_fae_2_thinker:OnCreated()
	print("[modifier_arrow_cookie_fae_2_thinker:OnCreated()] called")
	self.channelTime = 0
    self:StartIntervalThink(FrameTime())

    local caster = self:GetAbility():GetCaster()
    --A Liner Projectile must have a table with projectile info
    local cursorPt = self:GetAbility():GetCursorPosition()
    local casterPt = caster:GetAbsOrigin()
    local direction = cursorPt - casterPt
    direction = direction:Normalized()
    
    --precache projectile
    local projectile_speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" )
    self.info = 
    { 
        --grabs the ability that created this modifier
        Ability = self:GetAbility(),
        --somehow label the cookies
        EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        fDistance = 5000,
        fStartRadius = 150,
        fEndRadius = 150,
        --grabs the caster that created this modifier
        Source = self:GetCaster(),
        --bHasFrontalCone = false,
        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = direction * projectile_speed,
        bProvidesVision = true,
        --iVisionRadius = 500,
        --iVisionTeamNumber = caster:GetTeamNumber()
    }
end

--spell creates modifier
--on created, precache the projectile
--on destroyed, create the projectile
--on hit is handled by the spell

function modifier_arrow_cookie_fae_2_thinker:OnIntervalThink()
	self.channelTime = self.channelTime + FrameTime()
end

function modifier_arrow_cookie_fae_2_thinker:OnDestroy()
    --create a linear projectile
    ProjectileManager:CreateLinearProjectile( self.info )
    --pass the channeled time to projectileHit
    self:GetAbility().channelTime = self.channelTime
    self:GetCaster():SwapAbilities("arrow_cookie_fae_2_release", "arrow_cookie_fae_2", false, true)
end



--------------------------------------------------------------------------------
function arrow_cookie_fae_2:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function arrow_cookie_fae_2:PlayEffects2( target )
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

function arrow_cookie_fae_2:PlayEffects3( target, radius )
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