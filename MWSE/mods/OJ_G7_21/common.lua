local modname = "OJ_G7"
local common = {}

local debugMode = true
local prepend = '[' .. modname .. ': DEBUG] '

function common.debug(str, ...)
    if (debugMode == true) then
        str = prepend .. str
        mwse.log(str, ...)
        tes3.messageBox(str, ...)
    end
end

function common.getKeyFromValueFunc(tbl, func)
    for key, value in pairs(tbl) do
        if (func(value) == true) then return key end
    end
    return nil
end



common.diseases = {
    --Empty, loaded at runtime.
}

common.traps = {
    -- Constantly checks proximity to player and triggers trap.
    proximity = {
        ["OJ_G7_21_TrapProxStaticTest"] = {
            animate = true,
            proximity = 256,
            diseaseId = "VV20_DiseaseTrapTest3"
        }
    },
    -- Triggers trap on collision with player.
    collision = {
        ["OJ_G7_21_TrapCollStaticTest"] = {
            animate = true
        }
    }
}


return common