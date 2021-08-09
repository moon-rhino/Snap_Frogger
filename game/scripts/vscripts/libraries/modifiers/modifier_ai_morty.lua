modifier_ai_morty = class({})

local AI_STATE_IDLE = 0
local AI_STATE_AGGRESSIVE = 1
local AI_STATE_RETURNING = 2

local AI_THINK_INTERVAL = 0.5

local moveDelay = 0
local executingMove = false
local moveIndex

function modifier_ai_morty:OnCreated(params)
    -- Only do AI on server
    if IsServer() then
        -- Set initial state
        self.state = AI_STATE_IDLE

        -- Store parameters from AI creation:
        -- unit:AddNewModifier(caster, ability, "modifier_ai", { aggroRange = X, leashRange = Y })
        self.aggroRange = params.aggroRange
        self.leashRange = params.leashRange

        -- Store unit handle so we don't have to call self:GetParent() every time
        --this is HScript
        self.unit = self:GetParent()

        -- Set state -> action mapping
        self.stateActions = {
            [AI_STATE_IDLE] = self.IdleThink,
            [AI_STATE_AGGRESSIVE] = self.AggressiveThink,
            [AI_STATE_RETURNING] = self.ReturningThink,
        }

        -- Start thinking
        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function modifier_ai_morty:OnIntervalThink()

    --if stunned,
        --state action = returning
    if self.unit:IsStunned() then
        self.state = AI_STATE_RETURNING
    else
        -- Execute action corresponding to the current state
        self.stateActions[self.state](self)    
    end
end

function modifier_ai_morty:IdleThink()
    -- Find any enemy units around the AI unit inside the aggroRange
    --change spell to cast based on range of enemy
    local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false)

    -- If one or more units were found, start attacking the first one
    if #units > 0 then
        self.aggroTarget = units[1] -- Remember who to attack
        if (self.unit:GetAbsOrigin() - self.aggroTarget:GetAbsOrigin()):Length() > 700 then
            move_index = math.random(2,4)
        else
            move_index = math.random(1,3)
        end
        --check self.unit is an HScript
        --Start attacking (casting spells)
        --rain ult
        --set cursor target based on where players are
        --spit on players
        --eat players (preventable with bkb or cookie)
        --gyro cookie that can push players out
        --epicenter
        --abilities
        --channeled jump, signal where he will land, time based on distance
        --self.ult = self.unit:FindAbilityByName("mortimer_kisses_morty")
        --self.unit:SetCursorPosition(self.aggroTarget:GetAbsOrigin())
        --self.ult:OnSpellStart()
        --self.unit:MoveToTargetToAttack(self.aggroTarget) 
        self.state = AI_STATE_AGGRESSIVE --State transition
        return -- Stop processing this state
    end

    --if no target, stay in this state
    -- Nothing else to do in Idle state
end

