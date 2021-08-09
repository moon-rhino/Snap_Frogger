shoot_cookies = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)

function shoot_cookies:OnSpellStart()
    --shoot cookies
    --values
    self.number_of_cookies = self:GetSpecialValueFor("number_of_cookies")
    self.projectile_speed = self:GetSpecialValueFor("projectile_speed")
    --self.shoot_interval = self:GetSpecialValueFor("shoot_interval")
    self.projectile_distance = self:GetSpecialValueFor("projectile_distance")
    self.jump_horizontal_distance = self:GetSpecialValueFor("jump_horizontal_distance")
    --height
    --duration
    self.jump_height = self:GetSpecialValueFor("jump_height")
    self.jump_duration = self:GetSpecialValueFor("jump_duration")
    self.impact_radius = self:GetSpecialValueFor("impact_radius")
    self.impact_damage = self:GetSpecialValueFor("impact_damage")
    self.impact_stun_duration = self:GetSpecialValueFor("impact_stun_duration")
    self.caster = self:GetCaster()

    --math for calculating cookie direction for each cookie

    local forwardVector = self.caster:GetForwardVector()

    --get the angle that the character is facing
    local quadrant
    if self.caster:GetForwardVector().x > 0 and self.caster:GetForwardVector().y > 0 then
        --quadrant 1
        quadrant = 1
    elseif self.caster:GetForwardVector().x < 0 and self.caster:GetForwardVector().y > 0 then
        --quadrant 2
        quadrant = 2
    elseif self.caster:GetForwardVector().x < 0 and self.caster:GetForwardVector().y < 0 then
        --quadrant 3
        quadrant = 3
    else
        --quadrant 4
        quadrant = 4
    end
    local angleFacing = math.atan(self.caster:GetForwardVector().y / self.caster:GetForwardVector().x)
    --reversed for quadrants 2 and 
    --be aware of the range -pi/2 to pi/2
    if quadrant == 2 or quadrant == 3 then
        --cycles every pi
        --graph starts from bottom after one cycle
        angleFacing = angleFacing + math.pi
    end

    --cookie 1: forward

    --convert forward vector into radians
    --add angle to it
    --take new direction
    local angleTurn = math.rad(0)
    local angleShoot = angleFacing + angleTurn

    local direction = Vector(math.cos(angleShoot), math.sin(angleShoot), 0)
    --[[print("side direction: ")
    print(direction)
    direction = direction:Normalized()]]
    local info = 
    { 
        Ability = self,
        --EffectName = "models/morty_cookie_bullet.vmdl", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
        EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
        vSpawnOrigin = self.caster:GetAbsOrigin(),
        fDistance = self.projectile_distance,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = self.caster,
        --bHasFrontalCone = false,
        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5,
        bDeleteOnHit = true,
        vVelocity = direction * self.projectile_speed,
        bProvidesVision = true,
        iVisionRadius = 500,
        iVisionTeamNumber = self.caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)

    --cookie two
    local angleTurn = math.rad(60)
    local angleShoot = angleFacing + angleTurn

    local direction = Vector(math.cos(angleShoot), math.sin(angleShoot), 0)
    local info = 
    { 
        Ability = self,
        --EffectName = "models/morty_cookie_bullet.vmdl", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
        EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
        vSpawnOrigin = self.caster:GetAbsOrigin(),
        fDistance = self.projectile_distance,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = self.caster,
        --bHasFrontalCone = false,
        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5,
        bDeleteOnHit = true,
        vVelocity = direction * self.projectile_speed,
        bProvidesVision = true,
        iVisionRadius = 500,
        iVisionTeamNumber = self.caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)

    --cookie three
    local angleTurn = math.rad(120)
    local angleShoot = angleFacing + angleTurn

    local direction = Vector(math.cos(angleShoot), math.sin(angleShoot), 0)
    local info = 
    { 
        Ability = self,
        --EffectName = "models/morty_cookie_bullet.vmdl", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
        EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
        vSpawnOrigin = self.caster:GetAbsOrigin(),
        fDistance = self.projectile_distance,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = self.caster,
        --bHasFrontalCone = false,
        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5,
        bDeleteOnHit = true,
        vVelocity = direction * self.projectile_speed,
        bProvidesVision = true,
        iVisionRadius = 500,
        iVisionTeamNumber = self.caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)

    --cookie four
    local angleTurn = math.rad(180)
    local angleShoot = angleFacing + angleTurn

    local direction = Vector(math.cos(angleShoot), math.sin(angleShoot), 0)
    local info = 
    { 
        Ability = self,
        --EffectName = "models/morty_cookie_bullet.vmdl", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
        EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
        vSpawnOrigin = self.caster:GetAbsOrigin(),
        fDistance = self.projectile_distance,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = self.caster,
        --bHasFrontalCone = false,
        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5,
        bDeleteOnHit = true,
        vVelocity = direction * self.projectile_speed,
        bProvidesVision = true,
        iVisionRadius = 500,
        iVisionTeamNumber = self.caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)

    --cookie five
    local angleTurn = math.rad(240)
    local angleShoot = angleFacing + angleTurn

    local direction = Vector(math.cos(angleShoot), math.sin(angleShoot), 0)
    local info = 
    { 
        Ability = self,
        --EffectName = "models/morty_cookie_bullet.vmdl", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
        EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
        vSpawnOrigin = self.caster:GetAbsOrigin(),
        fDistance = self.projectile_distance,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = self.caster,
        --bHasFrontalCone = false,
        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5,
        bDeleteOnHit = true,
        vVelocity = direction * self.projectile_speed,
        bProvidesVision = true,
        iVisionRadius = 500,
        iVisionTeamNumber = self.caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)

    --cookie six
    local angleTurn = math.rad(300)
    local angleShoot = angleFacing + angleTurn

    local direction = Vector(math.cos(angleShoot), math.sin(angleShoot), 0)
    local info = 
    { 
        Ability = self,
        --EffectName = "models/morty_cookie_bullet.vmdl", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
        EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
        vSpawnOrigin = self.caster:GetAbsOrigin(),
        fDistance = self.projectile_distance,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = self.caster,
        --bHasFrontalCone = false,
        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5,
        bDeleteOnHit = true,
        vVelocity = direction * self.projectile_speed,
        bProvidesVision = true,
        iVisionRadius = 500,
        iVisionTeamNumber = self.caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)
