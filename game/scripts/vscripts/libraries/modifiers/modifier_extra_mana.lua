modifier_extra_mana = class({})
--------------------------------------------------------------------------------

function modifier_extra_mana:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_extra_mana:OnCreated( kv )
    --print("[modifier_extra_mana:OnCreated] kv: ")
    --PrintTable(kv)
    self.extraMana = kv.extraMana
    --doesn't work
    self.regen = kv.regen
    --this works
    self:GetParent():SetBaseManaRegen(1)
end


--------------------------------------------------------------------------------

function modifier_extra_mana:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_EXTRA_MANA_BONUS,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT ,
	}
	return funcs
end


--------------------------------------------------------------------------------

function modifier_extra_mana:GetModifierExtraManaBonus( params )
	return self.extraMana
end

--------------------------------------------------------------------------------

function modifier_extra_mana:GetModifierConstantManaRegen( params )
	return self.regen
end

--------------------------------------------------------------------------------

--if not done, effect will linger even after death
function modifier_extra_mana:OnDeath( params )
	if IsServer() then
        if params.unit == self:GetParent() then
		self:GetParent():RemoveModifierByName("modifier_extra_mana")
                
        end
	end
	return 0
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------