-- Game State Manager
local GameState = {}
GameState.__index = GameState

local Config = require('game.Config')

function GameState:new()
    local state = {
        currentPlayer = nil,
        gamePhase = "playing", -- "playing", "paused", "gameOver"
        turnNumber = 1,
        gameTime = 0,
        score = {player1 = 0, player2 = 0},
        winner = nil
    }
    setmetatable(state, self)
    return state
end

function GameState:update(dt)
    self.gameTime = self.gameTime + dt
end

function GameState:setCurrentPlayer(player)
    self.currentPlayer = player
end

function GameState:getCurrentPlayer()
    return self.currentPlayer
end

function GameState:nextTurn()
    self.turnNumber = self.turnNumber + 1
end

function GameState:getTurnNumber()
    return self.turnNumber
end

function GameState:setGamePhase(phase)
    self.gamePhase = phase
end

function GameState:getGamePhase()
    return self.gamePhase
end

function GameState:addScore(playerName, points)
    if self.score[playerName] then
        self.score[playerName] = self.score[playerName] + points
    end
end

function GameState:getScore()
    return self.score
end

function GameState:setWinner(player)
    self.winner = player
    self.gamePhase = "gameOver"
end

function GameState:getWinner()
    return self.winner
end

function GameState:reset()
    self.currentPlayer = nil
    self.gamePhase = "playing"
    self.turnNumber = 1
    self.gameTime = 0
    self.score = {player1 = 0, player2 = 0}
    self.winner = nil
end

return GameState 