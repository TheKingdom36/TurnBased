-- StateWindowDebugger
-- Utility class that displays level state information in an overlay panel
-- Updates in sync with the main level state

local StateWindowDebugger = {}
StateWindowDebugger.__index = StateWindowDebugger

---@class StateWindowDebugger
---@field levelState LevelState
---@field font table
---@field scrollOffset number
---@field width number
---@field height number
---@field x number
---@field y number

function StateWindowDebugger:new(levelState, windowWidth, windowHeight)
    windowWidth = windowWidth or 350
    windowHeight = windowHeight or 600

    local debugger = {
        levelState = levelState,
        font = love.graphics.newFont(12),
        titleFont = love.graphics.newFont(14),
        scrollOffset = 0,
        width = windowWidth,
        height = windowHeight,
        x = love.graphics.getWidth() - windowWidth,
        y = 0,
        headerHeight = 30,
        isOpen = true,
        isCollapsed = false,
        stateHistory = {},
        maxHistoryLength = 20,
        backgroundColor = { 0.1, 0.1, 0.1, 0.95 },
        headerColor = { 0.15, 0.15, 0.15, 0.95 },
        hoverColor = { 0.2, 0.2, 0.2, 0.95 },
        isHoveringHeader = false
    }

    setmetatable(debugger, self)

    return debugger
end

function StateWindowDebugger:update(dt)
    if not self.isOpen then
        return
    end

    -- Check if mouse is hovering over header
    local mx, my = love.mouse.getPosition()
    self.isHoveringHeader = mx >= self.x and mx <= self.x + self.width and
        my >= self.y and my <= self.y + self.headerHeight

    -- Record state changes
    self:recordStateSnapshot()
end

function StateWindowDebugger:mousepressed(x, y, button)
    if not self.isOpen or button ~= 1 then
        return false
    end

    -- Check if clicking on header to toggle collapse
    if x >= self.x and x <= self.x + self.width and
        y >= self.y and y <= self.y + self.headerHeight then
        self.isCollapsed = not self.isCollapsed
        return true
    end

    return false
end

function StateWindowDebugger:wheelmoved(x, y)
    if not self.isOpen or self.isCollapsed then
        return false
    end

    -- Check if mouse is over the panel
    local mx, my = love.mouse.getPosition()
    if mx >= self.x and mx <= self.x + self.width and
        my >= self.y and my <= self.y + self.height then
        self:scroll(-y * 30) -- Negative because wheel up is positive
        return true
    end

    return false
end

function StateWindowDebugger:recordStateSnapshot()
    local snapshot = {
        timestamp = love.timer.getTime(),
        turnNumber = self.levelState.turnNumber,
        gamePhase = self.levelState.gamePhase,
        currentPlayerName = self.levelState.currentPlayer and self.levelState.currentPlayer.name or "None",
        playersCount = #self.levelState.players,
        enemiesCount = #self.levelState.enemies,
        selectedFirst = {
            col = self.levelState.selection.first.col,
            row = self.levelState.selection.first.row
        },
        selectedSecond = {
            col = self.levelState.selection.second.col,
            row = self.levelState.selection.second.row
        }
    }
    table.insert(self.stateHistory, snapshot)

    -- Keep history limited
    if #self.stateHistory > self.maxHistoryLength then
        table.remove(self.stateHistory, 1)
    end
end

function StateWindowDebugger:draw()
    if not self.isOpen then
        return
    end

    -- Save current graphics state
    love.graphics.push()
    love.graphics.origin()

    local displayHeight = self.isCollapsed and self.headerHeight or self.height

    -- Draw header
    local headerBgColor = self.isHoveringHeader and self.hoverColor or self.headerColor
    love.graphics.setColor(headerBgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.headerHeight)

    -- Draw header border
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.headerHeight)
    love.graphics.setLineWidth(1)

    -- Draw title in header
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(0.2, 0.8, 1, 1)
    love.graphics.printf("LEVEL STATE", self.x + 5, self.y + 7, self.width - 30, "left")

    -- Draw collapse/expand indicator
    love.graphics.setFont(self.font)
    local indicator = self.isCollapsed and "▼" or "▲"
    love.graphics.printf(indicator, self.x, self.y + 7, self.width - 10, "right")

    if not self.isCollapsed then
        -- Draw background panel
        love.graphics.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", self.x, self.y + self.headerHeight, self.width, self.height - self.headerHeight)

        -- Draw border
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        love.graphics.setLineWidth(1)

        -- Set up scissor to clip content
        love.graphics.setScissor(self.x, self.y + self.headerHeight, self.width, self.height - self.headerHeight)

        love.graphics.setFont(self.font)
        love.graphics.setColor(1, 1, 1, 1)

        local y = self.y + self.headerHeight + 10 - self.scrollOffset

        -- Draw current state info
        self:drawStateInfo(y)

        -- Reset scissor
        love.graphics.setScissor()
    end

    -- Restore graphics state
    love.graphics.pop()
