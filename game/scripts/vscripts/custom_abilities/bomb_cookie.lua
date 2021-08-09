LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)

bomb_cookie = class({})

function bomb_cookie:GetAOERadius()
        return self:GetSpecialValueFor( "bomb_radius" )
end

function bomb_cookie:OnSpellStart()
    if IsServer() then
        

        local caster = self:GetCaster()
        self.caster = caster
        EmitSoundOn("flamebreak_cast", self.caster)
        local cursorPt = self:GetCursorPosition()
        local casterPt = caster:GetAbsOrigin()
        dummy = CreateUnitByName("dummy", cursorPt, true, caster, caster, caster:GetTeamNumber())
        --even if the dummy is killed right after it's created, OnProjectileHit will still trigger when it reaches where it was
        --maybe because the dummy isn't fully dead -- it hasn't been removed from the game
        dummy:ForceKill(false)

        self.duration = self:GetSpecialValueFor( "jump_duration" )
        self.height = self:GetSpecialValueFor( "jump_height" )
        self.distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
        self.stun = self:GetSpecialValueFor( "impact_stun_duration" )
        self.damage = self:GetSpecialValueFor( "impact_damage" )
        --can't be seen
        self.radius = self:GetSpecialValueFor( "impact_radius" )
        self.bomb_radius = self:GetSpecialValueFor( "bomb_radius" )

        local info = 
        {
            Target = dummy,
            Source = caster,
            Ability = self,	
            EffectName = "particles/hero_snapfire_cookie_projectile_molotov_2.vpcf",
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
end

function bomb_cookie:OnProjectileHit(hTarget, vLocation)
    if IsServer() then
        EmitSoundOn("flamebreak_impact", hTarget)
        --phase boots, force staff
        --bomb, arrow, chain
        --send cookies to targets
        local bomb_cookie_range = self.bomb_radius
        local units = FindUnitsInRadius(self:GetCaster():GetTeam(), hTarget:GetAbsOrigin(), nil, 
        bomb_cookie_range, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, false)
        --if there's no units found, it still exists, but it's empty
        local numUnits = 0
        for _, unit in pairs(units) do
            numUnits = numUnits + 1
        end

        --cookie_party:SpawnCookie(self.caster, numUnits)

        if numUnits>0 then
            for key, unit in pairs(units) do

                --bomb explodes
                --send a cookie to the unit
                    --create projectile
                    --source = hTarget
                    --target = unit
                    --ability = cookie_base
                local info = 
                {
                    Target = unit,
                    Source = hTarget,
                    Ability = self:GetCaster():FindAbilityByName("bomb_cookie_effect"),	
                    EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf",
                    iMoveSpeed = 1000,
                    vSourceLoc= self:GetCaster():GetAbsOrigin(),                -- Optional (HOW)
                    bDrawsOnMinimap = false,                          -- Optional
                        bDodgeable = false,                                -- Optional
                        bIsAttack = false,                                -- Optional
                        bVisibleToEnemies = true,                         -- Optional
                        bReplaceExisting = false,                         -- Optional
                        flExpireTime = GameRules:GetGameTime() + 5,      -- Optional but recommended
                    bProvidesVision = false,                           -- Optional
                    iVisionRadius = 400,                              -- Optional
                    iVisionTeamNumber = self:GetCaster():GetTeamNumber()        -- Optional
                }
                projectile = ProjectileManager:CreateTrackingProjectile(info)
                

            end
        end
        return true
    end
end

--------------------------------------------------------------------------------
function bomb_cookie:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function bomb_cookie:PlayEffects2( target )
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

function bomb_cookie:PlayEffects3( target, radius )
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

