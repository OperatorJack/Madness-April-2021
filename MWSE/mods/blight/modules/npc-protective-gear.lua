local common = require("blight.common")

local gear = {
    {id="TB_a_ClothMask1"},
    {id="TB_a_ClothMask2"},
    {id="TB_a_ClothMask3"},
}

local function getRandomGear()
    return table.choice(gear).id
end

