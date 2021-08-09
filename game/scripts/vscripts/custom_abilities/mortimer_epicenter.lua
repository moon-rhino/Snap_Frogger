--base cookie
--on cast
--if unit has baker's dozen then
--cast it on target

-- Cookie spell recreated by EarthSalamander42
-- see the reference at https://github.com/EarthSalamander42/dota_imba/blob/47d802f6718929726fb24dd4c5b140064f1dfd15/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/modifiers/generic/modifier_generic_knockback_lua.lua

--jump in the current position three times
--quickly
--radius gets bigger with each jump

--players can dodge by being far away
--------------------------------------------------------------------------------

local cast_length_time = 3
--------------------------------------------------------------------------------
mortimer_epicenter = class({})

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mortimer_kisses_thinker_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Custom KV
function mortimer_epicenter:GetCastPoint()
    if IsServer() then

        --play sound
        self:GetCaster():EmitSound("cookie_cookie_cookie_scream")
        return 0
    end
end

function mortimer_epicenter:OnAbilityPhaseStart()
    if IsServer() then
        self:PlayEffects1()

        return true -- if success
    end
end

--------------------------------------------------------------------------------
-- Ability Start
function mortimer_epicenter:OnSpellStart()
    if IsServer() then
        -- unit identifier
        local caster = self:GetCaster()
        self.caster = caster
        local target = self:GetCursorPosition()
        self.target = target



        
        -- load data
        local duration = self:GetSpecialValueFor( "jump_duration" )
        local height = self:GetSpecialValueFor( "jump_height" )
        --local distance = self:GetSpecialValueFor( "jump_horizontal_distance" )
        local distance = (self:GetCaster():GetAbsOrigin() - target):Length()
        --leave marks on landing, then players have limited space to roam 

        local stun = self:GetSpecialValueFor( "impact_stun_duration" )
        local damage = self:GetSpecialValueFor( "impact_damage" )
        local radius = self:GetSpecialValueFor( "impact_radius" )


        self.jump = 0
        --warning 2 seconds
        self:PlayEffects4( radius )
        Timers:CreateTimer(1, function()
            if self.jump == 3 then
                --stop aoe finder middle circle
                --self:StopEffects()
                --end timer
                return nil
            else
                -- Play sound
                --local sound_cast = "Hero_Snapfire.FeedCookie.Cast"
                --EmitSoundOn( sound_cast, self:GetCaster() )

                --receiving cookie effect
                local effect_cast = self:PlayEffects2( self:GetCaster() )
                
                if self.effect_cast then
                    --stop aoe finder middle circle
                    self:StopEffects()
                end
                


                --cast spell
                self.jump = self.jump + 1
                -- knockback
                -- describes the "jumping" motion
                --local direction = target - self:GetCaster():GetAbsOrigin()
                --direction = direction:Normalized()
                local knockback = self:GetCaster():AddNewModifier(
                    self:GetCaster(), -- player source
                    self, -- ability source
                    "modifier_knockback_custom", -- modifier name
                    {
                        distance = 0,
                        height = height,
                        duration = duration,
                        direction_x = self:GetCaster():GetForwardVector().x,
                        direction_y = self:GetCaster():GetForwardVector().y,
                        IsStun = true,
                    } -- kv
                )
                -- on landing
                local callback = function()
                    -- precache damage
                    local damageTable = {
                        -- victim = target,
                        attacker = self:GetCaster(),
                        damage = damage,
                        damage_type = self:GetAbilityDamageType(),
                        ability = self, --Optional.
                    }

                    -- find enemies
                    local enemies = FindUnitsInRadius(
                        self:GetCaster():GetTeamNumber(),	-- int, your team number
                        self:GetCaster():GetOrigin(),	-- point, center point
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
                                self:GetCaster(), -- player source
                                self, -- ability source
                                "modifier_stunned", -- modifier name
                                { duration = stun } -- kv
                            )
                    end

                    -- destroy trees
                    GridNav:DestroyTreesAroundPoint( target, radius, true )

                    -- play effects
                    ParticleManager:DestroyParticle( effect_cast, false )
                    ParticleManager:ReleaseParticleIndex( effect_cast )
                    self:PlayEffects3( self:GetCaster(), radius)
                    
                end
                
                --returns when knockback is finished

                --maybe target was dead when "knockback" was nil
                if not self:GetCaster():IsAlive() then
                    --nothing
                else
                    knockback:SetEndCallback( callback )
                end

                return 0.5
            end
        end)
    end

end


--------------------------------------------------------------------------------
function mortimer_epicenter:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function mortimer_epicenter:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_buff.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_receive.vpcf"
	--local sound_target = "Hero_Snapfire.FeedCookie.Consume"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, target )

	-- Create Sound
	--EmitSoundOn( sound_target, target )

	return effect_cast
end

function mortimer_epicenter:PlayEffects3( target, radius )
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
function mortimer_epicenter:PlayEffectsKisses( loc, owner )
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
--aoe finder
function mortimer_epicenter:PlayEffects4( radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

    -- Create Particle
    --repeat for all teams
    self.effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster(), 6 )
    
    --location of the finder
	ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( radius, 0, 0) )
    --first argument in the Vector decides how long the finder lasts
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( 2, 0, 0 ) )
end

function mortimer_epicenter:StopEffects()
	ParticleManager:DestroyParticle( self.effect_cast, true )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end



