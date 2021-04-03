local common = require("blight.common")

local function onRefCreated(e)
    local object = e.reference.object

    -- ensure the reference is susceptible to blight
    if (object.organic ~= true
        and object.objectType ~= tes3.objectType.npc
        and object.objectType ~= tes3.objectType.creature)
    then
        return
    end

    -- ensure the region is susceptible to blight
    local blightLevel = common.getBlightLevel(e.reference.cell)
    if blightLevel <= 0 then
        return
    end

    -- roll for chance of catching blight disease
    -- blight level 1 -> 1*5 == 5%
    -- blight level 3 -> 3*5 == 15%
    -- blight level 5 -> 5*5 == 25%
    local threshold = blightLevel * 5
    local roll = math.random(100)

    if threshold > roll then
        mwse.log("%s has caught blight disease! (threshold=%s vs roll=%s)", e.reference, threshold, roll)
        event.trigger("blight:TriggerDisease", { reference = e.reference, displayMessage = false })
    end
end
event.register("referenceActivated", onRefCreated)
