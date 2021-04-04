local common = require("blight.common")

local bodyPartBlacklist = {
    [tes3.activeBodyPart.groin] = true,
    [tes3.activeBodyPart.hair] = true,
    [tes3.activeBodyPart.leftPauldron] = true,
    [tes3.activeBodyPart.rightPauldron] = true,
    [tes3.activeBodyPart.shield] = true,
    [tes3.activeBodyPart.weapon] = true,
}

local decalTextures = {
    ["textures\\blight\\decal_blight1.dds"] = true,
    ["textures\\blight\\decal_blight2.dds"] = true,
}

--
-- Functions
--

local function iterBlightDecals(texturingProperty)
    local function iter()
        for i, map in ipairs(texturingProperty.maps) do
            local texture = map and map.texture
            local fileName = texture and texture.fileName
            if decalTextures[fileName] then
                coroutine.yield(i, map)
            end
        end
    end
    return coroutine.wrap(iter)
end

local function hasBlightDecal(texturingProperty)
    return iterBlightDecals(texturingProperty)() ~= nil
end

local function addBlightDecal(sceneNode)
    for node in common.traverse{sceneNode} do
        local alphaProperty = node:getProperty(0x0)
        local texturingProperty = node:getProperty(0x4)
        if texturingProperty and not alphaProperty then
            if texturingProperty.canAddDecal then
                if not hasBlightDecal(texturingProperty) then
                    local texturingProperty = node:detachProperty(0x4):clone()
                    texturingProperty:addDecalMap(table.choice(decalTextures))
                    node:attachProperty(texturingProperty)
                    node:updateProperties()
                    common.debug("Added blight decal to %s", node.name)
                end
            end
        end
    end
end

local function removeBlightDecal(sceneNode)
    for node in common.traverse{sceneNode} do
        local texturingProperty = node:getProperty(0x4)
        if texturingProperty then
            for i in iterBlightDecals(texturingProperty) do
                texturingProperty:removeDecalMap(i)
                common.debug("Removed blight decal from %s", node.name)
            end
        end
    end
end

--
-- Events
--

event.register("initialized", function()
    for k, v in pairs(decalTextures) do
        decalTextures[k] = niSourceTexture.createFromPath(k)
    end
end)

event.register("loaded", function(e)
    tes3.player:updateEquipment()
end)

event.register("bodyPartAssigned", function(e)
    -- ignore covered slots
    if e.object ~= nil then return end

    -- ignore blacklisted slots
    if bodyPartBlacklist[e.index] then return end

    -- the bodypart scene node is available on the next frame
    timer.delayOneFrame(function()
        -- local sceneNode = e.manager:getActiveBodyPartNode(tes3.activeBodyPartLayer.base, e.index)
        local activeBodyPart = e.manager:getActiveBodyPart(tes3.activeBodyPartLayer.base, e.index)
        local sceneNode = activeBodyPart.node
        if sceneNode then
            if common.hasBlight(e.reference) then
                addBlightDecal(sceneNode)
            else
                removeBlightDecal(sceneNode)
            end
        end
    end)
end)

event.register("referenceActivated", function(e)
    if e.reference.object.organic then
        if common.hasBlight(e.reference) then
            addBlightDecal(e.reference.sceneNode)
        end
    end
end)

event.register("blight:AddedBlight", function(e)
    if e.reference.object.organic then
        addBlightDecal(e.reference.sceneNode)
    else
        e.reference:updateEquipment()
    end
end)

event.register("blight:RemovedBlight", function(e)
    removeBlightDecal(e.reference.sceneNode)
end)