function modifier_ai_morty:AggressiveThink()
    --if casting a spell
        --continue
    --else,
        --cast a spell

    print("[modifier_ai_morty:AggressiveThink()] called")
    --[[if (self.unit.spawnVector - self.unit:GetAbsOrigin()):Length() > self.leashRange then
        self.unit:MoveToPosition(self.unit.spawnVector) --Move back to the spawnpoint
        self.state = AI_STATE_RETURNING --Transition the state to the 'Returning' state(!)
        return -- Stop processing this state
    end]]
    
    -- Check if the target has died
    --[[if not self.aggroTarget:IsAlive() then
        self.unit:MoveToPosition(self.unit.spawnVector) --Move back to the spawnpoint
        self.state = AI_STATE_RETURNING --Transition the state to the 'Returning' state(!)
        return -- Stop processing this state
    end]]

    if executingMove then
        --nothing
    else
        math.randomseed(Time())
        --move_index = math.random(4)
        --move_index = 2
        executingMove = true
        if move_index == 4 then
            local kissesToFire = math.random(3, 6)
            local kisses = 0
            Timers:CreateTimer(function()
                local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
                self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
                FIND_ANY_ORDER, false)
                --find length of "units"
                local lengthOfUnits = 0
                for _, unit in pairs(units) do
                  lengthOfUnits = lengthOfUnits + 1
                end
                if lengthOfUnits > 0 then
                    self.aggroTarget = units[1]
                    if lengthOfUnits > 1 then
                        self.aggroTarget2 = units[2]
                    end
                end
                print("[modifier_ai_morty:AggressiveThink()] timer for kiss")
                self.ult = self.unit:FindAbilityByName("mortimer_kisses_morty")
                self.unit:SetCursorPosition(self.aggroTarget:GetAbsOrigin())
                self.ult:OnSpellStart()
                if self.aggroTarget2 then
                    Timers:CreateTimer({
                        endTime = 0.15, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                        callback = function()
                            self.unit:SetCursorPosition(self.aggroTarget2:GetAbsOrigin())
                            self.ult:OnSpellStart()
                        end
                      })
                end
                kisses = kisses + 1
                if kisses == kissesToFire then
                    self.state = AI_STATE_RETURNING
                    executingMove = false
                    return nil
                else
                    print("[modifier_ai_morty:AggressiveThink()] casting kiss")
                    return 1.1
                end
            end)
        --2 = "trample"
        elseif move_index == 3 then
            --after a second,
            --jump to target
            print("[modifier_ai_morty:AggressiveThink()] casting cookie")
            self.cookie = self.unit:FindAbilityByName("mortimer_cookie")
            local totalCookies = math.random(3)
            local cookiesCast = 0
            Timers:CreateTimer("jumpTimer", {
                useGameTime = false,
                endTime = 0,
                callback = function()
                    if cookiesCast == totalCookies then
                        return nil
                    else
                        --re search enemies on every jump
                        local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
                        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
                        FIND_ANY_ORDER, false)
                
                        -- If one or more units were found, start attacking the first one
                        if #units > 0 then
                            self.aggroTarget = units[1]
                        end
                        self.unit:SetCursorPosition(self.aggroTarget:GetAbsOrigin())
                        self.cookie:OnSpellStart()
                        cookiesCast = cookiesCast + 1
                        return 1.6
                    end
                end
              })
            Timers:CreateTimer({
                endTime = 1.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                callback = function()
                    self.state = AI_STATE_RETURNING
                    executingMove = false
                end
            })
            --return ends the function
        --3 = "epicenter"
        elseif move_index == 1 then
            print("[modifier_ai_morty:AggressiveThink()] casting epicenter")
            self.epicenter = self.unit:FindAbilityByName("mortimer_epicenter")
            self.epicenter:OnSpellStart()
            --sync with how long the move is
            Timers:CreateTimer({
                endTime = 3.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                callback = function()
                    self.state = AI_STATE_RETURNING
                    executingMove = false
                end
            })
        --4 = "cookie_blast"
        elseif move_index == 2 then
            --cookie a far distance
            --blast cookies in a circle
            --none-tracking projectiles
            --announce "cookie blast!"
            --after a second,
                --execute move
            self.unit:EmitSound("mortimerCookieBlast")
            Timers:CreateTimer({
                endTime = 1.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                callback = function()
                    print("[modifier_ai_morty:AggressiveThink()] casting cookie blast")
                    self.cookieBlast = self.unit:FindAbilityByName('mortimer_cookie_blast')
                    self.cookieBlast:OnSpellStart()
                end
            })
            --execute move state
            Timers:CreateTimer({
                endTime = 4.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
                callback = function()
                    self.state = AI_STATE_RETURNING
                    executingMove = false
                end
            })
        end
    end
    -- Still in the aggressive state, so do some aggressive stuff.
    --self.unit:MoveToTargetToAttack(self.aggroTarget)
    --movelist
    --1 = "spit", 2 = "trample", 3 = "cookie_blast", 4 = "epicenter"
    --move_index = math.random(4)
    --[[math.randomseed(Time())
    move_index = math.random(4)
    move_index = 2
    executingMove = true
    --1 = "spit"
    
    if move_index == 1 then
        local kisses = 0
        Timers:CreateTimer(function()
            local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
            self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
            FIND_ANY_ORDER, false)
            if #units > 0 then
                self.aggroTarget = units[1]
            end
            print("[modifier_ai_morty:AggressiveThink()] timer for kiss")
            self.ult = self.unit:FindAbilityByName("mortimer_kisses_morty")
            self.unit:SetCursorPosition(self.aggroTarget:GetAbsOrigin())
            self.ult:OnSpellStart()
            kisses = kisses + 1
            if kisses == 6 then
                moveDelay = 0
                --end of move
                --resting state
                executingMove = false
                return nil
            else
                print("[modifier_ai_morty:AggressiveThink()] casting kiss")
                return 1.2
            end
        end)
        --casting spell flag
        --if not casting spell
            --change state to idle
        self.state = AI_STATE_RETURNING
        return

    --2 = "trample"
    elseif move_index == 3 then
        --after a second,
        --jump to target
        print("[modifier_ai_morty:AggressiveThink()] casting cookie")
        self.cookie = self.unit:FindAbilityByName("mortimer_cookie")
        self.unit:SetCursorPosition(self.aggroTarget:GetAbsOrigin())
        self.cookie:OnSpellStart()
        moveDelay = 0
        executingMove = false
        self.state = AI_STATE_RETURNING
        return
    --3 = "epicenter"
    elseif move_index == 4 then
        print("[modifier_ai_morty:AggressiveThink()] casting epicenter")
        self.epicenter = self.unit:FindAbilityByName("mortimer_epicenter")
        self.epicenter:OnSpellStart()
        --sync with how long the move is
        moveDelay = -3
        executingMove = false
        self.state = AI_STATE_RETURNING
        return
    --4 = "cookie_blast"
    elseif move_index == 2 then
        --cookie a far distance
        --blast cookies in a circle
        --none-tracking projectiles
        --announce "cookie blast!"
        --after a second,
            --execute move
        self.unit:EmitSound("mortimerCookieBlast")
        Timers:CreateTimer({
            endTime = 1.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
                print("[modifier_ai_morty:AggressiveThink()] casting cookie blast")
                self.cookieBlast = self.unit:FindAbilityByName('mortimer_cookie_blast')
                self.cookieBlast:OnSpellStart()
                --it takes time for cookies to travel
                
            end
        })
        --execute move state
        Timers:CreateTimer({
            endTime = 4, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
            callback = function()
                moveDelay = -1
                executingMove = false
            end
          })
        self.state = AI_STATE_RETURNING
        return]]
    --end
end




function modifier_ai_morty:ReturningThink()
    print("[modifier_ai_morty:ReturningThink()] called")
    if executingMove then
        --don't change state
    else
        --pause for 1 second between moves
        --moveDelay = moveDelay + 1
        --if moveDelay == 1 then
            self.state = AI_STATE_IDLE -- Transition the state to the 'Idle' state(!)
            return -- Stop processing this state
        --end
    end

end