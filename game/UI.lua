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
        boneButtons = {},
        attackButtonsConfig = {
            rows = 2,
            cols = 2,
            width = 80,
            height = 50
        },
        panels = {},
        tooltips = {},
        mouseX = 0,
        mouseY = 0,
        lastSelectedPlayer = nil,
        lastSelectedBonesKey = "",
        lastAttackCount = 0,
        lastBoneCount = 0
    }
    setmetatable(ui, self)

    -- Initialize UI elements
    ui:createActionPanel()
    ui:createBonePanel()
    ui:createSelectedEntityPanel()
    self.rightPanel = UIRightPanel:new(love.graphics.getWidth() - 600, 300, 300, 600, 10)

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

    self:refreshButtons(levelState)

    -- Update buttons
    for _, button in ipairs(self.attackButtons) do
        button.isHovered = self:isPointInRect(self.mouseX, self.mouseY, button.x, button.y, button.width, button.height)
    end
    -- Update buttons
    for _, button in ipairs(self.boneButtons) do
        button.isHovered = self:isPointInRect(self.mouseX, self.mouseY, button.x, button.y, button.width, button.height)
    end
end

function UI:refreshButtons(levelState)
    local currentPlayer = levelState.currentPlayer

    if not currentPlayer then
        self.attackButtons = {}
        self.boneButtons = {}
        self.lastSelectedPlayer = nil
        self.lastSelectedBonesKey = ""
        self.lastAttackCount = 0
        self.lastBoneCount = 0
        return
    end

    local bones = currentPlayer.bones or {}
    local attacks = currentPlayer.attacks or {}
    local selectedBonesKey = self:getSelectedBonesKey(levelState.selectedBones or {})

    local playerChanged = currentPlayer ~= self.lastSelectedPlayer
    local bonesChanged = #bones ~= self.lastBoneCount
    local attacksChanged = #attacks ~= self.lastAttackCount
    local selectedBonesChanged = selectedBonesKey ~= self.lastSelectedBonesKey

    if playerChanged or attacksChanged then
        self:updateAttackButtons(levelState)
    end

    if playerChanged or bonesChanged or selectedBonesChanged then
        self:updateBoneButtons(levelState)
    end

    for _, boneButton in ipairs(self.boneButtons) do
        boneButton.isSelected = self:isBoneSelected(boneButton.bone, levelState.selectedBones)
    end

    self.lastSelectedPlayer = currentPlayer
    self.lastSelectedBonesKey = selectedBonesKey
    self.lastAttackCount = #attacks
    self.lastBoneCount = #bones
end

function UI:getSelectedBonesKey(selectedBones)
    if not selectedBones or #selectedBones == 0 then
        return ""
    end

    local parts = {}
    for i, bone in ipairs(selectedBones) do
        local name = bone.name or ""
        parts[i] = tostring(name)
    end

    return table.concat(parts, "|")
end

function UI:isBoneSelected(bone, selectedBones)
    if not selectedBones or #selectedBones == 0 then
        return false
    end

    for i, selectedBone in ipairs(selectedBones) do
        local name = selectedBone.name or ""

        if tostring(name) == tostring(bone.name or "") then
            return true
        end
    end
    return false
end

function UI:updateAttackButtons(levelState)
    if #levelState.currentPlayer.attacks == 0 then
        return
    end

    self.attackButtons = {}

    local actionPanelPosX = self.actionPanel.x
    local actionPanelPosY = self.actionPanel.y

    local pos = 1
    for i = 1, self.attackButtonsConfig.rows, 1 do
        for j = 0, self.attackButtonsConfig.cols, 1 do
            if i + j > #levelState.currentPlayer.attacks then
                return
            end

            local button = levelState.currentPlayer.attacks[i + j]
            local x = actionPanelPosX + (i - 1) * (self.attackButtonsConfig.width + 15) + 10
            local y = actionPanelPosY + (j) * (self.attackButtonsConfig.height + 20) + 100

            local isClickable = levelState.currentPlayer.stats.mp >= button.mpCost

            self:addAttackButton(button.name, x, y, self.attackButtonsConfig.width, self.attackButtonsConfig.height,
                function()
                    levelState.currentAttack = levelState.currentPlayer.attacks[pos]
                end, { 1, 1, 1, 1 }, isClickable)
        end
    end
end

function UI:updateBoneButtons(levelState)
    self.boneButtons = {}
    if #levelState.currentPlayer.bones == 0 then
        return
    end

    local bonePanelPosX = self.bonePanel.x
    local bonePanelPosY = self.bonePanel.y

    local pos = 1
    for i = 1, self.attackButtonsConfig.rows, 1 do
        for j = 0, self.attackButtonsConfig.cols, 1 do
            if i + j > #levelState.currentPlayer.bones then
                return
            end

            local button = levelState.currentPlayer.bones[i + j]
            local x = bonePanelPosX + (i - 1) * (self.attackButtonsConfig.width + 15) + 10
            local y = bonePanelPosY + (j) * (self.attackButtonsConfig.height + 20) + 100

            self:addBoneButton(button.name, x, y, self.attackButtonsConfig.width, self.attackButtonsConfig.height,
                function()
                    self:toggleBone(levelState.selectedBones, levelState.currentPlayer.bones[i + j])
                end, { 1, 1, 1, 1 }, true, levelState.currentPlayer.bones[i + j])
        end
    end
end

