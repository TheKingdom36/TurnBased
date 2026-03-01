---@class Grid
-- Grid System for Prototyping
local Grid = {}
Grid.__index = Grid

local COST_COLORS = {
    [0] = { 0.8, 1.0, 0.8, 1 },        -- Free (light green)
    [1] = { 0.7, 0.7, 1.0, 1 },        -- Normal (light blue)
    [2] = { 1.0, 1.0, 0.5, 1 },        -- Medium (yellow)
    [3] = { 1.0, 0.6, 0.6, 1 },        -- High (red)
    [math.huge] = { 0.2, 0.2, 0.2, 1 } -- Blocked (dark gray)
}

local function defaultTile()
    return {
        cost = 1,        -- Movement cost
        entity = nil,    -- Player/enemy reference
        hovered = false, -- Is mouse over this tile?
        col = 1,
        row = 1,
        color = nil,
        onHover = nil
    }
end

function Grid:new(cols, rows, tileSize)
    ---@class Grid
    local g = setmetatable({}, self)
    g.cols = cols
    g.rows = rows
    g.tileSize = tileSize
    g.tiles = {}
    for col = 1, cols do
        g.tiles[col] = {}
        for row = 1, rows do
            local t = defaultTile()
            t.col = col
            t.row = row
            g.tiles[col][row] = t
        end
    end
    g.hoveredCol = nil
    g.hoveredRow = nil
    return g
end

function Grid:getTile(col, row)
    if self.tiles[col] and self.tiles[col][row] then
        return self.tiles[col][row]
    end
    return nil
end

function Grid:setCost(col, row, cost)
    local t = self:getTile(col, row)
    if t then t.cost = cost end
end

function Grid:setEntity(col, row, entity)
    local t = self:getTile(col, row)
    if t then t.entity = entity end
end

function Grid:update(dt, mouseX, mouseY)
    -- Clear previous hover
    if self.hoveredCol and self.hoveredRow then
        local prev = self:getTile(self.hoveredCol, self.hoveredRow)
        if prev then prev.hovered = false end
    end
    -- Set new hover
    local col, row = self:screenToGrid(mouseX, mouseY)
    if col and row then
        local t = self:getTile(col, row)
        if t then t.hovered = true end
        self.hoveredCol = col
        self.hoveredRow = row
        if t.onHover then
            t.onHover()
        end
    else
        self.hoveredCol = nil
        self.hoveredRow = nil
    end
end

function Grid:draw()
    local offsetX, offsetY, gridW, gridH = self:getGridOffset()
    -- Draw border
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", offsetX - 3, offsetY - 3, gridW + 6, gridH + 6, 8, 8)
    love.graphics.setLineWidth(1)


    -- Draw grid tiles
    for col = 1, self.cols do
        for row = 1, self.rows do
            local t = self:getTile(col, row)
            local x, y = self:gridToScreen(col, row)
            local color = t.color or COST_COLORS[t.cost] or { 1, 1, 1, 1 }
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)
            -- Draw coordinates on top
            -- love.graphics.setColor(0, 0, 0, 1)
            -- love.graphics.printf(string.format("%d,%d", col, row), x, y + self.tileSize / 2 - 6, self.tileSize, "center")
            t.color = nil
        end
    end
end

function Grid:gridToScreen(col, row)
    local offsetX, offsetY = self:getGridOffset()
    local x = offsetX + (col - 1) * self.tileSize
    local y = offsetY + (self.rows - row) * self.tileSize
    return x, y
end

function Grid:screenToGrid(x, y)
    local offsetX, offsetY = self:getGridOffset()
    local col = math.floor((x - offsetX) / self.tileSize) + 1
    local row = self.rows - math.floor((y - offsetY) / self.tileSize)
    if col >= 1 and col <= self.cols and row >= 1 and row <= self.rows then
        return col, row
    end
    return nil, nil
end

function Grid:getGridOffset()
    local winW = love.graphics.getWidth()
    local winH = love.graphics.getHeight()
    local gridW = self.cols * self.tileSize
    local gridH = self.rows * self.tileSize
    local offsetX = (winW - gridW) / 2
    local offsetY = (winH - gridH) / 2
    return offsetX, offsetY, gridW, gridH
end

-- A* pathfinding with cost
function Grid:findPath(startCol, startRow, endCol, endRow)
    local function key(c, r) return c .. "," .. r end
    local open = {}
    local closed = {}
    local cameFrom = {}
    local gScore = {}
    local fScore = {}
    local function heuristic(a, b, c, d)
        return math.abs(a - c) + math.abs(b - d)
    end
    local startK = key(startCol, startRow)
    gScore[startK] = 0
    fScore[startK] = heuristic(startCol, startRow, endCol, endRow)
    table.insert(open, { col = startCol, row = startRow })
    while #open > 0 do
        -- Find node with lowest fScore
        local bestIdx = 1
        for i = 2, #open do
            local k1 = key(open[bestIdx].col, open[bestIdx].row)
            local k2 = key(open[i].col, open[i].row)
            if (fScore[k2] or math.huge) < (fScore[k1] or math.huge) then
                bestIdx = i
            end
        end
        local current = table.remove(open, bestIdx)
        local ckey = key(current.col, current.row)
        if current.col == endCol and current.row == endRow then
            -- Reconstruct path
            local path = { { col = endCol, row = endRow } }
            while cameFrom[ckey] do
                local prev = cameFrom[ckey]
                table.insert(path, 1, { col = prev.col, row = prev.row })
                ckey = key(prev.col, prev.row)
            end
            return path
        end
        closed[ckey] = true
        -- Neighbors
        for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
            local nc, nr = current.col + d[1], current.row + d[2]
            local nkey = key(nc, nr)
            local tile = self:getTile(nc, nr)
            if tile and not closed[nkey] and not tile.entity then
                local cost = tile.cost or 1
                local tentativeG = (gScore[ckey] or math.huge) + cost
                if not gScore[nkey] or tentativeG < gScore[nkey] then
                    cameFrom[nkey] = { col = current.col, row = current.row }
                    gScore[nkey] = tentativeG
                    fScore[nkey] = tentativeG + heuristic(nc, nr, endCol, endRow)
                    local inOpen = false
                    for _, o in ipairs(open) do
                        if o.col == nc and o.row == nr then
                            inOpen = true
                            break
                        end
                    end
                    if not inOpen then table.insert(open, { col = nc, row = nr }) end
                end
            end
        end
    end
    return nil -- No path
end

return Grid
