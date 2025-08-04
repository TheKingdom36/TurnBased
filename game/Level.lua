local Grid = require('game.Grid')
local Player = require('game.Player')
local UI = require('game.UI')
local TurnManager = require('game.TurnManager')
local LevelState = require('game.LevelState')
local FireBall = require('game.attacks.FireBall')
local computeReachable = require('game.PathFindingUtils')

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local COST_COLORS = {
    [0] = { 0.8, 1.0, 0.8, 1 },        -- Free (light green)
    [1] = { 0.7, 0.7, 1.0, 1 },        -- Normal (light blue)
    [2] = { 1.0, 1.0, 0.5, 1 },        -- Medium (yellow)
    [3] = { 1.0, 0.6, 0.6, 1 },        -- High (red)
    [math.huge] = { 0.2, 0.2, 0.2, 1 } -- Blocked (dark gray)
}

local Level = {}
Level.__index = Level

function Level:new(cols, rows, tileSize)
    local level = setmetatable({}, self)
    level.config = {
        cols = cols or 16,
        rows = rows or 12,
        tileSize = tileSize or 48,
        maxDistance = 8,
        pathLineFadeTime = 2,
    }
    level.config.pathLineFadeSpeed = 1 / level.config.pathLineFadeTime
    level.grid = Grid:new(level.config.cols, level.config.rows, level.config.tileSize)
    level.selection = {
        first = { col = nil, row = nil },
        second = { col = nil, row = nil },
        reachable = {},
        pathLine = nil,
        pathLineAlpha = 0,
        selectedPlayer = nil,
        isAnimating = false,
        selectedAttack = nil
    }

    level.ui = UI:new()

    level.players = {}
    -- Place a player at (2,2)
    local player = Player:new(2, 2)
    table.insert(level.players, player)
    local fireball = FireBall:new(player, level.grid)
    table.insert(player.attacks,fireball)
    local fireball = FireBall:new(player, level.grid)
    table.insert(player.attacks, fireball)
    local fireball = FireBall:new(player, level.grid)
    table.insert(player.attacks, fireball)
    local fireball = FireBall:new(player, level.grid)
    table.insert(player.attacks, fireball)

    -- Create Turn Manager
    level.turnManager = TurnManager:new()
    level.turnManager.onTurnStart = function ()
        for index, value in ipairs(level.players) do
            level.turnManager:addPlayer(value)
            value.state = Player.State.WAITING
            value.actionPointsRemaining = 2
        end

        level.levelState.turnNumber = level.levelState.turnNumber + 1
    end

    -- Create Game State
    level.levelState = LevelState:new()
    level.levelState.currentPlayer = player

    -- Randomize costs
    math.randomseed(os.time())
    for col = 1, level.config.cols do
        for row = 1, level.config.rows do
            local r = math.random()
            local cost
            if r < 0.05 then
                cost = math.huge
            else
                cost = 1
            end
            level.grid:setCost(col, row, cost)
        end
    end
    
    return level
end

function Level:update(dt)

    if #self.turnManager.players == 0  then
        self.turnManager:onTurnStart()
    end


    if self.levelState.currentAttack then
        self.grid:getTile(1,1).color = COST_COLORS[3]
    end


    local mx, my = love.mouse.getPosition()
    self.grid:update(dt, mx, my)
    for _, player in ipairs(self.players) do
        player:update(dt)
        if player.state == Player.State.MOVING then
            self.selection.isAnimating = true
        elseif player.state == Player.State.DONE then
            self.turnManager:removePlayer(player)
        end
    end
    -- If no player is moving, allow input
    local anyMoving = false
    for _, player in ipairs(self.players) do
        if player.state == Player.State.MOVING then
            anyMoving = true
            break
        end
    end
    self.selection.isAnimating = anyMoving
    if self.selection.pathLineAlpha > 0 then
        self.selection.pathLineAlpha = math.max(0, self.selection.pathLineAlpha - self.config.pathLineFadeSpeed * dt)
    end

    self.ui:update(dt, self.levelState)
end

function Level:playerAt(col, row)
    for _, player in ipairs(self.players) do
        if player.col == col and player.row == row then
            return player
        end
    end
    return nil
end

function Level:resetSelection()
    self.selection.selectedPlayer = nil
    self.selection.first.col, self.selection.first.row = nil, nil
    self.selection.second.col, self.selection.second.row = nil, nil
    self.selection.reachable = {}
    self.selection.pathLine = nil
    self.selection.pathLineAlpha = 0
end

