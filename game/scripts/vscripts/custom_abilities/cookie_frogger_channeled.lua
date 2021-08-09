-- Cookie spell recreated by EarthSalamander42
-- see the reference at https://github.com/EarthSalamander42/dota_imba/blob/47d802f6718929726fb24dd4c5b140064f1dfd15/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/modifiers/generic/modifier_generic_knockback_lua.lua

--------------------------------------------------------------------------------
cookie_frogger_channeled = class({})
cookie_frogger_channeled_release = class({})
modifier_cookie_frogger_channeled_thinker = class({}) -- Custom class for attempting non-channel logic

LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cookie_frogger_channeled_thinker", "custom_abilities/cookie_frogger_channeled", LUA_MODIFIER_MOTION_NONE)

--channeling flag
local channeling = false
local channeledTime = 0

--------------------------------------------------------------------------------
-- ability gets replaced when cast
function cookie_frogger_channeled:GetAssociatedSecondaryAbilities()
	return "cookie_frogger_channeled_release"
end

function cookie_frogger_channeled_release:GetAssociatedPrimaryAbilities()
	return "cookie_frogger_channeled"
end

--------------------------------------------------------------------------------
-- Custom KV
function cookie_frogger_channeled:GetCastPoint()
	if IsServer() and self:GetCursorTarget()==self:GetCaster() then
		return self:GetSpecialValueFor( "self_cast_delay" )
	end
	return 0.0
end

--------------------------------------------------------------------------------
-- Channel Time
-- this has to run in order to start the channel bar
function cookie_frogger_channeled:GetChannelTime()
	return self:GetSpecialValueFor( "max_channel_time" )
end

--------------------------------------------------------------------------------
-- Ability Phase Start
function cookie_frogger_channeled:OnAbilityPhaseInterrupted()

end
function cookie_frogger_channeled:OnAbilityPhaseStart()

	if self:GetCursorTarget()==self:GetCaster() then
		self:PlayEffects1()
	end


	return true -- if success
end

--------------------------------------------------------------------------------
-- Ability Start
function cookie_frogger_channeled:OnSpellStart()
	local release_ability = self:GetCaster():FindAbilityByName("cookie_frogger_channeled_release")
	if not release_ability:IsTrained() then
		release_ability:SetLevel(1)
	end

	self:GetCaster():SwapAbilities("cookie_frogger_channeled", "cookie_frogger_channeled_release", false, true)

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_cookie_frogger_channeled_thinker", {duration = self:GetSpecialValueFor("max_channel_time")})

	--take the time
	--[[if channeling then
		self:OnChannelFinish(true)
	else
		channeling = true
		local caster = self:GetCaster()
		self.caster = caster
		local target = self:GetCaster()
		self.target = target
		local cursorPt = self:GetCursorPosition()
		local casterPt = caster:GetAbsOrigin()
		local direction = cursorPt - casterPt
		self.direction = direction:Normalized()

		-- Play sound
		local sound_cast = "Hero_Snapfire.FeedCookie.Cast"
		EmitSoundOn( sound_cast, self:GetCaster() )
	end]]
end


function cookie_frogger_channeled:OnChannelThink()
	-- Logic was moved to the "modifier_imba_keeper_of_the_light_illuminate_self_thinker" modifier's OnIntervalThink(FrameTime())
end

function cookie_frogger_channeled:OnChannelFinish(bInterrupted)
	-- Logic was moved to the "modifier_imba_keeper_of_the_light_illuminate_self_thinker" modifier's OnDestroy()
end


