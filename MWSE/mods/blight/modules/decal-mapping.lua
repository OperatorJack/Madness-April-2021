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
event.register("initialized", function()
    for k, v in pairs(decalTextures) do
        decalTextures[k] = niSourceTexture.createFromPath(k)
    end
end)

local function traverse(roots)
    local function iter(nodes)
        for i, node in ipairs(nodes or roots) do
            if node then
                coroutine.yield(node)
                if node.children then
                    iter(node.children)
                end
            end
        end
    end
    return coroutine.wrap(iter)
end

local function iterBlightDecals(texturingProperty)
    if texturingProperty == nil then return end

    local function iter()
        for i, map in ipairs(texturingProperty.maps) do
            local tex = map and map.texture
            local id = tex and tex.fileName
            if decalTextures[id] then
                coroutine.yield(i, map)
            end
        end
    end

    return coroutine.wrap(iter)
end

local function hasBlightDecal(texturingProperty)
    return iterBlightDecals(texturingProperty)()
end

local function addBlightDecal(sceneNode)
    for node in traverse{sceneNode} do
        local success, texturingProperty, alphaProperty = pcall(function()
            return node:getProperty(0x4), node:getProperty(0x0)
        end)
        if success and texturingProperty and not alphaProperty then
            if texturingProperty.canAddDecal and not hasBlightDecal(texturingProperty) then
                local texture = table.choice(decalTextures)
                texturingProperty:addDecalMap(texture)
                common.debug("Added blight decal to %s", node.name)
            end
        end
    end
end

local function removeBlightDecal(sceneNode)
    for node in traverse{sceneNode} do
        local texturingProperty = node:getProperty(0x4)
        for i in iterBlightDecals(texturingProperty) do
            texturingProperty:removeDecalMap(i)
        end
    end
end

event.register("bodyPartAssigned", function(e)
    -- ignore covered slots
    if e.object ~= nil then return end

    -- ignore blacklisted slots
    if bodyPartBlacklist[e.index] then return end

    -- ignore non-blighted NPCs
    if not common.hasBlight(e.reference) then return end

    -- the bodypart scene node is available on the next frame
    timer.delayOneFrame(function()
        local sceneNode = e.manager:getActiveBodyPartNode(tes3.activeBodyPartLayer.base, e.index)
        addBlightDecal(sceneNode)
    end)
end)

event.register("referenceActivated", function(e)
    if e.reference.object.organic then
        if common.hasBlight(e.reference) then
            addBlightDecal(e.reference.sceneNode)
        end
    end
end)

event.register("loaded", function(e)
    tes3.player:updateEquipment()
end)

event.register("blight:AddedBlight", function(e)
    if (e.reference.object.organic) then
        addBlightDecal(e.reference.sceneNode)
    else
        e.reference:updateEquipment()
    end
end)
event.register("blight:RemovedBlight", function(e)
    if (e.reference.object.organic) then
        removeBlightDecal(e.reference.sceneNode)
    else
        e.reference:updateEquipment()
    end
end)
