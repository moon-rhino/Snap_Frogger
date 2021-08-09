LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)

--shoot cookie at a target
--that target bounces
--that target shoots a cookie at a nearby target
--loop for # of bounces

chain_cookie = class({})

--first target casts cookie on herself
--repeat a set number of times
function chain_cookie:OnSpellStart()
    if IsServer() then
        --cast a cookie on a target
        self.caster = self:GetCaster()
        self.caster.bounces = self:GetSpecialValueFor("number_of_bounces")
        self.bounce_range = self:GetSpecialValueFor("bounce_range")
        self.targets_hit = 0
        local target = self:GetCursorTarget()
        local info = 
        {
            Target = target,
            Source = self.caster,
            Ability = self,
            EffectName = "particles/luna_glaive_crescent_moon_custom.vpcf",
            iMoveSpeed = 1000,
            vSourceLoc= self.caster:GetAbsOrigin(),                -- Optional (HOW)
            bDrawsOnMinimap = false,                          -- Optional
                bDodgeable = false,                                -- Optional
                bIsAttack = false,                                -- Optional
                bVisibleToEnemies = true,                         -- Optional
                bReplaceExisting = false,                         -- Optional
                flExpireTime = GameRules:GetGameTime() + 5,      -- Optional but recommended
            bProvidesVision = false,                           -- Optional
            iVisionRadius = 400,                              -- Optional
            iVisionTeamNumber = self.caster:GetTeamNumber()        -- Optional
        }
        projectile = ProjectileManager:CreateTrackingProjectile(info)
    end
end


function chain_cookie:OnProjectileHit(hTarget, vLocation)
    if IsServer() then

        self.targets_hit = self.targets_hit + 1

        --[[if hTarget == self:GetCaster() and self.caster.bounces == self:GetSpecialValueFor("number_of_bounces") then
            --continue
        else
            self:GetCaster().score = self:GetCaster().score + 1
        end]]

        self:GetCaster().score = self:GetCaster().score + 1

        --print("chain cookie, caster's score: " .. self:GetCaster().score)

        --spell attributes
        self.duration = self:GetSpecialValueFor( "jump_duration" )
        self.height = self:GetSpecialValueFor( "jump_height" )
        self.distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
        self.stun = self:GetSpecialValueFor( "impact_stun_duration" )
        self.damage = self:GetSpecialValueFor( "impact_damage" )
        self.radius = self:GetSpecialValueFor( "impact_radius" )

        --play effects
        local effect_cast = self:PlayEffects2( hTarget )

        --knockback
        local knockback = hTarget:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = self.distance,
                height = self.height,
                duration = self.duration,
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
                hTarget:GetTeamNumber(),	-- int, your team number
                hTarget:GetOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
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
            GridNav:DestroyTreesAroundPoint( hTarget:GetOrigin(), self.radius, true )

            -- play effects
            ParticleManager:DestroyParticle( effect_cast, false )
            ParticleManager:ReleaseParticleIndex( effect_cast )
            self:PlayEffects3( hTarget, self.radius )

        end
        if hTarget:IsAlive() then
            knockback:SetEndCallback( callback )
        end


        if self.caster.bounces > 0 then
            
            local cookie_multi_range = self.bounce_range

            --bounce
            local units = FindUnitsInRadius(self.caster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, 
            cookie_multi_range, DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER, false)

            local numUnits = 0
            for _, unit in pairs(units) do
                numUnits = numUnits + 1
            end

            --if there is 1 unit,
                --it's the caster
            --if there is 2 or more units,
                --if it's the caster,
                    --continue
                --else,
                    --bounce to that unit

            if numUnits == 1 then
                print("one unit found")
                --unit is caster
                --no other unit found; end chain
                --cookie_party:SpawnCookie(self.caster, self.targets_hit)
                --break
            elseif numUnits > 1 then
                print("more than one unit found")
                for _, unit in pairs(units) do
                    if unit == hTarget then
                        --continue
                    else
                        --take first unit
                        --create projectile
                        --send it to unit
                        --break
                        local info = 
                        {
                            Target = unit,
                            Source = hTarget, --will change this dynamically
                            Ability = self,	
                            EffectName = "particles/luna_glaive_crescent_moon_custom.vpcf",
                            iMoveSpeed = 1000,
                            vSourceLoc= hTarget:GetAbsOrigin(),  --will change this dynamically   
                            bDrawsOnMinimap = false,                          -- Optional
                                bDodgeable = false,                                -- Optional
                                bIsAttack = false,                                -- Optional
                                bVisibleToEnemies = true,                         -- Optional
                                bReplaceExisting = false,                         -- Optional
                            flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
                            bProvidesVision = false,                           -- Optional
                            iVisionRadius = 400,                              -- Optional
                            iVisionTeamNumber = self.caster:GetTeamNumber()        -- Optional
                        }
                        projectile = ProjectileManager:CreateTrackingProjectile(info)

                        --switch target
                        --hTarget = unit
                        break
                    end
                end
            end

            --if hTarget:GetUnitName() ~= "npc_dota_hero_snapfire" then
                --don't count in the number of bounces
            --else
                self.caster.bounces = self.caster.bounces - 1
            --end
        elseif self.caster.bounces == 0 then
            --cookie_party:SpawnCookie(self.caster, self.targets_hit)
        end

        return true
    end
end

function chain_cookie:PlayEffects2( target )
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

function chain_cookie:PlayEffects3( target, radius )
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

