---@class Entity
---@field col integer
---@field row integer
---@field name string
---@field stats table
---@field color table|nil
local Entity = {}
Entity.__index = Entity

function Entity:new(col, row, color, name, stats)
    local obj = setmetatable({}, self)
    obj.col = col
    obj.row = row
    obj.name = name
    obj.stats = stats
    obj.color = color or { 1, 1, 1, 1 }
    return obj
end

function Entity:takeDamage(amount)
    -- Default: do nothing. Override in subclasses.
end

return Entity
