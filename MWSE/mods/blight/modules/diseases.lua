local common = require("blight.common")

local function getRandomDisease()
    return tes3.getObject(table.choice(common.diseases).id)
end

event.register("blight:TriggerDisease", function(e)
    local disease = e.diseaseId and tes3.getObject(e.diseaseId) or getRandomDisease()
    mwscript.addSpell({
        reference = e.reference, 
        spell = disease
    })

    if e.displayMessage == true then
        local diseaseName = disease.name
        tes3.messageBox(e.message, diseaseName)
    end
end)

event.register("blight:TriggerBlight", function(e)
    event.trigger("blight:TriggerDisease", {
        reference = e.reference,
        diseaseId = e.diseaseId,
        displayMessage = e.displayMessage,
        message = e.message or "You have contracted %s."
    })
end)