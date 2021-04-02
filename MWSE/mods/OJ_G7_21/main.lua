
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



require("OJ_G7_21.modules.diseases")
require("OJ_G7_21.modules.traps")

local function initialized()
    print("[" .. modname .. ": INFO] Initialized")
end
event.register("initialized", initialized)

local function loadTestCell(e)
    if e.isAltDown and tes3.mobilePlayer then
        tes3.messageBox("Test function ran!")
    end
end
event.register("keyDown", loadTestCell, {filter=tes3.scanCode.d})
