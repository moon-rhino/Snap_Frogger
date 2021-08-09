modifier_bristleback_leaf = class({})

local COOLDOWN = 5

function modifier_bristleback_leaf:IsHidden()
	return false
end

function modifier_bristleback_leaf:OnCreated( kv )
	if IsServer() then
		-- references
		self.trigger_range = kv.trigger_range

        self.unit = self:GetParent()
		
		-- Start interval
		self:StartIntervalThink( 1 )
		self:OnIntervalThink()
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_bristleback_leaf:OnIntervalThink()
    if IsServer() then
		--burn enemies within range
        --bristleback - block path

        local enemies = FindUnitsInRadius(
            self.unit:GetTeam(), 
            self.unit:GetAbsOrigin(), 
            nil,
            self.trigger_range, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_ALL, 
            DOTA_UNIT_TARGET_FLAG_NONE, 
            FIND_ANY_ORDER, 
            false
        )
        local enemyCount = 0
        for _, enemy in pairs(enemies) do
          enemyCount = enemyCount + 1
        end
        if enemyCount > 0 then
            self.unit:SetCursorPosition(self.unit:GetAbsOrigin() + Vector(1, 0, 0))
            self.unit:FindAbilityByName("bristleback_quill_spray_custom"):OnSpellStart()
        end
	end
end

--take turns cookie-ing a creep
--perma stun or die