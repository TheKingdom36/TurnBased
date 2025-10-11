local LevelState = {}
-- Game State Manager
local LevelState = {}
LevelState.__index = LevelState

local Config = require('game.Config')

-- Enum for turn phases
Phase = {
    TURN_START = "turn_start",
    TURN_END = "turn_end",
    PLAYER_TURN = "player_turn",
    ENEMY_TURN = "enemy_turn"
}

---@class LevelSelection
---@field first table
---@field second table
---@field reachable table[]
---@field pathLine table[]|nil
---@field pathLineAlpha number
---@field selectedPlayer Player|nil
---@field isAnimating boolean
---@field selectedAttack any
---@field attackReachable table[]
---@field attackLine table[]|nil
---@field attackLineAlpha number

---@class LevelState
---@field grid Grid
---@field players Player[]
---@field enemies Enemy[]
---@field selection table
---@field currentPlayer Player
---@field currentAttack any
---@field gamePhase string
---@field turnNumber integer
---@field Phase table
local LevelState = {}

function LevelState:new()
    local state = {
        grid = nil,   -- The game grid
        players = {}, -- List of player objects
        enemies = {}, -- List of enemy objects
        entities = {}, -- List of all entities that are not players or enemies
        ---@type LevelSelection
        selection = {
            first = { col = nil, row = nil },
            second = { col = nil, row = nil },
            reachable = {},
            pathLine = nil,
            pathLineAlpha = 0,
            selectedPlayer = nil,
            isAnimating = false,
            selectedAttack = nil,
            attackReachable = {},
            attackLine = nil,
            attackLineAlpha = 2,
            hoveredEntity = nil
        },
        currentPlayer = nil,
        currentAttack = nil,
        gamePhase = Phase.TURN_START,
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
