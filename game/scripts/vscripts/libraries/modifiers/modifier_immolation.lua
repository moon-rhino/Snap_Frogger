modifier_immolation = class({})

function modifier_immolation:IsHidden()
	return false
end

function modifier_immolation:OnCreated( kv )
	if IsServer() then
		-- references
		self.immolation_damage = kv.immolation_damage
		self.immolation_range = kv.immolation_range
		self.immolation_interval = kv.immolation_interval
		
		-- Start interval
		self:StartIntervalThink( 0.3 )
		self:OnIntervalThink()
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_immolation:OnIntervalThink()
    if IsServer() then
		--burn enemies within range

		-- precache damage
		local damageTable = {
			-- victim = target,
			attacker = self:GetCaster(),
			damage = self.immolation_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
		}

		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetCaster():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.immolation_range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
			damageTable.victim = enemy
			ApplyDamage(damageTable)
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_immolation:GetEffectName()
	return "particles/ogre_magi_arcana_ignite_burn_immolation.vpcf"
end

function modifier_immolation:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

