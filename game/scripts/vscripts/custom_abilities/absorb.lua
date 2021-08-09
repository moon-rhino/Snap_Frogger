absorb = class({})

LinkLuaModifier("modifier_immolation", "libraries/modifiers/modifier_immolation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_absorb", "libraries/modifiers/modifier_absorb", LUA_MODIFIER_MOTION_NONE)

function absorb:OnSpellStart()
    --burn enemies around caster
        --find units in radius
        --damage each unit
    --if enemy dies
    --increase its size, its hp, and heal it

    self.caster = self:GetCaster()

    self.caster:AddNewModifier(self.caster, self, "modifier_absorb", {})

    --add immolation modifier based on the number of "absorb" stacks
    --load values
    --[[self.immolation_range = self:GetSpecialValueFor("range") + self.caster:FindModifierByName("modifier_absorb"):GetStackCount() * 70
    --does caster not have modifier_absorb sometimes?
    self.immolation_damage = self:GetSpecialValueFor("damage")
    self.immolation_interval = self:GetSpecialValueFor("interval")
    if self.caster:HasModifier("modifier_immolation") then
        self.caster:RemoveModifierByName("modifier_immolation")
    end
    self.caster:AddNewModifier(self.caster, self, "modifier_immolation", { immolation_range = self.immolation_range, 
    immolation_damage = self.immolation_damage,
    immolation_interval = self.immolation_interval })]]

    --set cooldown so the caster can't cast it
    self:StartCooldown(1000)

    --[[print("modifiers for this caster: ")
    for index = 0, 20 do
        print(self.caster:GetModifierNameByIndex(index))
    end]]

    
    
end