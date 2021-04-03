local common = require("blight.common")

local gear = {
    {id="daedric_god_helm"}
}

local function getRandomGear()
    return table.choice(gear).id
end

