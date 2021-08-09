modifier_dip = class({})

function modifier_dip:IsHidden()
	return false
end

function modifier_dip:OnCreated( kv )
    
	if IsServer() then
        
		-- references
		self.immolation_damage = kv.immolation_damage
		self.immolation_range = kv.immolation_range
		self.immolation_interval = kv.immolation_interval
		
		-- Start interval
		self:StartIntervalThink( kv.immolation_interval )
		self:OnIntervalThink()
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_dip:OnIntervalThink()
    if IsServer() then
		--burn enemies within range

		-- precache damage
		local damageTable = {
			-- victim = target,
			attacker = self:GetParent(),
			damage = self.immolation_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = nil, --Optional.
		}

		local enemies = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetAbsOrigin(),	-- point, center point
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
function modifier_dip:GetEffectName()
	return "particles/ogre_magi_arcana_ignite_burn_immolation.vpcf"
end

function modifier_dip:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

