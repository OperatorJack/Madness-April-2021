local common = require("blight.common")

local gear = {
    ["TB_a_ClothMask1"] = "TB_a_ClothMask1",
    ["TB_a_ClothMask2"] = "TB_a_ClothMask2",
    ["TB_a_ClothMask3"] = "TB_a_ClothMask3",
}

local function iterNPCs(func)
    for _, cell in pairs(tes3.getActiveCells()) do
        for reference in cell:iterateReferences() do
            if (reference.object.objectType == tes3.objectType.npc and reference.mobile) then
                func(reference)
            end
        end
    end
end

local function equipGear()
    iterNPCs(function(ref)
        for _, stack in pairs(ref.object.inventory) do
            local object = stack.object
            if gear[object.id] then
                ref.mobile:equip({item = object.id})
                common.debug("Equipping '%s' on '%s'.", object.id, ref)
                return
            end
        end
    end)
end

local function unequipGear()
    iterNPCs(function(ref)
        for _, stack in pairs(ref.object.equipment) do
            local object = stack.object
            if gear[object.id] then
                ref.mobile:unequip({item = object.id})
                common.debug("Unequipping '%s' on '%s'.", object.id, ref)
                return
            end
        end
    end)
end

-- Handle equipping and unequipping.
event.register("weatherTransitionStarted", function(e)
    if e.to == tes3.weather.blight or e.to == tes3.weather.ash then
        equipGear()
    elseif e.from == tes3.weather.blight or e.from == tes3.weather.ash then
        unequipGear()
    end
end)
event.register("cellChanged", function(e)
    -- Only worry about protective gear in possible transmission areas.
    if common.getBlightLevel(tes3.player.cell) <= 0 then
        return
    end

    if tes3.worldController.weatherController.currentWeather.index == tes3.weather.blight or
        tes3.worldController.weatherController.currentWeather.index == tes3.weather.ash then
        equipGear()
    else
        unequipGear()
    end
end)

-- Ditribute gear.
event.register("referenceActivated", function(e)
    local reference = e.reference

    -- Only NPCs need some gear.
    if reference.object.objectType ~= tes3.objectType.npc then
        return
    end

    -- Only NPCs who have not been processed should be considered.
    if reference.data.blight and reference.data.blight.protectiveGear == true then
        return
    end

    -- Only worry about protective gear in possible transmission areas.
    if common.getBlightLevel(reference.cell) <= 0 then
        return
    end

    -- Only NPCs who do not have helmets should get gear. Cache equipment value for later.
    local equipmentValue = 0
     for _, stack in pairs(reference.object.equipment) do
        local object = stack.object
		if object.objectType == tes3.objectType.armor then
            equipmentValue = equipmentValue + object.value

            if object.slot == tes3.armorSlot.helmet then
                return
            end
		end
	end

    local chance = 60

    -- Rich people are more likely to wear protective gear.
    chance = chance + equipmentValue / 100

    if common.calculateChanceResult(chance) then
        -- Winner, winner! NPC gets some gear.
        local item = table.choice(gear)

        mwscript.addItem({
            reference = reference,
            item = item
        })

        common.debug("Added '%s' to '%s'.", item, reference)
    end


    reference.data.blight = reference.data.blight or {}
    reference.data.blight.protectiveGear = true
end)
