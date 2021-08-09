--when blob lands,
--spawn a unit that casts a spell

mortimer_kisses_added_effect = class({})

--[[function mortimer_kisses_added_effect:OnSpellStart()
    local effectUnit = CreateUnitByName("dummy", location, true, self:GetCaster(), nil, self:GetCaster():GetTeam())
    --spell must be enclosed in brackets correctly in order to be used
    local epicenter = epicenterUnit:AddAbility("sandking_epicenter_custom")
    epicenter:SetLevel(1)
    epicenter:OnChannelFinish(false)
    
    Timers:CreateTimer({
        endTime = 0.1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
            epicenterUnit:ForceKill(false)
        end
    })
end]]

