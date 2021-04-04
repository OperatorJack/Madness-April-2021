local blightedCells = {}

local function getBlightedCells()
    for i, cell in pairs(tes3.dataHandler.nonDynamicData.cells) do
        if cell.region and cell.region.weatherChanceBlight > 0 then
            table.insert(blightedCells, {cell.gridX, cell.gridY})
        end
    end
end
event.register("initialized", getBlightedCells)

local function distance2d(p1, p2)
    local dx = p1[1] - p2[1]
    local dy = p1[2] - p2[2]
    return math.sqrt(dx * dx + dy * dy)
end

-- Get the "Blight Level" of the given cell.
-- Levels range 0 to 5. With 5 being the most-blighted areas.
-- The levels are calculated from the distance to the closest blighted region.
local function getBlightLevel(cell)
    if not (cell and cell.region) then
        return 0
    elseif cell.region.weatherChanceBlight > 0 then
        return 5
    end

    local min_dist = 5

    local current_grid = {cell.gridX, cell.gridY}
    for _, blight_grid in ipairs(blightedCells) do
        local dist = math.floor(distance2d(current_grid, blight_grid))
        if dist < min_dist then
            min_dist = dist
        end
    end

    return 5 - min_dist
end

return getBlightLevel
