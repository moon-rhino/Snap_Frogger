--casts berserker's call

modifier_ai_big_cookie = class({})

local AI_THINK_INTERVAL = 0.06

function modifier_ai_big_cookie:OnCreated(params)
    if IsServer() then
        self.unit = self:GetParent()
        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function modifier_ai_big_cookie:OnIntervalThink()
    if GameMode.games["cookie_eater"].finishedInitial then
        self:Destroy()
        --explode
        --call Destroy()
    end
end

function modifier_ai_big_cookie:OnDestroy()
    --loop of 20 cookies
    --randomly knock them back around the unit
    for cookieIndex = 0, 39 do
        local bigCookieLocation = GameMode:GetHammerEntityLocation("cookie_party_2_center")
        local cookieMini = CreateUnitByName("cookie_test", bigCookieLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
        local randomSign = math.random(1, 2)
        if randomSign == 1 then
            randomSign = -1
        else
            randomSign = 1
        end
        local knockback = cookieMini:AddNewModifier(
            nil, -- player source
            nil, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = math.random(30, 500),
                height = math.random(50, 500),
                duration = math.random(0.8, 1),
                direction_x = RandomFloat(0, 1) * randomSign,
                direction_y = RandomFloat(0, 1) * randomSign,
                IsStun = true,
            } -- kv
        )
    end
    --cookie explodes
    local particle_cast = "particles/alchemist_smooth_criminal_unstable_concoction_explosion_custom.vpcf"
    --PATTACH_ABSORIGIN_FOLLOW to create effect at unit's location
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.unit )
    ParticleManager:ReleaseParticleIndex( effect_cast )
    self.unit:EmitSound("explosion")
    self.unit:ForceKill(false)
    self.unit:RemoveSelf()
    
        --cookieMini:AddNewModifier(nil, nil, "modifier_magic_immune", duration = {})
end

--[[function modifier_ai_ginger_bread_man:OnDeath()
    self.unit:RemoveSelf()
end]]

--heap
--if enemy dies under its effect
--it gets bigger
--"eat" spell
--heal

