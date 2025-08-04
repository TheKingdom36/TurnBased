local EventSystem = require('game.EventSystem')
local UIRightPanel = require('game.ScrollableBlock')

-- UI System
local UI = {}
UI.__index = UI

local Config = require('game.Config')

function UI:new()
    local ui = {
        font = love.graphics.newFont(Config.UI_FONT_SIZE),
        attackButtons = {},
        attackButtonsConfig = {
            rows = 2,
            cols = 2,
            width = 80,
            height = 50 
        },
        panels = {},
        tooltips = {},
        mouseX = 0,
        mouseY = 0
    }
    setmetatable(ui, self)
    
    -- Initialize UI elements
    ui:createActionPanel()
    ui:createInfoPanel()
    self.rightPanel =  UIRightPanel:new(love.graphics.getWidth()-600,300,300,600,10)

    -- Register a listener
    EventSystem:register("log_action", function(message)
        self.rightPanel:addLine(message)
    end)
    
    return ui
end

function UI:update(dt, levelState)
    -- Update mouse position
    self.mouseX, self.mouseY = love.mouse.getPosition()

    

    -- In your update or keypressed function:
    if love.keyboard.isDown("up") then
        self.rightPanel:scroll(-20)
    elseif love.keyboard.isDown("down") then
        self.rightPanel:scroll(20)
    end

    if levelState.currentPlayer then
        self:updateAttackButtons(levelState)
    end

    -- Update buttons
    for _, button in ipairs(self.attackButtons) do
        button.isHovered = self:isPointInRect(self.mouseX, self.mouseY, button.x, button.y, button.width, button.height)
    end
end

function UI:updateAttackButtons(levelState)
    if #levelState.currentPlayer.attacks == 0 then
        return
    end

    local actionPanelPosX = self.actionPanel.x
    local actionPanelPosY = self.actionPanel.y

    local pos = 1
    for i = 1, self.attackButtonsConfig.rows, 1 do
        for j = 1, self.attackButtonsConfig.cols, 1 do
            local button = levelState.currentPlayer.attacks[pos]
            local x = actionPanelPosX + (i-1) * (self.attackButtonsConfig.width + 15)  + 10 
            local y = actionPanelPosY + (j-1) * (self.attackButtonsConfig.height + 20) + 100

            self:addAttackButton(button.name, x, y, self.attackButtonsConfig.width, self.attackButtonsConfig.height,  function()
                levelState.currentAttack = levelState.currentPlayer.attacks[pos]
            end  )
        end
    end
end

function UI:draw(gameState, turnManager)
    -- Set font
    love.graphics.setFont(self.font)
    
    -- Draw panels
    self:drawActionPanel(gameState, turnManager)
    self:drawInfoPanel(gameState, turnManager)
    self:drawTurnTimer(turnManager)

    self.rightPanel:draw()
end

function UI:createActionPanel()
    local panel = {
        x = 10,
        y = love.graphics.getHeight() - 400,
        width = 200,
        height = 300,
        title = "Actions"
    }
    self.actionPanel = panel
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

function UI:drawActionPanel(levelState, turnManager)
    local panel = self.actionPanel
   
    -- Draw panel background
    love.graphics.setColor(Config.COLORS.UI_BACKGROUND)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)
    
    -- Draw panel border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)
    
    -- Draw panel title
    love.graphics.setColor(Config.COLORS.UI_TEXT)
    love.graphics.print(panel.title, panel.x + 5, panel.y + 25)
    
    -- Draw current player info
    local currentPlayer = levelState.currentPlayer
    if currentPlayer then
        love.graphics.print("Current: " .. currentPlayer.name, panel.x + 5, panel.y + 5)
    end

    -- Draw current player info
    local currentAttack = levelState.currentAttack
    if currentAttack then
        love.graphics.print("Current Attack: " .. currentAttack.name, panel.x + 5, panel.y + 25)
    end

    self:drawAttackButtons()
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

function UI:addAttackButton(text, x, y, width, height, callback)
    local button = {
        x = x,
        y = y,
        width = width,
        height = height,
        text = text,
        callback = callback,
        isHovered = false
    }

    table.insert(self.attackButtons, button)
end

function UI:drawAttackButtons()

    for index, button in ipairs(self.attackButtons) do
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
        for _, uiButton in ipairs(self.attackButtons) do
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