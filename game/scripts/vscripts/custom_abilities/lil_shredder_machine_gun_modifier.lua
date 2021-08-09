lil_shredder_machine_gun_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function lil_shredder_machine_gun_modifier:IsHidden()
	return false
end

function lil_shredder_machine_gun_modifier:IsDebuff()
	return false
end

function lil_shredder_machine_gun_modifier:IsStunDebuff()
	return false
end

function lil_shredder_machine_gun_modifier:IsPurgable()
	return true
end


--------------------------------------------------------------------------------
-- Initializations
function lil_shredder_machine_gun_modifier:OnCreated( kv )
	if IsServer() then

		-- load attributes
		--self.attacks = self:GetAbility():GetSpecialValueFor( "buffed_attacks" )
		self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
		--self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
		self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
		self.attack_rate = self:GetAbility():GetSpecialValueFor( "attack_rate" )
		--self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )
		self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_stack")
		self.armor_reduction_per_stack = self:GetAbility():GetSpecialValueFor("armor_reduction_per_stack")
		self.bullet_speed = self:GetAbility():GetSpecialValueFor("bullet_speed")
		self.bullet_distance = self:GetAbility():GetSpecialValueFor("bullet_distance")
		self.caster = self:GetCaster()
		
		--disable normal attack
		self.caster:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)

		--[[if self.caster:HasTalent("special_bonus_unique_snapfire_6") then
			self.damage = self:GetCaster():GetAverageTrueAttackDamage(nil) 
		end]]

		if not IsServer() then return end
		
		--self:SetStackCount( self.attacks )

		--self.records = {}

		-- play Effects & Sound
		self:PlayEffects()
		--only on level up
		local sound_cast = "heavy_machine_gun"
		EmitSoundOn( sound_cast, self.caster )
		
		-- Start interval
		self:StartIntervalThink( self.attack_rate )
		self:OnIntervalThink()

		--if caster has "steam" upgrade, cast it
		if self.caster:HasAbility("lil_shredder_steam") then
			self.caster:FindAbilityByName("lil_shredder_steam"):OnSpellStart()
		end
	end

end

