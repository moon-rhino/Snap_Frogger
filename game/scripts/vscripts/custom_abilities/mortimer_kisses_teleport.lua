--cast ult by targeting
--replace with activate remnant ability
--on create blob, spawn a remnant at the target location
--on activate remnant, stop the ult, pass through all the remnants and land at the last one
--replace with ult


mortimer_kisses_teleport = class({})

function mortimer_kisses_teleport:OnSpellStart()
    if IsServer() then


        --variables
        self.caster = self:GetCaster()

        if self.caster.kisses_cast == false then
            --can't cast it
        else

            --flag to kill remnants if not cast and modifier is destroyed
            self.caster.teleportCast = true
            --on casting teleport, teleport to that location and end the ult

            --if caster stops without using q?
            
            --get the ult modifier
            local ult_modifier = self:GetCaster():FindModifierByName("mortimer_kisses_modifier")

            --stop ult by destroying it
            if ult_modifier ~= nil then
                ult_modifier:Destroy()


                local remnants = ult_modifier.remnants

                --remnant ID, assigned in mortimer_kisses_base
                local remnantID = 0

                --use a timer
                Timers:CreateTimer("knockback_to_remnants", {
                    useGameTime = true,
                    endTime = 0,
                    callback = function()

                        if self:GetCaster():IsAlive() then
                            remnantID = remnantID + 1
                            local remnant 
                            if remnants[remnantID] == nil then
                                --reached final remnant
                                --replace ability with ult
                                --self.caster:SwapAbilities("mortimer_kisses_teleport", "mortimer_kisses_base", false, true)
                                return nil
                            else
                                remnant = remnants[remnantID]
                            end

                            --knockback direction not the caster's forward direction
                            local teleportDirection = (remnant:GetAbsOrigin() - self:GetCaster():GetAbsOrigin())
                            local teleportDistance = (remnant:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length()

                            --jump time per remnant
                            --0.5 sec per 1000 units of distance
                            --add some time for minimum distance
                            local teleportDuration = (0.2 * teleportDistance / 1000) + 0.4

                            --travel by order
                            local knockback = self.caster:AddNewModifier(
                                self.caster, -- player source
                                self, -- ability source
                                "modifier_knockback_custom", -- modifier name
                                {
                                    distance = teleportDistance,
                                    height = 300,
                                    duration = teleportDuration,
                                    direction_x = teleportDirection.x,
                                    direction_y = teleportDirection.y,
                                    IsStun = true,
                                } -- kv
                            )

                            local callback = function()

                                --base cookie ability
                                local cookie_ability = self.caster:FindAbilityByName("cookie_base")

                                -- precache damage
                                local damageTable = {
                                    -- victim = target,
                                    attacker = self.caster,
                                    damage = cookie_ability:GetSpecialValueFor("impact_damage"),
                                    damage_type = cookie_ability:GetAbilityDamageType(),
                                    ability = cookie_ability, --Optional.
                                }
                    
                                -- find enemies
                                local enemies = FindUnitsInRadius(
                                    self.caster:GetTeamNumber(),	-- int, your team number
                                    self.caster:GetAbsOrigin(),	-- point, center point
                                    nil,	-- handle, cacheUnit. (not known)
                                    cookie_ability:GetSpecialValueFor("impact_radius"),	-- float, radius. or use FIND_UNITS_EVERYWHERE
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
                                        { duration = cookie_ability:GetSpecialValueFor("impact_stun_duration") - 0.7 } -- kv
                                    )
                                end
                    
                                -- destroy trees
                                local radius = cookie_ability:GetSpecialValueFor("impact_radius")
                                GridNav:DestroyTreesAroundPoint( self.caster:GetAbsOrigin(), radius, true )

                                local effect_cast = cookie_ability:PlayEffects2( target )

                                -- play effects
                                ParticleManager:DestroyParticle( effect_cast, false )
                                ParticleManager:ReleaseParticleIndex( effect_cast )
                                cookie_ability:PlayEffects3( self.caster, radius )

                                --kill the remnant
                                remnant:ForceKill(false)

                                --if caster is dead, kill remaining remnants
                                if self:GetCaster():IsAlive() == false then
                                    while remnants[remnantID + 1] ~= nil do
                                        remnantID = remnantID + 1
                                        remnants[remnantID]:ForceKill(false)
                                    end
                                end
                            end
                    
                            knockback:SetEndCallback( callback )
                            
                            --jump duration
                            return teleportDuration
                        end
                    end
                })
            else
                --nothing
            end
        end
    end
end

