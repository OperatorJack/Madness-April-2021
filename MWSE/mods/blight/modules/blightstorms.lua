local common = require("blight.common")



event.register("cellChanged", function(e)
    if (e.cell.isInterior == true and e.cell.behavesAsExterior ~= true) then
        tes3.setGlobal("TB_IsInExternalCell", 0)
        return
    end

    if (tes3.worldController.weatherController.currentWeather.index ~= tes3.weather.Blight) then
        return
    end

    -- Update Cell Position global.
    tes3.setGlobal("TB_IsInExternalCell", 1)

    -- Only proc if chance is met.
    if common.calculateChanceResult(common.calculateBlightChance(tes3.player)) == false then
        return
    end

    common.debug("Player is contracting blight from blightstorm.")

    event.trigger("blight:TriggerBlight", {
        reference = tes3.player
    })
end)