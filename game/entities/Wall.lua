---@class Wall
---@field col integer
---@field row integer
---@field color table

local Entity = require('game.entities.Entity')
local Wall = setmetatable({}, { __index = Entity })
Wall.__index = Wall

function Wall:new(col, row)
    local obj = Entity.new(self, col, row, { 0.3, 0.3, 0.3, 1 })
    setmetatable(obj, self)
    return obj
end

function Wall:draw(tileSize, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local x = offsetX + (self.col - 1) * tileSize
    local y = offsetY + (self.row - 1) * tileSize
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", x, y, tileSize, tileSize)
end

return Wall
