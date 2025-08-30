---@class Player
---@field col integer The column position of the player on the grid
---@field row integer The row position of the player on the grid
---@field stats table Player stats (health, maxHealth, state, etc)
---@field name string|nil Optional player name
---@field color table|nil Optional color for rendering
---@field sprite any|nil Optional sprite for rendering
---@field State table Player state enum
---@field update fun(self:Player,dt:number)
---@field draw fun(self:Player,tileSize:number,offsetX:number,offsetY:number)
---@field setMove fun(self:Player,path:table,row:integer,col:integer)
---@class Player

local Entity = require('game.entities.Enemy')
local EventSystem = require('game.EventSystem')
local Player = setmetatable({}, { __index = Entity })
Player.__index = Player

-- Enum for player states
Player.State = {
    MOVING = "moving",
    WAITING = "waiting",
    ATTACKING = "attacking",
    DONE = "done",
    DEAD = "dead"
}


function Player:new(col, row)
    local player = Entity.new(self, col, row, { 0.2, 0.6, 1.0, 1 })
    player.radius = 18
    player.path = nil -- for animation
    player.pathStep = 1
    player.animTime = 0
    player.animSpeed = 0.15 -- seconds per tile
    player.stats = {
        actionPointsRemaining = 2,
        health = 100,
        maxHealth = 100,
        state = Player.State.WAITING
        -- Add more stats here as needed (mana, etc.)
    }
    player.attacks = {}
    player.name = "default"
    setmetatable(player, self)
    return player
end

function Player:setMove(path, col, row)
    if path and #path > 1 and self.stats.state ~= Player.State.MOVING then
        self.stats.state = Player.State.MOVING
        self.path = path
        self.pathStep = 1
        self.animTime = 0
        self.stats.actionPointsRemaining = self.stats.actionPointsRemaining - 1
        self.row = row
        self.col = col
        EventSystem:emit("log_action", "I am moving")
    end
end

function Player:update(dt)
    if self.stats.state == Player.State.MOVING and self.path then
        self:doMove(dt)
    elseif self.stats.state == Player.State.WAITING and self.stats.actionPointsRemaining <= 0 then
        self.stats.state = Player.State.DONE
    end
end

function Player:draw(tileSize, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local x = offsetX + (self.col - 0.5) * tileSize
    local y = offsetY + (self.row - 0.5) * tileSize
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", x, y, self.radius)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", x, y, self.radius)
    love.graphics.setLineWidth(1)
end

function Player:doMove(dt)
    self.animTime = self.animTime + dt
    if self.animTime >= self.animSpeed then
        self.animTime = self.animTime - self.animSpeed
        self.pathStep = self.pathStep + 1
        if self.pathStep > #self.path then
            -- Arrived
            self.col = self.path[#self.path].col
            self.row = self.path[#self.path].row
            self.path = nil
            self.stats.state = Player.State.WAITING
        else
            self.col = self.path[self.pathStep].col
            self.row = self.path[self.pathStep].row
        end
    end
end

return Player
