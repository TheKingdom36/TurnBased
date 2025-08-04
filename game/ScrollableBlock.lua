local Config = require('game.Config')

local UIRightPanel = {}
UIRightPanel.__index = UIRightPanel

function UIRightPanel:new(x, y, width, height, margin)
    local panel = {
        x = x or 0,
        y = y or 0,
        width = width or 300,
        height = height or 200,
        margin = margin or 10,
        lines = {},
        font = love.graphics.newFont(Config.UI_FONT_SIZE or 18),
        scrollOffset = 0
    }
    setmetatable(panel, self)
    return panel
end

function UIRightPanel:addLine(text)
    table.insert(self.lines, text)
end

function UIRightPanel:scroll(amount)
    local lineHeight = self.font:getHeight() + 2
    local maxOffset = math.max(0, #self.lines * lineHeight - self.height + 20)
    self.scrollOffset = math.max(0, math.min(self.scrollOffset + amount, maxOffset))
end

function UIRightPanel:draw()
    love.graphics.setFont(self.font)
    local x = self.x + self.width - self.margin
    local y = self.y - self.margin

    -- Panel background
    love.graphics.setColor(0.15, 0.15, 0.15, 0.9)
    love.graphics.rectangle("fill", x, y, self.width, self.height)

    -- Panel border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, self.width, self.height)

    -- Draw lines of text with scroll
    love.graphics.setScissor(x, y, self.width, self.height)
    love.graphics.setColor(1, 1, 1, 1)
    local lineHeight = self.font:getHeight() + 2
    local textY = y + 10 - self.scrollOffset
    for _, line in ipairs(self.lines) do
        if textY + lineHeight > y and textY < y + self.height then
            love.graphics.print(line, x + 10, textY)
        end
        textY = textY + lineHeight
    end
    love.graphics.setScissor()
end

return UIRightPanel
