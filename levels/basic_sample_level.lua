local Player = require('game.Player')
local Enemy = require('game.entities.Enemy')
local Grid = require('game.Grid')
local LevelState = require('game.LevelState')
local Fireball = require('game.attacks.Fireball')
local Iceball = require('game.attacks.Iceball')
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
        table.insert(state.entities, wall)
      end
    end
  end

  -- Create player at (3,3)

  local stats = {
    actionPointsRemaining = 2,
    health = 100,
    maxHealth = 100,
    speed = 12,
    mp = 10,
    maxMp = 10,
    state = Player.State.WAITING
  }

  local player = Player:new(3, 4, "Jack", stats)

  local fireball = Fireball:new(player, state.grid)
  table.insert(player.attacks, fireball)
  fireball.player = player

  local iceball = Iceball:new(player, state.grid)
  table.insert(player.attacks, iceball)
  iceball.player = player

  state.players = { player }

  local enemyStats = function() 
    return {
      actionPointsRemaining = 2,
      health = 100,
      maxHealth = 100,
      speed = 10,
      state = Player.State.WAITING
    }
  end


  -- Create two enemies at (8,8) and (10,5)
  state.enemies = {
    Enemy:new(8, 8 , "one", enemyStats()),
    Enemy:new(10, 5, "two", enemyStats()),
    Enemy:new(8, 9, "three", enemyStats()),
  }


  -- Optionally set the current player
  state.currentPlayer = state.players[1]

  return state
end
