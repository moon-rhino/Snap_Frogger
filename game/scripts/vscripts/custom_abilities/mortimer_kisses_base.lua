--created by EarthSalamander42
--reference: https://github.com/EarthSalamander42/dota_imba/blob/master/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/abilities/heroes/hero_snapfire.lua

mortimer_kisses_base = class({})

LinkLuaModifier( "mortimer_kisses_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "mortimer_kisses_thinker_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "magma_burn_slow_modifier", "custom_abilities/mortimer_kisses_base", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_set_max_move_speed", "libraries/modifiers/modifier_set_max_move_speed", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function mortimer_kisses_base:GetAOERadius()
	return self:GetSpecialValueFor( "impact_radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function mortimer_kisses_base:OnSpellStart()


	--self.blob_hit = 0
	
	self.caster = self:GetCaster()
	self.caster.kisses_cast = true

	--set flag; if caster gains upgrade mid casting, it will be set to true, and the abilities will not swap
	--GameMode.teams[self.caster:GetTeam()].teleportJustGained = false

	--if caster has make it rain, start sound
	if self.caster:HasAbility("mortimer_kisses_make_it_rain") then
		--EmitGlobalSound("firework")
	end
	
	--for added effect
	if self.caster:HasAbility("mortimer_kisses_added_effect") then
		--1 = blue, torrent
		--2 = green, sprout
		--3 = red, blood rite
		--4 = purple, chronosphere
		--5 = black, trail
		self.addedEffect = math.random(1, 5)
		--testing
		--self.addedEffect = 5
	end
	
	local point = self:GetCursorPosition()

	-- load data
	local duration = self:GetDuration()

	-- add modifier
	self.caster:AddNewModifier(
		self.caster, -- player source
		self, -- ability source
		"mortimer_kisses_modifier", -- modifier name
		{
			duration = duration,
			pos_x = point.x,
			pos_y = point.y,

		} -- kv
	)
end

--------------------------------------------------------------------------------
-- Projectile
function mortimer_kisses_base:OnProjectileHit( target, location )
	--self.blob_hit = self.blob_hit + 1
	--print("projectile hit: " .. self.blob_hit)

	self.caster = self:GetCaster()
	if not target then return end

	-- load data
	local damage = self:GetSpecialValueFor( "damage_per_impact" )
	local duration = self:GetSpecialValueFor( "burn_ground_duration" )
	local impact_radius = self:GetSpecialValueFor( "impact_radius" )

	if target.secondary then
		impact_radius = self:GetSpecialValueFor("rings_radius")
	end
	local vision = self:GetSpecialValueFor( "projectile_vision" )

	-- precache damage
	local damageTable = {
		-- victim = target,
		attacker = self.caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		impact_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
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

	-- start aura on thinker
	local mod = target:AddNewModifier(
		self.caster, -- player source
		self, -- ability source
		"mortimer_kisses_thinker_modifier", -- modifier name
		{
			duration = duration,
			slow = 1,
		} -- kv
	)

	-- destroy trees
	GridNav:DestroyTreesAroundPoint( location, impact_radius, true )

	-- create Vision
	AddFOWViewer( self.caster:GetTeamNumber(), location, vision, duration, false )

	-- play effects
	self:PlayEffects( location )
	
	--if player has added effect upgrade
	if IsServer() then
		if self.caster:HasAbility("mortimer_kisses_added_effect") then
			--every time the spell is cast, choose a different effect
			self:AddedEffect(self.addedEffect, location)
		end
	end

	if target.secondary then return end

end

function mortimer_kisses_base:AddedEffect( effect_num, location )

	--torrent
	if effect_num == 1 then
		local torrentUnit = CreateUnitByName("dummy", location, true, self.caster, self.caster, self.caster:GetTeam())
		--spell must be enclosed in brackets correctly in order to be used
		--local epicenter = epicenterUnit:AddAbility("sandking_epicenter_custom")
		local torrent = torrentUnit:AddAbility("torrent_custom")
		torrent:SetLevel(1)
		torrentUnit:SetCursorPosition(location)
		torrent:OnSpellStart()
		torrentUnit:ForceKill(false)
	--sprout
	elseif effect_num == 2 then
		local sproutUnit = CreateUnitByName("dummy", location, true, self.caster, self.caster, self.caster:GetTeam())
		--spell must be enclosed in brackets correctly in order to be used
		--local epicenter = epicenterUnit:AddAbility("sandking_epicenter_custom")
		local sprout = sproutUnit:AddAbility("sprout_custom")
		sprout:SetLevel(1)
		sproutUnit:SetCursorPosition(location)
		sprout:OnSpellStart()
		sproutUnit:ForceKill(false)
	--blood bath
	elseif effect_num == 3 then
		local bloodBathUnit = CreateUnitByName("dummy", location, true, self.caster, self.caster, self.caster:GetTeam())
		--spell must be enclosed in brackets correctly in order to be used
		--local epicenter = epicenterUnit:AddAbility("sandking_epicenter_custom")
		local bloodBath = bloodBathUnit:AddAbility("blood_bath")
		bloodBath:SetLevel(1)
		bloodBathUnit:SetCursorPosition(location)
		bloodBath:OnSpellStart()
		bloodBathUnit:ForceKill(false)
	--chrono
	elseif effect_num == 4 then
		local chronoUnit = CreateUnitByName("dummy", location, true, self.caster, self.caster, self.caster:GetTeam())
		--spell must be enclosed in brackets correctly in order to be used
		--local epicenter = epicenterUnit:AddAbility("sandking_epicenter_custom")
		local chrono = chronoUnit:AddAbility("chrono_custom")
		chrono:SetLevel(1)
		chronoUnit:SetCursorPosition(location)
		chrono:OnSpellStart()
		chronoUnit:ForceKill(false)
	--shadow raze
	elseif effect_num == 5 then
		--taken care of in its own function
	end

end

--------------------------------------------------------------------------------
function mortimer_kisses_base:PlayEffects( loc )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf"
	local sound_cast = "Hero_Snapfire.MortimerBlob.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.caster )
	ParticleManager:SetParticleControl( effect_cast, 3, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self.caster )
	ParticleManager:SetParticleControl( effect_cast, 0, loc )
	ParticleManager:SetParticleControl( effect_cast, 1, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	local sound_location = "Hero_Snapfire.MortimerBlob.Impact"
	EmitSoundOnLocationWithCaster( loc, sound_location, self.caster )
end

--------------------------------------------------------------------------------
mortimer_kisses_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function mortimer_kisses_modifier:IsHidden()
	return false
end

function mortimer_kisses_modifier:IsDebuff()
	return false
end

function mortimer_kisses_modifier:IsStunDebuff()
	return false
end

function mortimer_kisses_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function mortimer_kisses_modifier:OnCreated( kv )
	--print("modifier created")
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	--flag to kill remnants if modifier is destroyed before teleport is cast
	self.caster.teleportCast = false

	--table of shadowraze units
	if self.ability.addedEffect == 5 then
		self.shadowrazeUnits = {}
	end
	
	self.unitNum = 0

	-- references
	self.min_range = self.ability:GetSpecialValueFor( "min_range" )
	self.max_range = self.ability:GetCastRange( Vector(0,0,0), nil )
	self.range = self.max_range-self.min_range

	self.min_travel = self.ability:GetSpecialValueFor( "min_lob_travel_time" )
	self.max_travel = self.ability:GetSpecialValueFor( "max_lob_travel_time" )
	self.travel_range = self.max_travel-self.min_travel

	local projectile_vision = self.ability:GetSpecialValueFor( "projectile_vision" )

	self.turn_rate = self.ability:GetSpecialValueFor( "turn_rate" )
	self.blob_count = 0

	if not IsServer() then return end

	-- load data

	local projectile_speed = self.ability:GetSpecialValueFor( "projectile_speed" ) + self.caster:FindTalentValue("special_bonus_unique_snapfire_1")
	--for shadow raze
	self.projectile_speed = projectile_speed
	local projectile_count = self.ability:GetSpecialValueFor( "projectile_count" ) + self.caster:FindTalentValue("special_bonus_unique_snapfire_1")
	local interval = self.ability:GetDuration() / projectile_count + 0.01 -- so it only has 8 projectiles instead of 9
	self:SetValidTarget( Vector( kv.pos_x, kv.pos_y, 0 ) )
	local projectile_start_radius = 0
	local projectile_end_radius = 0

	--change projectile effect based on added effect 
	local effectName
	if self.caster:HasAbility("mortimer_kisses_added_effect") then
		--based on effect id, change it
		if self.ability.addedEffect == 1 then
			--blue
			effectName = "particles/snapfire_lizard_blobs_arced_ice.vpcf"
		elseif self.ability.addedEffect == 2 then
			--green
			effectName = "particles/snapfire_lizard_blobs_arced_green.vpcf"
		elseif self.ability.addedEffect == 3 then
			--red
			effectName = "particles/snapfire_lizard_blobs_arced_red.vpcf"
		elseif self.ability.addedEffect == 4 then
			--purple
			effectName = "particles/snapfire_lizard_blobs_arced_purple.vpcf"
		elseif self.ability.addedEffect == 5 then
			--black
			effectName = "particles/snapfire_lizard_blobs_arced_black.vpcf"
		end
	else
		--regular
		effectName = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf"
	end

	-- precache projectile
	self.info = {
		-- Target = target,
		Source = self.caster,
		Ability = self.ability,	
		
		--EffectName = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf",
		--testing
		EffectName = effectName,
		iMoveSpeed = projectile_speed,
		bDodgeable = false,                           -- Optional
	
		vSourceLoc = self.caster:GetOrigin(),                -- Optional (HOW)
		
		bDrawsOnMinimap = false,                          -- Optional
		bVisibleToEnemies = true,                         -- Optional
		bProvidesVision = true,                           -- Optional
		iVisionRadius = projectile_vision,                              -- Optional
		iVisionTeamNumber = self.caster:GetTeamNumber()        -- Optional
	}

	--if player has teleport upgrade
	if self.caster:HasAbility("mortimer_kisses_teleport") then

		--replace ult with activate remnant
		local teleport_ability = self.caster:FindAbilityByName("mortimer_kisses_teleport")
		if not teleport_ability:IsTrained() then
			teleport_ability:SetLevel(1)
		end
		self.caster:SwapAbilities("mortimer_kisses_teleport", "mortimer_kisses_base", true, true)
		--self.caster:FindAbilityByName("mortimer_kisses_teleport"):SetAbilityIndex(5)

		--create a table with remnants
		self.remnants = {}

	end

	-- Start interval
	self:StartIntervalThink( interval )
	-- runs a thought
	self:OnIntervalThink()



end

function mortimer_kisses_modifier:OnRefresh( kv )
	
end

function mortimer_kisses_modifier:OnRemoved()
end

function mortimer_kisses_modifier:OnDestroy()
	--print("spell modifier destroyed")
	if IsServer() then

		self.caster.kisses_cast = false
		if self.caster:HasAbility("mortimer_kisses_teleport") then
			--if GameMode.teams[self.caster:GetTeam()].teleportJustGained then
				--nothing
			--else
			--print("has teleport")
			--switch ability back to ult
			--it was swapping again at the end of teleport; causes hotkey to disappear and the teleport ability to disappear
				self.caster:SwapAbilities("mortimer_kisses_base", "mortimer_kisses_teleport", true, true)
				--if caster died after casting kisses and before casting teleport
				if self.caster.teleportCast == false and self.remnants ~= nil then
					for _, remnant in pairs(self.remnants) do
						remnant:ForceKill(false)
					end
				end
			--end
		--if caster died after teleport
		else
			--kill remnants
			--kill 
			--self.caster:FindAbilityByName("mortimer_kisses_base"):SetAbilityIndex(5)
			--kill remnants
			--if he dies, kill remnants
			--if he dies during teleportation, kill remaining remnants
			--if he casts, kill remnants one by one
			if self.caster.teleportCast == true then
				--don't kill remnants
				--print("teleport cast is true")
			else
				--print("teleport cast is false; killing remnants")
				if self.remnants ~= nil then
					for _, remnant in pairs(self.remnants) do
						remnant:ForceKill(false)
					end
				end
			end
		end

		--GameMode.teams[self.caster:GetTeam()].teleportJustGained = false
	end

	
end

--------------------------------------------------------------------------------
-- Modifier Effects
function mortimer_kisses_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,

		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
	}

	return funcs
end

function mortimer_kisses_modifier:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	-- right click, switch position
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		self:SetValidTarget( params.new_pos )
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET or
		params.order_type==DOTA_UNIT_ORDER_ATTACK_TARGET
	then
		self:SetValidTarget( params.target:GetOrigin() )

	-- stop or hold
	elseif 
		params.order_type==DOTA_UNIT_ORDER_STOP or
		params.order_type==DOTA_UNIT_ORDER_HOLD_POSITION
	then
		self:Destroy()
		--take care of teleport upgrade
	end
end

function mortimer_kisses_modifier:GetModifierMoveSpeed_Limit()
	return 0.1
end

function mortimer_kisses_modifier:GetModifierTurnRate_Percentage()
	return -self.turn_rate
end

--------------------------------------------------------------------------------
-- Status Effects
function mortimer_kisses_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function mortimer_kisses_modifier:OnIntervalThink()
	--if stunned, 
		--remove modifier
	if IsServer() then
		if self.caster:IsStunned() or self.caster:IsSilenced() then
			self:Destroy()
		else
			self:CreateBlob(kv)
			--create extra more blobs
			if self.caster:HasAbility("mortimer_kisses_make_it_rain") then
				local blobs = 0
				Timers:CreateTimer("extra_blobs", {
					useGameTime = true,
					endTime = 0.2,
					callback = function()
						--print("extra_blob called")
						blobs = blobs + 1
						self:CreateBlobExtra(kv)
						--print("extra blobs: " .. self.caster:FindAbilityByName("mortimer_kisses_make_it_rain"):GetSpecialValueFor("extra_blobs"))
						--PrintTable(self.caster)
						--print("caster's name: " .. self.caster:GetUnitName())
						--if blobs == self.caster:FindAbilityByName("mortimer_kisses_make_it_rain"):GetSpecialValueFor("extra_blobs") then
						if blobs == 2 then
							return nil
						else
							return 0.3
						end
					end
				})
			end
		end
	end
end

function mortimer_kisses_modifier:CreateBlob(kv)

	--stop previous animation
	self:GetParent():FadeGesture(ACT_DOTA_CAST_ABILITY_4)
	--play animation
	self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_4)

	if not kv then kv = {} end

	local travel_time = self.travel_time
	local target_pos = self.target

	if kv.pos then
		target_pos = GetGroundPosition( self.target + kv.pos, nil )
	end


	if kv.travel_time then
		travel_time = kv.travel_time
	end

	self.blob_count = self.blob_count + 1
	--("blob count: " .. self.blob_count)

	----------------------
	-- teleport upgrade --
	----------------------

	--create a unit at the target position to represent the remnant
	--if ability was gained while casting base
	if self.caster:HasAbility("mortimer_kisses_teleport") then
		--if GameMode.teams[self.caster:GetTeam()].teleportJustGained == true then
			--skip
		--else
			self.remnants[self.blob_count] = CreateUnitByName("dummy", target_pos, true, self.caster, self.caster, self.caster:GetTeam())
			self.remnants[self.blob_count]:SetModel("models/cm_cookie_god.vmdl")
			self.remnants[self.blob_count]:AddAbility("cookie_god_spawn")
		--end
	end
	--don't need to control it
	--apply effects
	--invulnerable, unselectable, fire remnant effect
	--self.remnants[self.blob_count]:AddNewModifier(nil, nil, "modifier_fire_remnant_effect", { duration = 10})
	--self.remnants[self.blob_count]:AddAbility("invulnerable")
	

	-- create target thinker
	--add a duration so it will expire if not refreshed
	local thinker = CreateModifierThinker(
		self.caster, -- player source
		self.ability, -- ability source
        "mortimer_kisses_thinker_modifier", -- modifier name
		{ travel_time = travel_time,
		duration = travel_time + 1 }, -- kv
		target_pos,
		self:GetParent():GetTeamNumber(),
		false
	)

	--[[Timers:CreateTimer(string.format("blob_thinker_%s", self.blob_count), {
		useGameTime = false,
		endTime = 0,
		callback = function()
		  print("blob " .. self.blob_count .. "is alive: " .. tostring(thinker:IsAlive()))
		  return 0.1
		end
	  })]]



	--print(self.blob_count, self.ability:GetSpecialValueFor("mini_blob_counter"))
	--[[if self.blob_count == self.ability:GetSpecialValueFor("mini_blob_counter") then
		self.blob_count = 0
		thinker.mega_blob = true
	end]]

	-- set projectile
	self.info.iMoveSpeed = self.vector:Length2D() / travel_time
	self.info.Target = thinker

	-- launch projectile
	local projectile = ProjectileManager:CreateTrackingProjectile( self.info )	

	--shadow raze upgrade
	if self.ability.addedEffect == 5 then
		if self.caster:HasModifier("mortimer_kisses_modifier") then
			self:ShadowRazeUpgrade(target_pos, travel_time)
		end
	end

	-- create FOW
	AddFOWViewer( self:GetParent():GetTeamNumber(), thinker:GetOrigin(), 100, 1, false )

	-- play sound
	EmitSoundOn( "Hero_Snapfire.MortimerBlob.Launch", self:GetParent() )
end

function mortimer_kisses_modifier:CreateBlobExtra(kv)
	--print("making blob extra")

	if not kv then kv = {} end
	
	--the "z" has to be on the same height as the floor for modifier_thinker to show
	local target_pos = Vector(self.caster:GetAbsOrigin().x + math.random(-1500, 1500),
		self.caster:GetAbsOrigin().y + math.random(-1500, 1500),
		0)

	--so the modifier_thinker doesn't float in the air
	target_pos = GetGroundPosition(target_pos, nil)

	if kv.travel_time then
		--print("kv.travel_time: " .. kv.travel_time)
		travel_time = kv.travel_time
	end
	local travel_time = self.travel_time
	travel_time = ((target_pos - self.caster:GetAbsOrigin()):Length2D()-self.min_range)/self.range * self.travel_range + self.min_travel
	--print("travel_time: " .. travel_time)

    -- create target thinker
	local thinker = CreateModifierThinker(
		self.caster, -- player source
		self.ability, -- ability source
        "mortimer_kisses_thinker_modifier", -- modifier name
		{ travel_time = travel_time }, -- kv
		target_pos,
		self.caster:GetTeamNumber(),
		false
	)
	--thinker:SetModel("models/creeps/neutral_creeps/n_creep_kobold/kobold_c/n_creep_kobold_c.vmdl")

	-- set projectile
	self.info.iMoveSpeed = (target_pos - self.caster:GetAbsOrigin()):Length2D() / travel_time
	self.info.Target = thinker

	-- launch projectile
	local projectile = ProjectileManager:CreateTrackingProjectile( self.info )
	
	--shadow raze upgrade
	if self.ability.addedEffect == 5 then
		if self.caster:HasModifier("mortimer_kisses_modifier") then
			self:ShadowRazeUpgrade(target_pos, travel_time)
		end
	end

	-- create FOW
	AddFOWViewer( self.caster:GetTeamNumber(), thinker:GetOrigin(), 100, 1, false )

	-- play sound
	EmitSoundOn( "Hero_Snapfire.MortimerBlob.Launch", self.caster )
end

--------------------------------------------------------------------------------
-- Helper
function mortimer_kisses_modifier:SetValidTarget( location )
	local origin = self:GetParent():GetOrigin()
	local vec = location-origin
	local direction = vec
	direction.z = 0
	direction = direction:Normalized()

	if vec:Length2D()<self.min_range then
		vec = direction * self.min_range
	elseif vec:Length2D()>self.max_range then
		vec = direction * self.max_range
	end

	self.target = GetGroundPosition( origin + vec, nil )
	self.vector = vec
	self.travel_time = (vec:Length2D()-self.min_range)/self.range * self.travel_range + self.min_travel
end

--------------------------------------------------------------------------------
-- Trails upgrade
function mortimer_kisses_modifier:ShadowRazeUpgrade(target_pos, travel_time)
	
	--create dummy unit
	--start with a delay
	self.unitNum = self.unitNum + 1
	--set a local variable so it doesn't get updated when the next blob is created
	local unitNum = self.unitNum

	local shadowrazeUnit = CreateUnitByName("dummy", self.caster:GetAbsOrigin(), true, self.caster, self.caster, self.caster:GetTeam())
	--self.shadowrazeUnits[self.unitNum].unitNum = self.unitNum
	shadowrazeUnit:SetControllableByPlayer(0, true)
	--self.shadowrazeUnits[self.unitNum]:AddNewModifier(nil, nil, "modifier_set_max_move_speed", {})
	--direction
	--move to position doesn't work
	local shadowrazeUnitDirection = (-shadowrazeUnit:GetAbsOrigin() + target_pos)
	local knockback_secondary = shadowrazeUnit:AddNewModifier(
		self.caster, -- player source
		self.ability, -- ability source
		"modifier_knockback_custom", -- modifier name
		{
			distance = (shadowrazeUnit:GetAbsOrigin() - target_pos):Length(),
			height = 100,
			duration = travel_time,
			direction_x = shadowrazeUnitDirection.x,
			direction_y = shadowrazeUnitDirection.y,
			IsStun = true,
		} -- kv
	)

	shadowrazeUnit.spell = shadowrazeUnit:AddAbility("nevermore_shadowraze1_custom")
	
	--set level for damage to activate
	shadowrazeUnit.spell:SetLevel(1)

	local counter = 0
	Timers:CreateTimer(string.format("shadowraze_%s", self.unitNum), {
		useGameTime = true,
		callback = function()
			--take length between unit and target_pos
			--if it's close,
				--stop timer
			if counter > travel_time then
				shadowrazeUnit:ForceKill(false)
				shadowrazeUnit:RemoveSelf()
				return nil
			elseif (shadowrazeUnit:GetAbsOrigin() - target_pos):Length2D() > 300 then
				shadowrazeUnit.spell:OnSpellStart()
				counter = counter + 0.3
				return 0.2
			else
				shadowrazeUnit:ForceKill(false)
				shadowrazeUnit:RemoveSelf()
				return nil
			end
		end
	}) 
end

--------------------------------------------------------------------------------
magma_burn_slow_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function magma_burn_slow_modifier:IsHidden()
	return false
end

function magma_burn_slow_modifier:IsDebuff()
	return true
end

function magma_burn_slow_modifier:IsStunDebuff()
	return false
end

function magma_burn_slow_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function magma_burn_slow_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	-- references
	local dps = self:GetAbility():GetSpecialValueFor( "burn_damage" )
    local interval = self:GetAbility():GetSpecialValueFor( "burn_interval" )
    local slow_pct = self:GetAbility():GetSpecialValueFor("slow_pct")

	if not IsServer() then return end

	-- Fiery Slash Impact IMBAfication
	local distance = (self.caster:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
    -- local distance_travel = math.min(distance / self:GetCastRange(self.caster:GetAbsOrigin(), self.caster), 1)
	-- hardcoded for now
	local distance_travel = math.min(distance / 3000, 1)
	--local min_slow = self:GetAbility():GetSpecialValueFor("min_slow_pct") + self.caster:FindTalentValue("special_bonus_unique_snapfire_4")
	--local max_slow = self:GetAbility():GetSpecialValueFor("max_slow_pct") + self.caster:FindTalentValue("special_bonus_unique_snapfire_4")
    --self:SetStackCount(math.max(max_slow * distance_travel, min_slow))
    self:SetStackCount(slow_pct)

	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self.caster,
		damage = dps*interval,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}

	-- Start interval
	self:StartIntervalThink( interval )
	self:OnIntervalThink()
end

function magma_burn_slow_modifier:OnRefresh( kv )
	
end

function magma_burn_slow_modifier:OnRemoved()
end

function magma_burn_slow_modifier:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function magma_burn_slow_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function magma_burn_slow_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * (-1)
end

--------------------------------------------------------------------------------
-- Interval Effects
function magma_burn_slow_modifier:OnIntervalThink()
	-- apply damage
	ApplyDamage( self.damageTable )

	-- play overhead
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function magma_burn_slow_modifier:GetEffectName()
	return "particles/units/heroes/hero_snapfire/hero_snapfire_burn_debuff.vpcf"
end

function magma_burn_slow_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function magma_burn_slow_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function magma_burn_slow_modifier:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

--------------------------------------------------------------------------------
mortimer_kisses_thinker_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications

--------------------------------------------------------------------------------
-- Initializations
function mortimer_kisses_thinker_modifier:OnCreated( kv )
	--print("thinker modifier created")
	self.parent = self:GetParent()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	-- references
	self.max_travel = self.ability:GetSpecialValueFor( "max_lob_travel_time" )
	self.radius = self.ability:GetSpecialValueFor( "impact_radius" )
	self.linger = self.ability:GetSpecialValueFor( "burn_linger_duration" )

	if not IsServer() then return end

	-- dont start aura right off
	self.start = false

    -- create aoe finder particle
    if self:GetAbility():GetAbilityName() == "mortimer_kisses_base" then
        self:PlayEffects( kv.travel_time )
    end
end

function mortimer_kisses_thinker_modifier:OnRefresh( kv )
	--print("refresh")
	
	-- references
	self.max_travel = self.ability:GetSpecialValueFor( "max_lob_travel_time" )
	self.radius = self.ability:GetSpecialValueFor( "impact_radius" )
	self.linger = self.ability:GetSpecialValueFor( "burn_linger_duration" )

	if not IsServer() then return end

	-- start aura
	self.start = true

	-- stop aoe finder particle
	self:StopEffects()
end

--before unit loses modifier
function mortimer_kisses_thinker_modifier:OnRemoved()
end

--after unit loses modifier
function mortimer_kisses_thinker_modifier:OnDestroy()
	--print("thinker modifier destroyed")
	if not IsServer() then return end
	self:StopEffects()
	UTIL_Remove( self.parent )
end

--------------------------------------------------------------------------------
-- Aura Effects
function mortimer_kisses_thinker_modifier:IsAura()
	return self.start
end

function mortimer_kisses_thinker_modifier:GetModifierAura()
	return "magma_burn_slow_modifier"
end

function mortimer_kisses_thinker_modifier:GetAuraRadius()
	return self.radius
end

function mortimer_kisses_thinker_modifier:GetAuraDuration()
	return self.linger
end

function mortimer_kisses_thinker_modifier:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function mortimer_kisses_thinker_modifier:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function mortimer_kisses_thinker_modifier:PlayEffects( time )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_CUSTOMORIGIN, self.caster, self.caster:GetTeamNumber() )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius*(self.max_travel/time) ) )
	ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( time, 0, 0 ) )
end

function mortimer_kisses_thinker_modifier:StopEffects()
	ParticleManager:DestroyParticle( self.effect_cast, true )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end



