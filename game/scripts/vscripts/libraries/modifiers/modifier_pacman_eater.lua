modifier_pacman_eater = class({})

local AI_THINK_INTERVAL = 0.1
local EAT_RANGE = 150
local EAT_SLOW = 0.6
local EAT_SLOW_DURATION = 0.1

function modifier_pacman_eater:OnCreated()

    --eat radius
    --how often to run interval
    if IsServer() then
        self.unit = self:GetParent()
        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function modifier_pacman_eater:OnIntervalThink()
    if IsServer() then
		--eat cookies within range

		local enemies = FindUnitsInRadius(
			self.unit:GetTeamNumber(),	-- int, your team number
			self.unit:GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			EAT_RANGE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
            if enemy:GetUnitName() == "pacman_dot" then
                --won't die if it's invulnerable
                --custom function on modifier didn't work
                enemy:ForceKill(false)
                enemy:RemoveSelf()
                GameMode.settings["pacman"].dotCount = GameMode.settings["pacman"].dotCount - 1
                self.unit:AddNewModifier(nil, nil, "modifier_slow", { duration = 0.1, slowRate = -40 })
                EmitSoundOn("cookie_eating_1", self.unit)
                if GameMode.settings["pacman"].dotCount == 0 then
                    Notifications:BottomToAll({text="FINISHED!", duration=9, style={color="green"}})
                end
            end
		end
	end
end