function UI:draw(gameState, turnManager)
    -- Set font
    love.graphics.setFont(self.font)

    -- Draw panels
    self:drawActionPanel(gameState, turnManager)
    self:drawBonePanel(gameState)
    self:drawSelectedEntityPanel(gameState, turnManager)

    self.rightPanel:draw()
end

function UI:createActionPanel()
    local panel = {
        x = 10,
        y = 480,
        width = 300,
        height = 300,
        title = "Actions"
    }
    self.actionPanel = panel
end

function UI:createBonePanel()
    local panel = {
        x = 10,
        y = 170,
        width = 300,
        height = 300,
        title = "Bone"
    }
    self.bonePanel = panel
end

function UI:createSelectedEntityPanel()
    local panel = {
        x = 10,
        y = 10,
        width = 200,
        height = 150,
    }
    self.selectedEntityPanel = panel
end

function UI:drawBonePanel(levelState)
    local panel = self.bonePanel

    -- Draw panel background
    love.graphics.setColor(Config.COLORS.UI_BACKGROUND)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)

    -- Draw panel border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)

    -- Draw panel title
    love.graphics.setColor(Config.COLORS.UI_TEXT)
    love.graphics.print(panel.title, panel.x + 5, panel.y + 25)

    self:drawBoneButtons()
end

function UI:drawBoneButtons()
    if self.boneButtons == nil then
        return
    end

    for index, button in ipairs(self.boneButtons) do
        -- Button background
        if button.isSelected then
            love.graphics.setColor(Config.COLORS.UI_BUTTON_SELECTED)
        elseif button.isHovered then
            love.graphics.setColor(Config.COLORS.UI_BUTTON_HOVER)
        elseif button.clickable then
            love.graphics.setColor(Config.COLORS.UI_BUTTON)
        elseif button.clickable == false then
            love.graphics.setColor(Config.COLORS.UI_BUTTON_DEACTIVATED)
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

function UI:drawSelectedEntityPanel(gameState, turnManager)
    local panel = self.selectedEntityPanel

    -- Draw panel background
    love.graphics.setColor(Config.COLORS.UI_BACKGROUND)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)

    -- Draw panel border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)

    local entity = gameState.selection.hoveredEntity

    local space = 5
    local padding = 30
    if entity then
        love.graphics.setColor(Config.COLORS.UI_TEXT)
        love.graphics.print(entity.name, panel.x + 5, panel.y + space)
        space = space + padding

        if entity.stats == nil then
            return
        end

        if entity.stats.health then
            love.graphics.setColor(Config.COLORS.UI_TEXT)
            local healthString = "HP: " .. tostring(entity.stats.health) .. "/" .. tostring(entity.stats.maxHealth)
            love.graphics.print(healthString, panel.x + 5, panel.y + space)
            space = space + padding
        end

        if entity.stats.mp then
            love.graphics.setColor(Config.COLORS.UI_TEXT)
            local mpString = "MP: " .. tostring(entity.stats.mp) .. "/" .. tostring(entity.stats.maxMp)
            love.graphics.print(mpString, panel.x + 5, panel.y + space)
            space = space + padding
        end

        if entity.stats.speed then
            love.graphics.setColor(Config.COLORS.UI_TEXT)
            local speedString = "Speed: " .. tostring(entity.stats.speed)
            love.graphics.print(speedString, panel.x + 5, panel.y + space)
        end
    end
end

function UI:addAttackButton(text, x, y, width, height, callback, color, clickable)
    local button = {
        x = x,
        y = y,
        width = width,
        height = height,
        text = text,
        callback = callback,
        isHovered = false,
        color = color,
        clickable = clickable
    }

    table.insert(self.attackButtons, button)
end

function UI:addBoneButton(text, x, y, width, height, callback, color, clickable, bone)
    local button = {
        x = x,
        y = y,
        width = width,
        height = height,
        text = text,
        isHovered = false,
        color = color,
        clickable = clickable,
        isSelected = false,
        bone = bone
    }

    button.callback = function()
        callback()
        button.isSelected = not button.isSelected
    end

    table.insert(self.boneButtons, button)
end

function UI:drawAttackButtons()
    for index, button in ipairs(self.attackButtons) do
        -- Button background
        if button.isHovered then
            love.graphics.setColor(Config.COLORS.UI_BUTTON_HOVER)
        elseif button.clickable then
            love.graphics.setColor(Config.COLORS.UI_BUTTON)
        elseif button.clickable == false then
            love.graphics.setColor(Config.COLORS.UI_BUTTON_DEACTIVATED)
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

-- Toggle bone in selectedBones array
-- If bone is in selectedBones, remove it; otherwise add it
-- bone: { name = string, quality = number }
function UI:toggleBone(selectedBones, bone)
    for i, selectedBone in ipairs(selectedBones) do
        if selectedBone.name == bone.name then
            table.remove(selectedBones, i)
            return
        end
    end
    table.insert(selectedBones, bone)
end

function UI:mousepressed(x, y, button)
    if button == 1 then -- Left click
        for _, uiButton in ipairs(self.attackButtons) do
            if self:isPointInRect(x, y, uiButton.x, uiButton.y, uiButton.width, uiButton.height) then
                if uiButton.callback and uiButton.clickable then
                    uiButton.callback()
                end
                break
            end
        end

        for _, uiButton in ipairs(self.boneButtons) do
            if self:isPointInRect(x, y, uiButton.x, uiButton.y, uiButton.width, uiButton.height) then
                if uiButton.callback and uiButton.clickable then
                    uiButton.callback()
                end
                break
            end
        end
    end
end

return UI
