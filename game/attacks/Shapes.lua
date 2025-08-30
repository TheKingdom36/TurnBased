local Shapes = {
    -- Diamond (radius 1 Manhattan distance)
    SINGLE_POINT = {
        { col = 0, row = 0 },  -- Center
    },

    -- 4-point (cardinal directions)
    FOUR_POINT = {
        { col = 0,  row = -1 }, -- Up
        { col = 0,  row = 1 },  -- Down
        { col = -1, row = 0 },  -- Left
        { col = 1,  row = 0 }   -- Right
    },

    -- 4-point diagonal
    FOUR_POINT_DIAGONAL = {
        { col = -1, row = -1 }, -- Up-Left
        { col = 1,  row = -1 }, -- Up-Right
        { col = -1, row = 1 },  -- Down-Left
        { col = 1,  row = 1 }   -- Down-Right
    },

    -- L shape (like a chess knight)
    L_SHAPE = {
        { col = 2,  row = 1 },
        { col = 1,  row = 2 },
        { col = -1, row = 2 },
        { col = -2, row = 1 },
        { col = -2, row = -1 },
        { col = -1, row = -2 },
        { col = 1,  row = -2 },
        { col = 2,  row = -1 }
    },

    -- All points (surrounding 8 tiles)
    ALL_POINTS = {
        { col = 0,  row = -1 }, -- Up
        { col = 1,  row = -1 }, -- Up-Right
        { col = 1,  row = 0 },  -- Right
        { col = 1,  row = 1 },  -- Down-Right
        { col = 0,  row = 1 },  -- Down
        { col = -1, row = 1 },  -- Down-Left
        { col = -1, row = 0 },  -- Left
        { col = -1, row = -1 }  -- Up-Left
    },

    -- Diamond (radius 1 Manhattan distance)
    DIAMOND = {
        { col = 0,  row = 0 },  -- Center
        { col = 0,  row = -1 }, -- Up
        { col = 1,  row = 0 },  -- Right
        { col = 0,  row = 1 },  -- Down
        { col = -1, row = 0 }   -- Left
    },

    -- 3x3 square (center + all surrounding tiles)
    SQUARE_3x3 = {
        { col = -1, row = -1 }, { col = 0, row = -1 }, { col = 1, row = -1 },
        { col = -1, row = 0 }, { col = 0, row = 0 }, { col = 1, row = 0 },
        { col = -1, row = 1 }, { col = 0, row = 1 }, { col = 1, row = 1 }
    },

    -- Horizontal line (length 3)
    HORIZONTAL_LINE = {
        { col = -1, row = 0 },
        { col = 0,  row = 0 },
        { col = 1,  row = 0 }
    },

    -- Vertical line (length 3)
    VERTICAL_LINE = {
        { col = 0, row = -1 },
        { col = 0, row = 0 },
        { col = 0, row = 1 }
    },
}

return Shapes
