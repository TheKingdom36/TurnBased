-- Simple Test Game
-- This is a basic version to test the grid system
local lurker = require("game.lurker")
local Level = require('game.Level')


local sampleLevel = require('levels.basic_sample_level')
local level
STARTED = STARTED or false

function love.load()
    if not STARTED then
        local desktop_w, desktop_h = love.window.getDesktopDimensions()
        local win_w, win_h = math.floor(desktop_w * 0.9), math.floor(desktop_h * 0.9)
        love.window.setMode(win_w, win_h, { fullscreen = false, resizable = false, centered = true })
        -- Set window position to current position
        local cur_x, cur_y = love.window.getPosition()
        love.window.setPosition(cur_x, cur_y)
        STARTED = true
    end

    local config    = {
            cols = 18,
            rows = 14,
            tileSize = 48,
            maxDistance = 8,
            pathLineFadeTime = 2,
    }

    local state = sampleLevel(config)
    
    level = Level:create(state, config)

    lurker.postswap = function(file)
        love.load()
    end
end

function love.update(dt)
    lurker.update()
    level:update(dt)
end

function love.draw()
    level:draw()
end

function love.mousepressed(x, y, button)
    level:mousepressed(x, y, button)
end

function love.keypressed(key)
    level:keypressed(key)
end
