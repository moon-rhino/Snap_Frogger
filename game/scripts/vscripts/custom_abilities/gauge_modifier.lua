gauge_modifier = class({})

function gauge_modifier:IsHidden()
	return false
end

function gauge_modifier:OnCreated( kv )
    -- Play sound
    local cast_sound = "gauge"
    self:GetParent():EmitSound(cast_sound)
end
