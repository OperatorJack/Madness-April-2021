local common = require("blight.common")

-- Possible can be resisted, buttt.....
event.register("spellResist", function(e)
    if  e.target == tes3.player and 
        tes3.player.data.blight.blightProgession and 
        e.effectInstance.effectId == tes3.effect.cureBlightDisease then
        tes3.player.data.blight.blightProgession = {}
    end
end)

local function onLoaded()
    timer.start({
        duration = 10,
        iterations = -1,
        callback = function()
            tes3.player.data.blight = tes3.player.data.blight or {}
            tes3.player.data.blight.blightProgession = tes3.player.data.blight.blightProgession or {}
            local progressions = tes3.player.data.blight.blightProgession

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
                        common.debug("Processing progression for " .. spell.name)

                        local progression = progressions[spell.id]
                        progression.days = tes3.worldController.daysPassed.value - progression.lastDay
                        progression.lastDay = tes3.worldController.daysPassed.value

                        common.debug(json.encode(progression, { indent = true }))

                        if (progression.days >= progression.nextProgession) then
                            common.debug("Progressing for " .. spell.name)

                            progression.progression = progression.progression + 1
                            progression.nextProgession = math.random(2, 8)

                            local progressionSpellId = spell.id .. "_P"
                            local progressionSpell = tes3.getObject(progressionSpellId) or tes3spell.create(progressionSpellId, "Infectious " .. spell.name)

                            common.debug("Made ID " .. progressionSpellId)

                            progressionSpell.name = "Infectious " .. spell.name

                            for i=1, #spell.effects do
                                local effect = progressionSpell.effects[i]
                                local newEffect = spell.effects[i]

                                effect.id = newEffect.id
                                effect.rangeType = newEffect.range
                                effect.min = 5 * progression.progression
                                effect.max = 5 * progression.progression
                                effect.duration = newEffect.duration
                                effect.radius = newEffect.radius
                                effect.skill = newEffect.skill
                                effect.attribute = newEffect.attribute
                            end

                            progressionSpell.castType = tes3.spellType.Blight

                            mwscript.addSpell({
                                reference = tes3.player,
                                spell = progressionSpell
                            })

                            tes3.messageBox(string.format("Your %s worsens.", spell.name))
                        end
                    end
                end
            end
        end
    })
end
event.register("loaded", onLoaded)