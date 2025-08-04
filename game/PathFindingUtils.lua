-- Dijkstra's algorithm to find all tiles within maxDistance cost
local function computeReachable(grid, startCol, startRow, maxDist)
    local result = {}
    local visited = {}
    local queue = { { col = startCol, row = startRow, cost = 0 } }
    local key = function(c, r) return c .. ',' .. r end
    while #queue > 0 do
        local current = table.remove(queue, 1)
        local k = key(current.col, current.row)
        if not visited[k] then
            visited[k] = true
            local t = grid:getTile(current.col, current.row)
            if t and t.cost < math.huge and current.cost <= maxDist then
                table.insert(result, { col = current.col, row = current.row, cost = current.cost })
                for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
                    local nc, nr = current.col + d[1], current.row + d[2]
                    local nt = grid:getTile(nc, nr)
                    if nt and nt.cost < math.huge then
                        table.insert(queue, { col = nc, row = nr, cost = current.cost + nt.cost })
                    end
                end
            end
        end
    end
    return result
end


return computeReachable
