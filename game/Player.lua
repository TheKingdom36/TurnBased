-- Player Class
local Player = {}
Player.__index = Player

function Player:new(col, row)
    local player = setmetatable({}, self)
    player.col = col
    player.row = row
    player.color = {0.2, 0.6, 1.0, 1}
    player.radius = 18
    player.path = nil -- for animation
    player.pathStep = 1
    player.animTime = 0
    player.animSpeed = 0.15 -- seconds per tile
    player.isMoving = false
    return player
end

function Player:setPath(path)
    self.path = path
    self.pathStep = 1
    self.animTime = 0
    self.isMoving = path and #path > 1
end

function Player:update(dt)
    if self.isMoving and self.path then
        self.animTime = self.animTime + dt
        if self.animTime >= self.animSpeed then
            self.animTime = self.animTime - self.animSpeed
            self.pathStep = self.pathStep + 1
            if self.pathStep > #self.path then
                -- Arrived
                self.col = self.path[#self.path].col
                self.row = self.path[#self.path].row
                self.path = nil
                self.isMoving = false
            else
                self.col = self.path[self.pathStep].col
                self.row = self.path[self.pathStep].row
            end
        end
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

return Player 