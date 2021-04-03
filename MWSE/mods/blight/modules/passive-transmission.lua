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

    -- Check for expired blight diseases on reference, remove if expired.
    if  e.reference.data.blight and
        e.reference.data.blight.passiveTransmission then
        for spellId, day in pairs(e.reference.data.blight.passiveTransmission) do
            if day <= tes3.worldController.daysPassed.value then
                common.removeBlight(e.reference, spellId)
                e.reference.data.blight.passiveTransmission[spellId] = nil
            end
        end
    end
 

    -- roll for chance of catching blight disease
    -- blight level 1 -> 1*5 == 5%
    -- blight level 3 -> 3*5 == 15%
    -- blight level 5 -> 5*5 == 25%
    local threshold = blightLevel * 5
    local roll = math.random(100)

    if threshold > roll then
        mwse.log("%s has caught blight disease! (threshold=%s vs roll=%s)", e.reference, threshold, roll)
        event.trigger("blight:TriggerDisease", { 
            reference = e.reference, 
            displayMessage = false, 
            callback = function (spell)
                -- Setup information to remove disease later.
                e.reference.data.blight = e.reference.data.blight or {}
                e.reference.data.blight.passiveTransmission = e.reference.data.blight.passiveTransmission or {}
                e.reference.data.blight.passiveTransmission[spell.id] = tes3.worldController.daysPassed.value + math.random(2,8)
            end
        })
    end
end
event.register("referenceActivated", onRefCreated)
