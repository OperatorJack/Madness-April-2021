local common = require("blight.common")

local function attemptTransmission(reference, isTransmitterPlayer, transmitterName)
    local chance = common.calculateBlightChance(reference)
    local message = "You have transmitted %s to " .. reference.object.name .. "." 
    if (isTransmitterPlayer == false) then
        message = "You have contracted %s from " .. transmitterName .. "."
    end

  --  if common.calculateChanceResult(chance) then
        event.trigger("blight:TriggerBlight", {
            reference = reference,
            message = message
        })
  --  end
end

event.register("activate", function(e)
    if  e.target.object.objectType ~= tes3.objectType.npc and
        e.target.object.objectType ~= tes3.objectType.creature then
        return
    end

    local activator = e.activator
    local actHasBlight = false

    local target = e.target
    local targetHasBlight = false

    -- Check if activating actor has blight, and check transmission to target if so.
    if common.hasBlight(activator) == true then
        actHasBlight = true
    end

    -- Check if target has blight, and check transmission to activating actor if so.
    if common.hasBlight(target) == true then
        targetHasBlight = true
    end

    -- Calculated blight status separately so that the first actions would not impact the target's set of actions.
    if actHasBlight == true then
        attemptTransmission(target, activator == tes3.player, activator.object.name)
    end
    if targetHasBlight == true then
        attemptTransmission(activator, target == tes3.player, target.object.name)
    end
end)