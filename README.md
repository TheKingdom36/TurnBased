# Turn-based Game Template for LÖVE 2D

A comprehensive template for creating turn-based games using LÖVE 2D and Lua. This template provides a solid foundation with modular components that can be easily extended and customized.

## Features

- **Turn Management**: Automatic turn switching with configurable time limits
- **Player System**: Extensible player class with health, actions, and movement
- **Game State Management**: Centralized game state handling
- **UI System**: Modular UI components with buttons, panels, and timers
- **Configuration System**: Easy-to-modify game settings
- **Action System**: Extensible action framework for players

## Requirements

- [LÖVE 2D](https://love2d.org/) (version 11.0 or higher recommended)
- Lua 5.1 or higher

## Installation

1. Download and install LÖVE 2D from [love2d.org](https://love2d.org/)
2. Clone or download this template
3. Run the game using one of these methods:

### Method 1: Drag and Drop
Drag the project folder onto the LÖVE executable.

### Method 2: Command Line
```bash
love /path/to/your/game
```

### Method 3: Create a .love file
```bash
zip -9 -r game.love . -x "*.git*" "*.md"
love game.love
```

## How to Play

- **Left Click** on a player to perform an action (when it's their turn)
- **Spacebar** to skip the current turn
- **Escape** to quit the game
- **UI Buttons** for additional actions

## Project Structure

```
├── main.lua              # Main entry point
├── game/
│   ├── Config.lua        # Game configuration and constants
│   ├── GameState.lua     # Game state management
│   ├── TurnManager.lua   # Turn-based gameplay logic
│   ├── Player.lua        # Player class and actions
│   └── UI.lua           # User interface system
└── README.md            # This file
```

## Customization

### Adding New Actions

1. Open `game/Player.lua`
2. Add a new action method:
```lua
function Player:newAction()
    -- Your action logic here
    print(self.name .. " performed new action!")
end
```

3. Register the action in the constructor:
```lua
player:addAction("New Action", function(self) self:newAction() end)
```

### Modifying Game Settings

Edit `game/Config.lua` to change:
- Window size and title
- Player health and speed
- Turn duration and warning time
- UI colors and sizes

### Adding New Players

In `main.lua`, create additional players:
```lua
local player3 = Player:new("Player 3", 400, 300, {r = 0.5, g = 1.0, b = 0.5})
turnManager:addPlayer(player3)
```

### Extending the UI

1. Add new UI elements in `game/UI.lua`
2. Create new panels or buttons as needed
3. Update the draw methods to include your new elements

## Game Components

### GameState
Manages overall game state including:
- Current player
- Game phase (playing, paused, game over)
- Turn number
- Scores
- Winner determination

### TurnManager
Handles turn-based gameplay:
- Player turn rotation
- Turn timing with warnings
- Turn start/end callbacks
- Automatic turn progression

### Player
Represents game characters with:
- Health and damage system
- Movement and positioning
- Action system with cooldowns
- Visual representation

### UI
Provides user interface elements:
- Action buttons
- Information panels
- Turn timer
- Health bars
- Interactive elements

## Development Tips

1. **Modular Design**: Each component is self-contained and can be modified independently
2. **Configuration First**: Use the Config.lua file for easy tweaking
3. **Extensible Actions**: The action system allows for easy addition of new player abilities
4. **Event-Driven**: Use callbacks for turn events to add custom logic

## Example Extensions

### Combat System
```lua
function Player:attack(target)
    local damage = math.random(10, 20)
    target:takeDamage(damage)
    print(self.name .. " attacks " .. target.name .. " for " .. damage .. " damage!")
end
```

### Special Abilities
```lua
function Player:specialAbility()
    if self.mana >= 20 then
        self.mana = self.mana - 20
        self.health = math.min(self.maxHealth, self.health + 30)
        print(self.name .. " uses healing ability!")
    end
end
```

### AI Players
```lua
function Player:aiTurn()
    -- Simple AI logic
    local actions = {"moveAction", "attackAction", "defendAction"}
    local action = actions[math.random(1, #actions)]
    self:executeAction(action)
end
```

## Troubleshooting

### Common Issues

1. **Game won't start**: Make sure LÖVE 2D is properly installed
2. **Missing modules**: Check that all files are in the correct directory structure
3. **Performance issues**: Reduce the number of players or simplify graphics

### Debug Mode

Add debug information by modifying the draw functions to show additional data:
```lua
-- In main.lua love.draw()
love.graphics.print("Debug: " .. debugInfo, 10, 30)
```

## License

This template is provided as-is for educational and development purposes. Feel free to modify and use it in your own projects.

## Contributing

Feel free to submit improvements, bug fixes, or additional features to make this template even better!

---

Happy coding! 🎮 