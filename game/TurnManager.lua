-- Turn Manager
local TurnManager = {}
TurnManager.__index = TurnManager

local Config = require('game.Config')

function TurnManager:new()
    local manager = {
        players = {},
        turnTimer = 0,
        turnDuration = Config.TURN_DURATION,
        turnWarningTime = Config.TURN_WARNING_TIME,
        onTurnEnd = nil,
        onTurnStart = nil
    }
    setmetatable(manager, self)
    return manager
end

function TurnManager:addPlayer(player)
    table.insert(self.players, player)
end

function TurnManager:removePlayer(player)
    for i, p in ipairs(self.players) do
        if p == player then
            table.remove(self.players, i)
            break
        end
    end
end

function TurnManager:getCurrentPlayer()
    if #self.players == 0 then
        return nil
    end
    return self.players[self.currentPlayerIndex]
end

function TurnManager:nextTurn()
    if #self.players == 0 then
        return
    end
    
    -- Call turn end callback
    if self.onTurnEnd then
        self.onTurnEnd(self:getCurrentPlayer())
    end
    
    -- Move to next player
    self.currentPlayerIndex = self.currentPlayerIndex + 1
    if self.currentPlayerIndex > #self.players then
        self.currentPlayerIndex = 1
    end
    
    -- Reset turn timer
    self.turnTimer = 0
    
    -- Call turn start callback
    if self.onTurnStart then
        self.onTurnStart(self:getCurrentPlayer())
    end
end

function TurnManager:update(dt)
    if #self.players == 0 then
        return
    end
    
    self.turnTimer = self.turnTimer + dt
    
    -- Check if turn time is up
    if self.turnTimer >= self.turnDuration then
        self:nextTurn()
    end
end

function TurnManager:getTurnTimeRemaining()
    return math.max(0, self.turnDuration - self.turnTimer)
end

function TurnManager:getTurnProgress()
    return self.turnTimer / self.turnDuration
end

function TurnManager:isTurnWarning()
    return self.turnTimer >= (self.turnDuration - self.turnWarningTime)
end

function TurnManager:setTurnDuration(duration)
    self.turnDuration = duration
end

function TurnManager:setTurnWarningTime(warningTime)
    self.turnWarningTime = warningTime
end

function TurnManager:setTurnEndCallback(callback)
    self.onTurnEnd = callback
end

function TurnManager:setTurnStartCallback(callback)
    self.onTurnStart = callback
end

function TurnManager:reset()
    self.currentPlayerIndex = 1
    self.turnTimer = 0
end

return TurnManager 