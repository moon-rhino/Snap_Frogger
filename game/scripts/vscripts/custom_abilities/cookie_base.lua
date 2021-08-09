--base cookie
--on cast
--if unit has baker's dozen then
--cast it on target

-- Cookie spell recreated by EarthSalamander42
-- see the reference at https://github.com/EarthSalamander42/dota_imba/blob/47d802f6718929726fb24dd4c5b140064f1dfd15/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/abilities/heroes/hero_snapfire.lua

--secondary cookie search radius = 450
--secondary cookie jump distance ally = 450
--secondary cookie jump distance enemy = 0

--------------------------------------------------------------------------------
cookie_base = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mortimer_kisses_thinker_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Custom KV
function cookie_base:GetCastPoint()
	if IsServer() and self:GetCursorTarget()==self:GetCaster() then
		return self:GetSpecialValueFor( "self_cast_delay" )
	end
	return 0.2
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function cookie_base:CastFilterResultTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return UF_FAIL_CUSTOM
    elseif IsServer() then
        --if unit has raisin firesnap then
            --cast to all
        --else
            --cast to friendly
        local nResult
        local caster = self:GetCaster()
        if self:GetCaster():HasAbility("cookie_raisin_firesnap") or self:GetCaster():HasAbility("cookie_bakers_dozen") 
        or self:GetCaster():HasAbility("cookie_party") then
            nResult = UnitFilter(
                hTarget,
                DOTA_UNIT_TARGET_TEAM_BOTH,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
                0,
                self:GetCaster():GetTeamNumber()
            )
        else
            nResult = UnitFilter(
                hTarget,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
                0,
                self:GetCaster():GetTeamNumber()
            )
        end
        if nResult ~= UF_SUCCESS then
            return nResult
        end

        return UF_SUCCESS
    end
end

function cookie_base:GetCustomCastErrorTarget( hTarget )
	if IsServer() and hTarget:IsChanneling() then
		return "#dota_hud_error_is_channeling"
	end

	return ""
end



--------------------------------------------------------------------------------
-- Ability Phase Start
function cookie_base:OnAbilityPhaseInterrupted()

end
function cookie_base:OnAbilityPhaseStart()
	if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end


	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function cookie_base:OnSpellStart()

    self.secondary_projectiles = {}
	-- unit identifier
    local caster = self:GetCaster()
    self.caster = caster
    local target = self:GetCursorTarget()
    self.target = target
    

	-- load data
    local projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf"
    self.projectile_name = projectile_name
    local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
    self.projectile_speed = projectile_speed

	--[[if caster:GetTeam() ~= target:GetTeam() then
		projectile_name = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_enemy_projectile.vpcf"
	end]]

	-- create projectile
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
	EmitSoundOn( sound_cast, self.caster )
end