end

function shoot_cookies:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then
        --skip
    elseif hTarget == self:GetCaster() then
        --skip
    else
        if GameMode.gameActive then
            self:GetCaster():GetOwnerEntity().score = self:GetCaster():GetOwnerEntity().score + 1 
        end
        local knockback = hTarget:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = self.jump_horizontal_distance,
                height = self.jump_height,
                duration = self.jump_duration,
                direction_x = hTarget:GetForwardVector().x,
                direction_y = hTarget:GetForwardVector().y,
                IsStun = true,
            } -- kv
        )
       -- hTarget:AddNewModifier(nil, nil, "modifier_invulnerable", {duration = self.jump_duration})
        -- on landing
        local callback = function()
            -- precache damage
            local damageTable = {
                -- victim = hTarget,
                attacker = self.caster,
                damage = self.impact_damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self, --Optional.
            }

            -- find enemies
            local enemies = FindUnitsInRadius(
                self.caster:GetTeamNumber(),	-- int, your team number
                hTarget:GetAbsOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                self.impact_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
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
                    { duration = self.impact_stun_duration } -- kv
                )
            end

            -- destroy trees
            GridNav:DestroyTreesAroundPoint( hTarget:GetOrigin(), self.impact_radius, true )

            -- play effects
            --ParticleManager:DestroyParticle( effect_cast, false )
            --ParticleManager:ReleaseParticleIndex( effect_cast )
            self:PlayEffects3( hTarget, self.impact_radius )

        end

        --returns when knockback is finished
        if hTarget:IsAlive() then
            knockback:SetEndCallback( callback )
        end

        return true
    end
end

function shoot_cookies:PlayEffects3( target, radius )
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