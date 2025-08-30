---@class FireBallAnimation
---@field animating boolean
---@field animX number
---@field animY number
---@field animTargetX number
---@field animTargetY number
---@field animVX number
---@field animVY number
---@field animSpeed number
---@field animCallback function|nil

local FireBallAnimation = {}
FireBallAnimation.__index = FireBallAnimation

function FireBallAnimation:new()
    local obj = setmetatable({}, self)
    obj.animating = false
    obj.animX = 0
    obj.animY = 0
    obj.animTargetX = 0
    obj.animTargetY = 0
    obj.animVX = 0
    obj.animVY = 0
    obj.animSpeed = 600
    obj.animCallback = nil
    return obj
end

function FireBallAnimation:start(sx, sy, tx, ty, callback)
    self.animX = sx
    self.animY = sy
    self.animTargetX = tx
    self.animTargetY = ty
    local dx = tx - sx
    local dy = ty - sy
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist == 0 then dist = 1 end
    self.animVX = dx / dist * self.animSpeed
    self.animVY = dy / dist * self.animSpeed
    self.animating = true
    self.animCallback = callback
end

function FireBallAnimation:update(dt)
    if self.animating then
        local dx = self.animTargetX - self.animX
        local dy = self.animTargetY - self.animY
        local dist = math.sqrt(dx * dx + dy * dy)
        local step = self.animSpeed * dt
        if dist <= step then
            self.animX = self.animTargetX
            self.animY = self.animTargetY
            self.animating = false
            if self.animCallback then
                self.animCallback()
                self.animCallback = nil
            end
        else
            self.animX = self.animX + self.animVX * dt
            self.animY = self.animY + self.animVY * dt
        end
    end
end

function FireBallAnimation:draw()
    if self.animating then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.circle("fill", self.animX, self.animY, 12)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return FireBallAnimation
