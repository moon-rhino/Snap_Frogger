cookie_bomb = class({})

function cookie_bomb:GetAOERadius()
    return 300
end

function cookie_bomb:OnSpellStart()
    local caster = self:GetCaster()
    local cursorPt = self:GetCursorPosition()
    local casterPt = caster:GetAbsOrigin()
    dummy = CreateUnitByName("dummy", cursorPt, true, caster, caster, caster:GetTeamNumber())
    --even if the dummy is killed right after it's created, OnProjectileHit will still trigger when it reaches where it was
    --maybe because the dummy isn't fully dead -- it hasn't been removed from the game
    dummy:ForceKill(false)

    --special values
    --because random float doesn't work with negative values
    local randomSign = math.random(1, 2)
    if randomSign == 1 then
        randomSign = -1
    else
        randomSign = 1
    end
    self.duration = self:GetSpecialValueFor( "jump_duration" ) + randomSign * RandomFloat(0, 0.2)
    self.height = self:GetSpecialValueFor( "jump_height" ) + math.random(-50, 50)
    self.distance = self:GetSpecialValueFor( "jump_horizontal_distance" ) + math.random(-100, 100)
    self.stun = self:GetSpecialValueFor( "impact_stun_duration" ) + randomSign * RandomFloat(0, 0.3)
    self.damage = self:GetSpecialValueFor( "impact_damage" ) + math.random(-100, 100)
    --can't be seen
    self.radius = self:GetSpecialValueFor( "impact_radius" )

    local info = 
    {
        Target = dummy,
        Source = caster,
        Ability = self,	
        EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf",
        iMoveSpeed = 1000,
        vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
        bDrawsOnMinimap = false,                          -- Optional
            bDodgeable = false,                                -- Optional
            bIsAttack = false,                                -- Optional
            bVisibleToEnemies = true,                         -- Optional
            bReplaceExisting = false,                         -- Optional
            flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
        bProvidesVision = false,                           -- Optional
        iVisionRadius = 400,                              -- Optional
        iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
    }
    projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function cookie_bomb:OnProjectileHit(hTarget, vLocation)
    local cookie_bomb_range = 300
    local units = FindUnitsInRadius(self:GetCaster():GetTeam(), hTarget:GetAbsOrigin(), nil, 
    cookie_bomb_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER, false)
    --if there's no units found, it still exists, but it's empty
    local numUnits = 0
    for _, unit in pairs(units) do
        numUnits = numUnits + 1
    end
    if numUnits>0 then
        for key, unit in pairs(units) do
            if unit == self:GetCaster() then
                --nothing
            else
                --bomb explodes
                --unit gets knocked back
                --unit stuns and damages its enemies, not the caster's
                local effect_cast = self:PlayEffects2( unit )
                --knockback
                local knockback = unit:AddNewModifier(
                    self:GetCaster(), -- player source
                    self, -- ability source
                    "modifier_knockback_custom", -- modifier name
                    {
                        distance = self.distance,
                        height = self.height,
                        duration = self.duration,
                        direction_x = unit:GetForwardVector().x,
                        direction_y = unit:GetForwardVector().y,
                        IsStun = true,
                    } -- kv
                )
                -- on landing
                local callback = function()
                    -- precache damage
                    local damageTable = {
                        -- victim = unit,
                        attacker = self:GetCaster(),
                        damage = self.damage,
                        damage_type = self:GetAbilityDamageType(),
                        ability = self, --Optional.
                    }

                    -- find enemies
                    local enemies = FindUnitsInRadius(
                        unit:GetTeamNumber(),	-- int, your team number
                        unit:GetOrigin(),	-- point, center point
                        nil,	-- handle, cacheUnit. (not known)
                        self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                        0,	-- int, flag filter
                        0,	-- int, order filter
                        false	-- bool, can grow cache
                    )

                    for _,enemy in pairs(enemies) do
                        --if enemy is the caster,
                        if enemy:GetTeam() == self:GetCaster():GetTeam() then
                            --skip
                        --else
                        else
                            --apply damage
                            damageTable.victim = enemy
                            ApplyDamage(damageTable)
                            --stun
                            enemy:AddNewModifier(
                                self:GetCaster(), -- player source
                                self, -- ability source
                                "modifier_stunned", -- modifier name
                                { duration = self.stun } -- kv
                            )
                        end
                    end

                    -- destroy trees
                    GridNav:DestroyTreesAroundPoint( unit:GetOrigin(), self.radius, true )

                    -- play effects
                    ParticleManager:DestroyParticle( effect_cast, false )
                    ParticleManager:ReleaseParticleIndex( effect_cast )
                    self:PlayEffects3( unit, self.radius )

                end
                --returns when knockback is finished
                if self:GetCaster():IsAlive() then
                    knockback:SetEndCallback( callback )
                elseif unit:IsAlive() then
                    knockback:SetEndCallback( callback )
                end
            end
        end
    end
    return true
end

--------------------------------------------------------------------------------
function cookie_bomb:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function cookie_bomb:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_buff.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_receive.vpcf"
	local sound_target = "Hero_Snapfire.FeedCookie.Consume"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, target )

	-- Create Sound
	--EmitSoundOn( sound_target, target )

	return effect_cast
end

function cookie_bomb:PlayEffects3( target, radius )
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

