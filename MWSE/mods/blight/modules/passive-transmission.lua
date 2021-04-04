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

    -- get reference blight data
    local data = e.reference.data
    data.blight = data.blight or {}

    -- restrict passive transmission to once per day
    local daysPassed = tes3.worldController.daysPassed.value
    if data.blight.lastEncounter ~= daysPassed then
        data.blight.lastEncounter = daysPassed
    else
        common.debug("%s already encountered today (passive transmission disabled)", e.reference)
        return
    end

    -- Check for expired blight diseases on reference, remove if expired.
    if data.blight.passiveTransmission then
        for spellId, day in pairs(data.blight.passiveTransmission) do
            if day <= daysPassed then
                common.debug("%s recovered from %s blight disease!", e.reference, spellId)
                common.removeBlight(e.reference, spellId)
                data.blight.passiveTransmission[spellId] = nil
            end
        end
    end

    -- roll for chance of catching blight disease
    -- blight level 1 -> 1*4 == 4%
    -- blight level 3 -> 3*4 == 12%
    -- blight level 5 -> 5*4 == 20%
    local threshold = blightLevel * 4
    local roll = math.random(100)

    if threshold > roll then
        common.debug("%s has caught blight disease! (threshold=%s vs roll=%s)", e.reference, threshold, roll)
        event.trigger("blight:TriggerDisease", {
            reference = e.reference,
            displayMessage = false,
            callback = function (spell)
                -- Setup information to remove disease later.
                data.blight = data.blight or {}
                data.blight.passiveTransmission = data.blight.passiveTransmission or {}
                data.blight.passiveTransmission[spell.id] = daysPassed + math.random(2,8)
            end
        })
    end
end
event.register("referenceActivated", onRefCreated)
