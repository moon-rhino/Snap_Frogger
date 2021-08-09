buckshot = class({})
LinkLuaModifier("scatterblast_base_modifier", "custom_abilities/scatterblast_base_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("scatterblast_base_modifier_spark_effect", "custom_abilities/scatterblast_base_modifier_spark_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("scatterblast_base_modifier_impact_effect", "custom_abilities/scatterblast_base_modifier_impact_effect", LUA_MODIFIER_MOTION_NONE)


--1 projectile with narrow start radius and wide end radius

function buckshot:OnSpellStart()
    --sound
    self:GetCaster():EmitSound("buckshot")
    self.damage = self:GetSpecialValueFor( "damage" ) 
    --gauge = 2x damage
    if self:GetCaster():HasModifier("gauge_modifier") then
        local multiplier = self:GetCaster():FindAbilityByName("gauge"):GetSpecialValueFor("multiplier")
        self.damage = self.damage * multiplier
    end
    self.point_blank_range = self:GetSpecialValueFor( "point_blank_range" ) 
    self.point_blank_dmg_bonus_pct = self:GetSpecialValueFor( "point_blank_dmg_bonus_pct" ) 
    self.blast_width_initial = self:GetSpecialValueFor( "blast_width_initial" ) 
    self.blast_width_end = self:GetSpecialValueFor( "blast_width_end" ) 
    self.bullet_distance = self:GetSpecialValueFor( "distance" ) 
    self.bullet_speed = self:GetSpecialValueFor( "blast_speed" )
    self.cast_loc = self:GetCaster():GetAbsOrigin()

    print("[buckshot:OnSpellStart] called")
    local caster = self:GetCaster()
    --A Liner Projectile must have a table with projectile info
    local cursorPt = self:GetCursorPosition()
    local casterPt = caster:GetAbsOrigin()
    local direction = cursorPt - casterPt
    direction = direction:Normalized()
    local info = 
    { 
        Ability = self,
        EffectName = "particles/hero_snapfire_shotgun_buckshot.vpcf", --particle effect
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

    --gauge: knockback
    if self:GetCaster():HasModifier("gauge_modifier") then
        local knockback_distance = self:GetCaster():FindAbilityByName("gauge"):GetSpecialValueFor("knockback_distance")
        local knockback_duration = self:GetCaster():FindAbilityByName("gauge"):GetSpecialValueFor("knockback_duration")
        local knockback = self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = knockback_distance,
                height = 0,
                duration = knockback_duration,
                direction_x = -self:GetCaster():GetForwardVector().x,
                direction_y = -self:GetCaster():GetForwardVector().y,
                IsStun = true,
            } -- kv
        )
    end
end


function buckshot:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then
        print("[buckshot:OnProjectileHit] scatterblast expired")
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