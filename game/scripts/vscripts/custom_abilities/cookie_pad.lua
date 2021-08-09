--summon a unit
--knockback to cursor point
--500hp
--thinker: find units in radius
--when a unit is found, cookie effect
--magic immune
--charges; maximum 3 on the field
--determine distance of jump based on channel

--use for event

cookie_pad = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Ability Start
function cookie_pad:OnSpellStart()
    local caster = self:GetCaster()
    local cursorPt = self:GetCursorPosition()
    local casterPt = caster:GetAbsOrigin()
    local direction = cursorPt - casterPt
    direction = direction:Normalized()

    --summon a unit
    local pad = CreateUnitByName("cookie_pad", casterPt, true, caster, caster, caster:GetTeamNumber())
    --buff depending on what kind of cookie it is
    --randomized cookie
    --cm: lich armor

    --knock back to cursorpoint
    local knockback = pad:AddNewModifier(
        self:GetCaster(), -- player source
        self, -- ability source

        "modifier_knockback_custom", -- modifier name
        {
            distance = (casterPt - cursorPt):Length(),
            height = 150,
            duration = 0.7,
            direction_x = direction.x,
            direction_y = direction.y,
            IsStun = true,
        } -- kv
    )

    pad:AddNewModifier(self:GetCaster(), self, "cookie_pad_modifier", {})
end

-------------------------
-- COOKIE PAD MODIFIER --
-------------------------

cookie_pad_modifier = class({})

function cookie_pad_modifier:IsHidden()
	return false
end

function cookie_pad_modifier:OnCreated()
	self:StartIntervalThink(FrameTime())
end

function cookie_pad_modifier:OnIntervalThink()
    --special values
    local spell = self:GetAbility()
    local search_radius = spell:GetSpecialValueFor("search_radius")
    local aura_jump_distance = spell:GetSpecialValueFor("aura_jump_distance")
    local aura_jump_height = spell:GetSpecialValueFor("aura_jump_height")
    local aura_jump_duration = spell:GetSpecialValueFor("aura_jump_duration")


    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),	-- int, your team number
        self:GetParent():GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        search_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ALL,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _,unit in pairs(units) do
        --flag so that the same unit is not casted on every interval
        if unit.jumping then
            --skip
        elseif not unit.jumping or unit.jumping == nil then
            unit.jumping = true
            --cookie effect

            --play effects
            --cookie eating effects
            --cookie_pad:PlayEffects1()
            local effect_cast = cookie_pad:PlayEffects2( hTarget )

            --jumping motion
            local knockback = unit:AddNewModifier(
                self:GetCaster(), -- player source
                self:GetAbility(), -- ability source
                "modifier_knockback_custom", -- modifier name
                {
                    distance = aura_jump_distance,
                    height = aura_jump_height,
                    duration = aura_jump_duration,
                    direction_x = unit:GetForwardVector().x,
                    direction_y = unit:GetForwardVector().y,
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
            local knockback_ended = knockback:SetEndCallback( callback )
            print("knockback_ended is : " .. knockback_ended)
            --leverage callback to set "jumping" flag to false
        end
    end
end

-------------
-- EFFECTS --
-------------

--------------------------------------------------------------------------------
function cookie_pad:PlayEffects1(target)
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

function cookie_pad:PlayEffects2( target )
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

function cookie_pad:PlayEffects3( target, radius )
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

