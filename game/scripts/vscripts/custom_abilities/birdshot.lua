birdshot = class({})
LinkLuaModifier("scatterblast_base_modifier", "custom_abilities/scatterblast_base_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("scatterblast_base_modifier_spark_effect", "custom_abilities/scatterblast_base_modifier_spark_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("scatterblast_base_modifier_impact_effect", "custom_abilities/scatterblast_base_modifier_impact_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("load_modifier", "custom_abilities/load_modifier", LUA_MODIFIER_MOTION_NONE)

--1 projectile with narrow start radius and wide end radius

function birdshot:OnAbilityPhaseStart()
    if IsServer() then
        EmitSoundOn("shotgun_load", self:GetCaster())
        self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1)
        --return true for successful cast
        return true
    end
end

function birdshot:GetCastPoint()
    if IsServer() then
        if self:GetCaster():HasModifier("scatterblast_base_modifier") then
		    return 0.6
        else
            return 0.2
        end
    end
end


function birdshot:OnSpellStart()
    if IsServer() then
        --sound
        self:GetCaster():EmitSound("shotgun_fire")
        self.damage = self:GetSpecialValueFor( "damage" ) 
        --load = 2x damage, knockback on target within point blank, longer cooldown
        if self:GetCaster():HasModifier("load_modifier") then
            local multiplier = self:GetCaster():FindAbilityByName("load"):GetSpecialValueFor("multiplier")
            self.damage = self.damage * multiplier
            self.knockback_distance = self:GetCaster():FindAbilityByName("load"):GetSpecialValueFor("knockback_distance")
            self.knockback_duration = self:GetCaster():FindAbilityByName("load"):GetSpecialValueFor("knockback_duration")
            self.cooldownAddition = self:GetCaster():FindAbilityByName("load"):GetSpecialValueFor("cooldown_addition")
            --get cooldown's parameter is the level
            self:StartCooldown(self:GetCooldown(1) + self.cooldownAddition)
            self:GetCaster():RemoveModifierByName("load_modifier")
        end
        self.point_blank_range = self:GetSpecialValueFor( "point_blank_range" ) 
        self.point_blank_dmg_bonus_pct = self:GetSpecialValueFor( "point_blank_dmg_bonus_pct" ) 
        self.blast_width_initial = self:GetSpecialValueFor( "blast_width_initial" ) 
        self.blast_width_end = self:GetSpecialValueFor( "blast_width_end" ) 
        self.bullet_distance = self:GetSpecialValueFor( "distance" ) 
        self.bullet_speed = self:GetSpecialValueFor( "blast_speed" )
        self.cast_loc = self:GetCaster():GetAbsOrigin()

        local caster = self:GetCaster()
        --A Liner Projectile must have a table with projectile info
        local cursorPt = self:GetCursorPosition()
        local casterPt = caster:GetAbsOrigin()
        local direction = cursorPt - casterPt
        direction = direction:Normalized()
        
        local info = 
        { 
            Ability = self,
            EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf", --particle effect
            --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
            vSpawnOrigin = caster:GetAbsOrigin(),
            fDistance = self.bullet_distance,
            fStartRadius = self.blast_width_initial,
            fEndRadius = self.blast_width_end,
            Source = caster,
            --bHasFrontalCone = true,
            --bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 5.0,
            bDeleteOnHit = false,
            vVelocity = direction * self.bullet_speed,
            bProvidesVision = false,
            --iVisionRadius = 500,
            --iVisionTeamNumber = caster:GetTeamNumber()
        }
        projectile = ProjectileManager:CreateLinearProjectile(info)
    end
    
end


function birdshot:OnProjectileHit(hTarget, vLocation)
    if IsServer() then
        if hTarget == nil then
            self.knockback_distance = nil
        else
            if (self.cast_loc - vLocation):Length() < self.point_blank_range then
                --apply multiplier
                if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
                    local damage = {
                        victim = hTarget,
                        attacker = self:GetCaster(),
                        damage = self.damage + (self.damage * 0.01 * self.point_blank_dmg_bonus_pct),
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = self
                    }
            
                    ApplyDamage( damage )

                    --load: apply knockback
                    if self.knockback_distance ~= nil then
                        local knockback_direction = hTarget:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
                        knockback_direction = knockback_direction:Normalized()
                        local knockback = hTarget:AddNewModifier(
                            self:GetCaster(), -- player source
                            self, -- ability source
                            "modifier_knockback_custom", -- modifier name
                            {
                                distance = self.knockback_distance,
                                height = 0,
                                duration = self.knockback_duration,
                                direction_x = knockback_direction.x,
                                direction_y = knockback_direction.y,
                                IsStun = true,
                            } -- kv
                        )
                        
                    end

                    --sparks
                    hTarget:AddNewModifier(self:GetCaster(), self, "scatterblast_base_modifier_spark_effect", { duration = 1.0 })
                end
            else
                --apply normal damage
                if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
                    local damage = {
                        victim = hTarget,
                        attacker = self:GetCaster(),
                        damage = self.damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = self
                    }
            
                    ApplyDamage( damage )
                end
            end



            --impact effect
            hTarget:AddNewModifier(self:GetCaster(), self, "scatterblast_base_modifier_impact_effect", { duration = 1.0 })

            --impact slow
            hTarget:AddNewModifier(self:GetCaster(), self, "scatterblast_base_modifier", { duration = 1.0 })
        end

        return false
    end
end