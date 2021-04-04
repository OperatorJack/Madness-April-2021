
local modname = "Blight"

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

local common = require("blight.common")
require("blight.modules.diseases")
require("blight.modules.traps")
require("blight.modules.blightstorms")
require("blight.modules.blight-progression")
require("blight.modules.active-transmission")
require("blight.modules.passive-transmission")
require("blight.modules.decal-mapping")
require("blight.modules.npc-protective-gear")
require("blight.modules.blighted-tooltips")

local function initialized()
    for object in tes3.iterateObjects({tes3.objectType.spell}) do
        if (object.castType == tes3.spellType.blight) then
            if object.id ~= "corprus" then
                common.diseases[object.id] = {
                    id = object.id
                }
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
