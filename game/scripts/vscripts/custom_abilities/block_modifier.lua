

block_modifier = class({})

function block_modifier:IsHidden()
	return false
end

function block_modifier:OnCreated( kv )
    -- Play sound
    local cast_sound = "block"
    self:GetParent():EmitSound(cast_sound)
end
