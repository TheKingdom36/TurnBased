-- Grid System for Prototyping
local Grid = {}
Grid.__index = Grid

local function defaultTile()
    return {
        cost = 1,         -- Movement cost
        entity = nil,     -- Player/enemy reference
        hovered = false,  -- Is mouse over this tile?
        col = 1,
        row = 1
    }
end

function Grid:new(cols, rows, tileSize)
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

function Grid:screenToGrid(x, y)
    local col = math.floor(x / self.tileSize) + 1
    local row = math.floor(y / self.tileSize) + 1
    if col >= 1 and col <= self.cols and row >= 1 and row <= self.rows then
        return col, row
    end
    return nil, nil
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
    else
        self.hoveredCol = nil
        self.hoveredRow = nil
    end
end

function Grid:draw()
    for col = 1, self.cols do
        for row = 1, self.rows do
            local t = self.tiles[col][row]
            local x = (col - 1) * self.tileSize
            local y = (row - 1) * self.tileSize
            -- Color by cost
            local base = 0.2 + 0.2 * (t.cost - 1)
            love.graphics.setColor(base, base, base, 1)
            love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)
            -- Hover glow
            if t.hovered then
                love.graphics.setColor(1, 0.8, 1, 0.4)
                love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)
            end
            -- Entity
            if t.entity then
                t.entity:draw(x + self.tileSize/2, y + self.tileSize/2, self.tileSize)
            end
            -- Border
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
            love.graphics.rectangle("line", x, y, self.tileSize, self.tileSize)
        end
    end
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
    table.insert(open, {col = startCol, row = startRow})
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
            local path = {{col = endCol, row = endRow}}
            while cameFrom[ckey] do
                local prev = cameFrom[ckey]
                table.insert(path, 1, {col = prev.col, row = prev.row})
                ckey = key(prev.col, prev.row)
            end
            return path
        end
        closed[ckey] = true
        -- Neighbors
        for _, d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
            local nc, nr = current.col + d[1], current.row + d[2]
            local nkey = key(nc, nr)
            local tile = self:getTile(nc, nr)
            if tile and not closed[nkey] and not tile.entity then
                local cost = tile.cost or 1
                local tentativeG = (gScore[ckey] or math.huge) + cost
                if not gScore[nkey] or tentativeG < gScore[nkey] then
                    cameFrom[nkey] = {col = current.col, row = current.row}
                    gScore[nkey] = tentativeG
                    fScore[nkey] = tentativeG + heuristic(nc, nr, endCol, endRow)
                    local inOpen = false
                    for _, o in ipairs(open) do
                        if o.col == nc and o.row == nr then inOpen = true break end
                    end
                    if not inOpen then table.insert(open, {col = nc, row = nr}) end
                end
            end
        end
    end
    return nil -- No path
end

return Grid 