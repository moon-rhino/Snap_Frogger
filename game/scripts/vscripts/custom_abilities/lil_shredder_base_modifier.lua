--imported from EarthSalamander42's IMBA github
--https://github.com/EarthSalamander42/dota_imba/blob/master/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/abilities/heroes/hero_snapfire.lua

--------------------------------------------------------------------------------
lil_shredder_base_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function lil_shredder_base_modifier:IsHidden()
	return false
end

function lil_shredder_base_modifier:IsDebuff()
	return false
end

function lil_shredder_base_modifier:IsStunDebuff()
	return false
end

function lil_shredder_base_modifier:IsPurgable()
	return true
end


--------------------------------------------------------------------------------
-- Initializations
function lil_shredder_base_modifier:OnCreated( kv )
	-- references
	self.attacks = self:GetAbility():GetSpecialValueFor( "buffed_attacks" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_stack")
	self.caster = self:GetCaster()

	--HasTalent: a function in player.lua in libraries
	--[[if self:GetCaster():HasTalent("special_bonus_unique_snapfire_6") then
		self.damage = self:GetCaster():GetAverageTrueAttackDamage(nil) 
	end]]

	if not IsServer() then return end

	--self.toggle_state = self:GetAbility():GetAutoCastState()

	--[[if self.toggle_state then
		self:SetStackCount( 1 )
		self.damage = self.damage * self:GetAbility():GetSpecialValueFor( "buffed_attacks" )
	else
		self:SetStackCount( self.attacks )
    end]]
    
    self:SetStackCount( self.attacks )

	self.records = {}

	-- play Effects & Sound
	self:PlayEffects()
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	EmitSoundOn( sound_cast, self:GetParent() )

	--if caster has "lil_shredder_steam" upgrade, cast it
	if self.caster:HasAbility("lil_shredder_steam") then
		self.caster:FindAbilityByName("lil_shredder_steam"):OnSpellStart()
	end
end

function lil_shredder_base_modifier:OnRefresh( kv )
	-- references
	self.attacks = self:GetAbility():GetSpecialValueFor( "buffed_attacks" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )
	self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_stack")

	self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )

	if not IsServer() then return end
	self:SetStackCount( self.attacks )

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	EmitSoundOn( sound_cast, self:GetParent() )
end


function lil_shredder_base_modifier:OnRemoved()
end

function lil_shredder_base_modifier:OnDestroy()
	if not IsServer() then return end

	-- stop sound
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	StopSoundOn( sound_cast, self:GetParent() )

	-- lil_shredder_steam modifier
	if self:GetParent():HasModifier("modifier_immolation") then
		self:GetParent():RemoveModifierByName("modifier_immolation")
	end
	if self:GetParent():HasModifier("modifier_outgoing_damage") then
		self:GetParent():RemoveModifierByName("modifier_outgoing_damage")
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function lil_shredder_base_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,		
	}

	return funcs
end

function lil_shredder_base_modifier:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	if self:GetStackCount()<=0 then return end

	-- record attack
	self.records[params.record] = true

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShellsBuff.Attack"
	EmitSoundOn( sound_cast, self:GetParent() )

	-- decrement stack
	if self:GetStackCount()>0 then
		self:DecrementStackCount()
	end
end

function lil_shredder_base_modifier:OnAttackLanded( params )
	if self.records[params.record] then
		local target = params.target
		-- add modifier
		--skip if target is magic immune
		if target:IsMagicImmune() then
			--nothing
		else
			target:AddNewModifier(
				self:GetParent(), -- player source
				self:GetAbility(), -- ability source
				"lil_shredder_base_debuff_modifier", -- modifier name
				{ duration = self.slow } -- kv
			)
		end
		--fragments upgrade
		if self.caster:HasAbility("lil_shredder_fragments") then

			--find units around target
			local enemies = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(),	-- int, your team number
				target:GetAbsOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				self.caster:FindAbilityByName("lil_shredder_fragments"):GetSpecialValueFor("enemy_find_range"),	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				0,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)

			--loop through enemies
			for _,enemy in pairs(enemies) do
				if enemy == target then
					--skip
				else
				--fire a fragment to him
				--load fragment
				--proc chance
					local dice = math.random(1, 100)
					local proc_chance = self.caster:FindAbilityByName("lil_shredder_fragments"):GetSpecialValueFor("proc_chance")
					if dice <= proc_chance then
						local info = {
							Target 				= enemy,
							Ability 			= self:GetAbility(),
							--if faulty, projectile may shoot out of the map
							EffectName 			= "particles/hero_snapfire_cookie_projectile_tracking_fragment.vpcf",
							iMoveSpeed			= 1000,
							vSourceLoc 			= target:GetAbsOrigin(),
							Source				= target,
							bDrawsOnMinimap 	= false,
							bDodgeable 			= false,
							bIsAttack 			= false,
							bVisibleToEnemies 	= true,
							bReplaceExisting 	= false,
							flExpireTime 		= GameRules:GetGameTime() + 10,
							bProvidesVision 	= false,
						}
						ProjectileManager:CreateTrackingProjectile(info)
					else
					--skip
					end
				end
			end
		end
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
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function lil_shredder_base_modifier:PlayEffects()
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