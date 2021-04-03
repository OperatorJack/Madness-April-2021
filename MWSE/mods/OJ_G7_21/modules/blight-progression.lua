local common = require("OJ_G7_21.common")

-- Possible can be resisted, buttt.....
event.register("spellResist", function(e)
    if  e.target == tes3.player and 
        tes3.player.data.OJ_G7_21.blightProgession and 
        e.effectInstance.effectId == tes3.effect.cureBlightDisease then
        tes3.player.data.OJ_G7_21.blightProgession = {}
    end
end)

local function onLoaded()
    timer.start({
        duration = 10,
        iterations = -1,
        callback = function()
            tes3.player.data.OJ_G7_21 = tes3.player.data.OJ_G7_21 or {}
            tes3.player.data.OJ_G7_21.blightProgession = tes3.player.data.OJ_G7_21.blightProgession or {}
            local progressions = tes3.player.data.OJ_G7_21.blightProgession

            for spell in tes3.iterate(tes3.player.object.spells.iterator) do
                if (common.diseases[spell.id]) then
                    if not progressions[spell.id] then
                        progressions[spell.id] = {
                            progression = 0,
                            lastDay = tes3.worldController.daysPassed.value,
                            days = 0,
                            nextProgession = math.random(2,3)
                        }

                        common.debug("Registered progression for " .. spell.name)
                    else
                        local progression = progressions[spell.id]
                        progression.days = tes3.worldController.daysPassed.value - progression.lastDay
                        progression.lastDay = tes3.worldController.daysPassed.value
                        if (progression.days >= progression.nextProgession) then
                            progression.progression = progression.progression + 1
                            progression.nextProgession = math.random(2, 8)

                            local progressionSpellId = spell.id .. "_P"
                            local progressionSpell = tes3.getObject or tes3spell.create(progressionSpellId, "Infectious " .. spell.name)

                            progressionSpell.effects = spell.effects
                            for _, effect in pairs(progressionSpell.effects) do
                                effect.min = 5 * progression.progression
                                effect.max = 5 * progression.progression
                            end

                            progressionSpell.castType = tes3.spellType.blight

                            if not tes3.player.object.spells:contains(progressionSpell) then
                                mwscript.addSpell({
                                    reference = tes3.player,
                                    spell = progressionSpell
                                })
                            end

                            tes3.messageBox(string.format("Your %s worsens.", progressionSpell.name))
                        end
                    end
                end
            end
        end
    })
end
event.register("loaded", onLoaded)