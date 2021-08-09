shadowraze_custom = class({})

function shadowraze_custom:OnSpellStart()
    print("spell casted")
    
    --load values
    --will be 0 unless level is set
    self.caster = self:GetCaster()
    self.radius = self:GetSpecialValueFor("shadowraze_range")
    self.damage = self:GetSpecialValueFor("shadowraze_damage")
    self.location = self.caster:GetAbsOrigin()

    --cast on caster's location
    --find units in radius
    --apply damage to each unit found

    local particle_raze = "particles/nevermore_shadowraze_custom.vpcf"
	-- Add particle effects. CP0 is location, CP1 is radius
	local particle_raze_fx = ParticleManager:CreateParticle(particle_raze, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle_raze_fx, 0, self.location)
	ParticleManager:SetParticleControl(particle_raze_fx, 1, Vector(self.radius, 1, 1))
	ParticleManager:ReleaseParticleIndex(particle_raze_fx)

    -- precache damage
	local damageTable = {
		-- victim = target,
		attacker = self.caster,
		damage = self.damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
    }
    
    print("self.caster: " .. self.caster:GetUnitName())
    print("his team: " .. self.caster:GetTeamNumber())
    print("his location: ")
    print(self.location)
    print("the radius: " .. self.radius)
    print("the damage from special value: " .. self:GetSpecialValueFor("shadowraze_damage"))

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
    )
    
    PrintTable(enemies)

    for _,enemy in pairs(enemies) do
        print("applying damage")
		damageTable.victim = enemy
		ApplyDamage(damageTable)
    end
    

end

