local common = require("OJ_G7_21.common")

event.register("cellChanged", function(e)
    if (e.cell.isInterior == true and e.cell.behavesAsExterior ~= true) then
        return
    end

    if (tes3.worldController.weatherController.currentWeather.index ~= tes3.weather.blight) then
        return
    end

    -- Only proc if chance is met.
    if (math.random(0, 100) > 5) then
        return
    end

    common.debug("Player is contracting blight from blightstorm.")

    event.trigger("OJ_G7_21:TriggerDisease", {
        reference = tes3.player,
        displayMessage = true,
        message = "You have contracted %s."
    })
end)