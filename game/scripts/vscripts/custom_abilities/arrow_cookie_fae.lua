--only hurts creeps (team bad guys)

arrow_cookie_fae = class({})
LinkLuaModifier("arrow_cookie_fae_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_invulnerable", "libraries/modifiers/modifier_invulnerable", LUA_MODIFIER_MOTION_BOTH)

local caster

function arrow_cookie_fae:OnSpellStart()
    local caster = self:GetCaster()
    --A Liner Projectile must have a table with projectile info
    local cursorPt = self:GetCursorPosition()
    local casterPt = caster:GetAbsOrigin()
    local direction = cursorPt - casterPt
    direction = direction:Normalized()
    local speed = self:GetSpecialValueFor( "projectile_speed" )
    self.horizontal_jump_distance = self:GetSpecialValueFor( "horizontal_jump_distance")
    --must declare correct type for number
    self.jump_duration = self:GetSpecialValueFor( "jump_duration" )
    local info = 
    { 
        Ability = self,
        EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 10000,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = caster,
        --bHasFrontalCone = false,
        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = direction * speed,
        bProvidesVision = true,
        iVisionRadius = 500,
        iVisionTeamNumber = caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)
end

function arrow_cookie_fae:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then
        return false
        --skip
    elseif hTarget:GetUnitName() == "npc_dota_hero_snapfire" then
        if hTarget == self:GetCaster() then
            return false
            --skip
        else
            --local duration = self:GetSpecialValueFor( "jump_duration" )
            --local height = self:GetSpecialValueFor( "jump_height" )
            --local distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
            --if self:GetCaster():HasAbility("cookie_bakers_dozen") then
                --local distance_secondary = self:GetCaster():FindAbilityByName("cookie_bakers_dozen"):GetSpecialValueFor( "horizontal_jump_distance" )
            --end
            local stun = self:GetSpecialValueFor( "impact_stun_duration" )
            local damage = self:GetSpecialValueFor( "impact_damage" )
            local radius = self:GetSpecialValueFor( "impact_radius" )
    
            --jumping motion
            --hTarget even though it didn't hit anything
            local knockback = hTarget:AddNewModifier(
                self:GetCaster(), -- player source
                self, -- ability source
                "modifier_knockback_custom", -- modifier name
                {
                    distance = self.horizontal_jump_distance,
                    height = 200,
                    duration = self.jump_duration,
                    direction_x = hTarget:GetForwardVector().x,
                    direction_y = hTarget:GetForwardVector().y,
                    IsStun = true,
                } -- kv
            )

            --while being knocked back, apply invincible modifier
            hTarget:AddNewModifier(nil, nil, "modifier_invulnerable", {duration = self.jump_duration})

            -- on landing
            local callback = function()
                -- find enemies
                -- meant to kill creeps; team bad guys are 3
                local enemies = FindUnitsInRadius(
                    self:GetCaster():GetTeamNumber(),	-- int, your team number
                    hTarget:GetOrigin(),	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                    DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                    0,	-- int, flag filter
                    0,	-- int, order filter
                    false	-- bool, can grow cache
                )

                --stun timbersaws only
                --only on checkpoint 3
                if GameMode.games["escape"].checkpointActivated > 2 then
                    for _,enemy in pairs(enemies) do
                        if enemy:GetUnitName() ~= "fae_runner" then
                            --nothing
                        else
                            -- stun
                            enemy:AddNewModifier(
                                self:GetCaster(), -- player source
                                nil, -- ability source
                                "modifier_stunned", -- modifier name
                                { duration = stun } -- kv
                            )
                        end
                    end
                end

                self:PlayEffects3( hTarget, radius )
            end

            knockback:SetEndCallback( callback )
            return true

        end
    end
end

function arrow_cookie_fae:PlayEffects3( target, radius )
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

--shoot an arrow
--on hit, target jumps in the direction it's facing 