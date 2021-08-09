arrow_cookie_2 = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_ai_oreo", "libraries/modifiers/modifier_ai_oreo", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_ai_stack", "libraries/modifiers/modifier_ai_stack", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_ai_heap", "libraries/modifiers/modifier_ai_heap", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_ai_ginger_bread_man", "libraries/modifiers/modifier_ai_ginger_bread_man", LUA_MODIFIER_MOTION_BOTH)


function arrow_cookie_2:OnSpellStart()
    if IsServer() then
    
        local caster = self:GetCaster()
        self.caster = caster
        --A Liner Projectile must have a table with projectile info
        local cursorPt = self:GetCursorPosition()
        local casterPt = caster:GetAbsOrigin()
        local direction = cursorPt - casterPt
        local projectile_speed = self:GetSpecialValueFor("projectile_speed")
        self.targets_hit = 0
        direction = direction:Normalized()
        local info = 
        { 
            Ability = self,
            --EffectName = "particles/mirana_spell_arrow_custom_2.vpcf", --particle effect
            EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
            --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
            vSpawnOrigin = caster:GetAbsOrigin(),
            fDistance = 2000,
            fStartRadius = 150,
            fEndRadius = 150,
            Source = caster,
            --bHasFrontalCone = false,
            --bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 5,
            bDeleteOnHit = false,
            vVelocity = direction * projectile_speed,
            bProvidesVision = true,
            iVisionRadius = 500,
            iVisionTeamNumber = caster:GetTeamNumber()
        }
        projectile = ProjectileManager:CreateLinearProjectile(info)
    end
end

function arrow_cookie_2:OnProjectileHit(hTarget, vLocation)
    if IsServer() then
        if hTarget == nil then
            --gets called without "require"ing the fire
            --cookie_party:SpawnCookie(self.caster, self.targets_hit)
        else
            if hTarget == self:GetCaster() then
                --skip
            else
                --cookie_party:SpawnCookie(self.caster, 1)
                --score for caster
                --saved from game function
                self:GetCaster().score = self:GetCaster().score + 1
                self.targets_hit = self.targets_hit + 1
                --print("caster's score: " .. self:GetCaster().score)
                local duration = self:GetSpecialValueFor( "jump_duration" )
                local height = self:GetSpecialValueFor( "jump_height" )
                local distance = self:GetSpecialValueFor( "jump_distance" )
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
                        duration = duration,
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
                        attacker = self:GetCaster(),
                        damage = damage,
                        damage_type = self:GetAbilityDamageType(),
                        ability = self, --Optional.
                    }

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

                    --stun target's friends; not the target itself
                    for _,enemy in pairs(enemies) do
                        if enemy == hTarget then
                            --nothing
                        else
                            -- apply damage
                            --damageTable.victim = enemy
                            --ApplyDamage(damageTable)

                            -- stun
                            enemy:AddNewModifier(
                                self:GetCaster(), -- player source
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
                --if arrow expires before callback is called, there will be no "self" to GetCaster() from
                knockback:SetEndCallback( callback )
            end
        end
        return false
    end
end

function arrow_cookie_2:PlayEffects2( target )
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

function arrow_cookie_2:PlayEffects3( target, radius )
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