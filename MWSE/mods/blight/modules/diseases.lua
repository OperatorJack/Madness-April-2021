local common = require("blight.common")

local function getRandomDisease()
    return tes3.getObject(table.choice(common.diseases).id)
end

event.register("blight:TriggerDisease", function(e)
    local disease = e.diseaseId and tes3.getObject(e.diseaseId) or getRandomDisease()

    common.addBlight(e.reference, disease.id)

    if e.displayMessage == true then
        local diseaseName = disease.name
        tes3.messageBox(e.message, diseaseName)
    end

    if (e.callback) then
        e.callback(disease)
    end
end)

event.register("blight:TriggerBlight", function(e)
    -- roll for chance of actually getting blight.
    chance = common.calculateBlightChance(e.reference)
    if e.overrideCheck or common.calculateChanceResult(chance) == false then
        -- Reference avoids catching blight.
        return
    end

    event.trigger("blight:TriggerDisease", {
        reference = e.reference,
        diseaseId = e.diseaseId,
        displayMessage = e.displayMessage,
        message = e.message or "You have contracted %s.",
        callback = e.callback
    })
end)