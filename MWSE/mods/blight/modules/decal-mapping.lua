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
    ["textures\\tb\\decal_blight1.dds"] = true,
    ["textures\\tb\\decal_blight2.dds"] = true,
}

--
-- Functions
--

local function iterBlightDecals(texturingProperty)
    return coroutine.wrap(function()
        for i, map in ipairs(texturingProperty.maps) do
            local texture = map and map.texture
            local fileName = texture and texture.fileName
            if decalTextures[fileName] then
                coroutine.yield(i, map)
            end
        end
    end)
end

local function hasBlightDecal(texturingProperty)
    return iterBlightDecals(texturingProperty)() ~= nil
end

local function addBlightDecal(sceneNode)
    for node in common.traverse{sceneNode} do
        if node:isInstanceOfType(tes3.niType.NiTriShape) then
            -- only interested in textured shapes without alpha
            -- decals ontop of alpha masked areas will look bad
            local alphaProperty = node:getProperty(0x0)
            local texturingProperty = node:getProperty(0x4)
            if texturingProperty and not alphaProperty then
                -- also ignore properties with full decal slots
                if texturingProperty.canAddDecal then
                    -- also ignore if already have blight decal
                    if not hasBlightDecal(texturingProperty) then
                        -- we have to detach/clone the property
                        -- because it could have multiple users
                        local texturingProperty = node:detachProperty(0x4):clone()
                        -- add the new decal map then attach it
                        texturingProperty:addDecalMap(table.choice(decalTextures))
                        node:attachProperty(texturingProperty)
                        node:updateProperties()
                        common.debug("Added blight decal to '%s'.", node.name)
                    end
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
                common.debug("Removed blight decal from '%s'.", node.name)
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
        local sceneNode = e.manager:getActiveBodyPart(tes3.activeBodyPartLayer.base, e.index).node
        if sceneNode then
            if common.hasBlight(e.reference) then
                common.debug("Blighted bodypart '%s' was assigned for '%s'.", e.bodyPart, e.reference)
                addBlightDecal(sceneNode)
            else
                removeBlightDecal(sceneNode) -- clear decals inherited when cloning
            end
        end
    end)
end)

event.register("referenceActivated", function(e)
    if e.reference.object.organic then
        if common.hasBlight(e.reference) then
            common.debug("Previously-blighted reference '%s' was loaded.", e.reference)
            addBlightDecal(e.reference.sceneNode)
        else
            removeBlightDecal(e.reference.sceneNode) -- clear decals inherited when cloning
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
