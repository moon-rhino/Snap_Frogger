modifier_earthshaker_leaf = class({})

local COOLDOWN = 5

function modifier_earthshaker_leaf:IsHidden()
	return false
end

function modifier_earthshaker_leaf:OnCreated( kv )
	if IsServer() then
		-- references
		self.trigger_range = kv.trigger_range
        self.orientation = kv.orientation
        
        --internal
        self.unit = self:GetParent()
        --OnSpellStart ignores cooldown
		self.cooldown = 0

		-- Start interval
		self:StartIntervalThink( 1 )
		self:OnIntervalThink()
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_earthshaker_leaf:OnIntervalThink()
    if IsServer() then
		--burn enemies within range
        --earthshaker - block path

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
            if self.cooldown == 0 then
                if self.orientation == 1 then
                    self.unit:SetCursorPosition(self.unit:GetAbsOrigin() + Vector(0, -10, 0))
                elseif self.orientation == 2 then
                    self.unit:SetCursorPosition(self.unit:GetAbsOrigin() + Vector(-10, 0, 0))
                elseif self.orientation == 3 then
                    self.unit:SetCursorPosition(self.unit:GetAbsOrigin() + Vector(0, 10, 0))
                else
                    self.unit:SetCursorPosition(self.unit:GetAbsOrigin() + Vector(10, 0, 0))
                end
                self.unit:FindAbilityByName("earthshaker_fissure"):OnSpellStart()
                self.cooldown = 5
            end
        end
	end
    if self.cooldown ~= 0 then
        self.cooldown = self.cooldown - 1
    end
end

--take turns cookie-ing a creep
--perma stun or die