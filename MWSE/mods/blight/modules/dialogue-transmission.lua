local common = require("blight.common")

local function attemptTransmission(reference)
    local chance = common.calculateBlightChance(reference)
    if common.calculateChanceResult(chance) then
        event.trigger("blight:TriggerBlight", {
            reference = reference,
            message = "You have contracted %s from " .. reference.object.name .. "."
        })
    end
end

event.register("activate", function(e)
    if  e.target.objectType ~= tes3.objectType.npc and
        e.target.objectType ~= tes3.objectType.creature then
        return
    end

    local activactor = e.activactor
    local actHasBlight = false

    local target = e.target
    local targetHasBlight = false

    -- Check if activating actor has blight, and check transmission to target if so.
    if common.hasBlight(activactor) == true then
        actHasBlight = true
    end

    -- Check if target has blight, and check transmission to activating actor if so.
    if common.hasBlight(target) == true then
        targetHasBlight = true
    end

    -- Calculated blight status separately so that the first actions would not impact the target's set of actions.
    if actHasBlight == true then
        attemptTransmission(target)
    end
    if targetHasBlight == true then
        attemptTransmission(activactor)
    end
end)