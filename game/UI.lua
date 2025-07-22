-- UI System
local UI = {}
UI.__index = UI

local Config = require('game.Config')

function UI:new()
    local ui = {
        font = love.graphics.newFont(Config.UI_FONT_SIZE),
        buttons = {},
        panels = {},
        tooltips = {},
        mouseX = 0,
        mouseY = 0
    }
    setmetatable(ui, self)
    
    -- Initialize UI elements
    ui:createActionPanel()
    ui:createInfoPanel()
    
    return ui
end

function UI:update(dt)
    -- Update mouse position
    self.mouseX, self.mouseY = love.mouse.getPosition()
    
    -- Update buttons
    for _, button in ipairs(self.buttons) do
        button.isHovered = self:isPointInRect(self.mouseX, self.mouseY, button.x, button.y, button.width, button.height)
    end
end

function UI:draw(gameState, turnManager)
    -- Set font
    love.graphics.setFont(self.font)
    
    -- Draw panels
    self:drawActionPanel(gameState, turnManager)
    self:drawInfoPanel(gameState, turnManager)
    self:drawTurnTimer(turnManager)
    self:drawButtons()
end

function UI:createActionPanel()
    local panel = {
        x = 10,
        y = love.graphics.getHeight() - 120,
        width = 200,
        height = 110,
        title = "Actions"
    }
    self.actionPanel = panel
    
    -- Create action buttons
    local buttonY = panel.y + 30
    local buttonSpacing = 35
    
    self:addButton("Move", panel.x + 10, buttonY, 80, 25, function()
        -- Move action
        print("Move action selected")
    end)
    
    self:addButton("Attack", panel.x + 100, buttonY, 80, 25, function()
        -- Attack action
        print("Attack action selected")
    end)
    
    self:addButton("Defend", panel.x + 10, buttonY + buttonSpacing, 80, 25, function()
        -- Defend action
        print("Defend action selected")
    end)
    
    self:addButton("Skip Turn", panel.x + 100, buttonY + buttonSpacing, 80, 25, function()
        -- Skip turn
        print("Turn skipped")
    end)
end

function UI:createInfoPanel()
    local panel = {
        x = love.graphics.getWidth() - 210,
        y = 10,
        width = 200,
        height = 150,
        title = "Game Info"
    }
    self.infoPanel = panel
end

function UI:drawActionPanel(gameState, turnManager)
    local panel = self.actionPanel
    
    -- Draw panel background
    love.graphics.setColor(Config.COLORS.UI_BACKGROUND)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)
    
    -- Draw panel border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)
    
    -- Draw panel title
    love.graphics.setColor(Config.COLORS.UI_TEXT)
    love.graphics.print(panel.title, panel.x + 5, panel.y + 5)
    
    -- Draw current player info
    local currentPlayer = turnManager:getCurrentPlayer()
    if currentPlayer then
        love.graphics.print("Current: " .. currentPlayer.name, panel.x + 5, panel.y + 15)
    end
end

function UI:drawInfoPanel(gameState, turnManager)
    local panel = self.infoPanel
    
    -- Draw panel background
    love.graphics.setColor(Config.COLORS.UI_BACKGROUND)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)
    
    -- Draw panel border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)
    
    -- Draw panel title
    love.graphics.setColor(Config.COLORS.UI_TEXT)
    love.graphics.print(panel.title, panel.x + 5, panel.y + 5)
    
    -- Draw game info
    local y = panel.y + 25
    love.graphics.print("Turn: " .. gameState:getTurnNumber(), panel.x + 5, y)
    y = y + 20
    love.graphics.print("Phase: " .. gameState:getGamePhase(), panel.x + 5, y)
    y = y + 20
    
    -- Draw scores
    local scores = gameState:getScore()
    love.graphics.print("Score P1: " .. scores.player1, panel.x + 5, y)
    y = y + 20
    love.graphics.print("Score P2: " .. scores.player2, panel.x + 5, y)
end

function UI:drawTurnTimer(turnManager)
    local timeRemaining = turnManager:getTurnTimeRemaining()
    local progress = turnManager:getTurnProgress()
    
    -- Draw timer bar
    local barX = 220
    local barY = 10
    local barWidth = 300
    local barHeight = 20
    
    -- Background
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- Progress
    local color = {0.2, 0.8, 0.2, 1}
    if turnManager:isTurnWarning() then
        color = {0.8, 0.2, 0.2, 1}
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", barX, barY, barWidth * progress, barHeight)
    
    -- Border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
    
    -- Time text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("Time: %.1f", timeRemaining), barX + barWidth/2 - 30, barY + 2)
end

function UI:addButton(text, x, y, width, height, callback)
    local button = {
        text = text,
        x = x,
        y = y,
        width = width,
        height = height,
        callback = callback,
        isHovered = false
    }
    table.insert(self.buttons, button)
end

function UI:drawButtons()
    for _, button in ipairs(self.buttons) do
        -- Button background
        if button.isHovered then
            love.graphics.setColor(Config.COLORS.UI_BUTTON_HOVER)
        else
            love.graphics.setColor(Config.COLORS.UI_BUTTON)
        end
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        
        -- Button border
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
        
        -- Button text
        love.graphics.setColor(Config.COLORS.UI_TEXT)
        local textWidth = self.font:getWidth(button.text)
        local textX = button.x + (button.width - textWidth) / 2
        local textY = button.y + (button.height - Config.UI_FONT_SIZE) / 2
        love.graphics.print(button.text, textX, textY)
    end
end

function UI:isPointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

function UI:mousepressed(x, y, button)
    if button == 1 then -- Left click
        for _, uiButton in ipairs(self.buttons) do
            if self:isPointInRect(x, y, uiButton.x, uiButton.y, uiButton.width, uiButton.height) then
                if uiButton.callback then
                    uiButton.callback()
                end
                break
            end
        end
    end
end

return UI 