end

function StateWindowDebugger:drawStateInfo(startY)
    local y = startY
    local lineHeight = 20
    local x = self.x + 10

    -- Current turn info
    love.graphics.setColor(0.2, 1, 0.2, 1)
    love.graphics.print("Turn: " .. self.levelState.turnNumber, x, y)
    y = y + lineHeight

    love.graphics.setColor(0.2, 0.8, 1, 1)
    love.graphics.print("Phase: " .. self.levelState.gamePhase, x, y)
    y = y + lineHeight

    -- Current player
    love.graphics.setColor(1, 1, 0.2, 1)
    local currentPlayerName = self.levelState.currentPlayer and self.levelState.currentPlayer.name or "None"
    love.graphics.print("Current Player: " .. currentPlayerName, x, y)
    y = y + lineHeight

    -- Players count
    love.graphics.setColor(0.2, 1, 0.2, 1)
    love.graphics.print("Players: " .. #self.levelState.players, x, y)
    y = y + lineHeight

    -- Enemies count
    love.graphics.setColor(1, 0.2, 0.2, 1)
    love.graphics.print("Enemies: " .. #self.levelState.enemies, x, y)
    y = y + lineHeight

    -- Selection info
    y = y + 10
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print("Selection:", x, y)
    y = y + lineHeight

    love.graphics.setColor(1, 1, 1, 1)
    local firstSelected = self.levelState.selection.first.col and self.levelState.selection.first.row
    if firstSelected then
        love.graphics.print(
            "First: (" .. self.levelState.selection.first.col .. ", " .. self.levelState.selection.first.row .. ")",
            x + 10,
            y)
    else
        love.graphics.print("First: None", x + 10, y)
    end
    y = y + lineHeight

    local secondSelected = self.levelState.selection.second.col and self.levelState.selection.second.row
    if secondSelected then
        love.graphics.print(
            "Second: (" .. self.levelState.selection.second.col .. ", " .. self.levelState.selection.second.row .. ")",
            x + 10, y)
    else
        love.graphics.print("Second: None", x + 10, y)
    end
    y = y + lineHeight

    -- Reachable tiles count
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print("Reachable: " .. #self.levelState.selection.reachable, x + 10, y)
    y = y + lineHeight + 10

    -- Selected Player Section
    if self.levelState.selection.selectedPlayer then
        love.graphics.setColor(0.2, 1, 0.8, 1)
        love.graphics.print("=== SELECTED PLAYER ===", x, y)
        y = y + lineHeight

        local player = self.levelState.selection.selectedPlayer

        -- Player name
        love.graphics.setColor(1, 1, 0.5, 1)
        love.graphics.print(player.name or "Unknown", x, y)
        y = y + lineHeight

        -- Stats
        love.graphics.setColor(1, 1, 1, 1)
        if player.stats then
            love.graphics.print(
                "HP: " .. (player.stats.hp or "?") .. "/" .. (player.stats.maxHp or "?") ..
                " | MP: " .. (player.stats.mp or "?") .. "/" .. (player.stats.maxMp or "?"),
                x + 5, y)
            y = y + lineHeight
            love.graphics.print("Movement: " .. (player.stats.movement or "?"), x + 5, y)
            y = y + lineHeight
        end

        -- Position
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.print("Position: (" .. player.col .. ", " .. player.row .. ")", x + 5, y)
        y = y + lineHeight + 5
    end

    -- Selected Bones Section
    if self.levelState.selectedBones and #self.levelState.selectedBones > 0 then
        love.graphics.setColor(1, 0.8, 1, 1)
        love.graphics.print("Selected Bones (" .. #self.levelState.selectedBones .. "):", x, y)
        y = y + lineHeight

        for i, bone in ipairs(self.levelState.selectedBones) do
            love.graphics.setColor(0.9, 0.7, 1, 1)
            local boneName = bone.name or ("Bone " .. i)
            love.graphics.print("  - " .. boneName, x + 5, y)
            y = y + lineHeight
        end
        y = y + 5
    end

    -- Attack info if selected
    if self.levelState.currentAttack then
        love.graphics.setColor(1, 0.5, 0.5, 1)
        love.graphics.print("Selected Attack:", x, y)
        y = y + lineHeight

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Name: " .. (self.levelState.currentAttack.name or "Unknown"), x + 10, y)
        y = y + lineHeight

        if self.levelState.currentAttack.mpCost then
            love.graphics.print("MP Cost: " .. self.levelState.currentAttack.mpCost, x + 10, y)
            y = y + lineHeight
        end

        love.graphics.print("Attack Reachable: " .. #self.levelState.selection.attackReachable, x + 10, y)
        y = y + lineHeight + 10
    end

    -- All Players Info
    if #self.levelState.players > 0 then
        y = y + 10
        love.graphics.setColor(0.2, 1, 1, 1)
        love.graphics.print("=== ALL PLAYERS ===", x, y)
        y = y + lineHeight

        for i, player in ipairs(self.levelState.players) do
            -- Player name
            love.graphics.setColor(1, 1, 0.5, 1)
            love.graphics.print(player.name or ("Player " .. i), x, y)
            y = y + lineHeight

            -- Stats
            love.graphics.setColor(1, 1, 1, 1)
            if player.stats then
                love.graphics.print(
                    "  HP: " .. (player.stats.hp or "?") .. "/" .. (player.stats.maxHp or "?") ..
                    " | MP: " .. (player.stats.mp or "?") .. "/" .. (player.stats.maxMp or "?"),
                    x + 5, y)
                y = y + lineHeight
            end

            -- Position
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
            love.graphics.print("  Pos: (" .. player.col .. ", " .. player.row .. ")", x + 5, y)
            y = y + lineHeight

            -- Bones
            if player.bones and #player.bones > 0 then
                love.graphics.setColor(0.8, 0.8, 1, 1)
                love.graphics.print("  Bones (" .. #player.bones .. "):", x + 5, y)
                y = y + lineHeight
                for j, bone in ipairs(player.bones) do
                    love.graphics.setColor(0.7, 0.7, 1, 1)
                    local boneName = bone.name or ("Bone " .. j)
                    love.graphics.print("    - " .. boneName, x + 10, y)
                    y = y + lineHeight
                end
            else
                love.graphics.setColor(0.6, 0.6, 0.6, 1)
                love.graphics.print("  Bones: None", x + 5, y)
                y = y + lineHeight
            end

            -- Attacks/Actions
            if player.attacks and #player.attacks > 0 then
                love.graphics.setColor(1, 0.8, 0.5, 1)
                love.graphics.print("  Attacks (" .. #player.attacks .. "):", x + 5, y)
                y = y + lineHeight
                for j, attack in ipairs(player.attacks) do
                    love.graphics.setColor(1, 0.7, 0.4, 1)
                    local attackName = attack.name or ("Attack " .. j)
                    local mpCost = attack.mpCost or 0
                    love.graphics.print("    - " .. attackName .. " (MP: " .. mpCost .. ")", x + 10, y)
                    y = y + lineHeight
                end
            else
                love.graphics.setColor(0.6, 0.6, 0.6, 1)
                love.graphics.print("  Attacks: None", x + 5, y)
                y = y + lineHeight
            end

            y = y + 5 -- Add spacing between players
        end
    end
end

function StateWindowDebugger:scroll(amount)
    self.scrollOffset = math.max(0, self.scrollOffset + amount)
end

function StateWindowDebugger:close()
    self.isOpen = false
end

function StateWindowDebugger:toggle()
    self.isOpen = not self.isOpen
end

return StateWindowDebugger