--------------------------------------------------------------------------------
-- Channel Finish
--function cookie_frogger_channeled:OnChannelFinish(interrupted)
	--channeling = false
	--local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime()) / self:GetChannelTime()
	-- Ability properties
	--[[local caster = self:GetCaster()
	local ability = self
	local modifier_pulse = "modifier_imba_epicenter_pulse"
	local failed_response = "sandking_skg_ability_failure_0"..math.random(1,6)

	-- Stop the blast particle
	ParticleManager:DestroyParticle(self.particle_sandblast_fx, false)
	ParticleManager:ReleaseParticleIndex(self.particle_sandblast_fx)

	-- If the caster was interrupted, complain and do nothing 
	if interrupted then
		EmitSoundOn(failed_response, caster)
		return nil
	end

	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)

	-- Channel is complete! Start pulsing!
    caster:AddNewModifier(caster, ability, modifier_pulse, {})]]
    
    --jump based on how long the ability was channeled
    
    --[[local knockback = self:GetCaster():AddNewModifier(
        self:GetCaster(), -- player source
        self, -- ability source
        "modifier_knockback_custom", -- modifier name
        {
            distance = 1000 * channel_pct,
            height = height,
            duration = 1,
            direction_x = self.direction.x,
            direction_y = self.direction.y,
            IsStun = true,
        } -- kv
    )]]
--end

function cookie_frogger_channeled_release:OnSpellStart()
	local cookie_frogger_channeled_thinker = self:GetCaster():FindModifierByName("modifier_cookie_frogger_channeled_thinker")
	

	-- If it's there, destroy it (which will make snap jump)
	if cookie_frogger_channeled_thinker then
		cookie_frogger_channeled_thinker:Destroy()
	end
end

--------------------------------------
-- COOKIE FROGGER CHANNELED THINKER --
--------------------------------------

function modifier_cookie_frogger_channeled_thinker:IsHidden()
	return false
end

function modifier_cookie_frogger_channeled_thinker:OnCreated()
	self.channelTime = 0
	self:StartIntervalThink(FrameTime())
end

function modifier_cookie_frogger_channeled_thinker:OnIntervalThink()
	self.channelTime = self.channelTime + FrameTime()
end

function modifier_cookie_frogger_channeled_thinker:OnDestroy()
	if IsServer() then
		if self:GetCaster():IsStunned() == false then
			local max_distance = self:GetAbility():GetSpecialValueFor("max_distance")
			local max_channel_time = self:GetAbility():GetSpecialValueFor("max_channel_time")
			local knockback = self:GetCaster():AddNewModifier(
				self:GetCaster(), -- player source
				self, -- ability source
				"modifier_knockback_custom", -- modifier name
				{
					distance = max_distance * (self.channelTime / max_channel_time),
					height = 200,
					duration = 0.3,
					direction_x = self:GetCaster():GetForwardVector().x,
					direction_y = self:GetCaster():GetForwardVector().y,
					IsStun = true,
				} -- kv
			)
		end
		--should end when interrupted
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invulnerable", {duration = 0.3})
		self:GetCaster():SwapAbilities("cookie_frogger_channeled_release", "cookie_frogger_channeled", false, true)
	end
end

function modifier_cookie_frogger_channeled_thinker:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
	}
	return funcs
end

--OnOrder
function modifier_cookie_frogger_channeled_thinker:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	-- right click, switch position
	if 	params.order_type==DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		params.unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
		self:Destroy()
		params.unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
	elseif 
		params.order_type==DOTA_UNIT_ORDER_MOVE_TO_TARGET
	then
		params.unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
		self:Destroy()
		params.unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
	-- stop
	elseif 
		params.order_type==DOTA_UNIT_ORDER_STOP
	then
		params.unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
		self:Destroy()
		params.unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
	end
end


--------------------------------------------------------------------------------
function cookie_frogger_channeled:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function cookie_frogger_channeled:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_buff.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_receive.vpcf"
	local sound_target = "Hero_Snapfire.FeedCookie.Consume"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, target )

	-- Create Sound
	EmitSoundOn( sound_target, target )

	return effect_cast
end

function cookie_frogger_channeled:PlayEffects3( target, radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf"
	local sound_location = "Hero_Snapfire.FeedCookie.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_location, target )
end


--create projectile
--hit the spot the target lands at


