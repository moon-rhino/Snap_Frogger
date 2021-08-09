--spell start
--fire bullets in the direction it's facing
--can turn, can't move
--"stop" to stop firing


lil_shredder_machine_gun = class({})

LinkLuaModifier( "lil_shredder_machine_gun_modifier", "custom_abilities/lil_shredder_machine_gun_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lil_shredder_base_debuff_modifier", "custom_abilities/lil_shredder_base_debuff_modifier", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function lil_shredder_machine_gun:OnSpellStart()
	-- unit identifier
	self.caster = self:GetCaster()

	-- load data
	self.duration = self:GetDuration()
	self.slow = self:GetSpecialValueFor( "slow_duration" )

	-- add buff
	self.caster:AddNewModifier(
		self.caster, -- player source
		self, -- ability source
		"lil_shredder_machine_gun_modifier", -- modifier name
		{ duration = self.duration } -- kv
	)
end

function lil_shredder_machine_gun:OnProjectileHit( target, location )
	
	--hit an existing target
	if target then

		--initial bullet
		target:AddNewModifier(self:GetCaster(), self, "lil_shredder_base_debuff_modifier", { duration = self.slow })
		local damageTable = {
			victim = target,
			attacker = self:GetCaster(),
			--change when talent for normal attack damage acquired
			damage = self:GetCaster():FindAbilityByName("lil_shredder_machine_gun"):GetSpecialValueFor("damage"),
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
		}
		ApplyDamage(damageTable)

		self:PlayEffectHit(target)
		--fragments effect
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
							Ability 			= self,
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

	return true
end

function lil_shredder_machine_gun:PlayEffectHit( target )
	-- Get Resources
	local particle_cast = "particles/antimage_manavoid_explode_b_b_ti_5_gold_fragment.vpcf"
	local random_int = math.random(1, 5)
	local sound_target
	if random_int == 1 then
		sound_target = "gun_clank"
	elseif random_int == 2 then
		sound_target = "gun_clank_2"
	elseif random_int == 3 then
		sound_target = "gun_clank_3"
	elseif random_int == 4 then
		sound_target = "gun_clank_4"
	else
		sound_target = "gun_clank_5"
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	-- take one of a few
	--EmitSoundOn( sound_target, target )

	return effect_cast
end