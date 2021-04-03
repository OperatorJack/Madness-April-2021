local modname = "Blight"
local common = {}

local debugMode = true
local prepend = '[' .. modname .. ': DEBUG] '

common.getBlightLevel = require("blight.modules.getBlightLevel")

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

function common.iterBlightDiseases(reference)
    return coroutine.wrap(function()
        for _, spell in pairs(reference.object.spells.iterator) do
            if common.diseases[spell.id] then
                coroutine.yield(spell)
            end
        end
    end)
end

function common.hasBlight(reference)
    for spell in common.iterBlightDiseases(reference) do
        return true
    end
    return false
end

function common.calculateBlightChance(reference)
    local chance = 10 --Base Chance

    -- Modify based on helmet
    for _, stack in pairs(reference.object.equipment) do
        local object = stack.object
		if object.objectType == tes3.objectType.armor then
            local parts = 0
            if object.slot == tes3.armorSlot.helmet then
                for _, part in pairs(object.parts) do
                    if (part.type == tes3.activeBodyPart.hair) then
                        common.debug("Calculating Blight Chance: Hair coverage found.")
                        parts = parts + 1
                    elseif (part.type == tes3.activeBodyPart.head) then
                        common.debug("Calculating Blight Chance: Head coverage found.")
                        parts = parts + 3
                    elseif (part.type == tes3.activeBodyPart.neck) then
                        common.debug("Calculating Blight Chance: Neck coverage found.")
                        parts = parts + 1
                    end
                end
            end

            chance = chance - parts
		end
	end

    return chance
end

common.diseases = {
    --Empty, loaded at runtime.
}

common.traps = {
    -- Constantly checks proximity to player and triggers trap.
    proximity = {
        ["blight_TrapProxStaticTest"] = {
            animate = true,
            proximity = 256,
            diseaseId = "VV20_DiseaseTrapTest3"
        }
    },
    -- Triggers trap on collision with player.
    collision = {
        ["blight_TrapCollStaticTest"] = {
            animate = true
        }
    }
}

return common
