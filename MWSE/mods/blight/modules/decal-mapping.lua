local common = require("blight.common")

local function traverseNIF(roots)
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

local texture
local function onInitialized()
    texture = niSourceTexture.createFromPath("textures\\blight\\decal_blight1.dds")
end
event.register("initialized", onInitialized)


local managedReferences = {}

local function onObjectInvalidated(e)
    managedReferences[e.object] = nil
end
event.register("objectInvalidated", onObjectInvalidated)

local function addBlightDecal(e)
    local reference = e.reference

    for node in traverseNIF({ reference.sceneNode }) do
        local success, texturingProperty, alphaProperty = pcall(function() return node:getProperty(0x4), node:getProperty(0x0) end)
        if (success and texturingProperty and not alphaProperty) then
            if (texturingProperty.canAddDecal) then
                local map, index = texturingProperty:addDecalMap(texture)
                if (map) then
                    common.debug("Added decal to '%s' (%s) at index %d", node.name, node.RTTI.name, index)
                    managedReferences[reference] = true 
                end
            end
        end
    end
end

local function removeBlightDecal(e)
    local reference = e.reference


end


event.register("referenceActivated", function(e)
    local object = e.reference.object

    -- ensure the reference is susceptible to blight
    if (object.organic ~= true
        and object.objectType ~= tes3.objectType.npc
        and object.objectType ~= tes3.objectType.creature)
    then
        return
    end

    -- if actor has blight, decal map em.
    if common.hasBlight(e.reference) then
        addBlightDecal(e)
    end
end)


event.register("load", function(e)
    if common.hasBlight(tes3.player) then
        addBlightDecal(tes3.player)
        addBlightDecal(tes3.mobilePlayer.firstPersonReference)
    end
end)

event.register("blight:AddedBlight", addBlightDecal)
event.register("blight:RemovedBlight", removeBlightDecal)