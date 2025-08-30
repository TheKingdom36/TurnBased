---@class Enemy
---@field col integer The column position of the enemy on the grid
---@field row integer The row position of the enemy on the grid
---@field color table|nil Optional color for rendering
---@field type string|nil Optional enemy type
---@field health number|nil Optional health value
---@field update fun(self:Enemy,dt:number)
---@field draw fun(self:Enemy,tileSize:number,offsetX:number,offsetY:number)
---@class Enemy
local Enemy = {}
-- Enemy.lua

local EventSystem = require('game.EventSystem')


local Entity = require('game.entities.Entity')
local Enemy = setmetatable({}, { __index = Entity })
Enemy.__index = Enemy

function Enemy:new(col, row, stats, effects)
    local obj = Entity.new(self, col, row, { 0, 1, 0, 1 })
    obj.name = "rodger"
    obj.stats = {
        health = (stats and stats.health) or 100,
        attackDamage = (stats and stats.attackDamage) or 10,
        movement = (stats and stats.movement) or 1
    }
    obj.effects = effects or setmetatable({}, { __index = Enemy.Effects })
    setmetatable(obj, self)
    return obj
end

function Enemy:draw(tileSize, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local x = offsetX + (self.col - 1) * tileSize
    local y = offsetY + (self.row - 1) * tileSize
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, tileSize, tileSize)
end

function Enemy:takeDamage(amount)
    EventSystem:emit("log_action", self.name .. " taken " .. amount .. " damage.")
    self.stats.health = self.stats.health - amount
    if self.effects.onHit then
        self.effects.onHit(self, amount)
    end
end

function Enemy:move()
    -- Implement movement logic here
    if self.effects.onMove then
        self.effects.onMove(self)
    end
end

function Enemy:attack(target)
    if target and target.takeDamage then
        target:takeDamage(self.stats.attackDamage)
    end
end

return Enemy
