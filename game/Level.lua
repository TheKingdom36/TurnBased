local Player = require('game.Player')
local UI = require('game.UI')
local TurnManager = require('game.TurnManager')
local computeReachable = require('game.PathFindingUtils')
local EventSystem = require('game.EventSystem')

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

---@param levelState LevelState
function Level:create(levelState, config)
    -- Anonymous function to find and delete an entity by name
    local findAndDeleteByName = function(name)
        for i, player in ipairs(levelState.players or {}) do
            if player.name == name then
                table.remove(levelState.players, i)
                levelState.grid:getTile(player.col, player.row).entity = nil
                return player
            end
        end
        for i, enemy in ipairs(levelState.enemies or {}) do
            if enemy.name == name then
                table.remove(levelState.enemies, i)
                levelState.grid:getTile(enemy.col, enemy.row).entity = nil
                return enemy
            end
        end
        return nil
    end

    local level = setmetatable({}, Level)
    level.levelState = levelState
    level.config = config
    level.config.pathLineFadeSpeed = 1 / level.config.pathLineFadeTime

    level.turnManager = TurnManager:new()
    table.insert(level.turnManager.players, levelState.players)
    table.insert(level.turnManager, levelState.players)


    EventSystem:register("death", findAndDeleteByName)

    level.turnManager.onTurnStart = function()
        for index, player in ipairs(levelState.players) do
            level.levelState.grid:getTile(player.col, player.row).entity = player
        end

        for index, enemy in ipairs(levelState.enemies) do
            level.levelState.grid:getTile(enemy.col, enemy.row).entity = enemy
        end
    end

    for index, player in ipairs(levelState.players) do
        level.levelState.grid:getTile(player.col, player.row).entity = player
    end

    for index, enemy in ipairs(levelState.enemies) do
        level.levelState.grid:getTile(enemy.col, enemy.row).entity = enemy
    end

    level.ui = UI:new()

    return level
end

function Level:update(dt)
    if #self.turnManager.players == 0 then
        self.turnManager:onTurnStart()
    end

    if self.levelState.currentAttack then
        self.levelState.currentAttack:update(dt)
    end

    self:handleCurrentSelectedAttack()

    -- Draw enemies
    for _, enemy in ipairs(self.levelState.enemies or {}) do
        enemy:update(dt)
    end

    local mx, my = love.mouse.getPosition()
    self.levelState.grid:update(dt, mx, my)
    for _, player in ipairs(self.levelState.players or {}) do
        player:update(dt)
        if player.stats.state == Player.State.MOVING then
            self.levelState.selection.isAnimating = true
        elseif player.stats.state == Player.State.DONE then
            self.turnManager:removePlayer(player)
        end
    end
    -- If no player is moving, allow input
    local anyMoving = false
    for _, player in ipairs(self.levelState.players or {}) do
        if player.stats.state == Player.State.MOVING then
            anyMoving = true
            break
        end
    end
    self.levelState.selection.isAnimating = anyMoving
    if self.levelState.selection.pathLineAlpha > 0 then
        self.levelState.selection.pathLineAlpha = math.max(0,
            self.levelState.selection.pathLineAlpha - self.config.pathLineFadeSpeed * dt)
    end

    local gx, gy = self.levelState.grid:screenToGrid(mx, my)
    if gx ~= nil and gy ~= nil and self:isInBounds(gx, gy) then
        local entity = self:entityAt(gx,gy)
        if entity then
            self.levelState.selection.hoveredEntity = entity
        else
            self.levelState.selection.hoveredEntity = nil
        end
    else 
        self.levelState.selection.hoveredEntity = nil
    end


    self.ui:update(dt, self.levelState)
end

function Level:playerAt(col, row)
    for _, player in ipairs(self.levelState.players or {}) do
        if player.col == col and player.row == row then
            return player
        end
    end
    return nil
end

function Level:entityAt(col, row)
    for _, enemy in ipairs(self.levelState.enemies or {}) do
        if enemy.col == col and enemy.row == row then
            return enemy
        end
    end

    for _, entity in ipairs(self.levelState.entities or {}) do
        if entity.col == col and entity.row == row then
            return entity
        end
    end

    for _, player in ipairs(self.levelState.players or {}) do
        if player.col == col and player.row == row then
            return player
        end
    end

    return nil
end

function Level:resetSelection()
    local sel = self.levelState.selection
    sel.selectedPlayer = nil
    sel.first.col, sel.first.row = nil, nil
    sel.second.col, sel.second.row = nil, nil
    sel.reachable = {}
    sel.pathLine = nil
    sel.pathLineAlpha = 0
end

function Level:resetAttackSelection()
    self.levelState.currentAttack = nil
    self.levelState.selection.attackReachable = {}
    self.levelState.selection.attackLine = {}
end

