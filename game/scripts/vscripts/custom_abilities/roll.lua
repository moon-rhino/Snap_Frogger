roll = class({})
pick = class({})
--LinkLuaModifier("modifier_knockback_custom", "libraries/modifiers/modifier_knockback_custom", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_rolling", "libraries/modifiers/modifier_rolling", LUA_MODIFIER_MOTION_BOTH)

function roll:OnSpellStart()
    --do something
    if IsServer() then
        self.caster = self:GetCaster()
        self.caster:AddNewModifier(self.caster, self, "modifier_rolling", {})
        --self.caster.rolled = true
        --display a random number between 1 and 6 rapidly
        --self.caster.picked = false
        Timers:CreateTimer("displayRandomNumbers", {
            useGameTime = true,
            endTime = 0,
            callback = function()
                Notifications:ClearBottomFromAll()
                --*cycle through cm / axe / hero cookies underneath the horse
                --*on pick, jump in place; on landing, stop on a hero
                --*hero face = squares to jump (e.g. cm = 1, axe = 2)
                local randomNumber = math.random(1, 6)
                --local randomNumber = 1
                if self.caster:HasModifier("modifier_rolling") then
                    Notifications:BottomToAll({text=randomNumber, duration=1, style={color="white"}})
                    return 0.2
                else
                    Notifications:BottomToAll({text=randomNumber, duration=5, style={color=GameMode.teamColors[self.caster:GetTeam()]}})
                    --advance
                    return nil
                end
            end
        })
        local pickAbility = self.caster:FindAbilityByName("pick")
        self.caster:SwapAbilities("roll", "pick", false, true)
    end
end

--pick
function pick:OnSpellStart()
    if IsServer() then
        self.caster = self:GetCaster()
        self.caster:RemoveModifierByName("modifier_rolling")
        self.caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
        self:StartCooldown(1000)
    end
end

--[[function roll:Advance(hero, squares)
    Timers:CreateTimer("advance", {
        useGameTime = true,
        endTime = 0,
        callback = function()
            if hero.rolled == false then
                if hero.celebrate > 0 then
                    --continue
                    hero.celebrate = hero.celebrate - 0.06
                    return 0.06
                elseif hero.landed == true and squares ~= 0 then
                --if it goes over the start index (for short, it's 8) then
                    --reset currentYut to 1
                --local nextYutLocation = GameMode:GetHammerEntityLocation(string.format("yut_%s", hero.currentYut + 1))
                --if hero goes over "go" then
                    --add current score to permanent score
                    if hero.currentYut == 8 then
                        hero.currentYut = 0
                    end
                    local nextYutLocation = GameMode.board[hero.currentYut+1]:GetAbsOrigin()
                    local jumpDirection = (nextYutLocation - hero:GetAbsOrigin())
                    local jumpDistance = (nextYutLocation - hero:GetAbsOrigin()):Length()
                    local jumpDuration = 0.5
                    --ApplyHorizontalMotionController() -- nil value: restart computer
                    local knockback = hero:AddNewModifier(
                        hero, -- player source
                        nil, -- ability source
                        "modifier_knockback_custom", -- modifier name
                        {
                            distance = jumpDistance,
                            height = 300,
                            duration = jumpDuration,
                            direction_x = jumpDirection.x,
                            direction_y = jumpDirection.y,
                            IsStun = true,
                        } -- kv
                    )
                    hero.landed = false

                    --another timer that goes off when the hero lands
                    Timers:CreateTimer("callback_jump", {
                        useGameTime = true,
                        endTime = jumpDuration,
                        callback = function()
                            squares = squares - 1
                            hero.currentYut = hero.currentYut + 1
                            --hero scored if he lands on the starting square again
                            --all players start at pad_index 1; if currentYut is 1, it means the player made a full circle
                            if hero.currentYut == 1 then
                                Notifications:BottomToAll({text=string.format("%s scored %s points!", hero.playerName, hero.score), duration=3, style={color="orange"}})
                                hero.permanentScore = hero.permanentScore + hero.score
                                hero.score = 0
                                --set overhead score
                                --error: parameter type mismatch
                                GameMode:ShowScore(hero, hero.score, 4)
                                ParticleManager:DestroyParticle(hero.effect_cast, true)
                                local particle_cast = "particles/hoodwink_sharpshooter_timer_custom.vpcf"
                                hero.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, hero )
                                --second number: time value
                                ParticleManager:SetParticleControl( hero.effect_cast, 1, Vector( 1, hero.score, 3) )
                                ParticleManager:SetParticleControl( hero.effect_cast, 2, Vector( 2, 0, 0 ) )
                                hero.scored = true
                                GameMode:Celebrate(hero)
                                hero.celebrate = 2
                            else
                                --normal square
                                --continue
                            end
                            if squares == 0 then
                                --landed on the "go" square
                                if hero.scored then
                                    --delay rolled by a few seconds
                                    Timers:CreateTimer("rolled", {
                                        useGameTime = true,
                                        endTime = 3,
                                        callback = function()
                                            hero.rolled = true
                                            GameMode.rollCount = GameMode.rollCount + 1
                                            hero.scored = false
                                          return nil
                                        end
                                      })
                                --landed on some other square
                                else
                                    hero.rolled = true
                                    GameMode.rollCount = GameMode.rollCount + 1
                                end
                            else
                                --keep going
                            end
                            hero.landed = true
                            return nil
                        end
                    })
                    return 0.06
                else
                    return 0.06
                end
            else
                return nil
            end
        end
        })
end]]

--advance
--go or stop
--if scored, delay and celebrate