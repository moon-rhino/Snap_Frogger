modifier_ai_oreo = class({})

local AI_THINK_INTERVAL = 3

function modifier_ai_oreo:OnCreated(params)
    if IsServer() then
        self:StartIntervalThink(AI_THINK_INTERVAL)
        self.unit = self:GetParent()
        self.aggroRange = params.aggroRange
    end
    --start cooldowns on abilities
    --self.unit:FindAbilityByName("dunk"):StartCooldown(1000)
    --self.unit:FindAbilityByName("torrent_custom"):StartCooldown(1000)
end

function modifier_ai_oreo:OnIntervalThink()
    --find targets around itself
    --on first target,
        --jump to it
        --on landing,
            --cast torrent
    if self.unit:IsStunned() then
        --nothing
    --elseif self.unit:IsAlive() == false then
        --nothing
    else
        --find targets around itself
        --[[local enemies = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false)
        local numEnemies = 0
        for _, enemy in pairs(enemies) do
            numEnemies= numEnemies + 1
        end
        if numEnemies == 0 then
            --nothing
            --caster or no one
        else
            self.aggroTarget = enemies[1] -- Remember who to attack
            self.unit:SetCursorCastTarget(self.aggroTarget)]]
            local dunk = self.unit:FindAbilityByName("dunk")
            dunk:OnSpellStart()
        --end

    end
end

--[[function modifier_ai_oreo:OnDeath(params)
    self.unit:RemoveSelf()
end]]