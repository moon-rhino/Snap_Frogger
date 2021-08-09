modifier_absorb = class({})

--LinkLuaModifier("modifier_extra_health", "libraries/modifiers/modifier_extra_health", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Initializations
function modifier_absorb:IsHidden()
    return false
end

function modifier_absorb:OnCreated( kv )
    if not IsServer() then return 
    else
    self:SetStackCount( 0 )
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.interval = self:GetAbility():GetSpecialValueFor("interval")
    self.range = self:GetAbility():GetSpecialValueFor("range")
    self:StartIntervalThink(self.interval)
    end
end

function modifier_absorb:OnIntervalThink()
    if IsServer() then

        --burn enemies within range

        -- precache damage
        local damageTable = {
            -- victim = target,
            attacker = self:GetCaster(),
            damage = self.damage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            ability = self:GetAbility(), --Optional.
        }

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end
    end
end

function modifier_absorb:OnRefresh( kv )
    if IsServer() then

        self.damage = self:GetAbility():GetSpecialValueFor("damage")
        self.interval = self:GetAbility():GetSpecialValueFor("interval")
        self.range = self:GetAbility():GetSpecialValueFor("range")
        self:StartIntervalThink(self.interval)

        self:SetStackCount( self:GetStackCount() + 1 )
        self.range = self.range + self:GetStackCount() * 50
        --apply extra health modifier based on stack count
        --must destroy modifier to reapply it
        --self:GetParent():RemoveModifierByName("modifier_extra_health")
        --add ability for buff to show up on the buff bar
        --must use "GetModifierEXTRAHealthBonus" for creeps
        --heals automatically for a portion of the increase
        --self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_extra_health", { extraHealth = self:GetStackCount() * 50 })
        --self:GetParent():Heal(50, nil)
        if self:GetParent():GetModelScale() > 2 then
            --don't increase
        else
            self:GetParent():SetModelScale(self:GetParent():GetModelScale() + 0.1)
        end

        --add score to owner
        --only add score during cookie party
        if GameMode.games["cookieParty"].active then
            self:GetParent():GetOwnerEntity().score = self:GetParent():GetOwnerEntity().score + 1
        end
    end

end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_absorb:GetEffectName()
	return "particles/ogre_magi_arcana_ignite_burn_immolation.vpcf"
end

function modifier_absorb:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
