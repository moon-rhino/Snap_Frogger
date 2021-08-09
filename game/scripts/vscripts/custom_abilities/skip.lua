skip = class({})

function skip:OnSpellStart()
    --do something
    if IsServer() then
        self.caster = self:GetCaster()
        self.caster.skip = true
    end
end