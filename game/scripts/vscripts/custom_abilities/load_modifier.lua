load_modifier = class({})

function load_modifier:IsHidden()
	return false
end

function load_modifier:OnCreated( kv )
    if IsServer() then
        -- Play sound
        local cast_sound = "gauge"
        self:GetParent():EmitSound(cast_sound)
        --on spell cast,
        --if caster has modifier then
            --remove it
    end

end