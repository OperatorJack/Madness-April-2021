local common = require("OJ_G7_21.common")

local function isTrapTriggered(trap)
    return trap.data.OJ_G7_21 ~= nil and trap.data.OJ_G7_21.triggered == true
end

local function setTrapTriggered(trap)
    trap.data.OJ_G7_21 = trap.data.OJ_G7_21 or {}
    trap.data.OJ_G7_21.triggered = true
end


-- Trap Controller for non-event based traps.
local activeProximityTraps = {}

local function onReferenceActivated(e)
    if common.traps.proximity[e.reference.object.id] then
        activeProximityTraps[e.reference] = true
        common.debug("Activated Proximity trap: %s", e.reference)
    end
end
event.register("referenceActivated", onReferenceActivated)

local function onReferenceDeactivated(e)
    activeProximityTraps[e.reference] = nil
end
event.register("referenceDeactivated", onReferenceDeactivated)

-- Proximity Traps
local function proximityTrapCallback(trap)
    local config = common.traps.proximity[trap.object.id]

    if (config and
        config.proximity and
        isTrapTriggered(trap) == false and
        tes3.player.position:distance(trap.position) <= config.proximity
    ) then
        common.debug("Processing Proximity trap: %s", trap)

        -- Trigger disease
        event.trigger("OJ_G7_21:TriggerDisease", {
            reference = tes3.player,
            diseaseId = config.diseaseId
        })

        setTrapTriggered(trap)
        activeProximityTraps[trap] = nil

        if (config.animate) then
            -- Animate the trap somehow.
            tes3.messageBox("Animation!")
        end
    end
end


-- Collision Traps
-- TODO: Unregister collision events when leaving the cell.
local function onCollision(e)
    local trap = e.target
    if (e.mobile == tes3.mobilePlayer and
        trap and
        common.traps.collision[trap.object.id] and
        isTrapTriggered(trap) == false
    ) then
        common.debug("Processing Proximity trap: %s", trap)

        local config = common.traps.collision[trap.object.id]

        -- Trigger disease
        event.trigger("OJ_G7_21:TriggerDisease", {
            reference = tes3.player,
            diseaseId = config.diseaseId
        })

        setTrapTriggered(trap)

        if (config.animate) then
            -- Animate the trap somehow.
            tes3.messageBox("Animation!")
        end
    end
end
event.register("collision", onCollision)


local function trapTimerCallback()
    for trapReference in pairs(activeProximityTraps) do
        proximityTrapCallback(trapReference)
    end
end
event.register("loaded", function()
    timer.start{iterations = -1, duration = 0.15, callback=trapTimerCallback}
end)
