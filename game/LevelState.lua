-- Game State Manager
local LevelState = {}
LevelState.__index = LevelState

local Config = require('game.Config')

-- Enum for turn phases
LevelState.Phase = {
    TURN_START = "turn_start",
    TURN_END = "turn_end",
    PLAYER_TURN = "player_turn",
    ENEMY_TURN = "enemy_turn"
}

function LevelState:new()
    local state = {
        currentPlayer = nil,
        currentAttack = nil,
        gamePhase = LevelState.Phase.TURN_START,
        turnNumber = 1,
    }
    setmetatable(state, self)
    return state
end

function LevelState:update(dt)
    self.gameTime = self.gameTime + dt
end

function LevelState:setCurrentPlayer(player)
    self.currentPlayer = player
end

function LevelState:getCurrentPlayer()
    return self.currentPlayer
end

function LevelState:nextTurn()
    self.turnNumber = self.turnNumber + 1
end

function LevelState:getTurnNumber()
    return self.turnNumber
end

function LevelState:setGamePhase(phase)
    self.gamePhase = phase
end

function LevelState:getGamePhase()
    return self.gamePhase
end

function LevelState:reset()
    self.currentPlayer = nil
    self.gamePhase = "playing"
    self.turnNumber = 1
end

return LevelState 