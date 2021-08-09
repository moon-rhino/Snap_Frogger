--only hurts creeps (team bad guys)

shoot_cookie = class({})
LinkLuaModifier("shoot_cookie_modifier", "libraries/modifiers/shoot_cookie_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)

--on level up, when it hits a target, split into smaller cookies
--switch which cookie you throw
--oreo: high jump
--something else: far jump
function shoot_cookie:OnSpellStart()
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
            fDistance = 10000,
            fStartRadius = 150,
            fEndRadius = 150,
            Source = self.caster,
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
            iVisionTeamNumber = self.caster:GetTeamNumber()
        }
        projectile = ProjectileManager:CreateLinearProjectile(info)

        --play sounds
        self.caster:EmitSound("cookie_cast_linear_projectile")
        --projectile sound
        self.caster:EmitSound("cookie_projectile_linear_projectile")
    end
end

function shoot_cookie:OnProjectileHit(hTarget, vLocation)
    local radius = self:GetSpecialValueFor("impact_radius")
    local stun_duration = self:GetSpecialValueFor("impact_stun_duration")
    if hTarget == nil then
        return false
        --skip
    elseif hTarget == self:GetCaster() then
        return false
        --skip
    else



        --hit sound
        self.caster:EmitSound("cookie_target_linear_projectile")



        --jumping motion
        --hTarget even though it didn't hit anything
        
        --if target is on the same team, push it forward
        --else, push it backward
        local direction_multiplier = 1
        local distance_multiplier = 0.7
        if hTarget:GetTeamNumber() ~= self.caster:GetTeamNumber() then
            direction_multiplier = -1
            distance_multiplier = 1
        end

        local knockback = hTarget:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = self.horizontal_jump_distance * distance_multiplier,
                height = self.jump_height,
                duration = self.jump_duration,
                direction_x = direction_multiplier * hTarget:GetForwardVector().x,
                direction_y = direction_multiplier * hTarget:GetForwardVector().y,
                IsStun = true,
            } -- kv
        )

        -- on landing
        local callback = function()
            -- find enemies
            -- meant to kill creeps; team bad guys are 3
            local enemies = FindUnitsInRadius(
                self.caster:GetTeamNumber(),	-- int, your team number
                hTarget:GetOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                0,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            local damageTable = {
                -- victim = target,
                attacker = self.caster,
                damage = damage,
                damage_type = self.abilityDamageType,
                ability = self, --Optional.
            }

            for _,enemy in pairs(enemies) do
                -- apply damage
                damageTable.victim = enemy
                --if enemy == target, don't damage or stun him
                if enemy ~= hTarget then
                    ApplyDamage(damageTable)

                    -- stun
                    enemy:AddNewModifier(
                        self.caster, -- player source
                        self, -- ability source
                        "modifier_stunned", -- modifier name
                        { duration = stun_duration } -- kv
                    )
                end
            end

            self:PlayEffects3( hTarget, radius )
        end

        knockback:SetEndCallback( callback )
        return true

    end
end

function shoot_cookie:PlayEffects3( target, radius )
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