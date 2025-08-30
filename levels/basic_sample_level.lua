local Player = require('game.Player')
local Enemy = require('game.entities.Enemy')
local Grid = require('game.Grid')
local LevelState = require('game.LevelState')
local Fireball = require('game.attacks.Fireball')
local Wall = require('game.entities.Wall')

return function(config)
  local state = LevelState:new()

  -- Create grid
  state.grid = Grid:new(config.cols, config.rows, config.tileSize)

  -- Place walls on the outer ring
  state.walls = {}
  for col = 1, config.cols do
    for row = 1, config.rows do
      if col == 1 or col == config.cols or row == 1 or row == config.rows then
        local wall = Wall:new(col, row)
        table.insert(state.walls, wall)
        state.grid:setCost(col, row, math.huge)
        state.grid:setEntity(col, row, wall)
      end
    end
  end

  -- Create player at (3,3)
  local player = Player:new(3, 3)

  -- Fireball
  local fireball = Fireball:new(player, state.grid)

  table.insert(player.attacks, fireball)

  fireball.player = player

  state.players = { player }

  -- Create two enemies at (8,8) and (10,5)
  state.enemies = {
    Enemy:new(8, 8),
    Enemy:new(10, 5)
  }

  -- Optionally set the current player
  state.currentPlayer = state.players[1]

  return state
end
