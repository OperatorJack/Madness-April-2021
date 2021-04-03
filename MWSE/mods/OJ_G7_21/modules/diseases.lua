local common = require("OJ_G7_21.common")

local function getRandomDisease()
    return tes3.getObject(table.choice(common.diseases).id)
end

event.register("OJ_G7_21:TriggerDisease", function(e)
    local disease = e.diseaseId and tes3.getObject(e.diseaseId) or getRandomDisease()
    mwscript.addSpell({
        reference = e.reference, 
        spell = disease
    })

    if (e.displayMessage == true) then
        local diseaseName = disease.name
        tes3.messageBox(string.format(e.message, diseaseName))
    end
end)