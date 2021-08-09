dunk = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Ability Start
function dunk:OnSpellStart()

    -- unit identifier
    self.caster = self:GetCaster()
    local caster = self.caster
    self.aggroRange = 600

    --find enemy
    local enemies = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetAbsOrigin(), nil,
    self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
    FIND_ANY_ORDER, false)
    local numEnemies = 0
    for index, enemy in pairs(enemies) do
        numEnemies= numEnemies + 1
    end
    if numEnemies == 0 then
        --nothing
        --caster or no one
    else
        self.aggroTarget = enemies[1] -- Remember who to attack
    end

    if self.aggroTarget == nil then
        --nothing

    else



        -- load data
        --self.target = self.caster:GetCursorCastTarget()
        self.target = self.aggroTarget
        self.jump_height = self:GetSpecialValueFor("jump_height")
        self.jump_duration = self:GetSpecialValueFor("jump_duration")
        self.direction = self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()
        self.direction = self.direction:Normalized()
        self.radius = self:GetSpecialValueFor("impact_radius")
        self.impact_damage = self:GetSpecialValueFor("impact_damage")
        self.stun = self:GetSpecialValueFor( "impact_stun_duration" )
        self.torrent_position = self.aggroTarget:GetAbsOrigin()

        --jump to target
        --get distance between caster and target
        --get direction from caster to target
        local knockback = self.caster:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = (self.caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D(),
                height = self.jump_height,
                duration = self.jump_duration,
                direction_x = self.direction.x,
                direction_y = self.direction.y,
                IsStun = true,
            } -- kv
        )

        --on landing,
        local callback = function()
            --damage, stun
            -- precache damage
            local damageTable = {
                -- victim = target,
                attacker = self.caster,
                damage = self.impact_damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self, --Optional.
            }

            -- find enemies
            local enemies = FindUnitsInRadius(
                self.caster:GetTeamNumber(),	-- int, your team number
                self.caster:GetOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
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
                    { duration = self.stun } -- kv
                )
            end

            --cast torrent
            self.caster:SetCursorPosition(self.torrent_position)
            local torrent = self.caster:FindAbilityByName("torrent_custom")
            torrent:OnSpellStart()

            -- destroy trees
            GridNav:DestroyTreesAroundPoint( self.caster:GetOrigin(), self.radius, true )

            -- play effects
            self:PlayEffects3( self.caster, self.radius )

        end

        if caster:IsAlive() then
            knockback:SetEndCallback( callback )
        end
    end

end

function dunk:PlayEffects3( target, radius )
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