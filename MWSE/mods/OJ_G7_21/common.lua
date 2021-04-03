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