--------------------------------------------------------------------------------
-- Projectile
function cookie_base:OnProjectileHit( target, location )
    --cast on enemy
    --jump in place
    --everyone around the target gets a cookie
        --friends jump forward
        --enemies hop in place

    --cast on friend
    --jump
    --on land, if caster has baker's dozen then
        --everyone around the friend gets a cookie
        --friends jump forward
        --enemies hop in place

    -- load data
    local duration = self:GetSpecialValueFor( "jump_duration" )
    local height = self:GetSpecialValueFor( "jump_height" )
    local distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
    local distance_secondary
    if self.caster:HasAbility("cookie_bakers_dozen") then
        --allies jump forward, enemies don't
        if target:GetTeam() == self.caster:GetTeam() then
            --distance_secondary = self.caster:FindAbilityByName("cookie_bakers_dozen"):GetSpecialValueFor( "horizontal_jump_distance_ally" )
            distance_secondary = 450
        else
            --distance_secondary = self.caster:FindAbilityByName("cookie_bakers_dozen"):GetSpecialValueFor( "horizontal_jump_distance_enemy" )
            distance_secondary = 0
        end
    end
    local stun = self:GetSpecialValueFor( "impact_stun_duration" )
    local damage = self:GetSpecialValueFor( "impact_damage" )
    local radius = self:GetSpecialValueFor( "impact_radius" )
    if not target then return end
    --receiving cookie effect
    -- play effects2
    local effect_cast = self:PlayEffects2( target )

    --secondary units
    if target ~= self.target then
        --targets get knocked in the air
        --load data

        -- knockback
        -- describes the "jumping" motion
        local knockback_secondary = target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = distance_secondary,
                height = height,
                duration = duration,
                direction_x = target:GetForwardVector().x,
                direction_y = target:GetForwardVector().y,
                IsStun = true,
            } -- kv
        )

        -- on landing
        local callback = function()
            -- precache damage
            local damageTable = {
                -- victim = target,
                attacker = self.caster,
                damage = 0,
                damage_type = self:GetAbilityDamageType(),
                ability = self, --Optional.
            }

            -- find enemies
            local enemies = FindUnitsInRadius(
                self.caster:GetTeamNumber(),	-- int, your team number
                target:GetOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
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
                        { duration = stun } -- kv
                    )
            end

            -- destroy trees
            GridNav:DestroyTreesAroundPoint( target:GetOrigin(), radius, true )

            -- play effects
            ParticleManager:DestroyParticle( effect_cast, false )
            ParticleManager:ReleaseParticleIndex( effect_cast )
            self:PlayEffects3( target, radius )

            --apply raisin firesnap effect
            self:RaisinFiresnapEffect(self.caster, target)

        end

        if target:IsAlive() then
            knockback_secondary:SetEndCallback( callback )
        end

    --primary target
    else

        --if target is an enemy of caster
        if target:GetTeamNumber() ~= self.caster:GetTeamNumber() then
            -- knockback
            -- describes the "jumping" motion
            local knockback = target:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "modifier_knockback_custom", -- modifier name
                {
                    distance = distance_secondary,
                    height = height,
                    duration = duration,
                    direction_x = target:GetForwardVector().x,
                    direction_y = target:GetForwardVector().y,
                    IsStun = true,
                } -- kv
            )

            -- baker's dozen effect
            self:BakersDozenEffect(self.caster, target)

            -- cookie_oven effect
            if self.caster:HasAbility("cookie_oven") then
                self:OvenEffect(self.caster, target)
            end

            -- on landing
            local callback = function()
                -- precache damage
                local damageTable = {
                    -- victim = target,
                    attacker = self.caster,
                    damage = damage,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self, --Optional.
                }

                -- find enemies
                local enemies = FindUnitsInRadius(
                    self.caster:GetTeamNumber(),	-- int, your team number
                    target:GetOrigin(),	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
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
                        { duration = stun } -- kv
                    )

                end

                -- destroy trees
                GridNav:DestroyTreesAroundPoint( target:GetOrigin(), radius, true )

                -- play effects
                ParticleManager:DestroyParticle( effect_cast, false )
                ParticleManager:ReleaseParticleIndex( effect_cast )
                self:PlayEffects3( target, radius )

                --apply raisin firesnap effect
                self:RaisinFiresnapEffect(self.caster, target)

            end

            --if target dies during jump, there will be no modifier to callback and it will cause an error
            if target:IsAlive() then
                knockback:SetEndCallback( callback )
            end

        --self cast / ally
        else
            -- knockback
            -- describes the "jumping" motion
            local knockback = target:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "modifier_knockback_custom", -- modifier name
                {
                    distance = distance,
                    height = height,
                    duration = duration,
                    direction_x = target:GetForwardVector().x,
                    direction_y = target:GetForwardVector().y,
                    IsStun = true,
                } -- kv
            )

            --baker's dozen upgrade
            self:BakersDozenEffect(self.caster, target)

            -- oven effect
            if self.caster:HasAbility("cookie_oven") then
                self:OvenEffect(self.caster, target)
            end

            -- on landing
            local callback = function()
                -- precache damage
                local damageTable = {
                    -- victim = target,
                    attacker = self.caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self, --Optional.
                }

                -- find enemies
                local enemies = FindUnitsInRadius(
                    self.caster:GetTeamNumber(),	-- int, your team number
                    target:GetOrigin(),	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
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
                            { duration = stun } -- kv
                        )
                end

                -- destroy trees
                GridNav:DestroyTreesAroundPoint( target:GetOrigin(), radius, true )

                -- play effects
                ParticleManager:DestroyParticle( effect_cast, false )
                ParticleManager:ReleaseParticleIndex( effect_cast )
                self:PlayEffects3( target, radius )

                --apply raisin firesnap effect
                self:RaisinFiresnapEffect(self.caster, target)

            end
            --returns when knockback is finished
            if target:IsAlive() then
                knockback:SetEndCallback( callback )
            end
        end
    end
        
	if target:IsChanneling() or target:IsOutOfGame() then return end

	-- If the target possesses a ready Linken's Sphere, do nothing
	if target:GetTeam() ~= self.caster:GetTeam() then
		if target:TriggerSpellAbsorb(self) then
			return nil
		end
	end

	-- Firesnap Cookie heals
	if self.caster:HasTalent("special_bonus_unique_snapfire_5") then
		if target:GetTeam() == self.caster:GetTeam() then
			target:Heal(self.caster:FindTalentValue("special_bonus_unique_snapfire_5"), self.caster)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, self.caster:FindTalentValue("special_bonus_unique_snapfire_5"), nil)
		end
	end

end

--------------------------------------------------------------------------------
function cookie_base:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.caster )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function cookie_base:PlayEffects2( target )
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

function cookie_base:PlayEffects3( target, radius )
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

--------------------------------------------------------------------------------
function cookie_base:PlayEffectsKisses( loc, owner )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf"
	local sound_cast = "Hero_Snapfire.MortimerBlob.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, owner )
	ParticleManager:SetParticleControl( effect_cast, 3, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, owner )
	ParticleManager:SetParticleControl( effect_cast, 0, loc )
	ParticleManager:SetParticleControl( effect_cast, 1, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	local sound_location = "Hero_Snapfire.MortimerBlob.Impact"
	EmitSoundOnLocationWithCaster( loc, sound_location, owner )
end


--------------------------------------------------------------------------------
function cookie_base:PlayEffectsCalldown( owner )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_CUSTOMORIGIN, owner, owner:GetTeamNumber() )
	ParticleManager:SetParticleControl( self.effect_cast, 0, owner:GetOrigin() )
    --ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius*(self.max_travel/time) ) )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( 500, 0, -500*(2/time) ) )
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( time, 0, 0 ) )
end