function Level:mousepressed(x, y, button)
    self.ui:mousepressed(x, y, button)

    if button == 1 and not self.levelState.selection.isAnimating then
        local offsetX, offsetY = self.levelState.grid:getGridOffset()
        local col = math.floor((x - offsetX) / self.config.tileSize) + 1
        local row = 14 - math.floor((y - offsetY) / self.config.tileSize)
        if col >= 1 and col <= self.config.cols and row >= 1 and row <= self.config.rows then
            self:handlePlayerSelection(col, row)
            self:handleAttackSelection(row, col)
        else
            self:resetSelection()
        end
    end
end

function Level:keypressed(key)
    if self.levelState.selection.isAnimating then return end
    if key == "up" then
        self.config.maxDistance = self.config.maxDistance + 1
    elseif key == "down" then
        self.config.maxDistance = math.max(1, self.config.maxDistance - 1)
    elseif tonumber(key) then
        self.config.maxDistance = tonumber(key)
    end
    local sel = self.levelState.selection
    if sel.selectedPlayer then
        sel.first.col = sel.selectedPlayer.col
        sel.first.row = sel.selectedPlayer.row
        sel.reachable = computeReachable(self.levelState.grid, sel.first.col, sel.first.row,
            self.config.maxDistance)
        sel.second.col, sel.second.row = nil, nil
        sel.pathLine = nil
        sel.pathLineAlpha = 0
    end
end

