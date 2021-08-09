modifier_axe = class({})

modifier_axe = class({})

local AI_THINK_INTERVAL = 0.5

function modifier_axe:OnCreated(params)
    -- Only do AI on server
    if IsServer() then
        self.unit = self:GetParent()

        -- Store parameters from AI creation:
        -- unit:AddNewModifier(caster, ability, "modifier_ai", { aggroRange = X, leashRange = Y })
        self.aggroRange = params.aggroRange
        self.leashRange = params.leashRange

        Timers:CreateTimer(string.format("call_timer_%s_%s", self.unit.col, Time()), {
            useGameTime = true,
            endTime = 0,
            callback = function()
                local enemies = FindUnitsInRadius(
                    self.unit:GetTeam(), 
                    self.unit:GetAbsOrigin(), 
                    nil,
                    self.aggroRange, 
                    DOTA_UNIT_TARGET_TEAM_ENEMY, 
                    DOTA_UNIT_TARGET_ALL, 
                    DOTA_UNIT_TARGET_FLAG_NONE, 
                    FIND_ANY_ORDER, 
                    false
                )
            
                -- If one or more units were found, start attacking the first one
                if #enemies > 0 then
                    self.unit:SetCursorCastTarget(self.unit)
                    self.unit:FindAbilityByName("grimstroke_spirit_walk_custom"):OnSpellStart()
                    return 7
                else
                    return 1
                end
            end
        })


    end
end
