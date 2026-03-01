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
        grid = nil,    -- The game grid
        players = {},  -- List of player objects
        enemies = {},  -- List of enemy objects
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
        selectedBones = {},
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

function LevelState:__tostring()
    local playerCount = #self.players
    local enemyCount = #self.enemies
    local currentPlayerName = self.currentPlayer and self.currentPlayer.name or "None"

    local attacksList = "None"
    if self.currentPlayer and self.currentPlayer.attacks then
        local attackNames = {}
        for i, attack in ipairs(self.currentPlayer.attacks) do
            table.insert(attackNames, attack.name or "Attack" .. i)
        end
        attacksList = #attackNames > 0 and table.concat(attackNames, ", ") or "None"
    end

    local bonesList = "None"
    if self.currentPlayer and self.currentPlayer.bones then
        local boneNames = {}
        for i, bone in ipairs(self.currentPlayer.bones) do
            table.insert(boneNames, bone.name or "Bone" .. i)
        end
        bonesList = #boneNames > 0 and table.concat(boneNames, ", ") or "None"
    end

    local selectedBonesList = "None"
    if self.selectedBones and #self.selectedBones > 0 then
        local selectedBoneNames = {}
        for i, bone in ipairs(self.selectedBones) do
            table.insert(selectedBoneNames, bone.name or "Bone" .. i)
        end
        selectedBonesList = table.concat(selectedBoneNames, ", ")
    end

    return string.format(
        "LevelState { Turn: %d, Phase: %s, Players: %d, Enemies: %d, Current: %s, Attacks: [%s], Bones: [%s], Selected: [%s] }",
        self.turnNumber,
        self.gamePhase,
        playerCount,
        enemyCount,
        currentPlayerName,
        attacksList,
        bonesList,
        selectedBonesList
    )
end

return LevelState
