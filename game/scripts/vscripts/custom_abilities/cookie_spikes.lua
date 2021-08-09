--send a projectile
--whoever gets hit by it gets knocked back in the direction they're facing
--send out cookies in a line
--cookie has no collision
--jumps in place 

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)

cookie_spikes = class({})

function cookie_spikes:OnSpellStart()

    
    self.caster = self:GetCaster()
    --A Liner Projectile must have a table with projectile info

    local cursorPt = self:GetCursorPosition()
    local casterPt = self.caster:GetAbsOrigin()
    local direction = cursorPt - casterPt
    direction = direction:Normalized()

    local info = 
    { 
        Ability = self,
        EffectName = "particles/hero_snapfire_cookie_projectile_linear.vpcf", --particle effect
        --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
        vSpawnOrigin = self.caster:GetAbsOrigin(),
        fDistance = 2000,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = self.caster,
        --bHasFrontalCone = false,
        --bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = false,
        vVelocity = direction * 500,
        bProvidesVision = true,
        iVisionRadius = 500,
        iVisionTeamNumber = self.caster:GetTeamNumber()
    }
    self.projectile = ProjectileManager:CreateLinearProjectile(info)


    local counter = 0
    Timers:CreateTimer(string.format("cookie_spikes"), {
		useGameTime = true,
		callback = function()
            if counter < 1 then
                local dummyUnit = CreateUnitByName("leaf", Vector(3039 + (counter * 1000), 1286 + (counter * 1000), 384), true, nil, nil, 0)
                dummyUnit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
                --self.shadowrazeUnits[self.unitNum].unitNum = self.unitNum
                dummyUnit:SetControllableByPlayer(0, true)
                --self.shadowrazeUnits[self.unitNum]:AddNewModifier(nil, nil, "modifier_set_max_move_speed", {})
                --direction
                --move to position doesn't work
                --local shadowrazeUnitDirection = (-shadowrazeUnit:GetAbsOrigin() + target_pos)
                local knockback = dummyUnit:AddNewModifier(
                    nil, -- player source
                    nil, -- ability source
                    "modifier_knockback_custom", -- modifier name
                    {
                        distance = 0,
                        height = 200,
                        duration = 0.25,
                        direction_x = 1,
                        direction_y = 1,
                        IsStun = true,
                    } -- kv
                )
                counter = counter + 0.1
                Timers:CreateTimer("cookie_spikes_remove", {
                    useGameTime = true,
                    endTime = 0.15,
                    callback = function()
                        dummyUnit:ForceKill(false)
                        dummyUnit:RemoveSelf()
                        return nil
                    end
                })
                return 0.2
            else
                return nil
            end
        end
    }) 

end

function cookie_spikes:PlayEffects4(caster)
	local dummyUnit = CreateUnitByName("leaf", Vector(3039, 1286, 384), true, caster, caster, caster:GetTeam())
	--self.shadowrazeUnits[self.unitNum].unitNum = self.unitNum
	dummyUnit:SetControllableByPlayer(0, true)
	--self.shadowrazeUnits[self.unitNum]:AddNewModifier(nil, nil, "modifier_set_max_move_speed", {})
	--direction
	--move to position doesn't work
	--local shadowrazeUnitDirection = (-shadowrazeUnit:GetAbsOrigin() + target_pos)
	local knockback = dummyUnit:AddNewModifier(
		nil, -- player source
		nil, -- ability source
		"modifier_knockback_custom", -- modifier name
		{
			distance = 0,
			height = 100,
			duration = 2,
			direction_x = 1,
			direction_y = 1,
			IsStun = true,
		} -- kv
	)
    local counter = 0
    self.cookies = {}
	Timers:CreateTimer(string.format("cookie_spikes"), {
		useGameTime = true,
		callback = function()
			if counter >= 0.2 then
				dummyUnit:ForceKill(false)
				dummyUnit:RemoveSelf()
				return nil
			else
                self.cookies[1] = CreateUnitByName("leaf", dummyUnit:GetAbsOrigin(), true, caster, caster, 0)
                self.cookies[1]:SetControllableByPlayer(0, true)
                self.cookies[1]:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
				self.cookies[1]:AddNewModifier(
                    caster, -- player source
                    nil, -- ability source
                    "modifier_knockback_custom", -- modifier name
                    {
                        distance = 1,
                        height = 300,
                        duration = 0.5,
                        direction_x = 0,
                        direction_y = 0,
                        IsStun = true,
                    } -- kv
                )
                -- on landing
                --[[local callback = function()
                    self.cookies[counter]:ForceKill(false)
                    self.cookies[counter]:RemoveSelf()
                end]]
                --knockback_secondary:SetEndCallback( callback )
                counter = counter + 0.2
                return 0.2
            end
		end
	}) 
end


function cookie_spikes:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then
        print("arrow expired")
    elseif hTarget:IsRealHero() then
        if hTarget == self:GetCaster() then
            --skip
        else
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
                        print("[cookie_base:OnProjectileHit] enemy found")
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

function cookie_spikes:PlayEffects2( target )
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

function cookie_spikes:PlayEffects3( target, radius )
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