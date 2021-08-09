steam_3 = class({})

LinkLuaModifier("modifier_immolation", "libraries/modifiers/modifier_immolation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_outgoing_damage", "libraries/modifiers/modifier_outgoing_damage", LUA_MODIFIER_MOTION_NONE)

function steam_3:OnSpellStart()
    
    self.caster = self:GetCaster()

    --load values
    self.immolation_range = self:GetSpecialValueFor("immolation_range")
    self.immolation_damage = self:GetSpecialValueFor("immolation_damage")
    self.outgoing_damage_percent = self:GetSpecialValueFor("outgoing_damage_percent")
    self.immolation_interval = self:GetSpecialValueFor("immolation_interval")

    --when lil shredder is cast, cast this spell too

    --apply two modifiers: immolation, and damage increase
    self.caster:AddNewModifier(self.caster, self, "modifier_immolation", { immolation_range = self.immolation_range, 
                                                                immolation_damage = self.immolation_damage,
                                                                immolation_interval = self.immolation_interval,
                                                                outgoing_damage_percent = self.outgoing_damage_percent })
    self.caster:AddNewModifier(self.caster, self, "modifier_outgoing_damage", { outgoing_damage_percent = self.outgoing_damage_percent })
end