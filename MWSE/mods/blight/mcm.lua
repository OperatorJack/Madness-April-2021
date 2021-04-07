local config = require("blight.config")

local function createGeneralCategory(page)
    local category = page:createCategory{
        label = "General Settings"
    }

    -- Create option to capture debug mode.
    category:createOnOffButton{
        label = "Enable Debug Mode",
        description = "Use this option to enable debug mode.",
        variable = mwse.mcm.createTableVariable{
            id = "debugMode",
            table = config
        }
    }

    category:createSlider{
        label = "Base Blight Transmission Chance",
        description = "[DESC]",
        min = 0,
        max = 100,
        step = 1,
        jump = 5,
        variable = mwse.mcm.createTableVariable{
            id = "baseBlightTransmissionChance",
            table = config
        }
    }

    return category
end


local function createTransmissionCategory(page)
    local category = page:createCategory{
        label = "Transmission Settings"
    }

    category:createOnOffButton{
        label = "Enable Active Transmission",
        description = "[DESC]",
        variable = mwse.mcm.createTableVariable{
            id = "enableActiveTransmission",
            table = config
        }
    }

    category:createOnOffButton{
        label = "Enable Passive Transmission",
        description = "[DESC]",
        variable = mwse.mcm.createTableVariable{
            id = "enablePassiveTransmission",
            table = config
        }
    }

    category:createOnOffButton{
        label = "Enable Blightsorm Transmission",
        description = "[DESC]",
        variable = mwse.mcm.createTableVariable{
            id = "enableBlightstormTransmission",
            table = config
        }
    }


    return category
end


local function createProtectiveGearCategory(page)
    local category = page:createCategory{
        label = "Protective Gear Settings"
    }

    category:createOnOffButton{
        label = "Enable Protective Gear",
        description = "[DESC]",
        variable = mwse.mcm.createTableVariable{
            id = "enableProtectiveGear",
            table = config
        }
    }

    category:createOnOffButton{
        label = "Enable NPC Protective Gear Distribution",
        description = "[DESC]",
        variable = mwse.mcm.createTableVariable{
            id = "enableNpcProtectiveGearDistribution",
            table = config
        }
    }

    return category
end


local function createVisualEffectsCategory(page)
    local category = page:createCategory{
        label = "Visual Effects Settings"
    }

    category:createOnOffButton{
        label = "Enable Blight Decals",
        description = "[DESC]",
        variable = mwse.mcm.createTableVariable{
            id = "enableDecalMapping",
            table = config
        }
    }

    category:createOnOffButton{
        label = "Enable Blight Tooltips",
        description = "[DESC]",
        variable = mwse.mcm.createTableVariable{
            id = "enableTooltip",
            table = config
        }
    }

    return category
end

-- Handle mod config menu.
local template = mwse.mcm.createTemplate("The Blight")
template:saveOnClose("The-Blight", config)

local page = template:createSideBarPage{
    label = "Settings Sidebar",
    description = "Hover over a setting to learn more about it."
}

createGeneralCategory(page)
createTransmissionCategory(page)
createProtectiveGearCategory(page)
createVisualEffectsCategory(page)

mwse.mcm.register(template)