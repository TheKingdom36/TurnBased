local Shapes       = require("game.attacks.Shapes")
local EventSystem  = require('game.EventSystem')
local TravelType   = require('game.attacks.TravelType')

local AttackBase   = {}
AttackBase.__index = AttackBase

function AttackBase:cast(x, y, dir, callback)

end

function AttackBase:getRange()
    return self.range or { near = 1, far = 1 }
end

function AttackBase:getImpactShape()
    return self.range or 1
end

function AttackBase:getLaunchShape()
    return self.range or 1
end

function AttackBase:getTravelType()
    return self.range or 1
end

local IceBallAnimation = require('game.attacks.animations.FireBallAnimation')
local IceBall = setmetatable({}, AttackBase)
IceBall.__index = IceBall

function IceBall:new(player, grid)
    local obj = setmetatable({}, self)
    obj.range = { near = 1, far = 3 }
    obj.damage = 8
    obj.mpCost = 8
    obj.name = "Iceball"
    obj.describtion = "Fire a ball of fire in a stright line"
    obj.grid = grid
    obj.player = player
    obj.impactShape = Shapes.SQUARE_3x3
    obj.launchShape = Shapes.FOUR_POINT
    obj.travelType = TravelType.PROJECTILE
    obj.animation = IceBallAnimation:new()
    return obj
end

function IceBall:getImpactShape()
    return self.impactShape
end

function IceBall:getLaunchShape()
    return self.launchShape
end

-- Casts the fireball and triggers animation. Callback runs when animation completes.
function IceBall:cast(x, y, dir, callback)
    EventSystem:emit("log_action", self.player.name .. " attcking with iceball")
    -- Find stop point
    local function findFireballStop(grid, col, row, dir)
        local c, r = col, row
        while true do
            c = c + dir.col
            r = r + dir.row
            local tile = grid:getTile(c, r)
            if not tile or tile.entity then
                return c, r
            end
        end
    end
    local stopCol, stopRow = findFireballStop(self.grid, x, y, dir)
    local sx, sy = self.grid:gridToScreen(x, y)
    local tx, ty = self.grid:gridToScreen(stopCol, stopRow)
    sx = sx + self.grid.tileSize / 2
    sy = sy + self.grid.tileSize / 2
    tx = tx + self.grid.tileSize / 2
    ty = ty + self.grid.tileSize / 2

    local outerSelf = self
    local endOfAnimation = function()
        for index, value in ipairs(self.impactShape) do
            local tile = outerSelf.grid:getTile(stopCol + value.y, stopRow + value.x)
            if tile then
                tile.entity:takeDamage(outerSelf.damage)
            end
        end
        
        self.player:reduceMp(self.mpCost)
        if callback then
            callback()
        end
    end

    self.animation:start(sx, sy, tx, ty, endOfAnimation)
end

function IceBall:isAnimating()
    return self.animation.animating
end

function IceBall:update(dt)
    self.animation:update(dt)
end

function IceBall:draw()
    self.animation:draw()
end

return IceBall
