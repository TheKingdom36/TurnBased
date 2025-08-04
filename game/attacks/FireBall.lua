local AttackBase = {}
AttackBase.__index = AttackBase

function AttackBase:cast()
   
end

function AttackBase:getRange()
    return self.range or 1
end

function AttackBase:getDamage()
    return self.damage or 0
end


local FireBall = setmetatable({}, AttackBase)
FireBall.__index = FireBall

function FireBall:new(player, gird)
    local obj = setmetatable({}, self)
    obj.range = 5
    obj.damage = 10
    obj.name = "Fireball"
    obj.describtion = "Fire a ball of fire in a stright line"
    obj.gird = gird
    obj.animating = false
    return obj
end

function FireBall:cast()
    
end

return FireBall