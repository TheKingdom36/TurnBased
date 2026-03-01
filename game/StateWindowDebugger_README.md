# StateWindowDebugger Usage Guide

## Overview

`StateWindowDebugger` is a utility class that opens a second window displaying real-time level state information. It automatically updates alongside your main game state, making it useful for debugging and monitoring game state changes.

## Features

- **Real-time State Display**: Shows current turn, game phase, players, enemies, selection info
- **Player Stats Monitoring**: Displays HP, MP, movement, and bones for the current player
- **Attack Tracking**: Shows selected attack and reachable tiles for attacks
- **Event History**: Keeps recent state changes for reference
- **Scrollable Display**: Use up/down arrow keys to scroll through information
- **Automatic Updates**: Syncs with level state every frame

## Integration

### 1. Initialize in your Level class

```lua
local StateWindowDebugger = require('game.StateWindowDebugger')

function Level:create(levelState, config)
    -- ... existing code ...

    -- Create the debug window (optional parameters: width, height)
    level.stateDebugger = StateWindowDebugger:new(levelState, 400, 600)

    return level
end
```

### 2. Update in your Level:update method

```lua
function Level:update(dt)
    -- ... existing update code ...

    if self.stateDebugger then
        self.stateDebugger:update(dt)
    end
end
```

### 3. Draw in your Level:draw method

```lua
function Level:draw()
    -- ... existing draw code ...

    if self.stateDebugger then
        self.stateDebugger:draw()
    end
end
```

### 4. (Optional) Handle keypresses

```lua
function Level:keypressed(key)
    -- ... existing keypressed code ...

    if key == "f12" then  -- Or any hotkey you prefer
        if self.stateDebugger then
            self.stateDebugger:toggle()
        end
    end

    -- Also route arrow key presses to debugger for scrolling
    if self.stateDebugger and self.stateDebugger.isOpen then
        self.stateDebugger:keypressed(key)
    end
end
```

## API Reference

### Constructor

```lua
StateWindowDebugger:new(levelState, windowWidth, windowHeight)
```

- **levelState**: Reference to your LevelState object
- **windowWidth**: Width of debug window (default: 400)
- **windowHeight**: Height of debug window (default: 600)

### Methods

#### update(dt)

Updates the debugger each frame, records state snapshots.

#### draw()

Renders the debug window with current state information.

#### scroll(amount)

Scroll the content (positive = down, negative = up).

#### keypressed(key)

Handle keyboard input for scrolling.

#### toggle()

Show/hide the debug window.

#### close()

Close the debug window.

## Displayed Information

The debug window shows:

- **Turn Number**: Current game turn
- **Game Phase**: Current phase (TURN_START, PLAYER_TURN, etc.)
- **Current Player**: Name of the player whose turn it is
- **Player/Enemy Counts**: Total number of players and enemies
- **Selection Info**: Selected tiles (first and second)
- **Reachable Tiles**: Count of tiles the player can move to
- **Selected Attack**: Name and reachable tiles for attack
- **Player Stats**: HP, MP, Movement, Bones count
- **Recent Events**: History of recent state changes

## Notes

- The debug window is independent of the main window
- Use arrow keys to scroll through information if content exceeds window height
- State history keeps the last 20 snapshots for reference
- The debugger can be toggled on/off without affecting gameplay
