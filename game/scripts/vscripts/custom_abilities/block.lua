block = class({})

LinkLuaModifier("modifier_invulnerable", "libraries/modifiers/modifier_invulnerable", LUA_MODIFIER_MOTION_NONE)

function block:OnSpellStart()
    self.duration = self:GetSpecialValueFor( "duration" ) 
    self:GetCaster():AddNewModifier(nil, nil, "modifier_invulnerable", {duration = self.duration})
    self:PlayEffects()
end

--------------------------------------------------------------------------------
function block:PlayEffects()
	-- Get Resources
    --local particle_cast = "particles/econ/taunts/snapfire/snapfire_taunt_bubble.vpcf"
    local particle_cast = "particles/snapfire_taunt_bubble_invulnerable.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

    -- Destroy Particle after the spell ends
    Timers:CreateTimer({
        endTime = self.duration, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
        callback = function()
            ParticleManager:DestroyParticle( effect_cast, true )
        end
    })
    ParticleManager:ReleaseParticleIndex( effect_cast )
end
