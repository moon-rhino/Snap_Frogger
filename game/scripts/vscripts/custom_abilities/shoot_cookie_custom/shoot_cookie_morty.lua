--only hurts creeps (team bad guys)

shoot_cookie_morty = class({})
LinkLuaModifier("shoot_cookie_modifier", "libraries/modifiers/shoot_cookie_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_stunned", "libraries/modifiers/modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)

local SHOOT_DISTANCE = GameMode.cookieShootDistance
local SHOOT_SPEED = 600
local BULLET_RADIUS = 150
local GRACE_DISTANCE = 1500

--on level up, when it hits a target, split into smaller cookies
--switch which cookie you throw
--oreo: high jump
--something else: far jump
function shoot_cookie_morty:OnSpellStart()
    if IsServer() then
        self.caster = self:GetCaster()
        if self.caster.part == 1 then
            SHOOT_DISTANCE = GameMode.cookieShootDistancePart1
        else
            SHOOT_DISTANCE = GameMode.cookieShootDistancePart2
        end
        --A Liner Projectile must have a table with projectile info
        local cursorPt = self:GetCursorPosition()
        local casterPt = self.caster:GetAbsOrigin()
        self.casterPt = casterPt
        local direction = cursorPt - casterPt
        direction = direction:Normalized()
        local speed = self:GetSpecialValueFor( "projectile_speed" )
        self.horizontal_jump_distance = self:GetSpecialValueFor( "horizontal_jump_distance")
        self.jump_height = self:GetSpecialValueFor( "jump_height")
        --must declare correct type for number
        self.jump_duration = self:GetSpecialValueFor( "jump_duration" )
        self.abilityDamageType = self:GetAbilityDamageType()
        local info = 
        { 
            Ability = self,
            EffectName = "particles/hero_snapfire_cookie_projectile_linear_morty_perp_down.vpcf", --particle effect
            --EffectName = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", --particle effect
            vSpawnOrigin = self.caster:GetAbsOrigin(),
            fDistance = SHOOT_DISTANCE,
            fStartRadius = BULLET_RADIUS,
            fEndRadius = BULLET_RADIUS,
            Source = self.caster,
            --bHasFrontalCone = false,
            --bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 30.0,
            bDeleteOnHit = false,
            vVelocity = direction * SHOOT_SPEED,
            bProvidesVision = true,
            iVisionRadius = 500,
            iVisionTeamNumber = self.caster:GetTeamNumber()
        }
        projectile = ProjectileManager:CreateLinearProjectile(info)

        --play sounds
        self.caster:EmitSound("cookie_cast_linear_projectile")
        --projectile sound
        self.caster:EmitSound("cookie_projectile_linear_projectile")
    end
end

function shoot_cookie_morty:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then
        return false
        --skip
    elseif hTarget == self:GetCaster() then
        return false
        --skip
    elseif math.abs((self.casterPt - hTarget:GetAbsOrigin()):Length()) < GRACE_DISTANCE then
        return false
    elseif hTarget:GetTeamNumber() ~= self.caster:GetTeamNumber() then
        --[[local cookiePads = FindUnitsInRadius(
            hTarget:GetTeam(), 
            hTarget:GetAbsOrigin(), 
            nil,
            GameMode.level3CookiePadSearchRadius, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_ALL, 
            DOTA_UNIT_TARGET_FLAG_NONE, 
            FIND_ANY_ORDER, 
            false
        )
        for cookiePadIndex, cookiePad in pairs(cookiePads) do
            if string.sub(cookiePad:GetUnitName(), 12) == "morty" then
                return false
            end
        end
        hTarget:ForceKill(false)]]

        --[[local knockback = hTarget:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "modifier_knockback_custom", -- modifier name
            {
                distance = self.horizontal_jump_distance,
                height = self.jump_height,
                duration = self.jump_duration,
                direction_x = -hTarget:GetForwardVector().x,
                direction_y = -hTarget:GetForwardVector().y,
                IsStun = true,
            } -- kv
        )

        local callback = function()
            self:PlayEffects3( hTarget, radius )
        end

        knockback:SetEndCallback( callback )]]
        --make eating sound
        return true
    end
end

function shoot_cookie_morty:PlayEffects3( target, radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf"
	local sound_landing = "cookie_landing"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_landing, target )
end

--complete blocks in between
