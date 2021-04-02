local common = require("OJ_G7_21.common")

local function getRandomDisease()
    return tes3.getObject(common.diseases[math.random(#common.diseases)].id)
end

event.register("OJ_G7_21:TriggerDisease", function(e)
    mwscript.addSpell({
        reference = e.reference, 
        spell = e.diseaseId or getRandomDisease()
    })
end)