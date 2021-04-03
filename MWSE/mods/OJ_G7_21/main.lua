
local modname = "OJ_G7"

-- Check MWSE Build --
if (mwse.buildDate == nil) or (mwse.buildDate < 20201010) then
    local function warning()
        tes3.messageBox(
            "[" .. modname .. " ERROR] Your MWSE is out of date!"
            .. " You will need to update to a more recent version to use this mod."
        )
    end
    event.register("initialized", warning)
    event.register("loaded", warning)
    return
end
----------------------------

local common = require("OJ_G7_21.common")
require("OJ_G7_21.modules.diseases")
require("OJ_G7_21.modules.traps")
require("OJ_G7_21.modules.blightstorms")

local function initialized()
    for object in tes3.iterateObjects({tes3.objectType.spell}) do
        if (object.castType == tes3.spellType.blight) then
            if object.id ~= "corprus" then
                table.insert(common.diseases, {
                    id = object.id
                })
            end
        end
    end

    print("[" .. modname .. ": INFO] Initialized")
end
event.register("initialized", initialized)

local function debugKey(e)
    if e.isAltDown and tes3.mobilePlayer then
        common.debug("Blight Level: " .. common.getBlightLevel(tes3.player.cell))
        common.debug("Blight Chance: " .. common.calculateBlightChance(tes3.player))
    end
end
event.register("keyDown", debugKey, {filter=tes3.scanCode.z})