--------------------------------------------------------------------------------
-- Status Effects
function lil_shredder_machine_gun_modifier:CheckState()
	local state = {
		--[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function lil_shredder_machine_gun_modifier:OnIntervalThink()
	self:CreateBullet(kv)
end

function lil_shredder_machine_gun_modifier:CreateBullet(kv)
	--attack animation
	--stop previous animation
	self.caster:FadeGesture(ACT_DOTA_ATTACK)
	--play animation
	self.caster:StartGesture(ACT_DOTA_ATTACK)

	--create linear projectiles until the modifier expires
    --bullet speed: special value
    --fire rate: special value, interval thinker, return time
	--while self.caster:HasModifier("lil_shredder_machine_gun_modifier") do
	--with cookies instead
	local direction = self.caster:GetForwardVector()
	local info = 
	{ 
		Ability = self:GetAbility(),
		--EffectName = "models/morty_cookie_bullet.vmdl", --particle effect
		--EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
		EffectName = "particles/hero_snapfire_cookie_projectile_linear_machine_gun.vpcf", --particle effect
		vSpawnOrigin = self.caster:GetAbsOrigin(),
		fDistance = self.bullet_distance,
		fStartRadius = 150,
		fEndRadius = 150,
		Source = self.caster,
		--bHasFrontalCone = false,
		--bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 5,
		bDeleteOnHit = true,
		vVelocity = direction * self.bullet_speed,
		bProvidesVision = true,
		iVisionRadius = 500,
		iVisionTeamNumber = self.caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
	--if hero has 3x shredder talent, make bullets come out from his sides
	--if self.caster:HasTalent("special_bonus_unique_snapfire_8") then
		--if self.caster:FindAbilityByName("special_bonus_unique_snapfire_8"):GetLevel() > 0 then

			local forwardVector = self.caster:GetForwardVector()

			--get the angle that the character is facing
			local quadrant
			if self.caster:GetForwardVector().x > 0 and self.caster:GetForwardVector().y > 0 then
				--quadrant 1
				quadrant = 1
			elseif self.caster:GetForwardVector().x < 0 and self.caster:GetForwardVector().y > 0 then
				--quadrant 2
				quadrant = 2
			elseif self.caster:GetForwardVector().x < 0 and self.caster:GetForwardVector().y < 0 then
				--quadrant 3
				quadrant = 3
			else
				--quadrant 4
				quadrant = 4
			end
			local angleFacing = math.atan(self.caster:GetForwardVector().y / self.caster:GetForwardVector().x)
			--reversed for quadrants 2 and 
			--be aware of the range -pi/2 to pi/2
			if quadrant == 2 or quadrant == 3 then
				--cycles every pi
				--graph starts from bottom after one cycle
				angleFacing = angleFacing + math.pi
			end

			--convert forward vector into radians
			--add angle to it
			--take new direction
			local angleTurn = math.rad(-30)
			local angleShoot = angleFacing + angleTurn

			local direction = Vector(math.cos(angleShoot), math.sin(angleShoot), 0)
			--[[print("side direction: ")
			print(direction)
			direction = direction:Normalized()]]
			local info = 
			{ 
				Ability = self:GetAbility(),
				--EffectName = "models/morty_cookie_bullet.vmdl", --particle effect
				--EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
				EffectName = "particles/hero_snapfire_cookie_projectile_linear_machine_gun.vpcf", --particle effect
				vSpawnOrigin = self.caster:GetAbsOrigin(),
				fDistance = self.bullet_distance,
				fStartRadius = 150,
				fEndRadius = 150,
				Source = self.caster,
				--bHasFrontalCone = false,
				--bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				fExpireTime = GameRules:GetGameTime() + 5,
				bDeleteOnHit = true,
				vVelocity = direction * self.bullet_speed,
				bProvidesVision = true,
				iVisionRadius = 500,
				iVisionTeamNumber = self.caster:GetTeamNumber()
			}
			projectile = ProjectileManager:CreateLinearProjectile(info)

			--side two (left side)
			local angleTurn = math.rad(30)
			local angleShoot = angleFacing + angleTurn

			local direction = Vector(math.cos(angleShoot), math.sin(angleShoot), 0)
			local info = 
			{ 
				Ability = self:GetAbility(),
				--EffectName = "models/morty_cookie_bullet.vmdl", --particle effect
				--EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf",
				EffectName = "particles/hero_snapfire_cookie_projectile_linear_machine_gun.vpcf", --particle effect
				vSpawnOrigin = self.caster:GetAbsOrigin(),
				fDistance = self.bullet_distance,
				fStartRadius = 150,
				fEndRadius = 150,
				Source = self.caster,
				--bHasFrontalCone = false,
				--bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				fExpireTime = GameRules:GetGameTime() + 5,
				bDeleteOnHit = true,
				vVelocity = direction * self.bullet_speed,
				bProvidesVision = true,
				iVisionRadius = 500,
				iVisionTeamNumber = self.caster:GetTeamNumber()
			}
			projectile = ProjectileManager:CreateLinearProjectile(info)
		--end
	--end
	--end

	-- launch projectile
	--ProjectileManager:CreateLinearProjectile( self.info )

	-- play sound
	EmitSoundOn( "shredder_fire", self.caster )
end

function lil_shredder_machine_gun_modifier:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	-- right click, switch position
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		--set target (turn to the clicked position)
		--self:SetValidTarget( params.new_pos )
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		--self:SetValidTarget( params.target:GetOrigin() )

	-- stop or hold
	elseif 
		params.order_type==DOTA_UNIT_ORDER_STOP or
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
	then
		self:Destroy()
	end
end


function lil_shredder_machine_gun_modifier:OnRemoved()
end

function lil_shredder_machine_gun_modifier:OnDestroy()
	if not IsServer() then return 
	else

		-- stop sound
		local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
		StopSoundOn( sound_cast, self:GetParent() )

		--stop animation
		self.caster:FadeGesture(ACT_DOTA_ATTACK)

		--return normal attack
		self.caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

		-- steam modifier
		if self:GetParent():HasModifier("modifier_immolation") then
			self:GetParent():RemoveModifierByName("modifier_immolation")
		end
		if self:GetParent():HasModifier("modifier_outgoing_damage") then
			self:GetParent():RemoveModifierByName("modifier_outgoing_damage")
		end
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function lil_shredder_machine_gun_modifier:DeclareFunctions()
	local funcs = {
		--have to declare it here to edit it
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,	
	}

	return funcs
end

function lil_shredder_machine_gun_modifier:GetModifierMoveSpeedBonus_Percentage()
	return -80
end

--[[function lil_shredder_machine_gun_modifier:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	--if self:GetStackCount()<=0 then return end

	-- record attack
	--self.records[params.record] = true

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Attack"
	EmitSoundOn( sound_cast, self:GetParent() )

	-- decrement stack
	if self:GetStackCount()>0 then
		self:DecrementStackCount()
	end
end]]

--[[function lil_shredder_base_modifier:OnAttackLanded( params )
	if self.records[params.record] then
		-- add modifier
		params.target:AddNewModifier(
			self:GetParent(), -- player source
			self:GetAbility(), -- ability source
			"lil_shredder_base_debuff_modifier", -- modifier name
			{ duration = self.slow } -- kv
		)
	end

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Target"
	EmitSoundOn( sound_cast, params.target )
end

function lil_shredder_base_modifier:OnAttackRecordDestroy( params )
	if self.records[params.record] then
		self.records[params.record] = nil

		-- if table is empty and no stack left, destroy
		if next(self.records)==nil and self:GetStackCount()<=0 then
			self:Destroy()
		end
	end
end

function lil_shredder_base_modifier:GetModifierProjectileName()
	if self:GetStackCount()<=0 then return end
	return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf"
end

function lil_shredder_base_modifier:GetModifierOverrideAttackDamage(keys)
	if self:GetStackCount() <= 0 then return end
	if not IsServer() then return end
	
	local target = keys.target
		
	-- Calculate bonus damage from Fury Shredder
	local bonus_damage = 0

	-- "Does not work against buildings, wards and allied units when attacking them."			
	if target:IsBuilding() or target:IsOther() or target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return nil
	end

	local fury_shredder_handle = target:FindModifierByName("lil_shredder_base_debuff_modifier")
	if fury_shredder_handle then
		-- Get stack count
		local fury_shredder_stacks = fury_shredder_handle:GetStackCount()				

		-- Calculate damage
		bonus_damage = self.damage_per_stack * fury_shredder_stacks				
	end
	
	return self.damage + bonus_damage
end

function lil_shredder_base_modifier:GetModifierAttackRangeBonus()
	if self:GetStackCount()<=0 then return end
	return self.range_bonus
end

function lil_shredder_base_modifier:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount()<=0 then return end
	return self.as_bonus
end

function lil_shredder_base_modifier:GetModifierBaseAttackTimeConstant()
	if self:GetStackCount()<=0 then return end
	return self.bat
end]]

--------------------------------------------------------------------------------
-- Graphics & Animations
function lil_shredder_machine_gun_modifier:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		4,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		5,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end