function Level:mousepressed(x, y, button)

    self.ui:mousepressed(x,y,button)

    if button == 1 and not self.selection.isAnimating then
        local offsetX, offsetY = self.grid:getGridOffset()
        local col = math.floor((x - offsetX) / self.config.tileSize) + 1
        local row = math.floor((y - offsetY) / self.config.tileSize) + 1
        if col >= 1 and col <= self.config.cols and row >= 1 and row <= self.config.rows then
            local player = self:playerAt(col, row)
            if not self.selection.selectedPlayer then
                -- Only allow selection if a player is present
                if player then
                    self.selection.selectedPlayer = player
                    self.selection.first.col, self.selection.first.row = col, row
                    self.selection.reachable = computeReachable(self.grid, col, row, self.config.maxDistance)
                    self.selection.second.col, self.selection.second.row = nil, nil
                    self.selection.pathLine = nil
                    self.selection.pathLineAlpha = 0
                end
            elseif not self.selection.second.col then
                -- Only allow move if clicked tile is in range and not blocked
                local inRange = false
                for _, t in ipairs(self.selection.reachable) do
                    if t.col == col and t.row == row then
                        inRange = true
                        break
                    end
                end
                if inRange and not (col == self.selection.first.col and row == self.selection.first.row) then
                    self.selection.second.col, self.selection.second.row = col, row
                    local path = self.grid:findPath(self.selection.first.col, self.selection.first.row,
                        self.selection.second.col, self.selection.second.row)
                    if path then
                        self.selection.selectedPlayer:setMove(path)
                        self.selection.isAnimating = true
                        self.selection.pathLine = path
                        self.selection.pathLineAlpha = 1
                    end
                else
                    self:resetSelection()
                end
            else
                self:resetSelection()
            end
        end
    end
end

function Level:keypressed(key)
    if self.selection.isAnimating then return end
    if key == "up" then
        self.config.maxDistance = self.config.maxDistance + 1
    elseif key == "down" then
        self.config.maxDistance = math.max(1, self.config.maxDistance - 1)
    elseif tonumber(key) then
        self.config.maxDistance = tonumber(key)
    end
    if self.selection.selectedPlayer then
        self.selection.first.col = self.selection.selectedPlayer.col
        self.selection.first.row = self.selection.selectedPlayer.row
        self.selection.reachable = computeReachable(self.grid, self.selection.first.col, self.selection.first.row,
            self.config.maxDistance)
        self.selection.second.col, self.selection.second.row = nil, nil
        self.selection.pathLine = nil
        self.selection.pathLineAlpha = 0
    end
end

function Level:draw()
    local offsetX, offsetY = self.grid:getGridOffset()
    

    self.grid:draw()

    for _, tile in ipairs(self.selection.reachable) do
        local x, y = self.grid:gridToScreen(tile.col, tile.row)
        love.graphics.setColor(0.2, 1, 0.2, 0.4)
        love.graphics.rectangle("fill", x, y, self.config.tileSize, self.config.tileSize)
    end
    if self.selection.first.col and self.selection.first.row then
        local x, y = self.grid:gridToScreen(self.selection.first.col, self.selection.first.row)
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.rectangle("fill", x, y, self.config.tileSize, self.config.tileSize)
    end
    if self.selection.second.col and self.selection.second.row then
        local x, y = self.grid:gridToScreen(self.selection.second.col, self.selection.second.row)
        love.graphics.setColor(1, 0.5, 0, 0.5)
        love.graphics.rectangle("fill", x, y, self.config.tileSize, self.config.tileSize)
    end
    if self.selection.pathLine and self.selection.pathLineAlpha > 0 then
        love.graphics.setColor(1, 0.2, 0.2, 0.7 * self.selection.pathLineAlpha)
        for i = 1, #self.selection.pathLine - 1 do
            local a = self.selection.pathLine[i]
            local b = self.selection.pathLine[i + 1]
            local ax, ay = self.grid:gridToScreen(a.col, a.row)
            local bx, by = self.grid:gridToScreen(b.col, b.row)
            ax = ax + self.config.tileSize / 2
            ay = ay + self.config.tileSize / 2
            bx = bx + self.config.tileSize / 2
            by = by + self.config.tileSize / 2
            love.graphics.setLineWidth(6)
            love.graphics.line(ax, ay, bx, by)
        end
        love.graphics.setLineWidth(1)
    end
    for col = 1, self.config.cols do
        for row = 1, self.config.rows do
            local t = self.grid:getTile(col, row)
            local x, y = self.grid:gridToScreen(col, row)
            if t.hovered then
                love.graphics.setColor(0.2, 0.8, 1, 0.4)
                love.graphics.rectangle("fill", x, y, self.config.tileSize, self.config.tileSize)
            end
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
            love.graphics.rectangle("line", x, y, self.config.tileSize, self.config.tileSize)
        end
    end
    -- Draw players
    for _, player in ipairs(self.players) do
        player:draw(self.config.tileSize, offsetX, offsetY)
    end
    -- UI box and help text (keep at top left and bottom)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 10, 10, 180, 32, 6, 6)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 10, 10, 180, 32, 6, 6)
    love.graphics.print("Max Distance: " .. tostring(self.config.maxDistance), 18, 18)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Click a player, then a tile in range to move. Use UP/DOWN or 1-9 to set max distance.", 10,
    love.graphics.getHeight() - 32)

    -- need to initate the game state object 
    self.ui:draw(self.levelState, self.turnManager)
end

return Level
