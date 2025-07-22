-- Game Configuration
local Config = {}

-- Window settings
Config.WINDOW_WIDTH = 800
Config.WINDOW_HEIGHT = 600
Config.WINDOW_TITLE = "Turn-based Game Template"

-- Grid settings
Config.GRID_WIDTH = 20
Config.GRID_HEIGHT = 15
Config.GRID_TILE_SIZE = 40
Config.GRID_OFFSET_X = 0
Config.GRID_OFFSET_Y = 0

-- Player settings
Config.PLAYER_SIZE = 30
Config.PLAYER_SPEED = 100
Config.PLAYER_HEALTH = 100
Config.PLAYER_ACTION_COOLDOWN = 1.0
Config.PLAYER_MOVEMENT_RANGE = 3
Config.PLAYER_ATTACK_RANGE = 2

-- Turn settings
Config.TURN_DURATION = 30 -- seconds per turn
Config.TURN_WARNING_TIME = 10 -- seconds before turn ends

-- UI settings
Config.UI_FONT_SIZE = 16
Config.UI_PADDING = 10
Config.UI_BUTTON_HEIGHT = 30
Config.UI_BUTTON_WIDTH = 120

-- Colors
Config.COLORS = {
    BACKGROUND = {0.1, 0.1, 0.1, 1},
    UI_BACKGROUND = {0.2, 0.2, 0.2, 0.8},
    UI_TEXT = {1, 1, 1, 1},
    UI_BUTTON = {0.3, 0.3, 0.3, 1},
    UI_BUTTON_HOVER = {0.4, 0.4, 0.4, 1},
    PLAYER_1 = {0.2, 0.6, 1.0, 1},
    PLAYER_2 = {1.0, 0.3, 0.3, 1},
    TURN_INDICATOR = {1, 1, 0, 1},
    HEALTH_BAR_BG = {0.3, 0.3, 0.3, 1},
    HEALTH_BAR_FG = {0.2, 0.8, 0.2, 1},
    GRID_GRASS = {0.2, 0.6, 0.2, 1},
    GRID_OCCUPIED = {0.8, 0.8, 0.2, 1},
    GRID_OBSTACLE = {0.3, 0.3, 0.3, 1},
    GRID_BORDER = {0.1, 0.1, 0.1, 1},
    MOVEMENT_RANGE = {0, 1, 0, 0.3},
    ATTACK_RANGE = {1, 0, 0, 0.3}
}

return Config 