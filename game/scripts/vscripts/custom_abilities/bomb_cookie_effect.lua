bomb_cookie_effect = class({})

function bomb_cookie_effect:OnProjectileHit(hTarget, vLocation)
    if IsServer() then

        --[[if hTarget == self:GetCaster() then
            --continue
        else
            self:GetCaster().score = self:GetCaster().score + 1
        end]]

        self:GetCaster().score = self:GetCaster().score + 1

        --print("bomb cookie, caster's score: " .. self:GetCaster().score)

        self.duration = self:GetSpecialValueFor( "jump_duration" )
        self.height = self:GetSpecialValueFor( "jump_height" )
        self.distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
        self.stun = self:GetSpecialValueFor( "impact_stun_duration" )
        self.damage = self:GetSpecialValueFor( "impact_damage" )
        --can't be seen
        self.radius = self:GetSpecialValueFor( "impact_radius" )
        self.bomb_radius = self:GetSpecialValueFor( "bomb_radius" )
        self.caster = self:GetCaster()

        --unit stuns and damages its enemies, not the caster's
        local effect_cast = self:PlayEffects2( hTarget )
        --randomization
        --special values
        --because random float doesn't work with negative values
        local randomSign = math.random(1, 2)
        if randomSign == 1 then
            randomSign = -1
        else
            randomSign = 1
        end

        --knockback
        local knockback = hTarget:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = self.distance + randomSign * math.random(0, 200),
                height = self.height + randomSign * math.random(0, 50),
                duration = self.duration + randomSign * RandomFloat(0, 0.2),
                direction_x = hTarget:GetForwardVector().x,
                direction_y = hTarget:GetForwardVector().y,
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
            GridNav:DestroyTreesAroundPoint( hTarget:GetOrigin(), self.radius, true )

            -- play effects
            ParticleManager:DestroyParticle( effect_cast, false )
            ParticleManager:ReleaseParticleIndex( effect_cast )
            self:PlayEffects3( hTarget, self.radius )

        end
        --returns when knockback is finished
        if self:GetCaster():IsAlive() then
            knockback:SetEndCallback( callback )
        elseif hTarget:IsAlive() then
            knockback:SetEndCallback( callback )
        end
    end
end

--------------------------------------------------------------------------------
function bomb_cookie_effect:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function bomb_cookie_effect:PlayEffects2( target )
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

function bomb_cookie_effect:PlayEffects3( target, radius )
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
