eat_cookie = class({})

function eat_cookie:OnSpellStart()
    if IsServer() then
        
        --find cookie
        self.caster = self:GetCaster()
        self.radius = self:GetSpecialValueFor("search_radius")
        local cookies = FindUnitsInRadius(
            self.caster:GetTeamNumber(),	-- int, your team number
            self.caster:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )
        --if found
        for _, cookie in pairs(cookies) do
            --test cookie
            if GameMode.warmUp then
                --kill cookie
                cookie:ForceKill(false)
                cookie:RemoveSelf()
            --big cookie
            elseif cookie:GetUnitName() == "cookie_big" then
                --add to caster's score
                self.caster.cookiesEaten = self.caster.cookiesEaten + 1
                --show score on top
                GameMode:ShowScore(self.caster, self.caster.cookiesEaten, 9)
                --grow bigger
                self.caster:SetModelScale(self.caster:GetModelScale() + 0.01)
                --decrease cookie's size
                GameMode.games["cookie_eater"].bigCookie:SetModelScale(GameMode.games["cookie_eater"].bigCookie:GetModelScale() - 0.005)
            else
                --kill cookie
                cookie:ForceKill(false)
                cookie:RemoveSelf()
                --add to caster's score
                self.caster.cookiesEaten = self.caster.cookiesEaten + 1
                --show score on top
                GameMode:ShowScore(self.caster, self.caster.cookiesEaten, 9)
                --grow bigger
                self.caster:SetModelScale(self.caster:GetModelScale() + 0.01)
            end
            --sound effect
            self.caster:EmitSound("crunch")
            break
        end



        --eat the nearest one
        --decrease the size of the eaten one
        --if not warm up
            --increase the caster's score
    end
end