--create projectile
--hit the spot the target lands at

function cookie_base:RaisinFiresnapEffect(caster, target)
    --if raisin firesnap active then
    if caster:HasAbility("cookie_raisin_firesnap") then
        local mortimer_kisses_abil = caster:FindAbilityByName("mortimer_kisses_base")
        --create particle
        --[[local mod = target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "mortimer_kisses_thinker_modifier", -- modifier name
            {
                duration = mortimer_kisses_abil:GetSpecialValueFor("burn_ground_duration"),
                slow = 1,
            } -- kv
        )]]

        --create projectile
        -- create target thinker
        --needs mortimer_kisses_base ability to work
        local thinker = CreateModifierThinker(
            caster, -- player source
            caster:FindAbilityByName("mortimer_kisses_base"), -- ability source
            "mortimer_kisses_thinker_modifier", -- modifier name
            { travel_time = 0 }, -- kv
            target:GetAbsOrigin(),
            caster:GetTeamNumber(),
            false
        )

        --explosion only happens for the mortimer kisses ability
        local info = {
            Target = thinker,
            Source = target,
            Ability = caster:FindAbilityByName("mortimer_kisses_base"),	
            iMoveSpeed = 1000,
            EffectName = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf",
            bDodgeable = false,                           -- Optional

            vSourceLoc = target:GetAbsOrigin(),                -- Optional (HOW)

            bDrawsOnMinimap = false,                          -- Optional
            bVisibleToEnemies = true,                         -- Optional
            bProvidesVision = true,                           -- Optional
            iVisionRadius = self:GetSpecialValueFor( "projectile_vision" ),                              -- Optional
            iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
        }

        -- launch projectile
        ProjectileManager:CreateTrackingProjectile( info )
        --cookie_base:PlayEffectsKisses(target:GetAbsOrigin(), self.caster)
        --cookie_base:PlayEffectsCalldown( 1, target )
        --apply magma burn modifier
    end
end

function cookie_base:BakersDozenEffect(caster, target)

    if caster:HasAbility("cookie_bakers_dozen") then
        local bakers_dozen_ability = caster:FindAbilityByName("cookie_bakers_dozen")
        -- find friends around location
        -- when the projectile hits
        --doesn't work
        --local spread_radius = bakers_dozen_ability:GetSpecialValueFor("range")
        local units = FindUnitsInRadius(
            caster:GetTeamNumber(),	-- int, your team number
            target:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            --manually set because get special value for "range" doesn't work
            450,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY + DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        --create tracking projectiles to them
        for i, unit in pairs(units) do

            -- create projectile
            if unit ~= target then

                --cookie cast to self = don't cookie yourself again
                if target == caster then
                    if unit == caster then
                        --skip
                    else
                        local info = {
                            Target = unit,
                            Source = target,
                            Ability = self,	
                            EffectName = self.projectile_name,
                            iMoveSpeed = self.projectile_speed,
                            bDodgeable = false,                           -- Optional
                        }
                        self.secondary_projectiles[i] = ProjectileManager:CreateTrackingProjectile(info)
                    end

                --cookie cast to another hero = if you're in range, cookie yourself
                else
                    local info = {
                        Target = unit,
                        Source = target,
                        Ability = self,	
                        EffectName = self.projectile_name,
                        iMoveSpeed = self.projectile_speed,
                        bDodgeable = false,                           -- Optional
                    }
                    self.secondary_projectiles[i] = ProjectileManager:CreateTrackingProjectile(info)
                end
            end
        end
    end
end

--oven
--primary target
function cookie_base:OvenEffect(caster, target)

    --load parameters
    local ovenAbility = caster:FindAbilityByName("cookie_oven")
    local hullRadius = ovenAbility:GetSpecialValueFor("hull_radius")
    local spawnInterval = ovenAbility:GetSpecialValueFor("spawn_interval")
    --local maxSpawnDistance = ovenAbility:GetSpecialValueFor("max_spawn_distance")

    --create an oven at the target's location
    local oven = CreateUnitByName("oven", target:GetAbsOrigin(), true, caster, caster, caster:GetTeam())

    --add collision to the oven
    oven:SetHullRadius(hullRadius)

    --thinker
    oven:SetThink("OvenThinker", self)

    --for every 3 seconds, spawn a cookie
end

function cookie_base:OvenThinker(oven)
    local counter = 0
    Timers:CreateTimer(function()
        --cast bake
        local bakeAbility = oven:FindAbilityByName("bake")
        bakeAbility:OnSpellStart()
        counter = counter + 1
        if counter == 7 or oven:IsAlive() == false then
            oven:RemoveSelf()
        else
            --return 2.0
            --testing
            return 0.7
        end
    end)
end
    