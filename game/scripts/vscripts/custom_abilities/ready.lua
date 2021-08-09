ready = class({})

function ready:OnSpellStart()
    --do something
    if IsServer() then
        local caster = self:GetCaster()
        local casterPlayerId = caster:GetPlayerID()
        local casterName = PlayerResource:GetPlayerName(casterPlayerId)
        Notifications:BottomToAll({text=string.format("%s is ready", casterName), duration= 20, style={["font-size"] = "45px", color = GameMode.teamColors[casterPlayerId]}})
        GameMode.numberOfReadyPlayers = GameMode.numberOfReadyPlayers + 1
    end
end