function Level:draw()
    local offsetX, offsetY = self.levelState.grid:getGridOffset()

    self.levelState.grid:draw()

    -- Print mouse selection col and row
    local mx, my = love.mouse.getPosition()
    local col, row = self.levelState.grid:screenToGrid(mx, my)
    if col and row and love.mouse.isDown(1) then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("Mouse Grid: %d, %d", col, row), 20, 10)
    end

    if self.levelState.currentAttack then
        self.levelState.currentAttack:draw()
    end

    local sel = self.levelState.selection
    for _, tile in ipairs(sel.reachable) do
        local x, y = self.levelState.grid:gridToScreen(tile.col, tile.row)
        love.graphics.setColor(0.2, 1, 0.2, 0.4)
        love.graphics.rectangle("fill", x, y, self.config.tileSize, self.config.tileSize)
    end
    if sel.first.col and sel.first.row then
        local x, y = self.levelState.grid:gridToScreen(sel.first.col, sel.first.row)
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.rectangle("fill", x, y, self.config.tileSize, self.config.tileSize)
    end
    if sel.second.col and sel.second.row then
        local x, y = self.levelState.grid:gridToScreen(sel.second.col, sel.second.row)
        love.graphics.setColor(1, 0.5, 0, 0.5)
        love.graphics.rectangle("fill", x, y, self.config.tileSize, self.config.tileSize)
    end
    if sel.pathLine and sel.pathLineAlpha > 0 then
        love.graphics.setColor(1, 0.2, 0.2, 0.7 * sel.pathLineAlpha)
        for i = 1, #sel.pathLine - 1 do
            local a = sel.pathLine[i]
            local b = sel.pathLine[i + 1]
            local ax, ay = self.levelState.grid:gridToScreen(a.col, a.row)
            local bx, by = self.levelState.grid:gridToScreen(b.col, b.row)
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
            local t = self.levelState.grid:getTile(col, row)
            local x, y = self.levelState.grid:gridToScreen(col, row)
            if t.highlightColor then
                love.graphics.setColor(t.highlightColor)
                love.graphics.rectangle("fill", x, y, self.config.tileSize, self.config.tileSize)
            end
            if t.hovered then
                love.graphics.setColor(0.2, 0.8, 1, 0.4)
                love.graphics.rectangle("fill", x, y, self.config.tileSize, self.config.tileSize)
            end
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
            love.graphics.rectangle("line", x, y, self.config.tileSize, self.config.tileSize)
            t.highlightColor = nil -- Reset highlight after drawing
        end
    end

    -- Draw enemies
    for _, enemy in ipairs(self.levelState.enemies or {}) do
        enemy:draw(self.config.tileSize, offsetX, offsetY)
    end
    -- Draw players
    for _, player in ipairs(self.levelState.players or {}) do
        player:draw(self.config.tileSize, offsetX, offsetY)
    end

    if sel.attackLine and #sel.attackLine > 0 and sel.attackLineAlpha > 0 then
        love.graphics.setColor(1, 0.2, 0.2, 0.7 * sel.attackLineAlpha)
        for i = 1, #sel.attackLine - 1 do
            local a = sel.attackLine[i]
            local b = sel.attackLine[i + 1]
            local ax, ay = self.levelState.grid:gridToScreen(a.col, a.row)
            local bx, by = self.levelState.grid:gridToScreen(b.col, b.row)
            ax = ax + self.config.tileSize / 2
            ay = ay + self.config.tileSize / 2
            bx = bx + self.config.tileSize / 2
            by = by + self.config.tileSize / 2
            love.graphics.setLineWidth(6)
            love.graphics.line(ax, ay, bx, by)
        end

        local final = sel.attackLine[#sel.attackLine]
        local finalx, finaly = self.levelState.grid:gridToScreen(final.col, final.row)
        finalx = finalx + self.config.tileSize / 2
        finaly = finaly + self.config.tileSize / 2
        love.graphics.circle("fill", finalx, finaly, 10, 100)

        love.graphics.setLineWidth(1)
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

function Level:handleEntitySelection(col, row)
    local entity = self:entityAt(col, row)
end

function Level:handlePlayerSelection(col, row)
    local player = self:playerAt(col, row)
    local sel = self.levelState.selection
    if not sel.selectedPlayer then
        -- Only allow selection if a player is present
        if player then
            sel.selectedPlayer = player
            sel.first.col, sel.first.row = col, row
            sel.reachable = computeReachable(self.levelState.grid, col, row, self.config.maxDistance)
            sel.second.col, sel.second.row = nil, nil
            sel.pathLine = nil
            sel.pathLineAlpha = 0
        end
    elseif not sel.second.col then
        -- Only allow move if clicked tile is in range and not blocked
        local inRange = false
        for _, t in ipairs(sel.reachable) do
            if t.col == col and t.row == row then
                inRange = true
                break
            end
        end
        if inRange and not (col == sel.first.col and row == sel.first.row) then
            sel.second.col, sel.second.row = col, row
            local path = self.levelState.grid:findPath(sel.first.col, sel.first.row,
                sel.second.col, sel.second.row)
            if path then
                self.levelState.grid:getTile(sel.selectedPlayer.col, sel.selectedPlayer.row).entity = nil
                self.levelState.grid:getTile(col, row).entity = sel.selectedPlayer
                sel.selectedPlayer:setMove(path, col, row)
                sel.isAnimating = true
                sel.pathLine = path
                sel.pathLineAlpha = 1
            end
        else
            self:resetSelection()
        end
    else
        self:resetSelection()
    end
end

function Level:handleAttackSelection(row, col)
    -- check if click is within the bounds of one of the attack highlighted cells
    local sel = self.levelState.selection
    if self.levelState.currentAttack then
        local found = false
        for _, value in ipairs(sel.attackReachable) do
            if row == value.row and col == value.col then
                self.levelState.currentAttack:cast(value.col, value.row, value.dir,
                    function() self:resetAttackSelection() end)
                self.levelState.selection.attackReachable = {}
                self.levelState.selection.attackLine = {}
                found = true
                break
            end
        end
        if not found then
            -- No matching reachable tile, reset attack selection or give feedback
            self:resetAttackSelection()
        end
    else
        self:resetAttackSelection()
    end
end

function Level:handleCurrentSelectedAttack()
    if self.levelState.currentAttack and not self.levelState.currentAttack:isAnimating() then
        local attack                              = self.levelState.currentAttack
        local player                              = self.levelState.currentPlayer

        local shape                               = attack:getLaunchShape()

        self.levelState.selection.attackReachable = {}

        local outerSelf                           = self
        for index, dir in ipairs(shape) do
            local col = player.col + dir.col
            local row = player.row + dir.row

            if self:isInBounds(col, row) then
                local tile = self.levelState.grid:getTile(col, row)
                if tile.cost < math.huge then
                    table.insert(self.levelState.selection.attackReachable, { col = col, row = row, dir = dir })
                    self.levelState.grid:getTile(col, row).highlightColor = COST_COLORS[3]

                    self.levelState.grid:getTile(col, row).onHover = function()
                        local pcol = col
                        local prow = row

                        self.levelState.selection.attackLine = {}

                        table.insert(outerSelf.levelState.selection.attackLine,
                            outerSelf.levelState.grid:getTile(player.col, player.row))

                        while outerSelf:isInBounds(pcol, prow)
                            and outerSelf.levelState.grid:getTile(pcol, prow).cost < math.huge
                            and outerSelf.levelState.grid:getTile(pcol, prow).entity == nil do
                            table.insert(outerSelf.levelState.selection.attackLine,
                                outerSelf.levelState.grid:getTile(pcol, prow))
                            pcol = pcol + dir.col
                            prow = prow + dir.row
                        end
                        table.insert(outerSelf.levelState.selection.attackLine,
                            outerSelf.levelState.grid:getTile(pcol, prow))
                    end
                end
            end
        end
    else
        -- Clear all onHover functions when no attack is selected
        for col = 1, self.config.cols do
            for row = 1, self.config.rows do
                local tile = self.levelState.grid:getTile(col, row)
                tile.onHover = nil
            end
        end
    end
end

function Level:isInBounds(col, row)
    return col >= 1 and col <= self.config.cols and row >= 1 and row <= self.config.rows
end

return Level
