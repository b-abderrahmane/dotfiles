# AeroSpace Configuration

AeroSpace is an i3-like tiling window manager for macOS. This configuration replicates the i3 window manager experience with macOS-native features.

## Purpose

Provide a keyboard-driven, tiling window management experience on macOS that closely mirrors the Linux i3 window manager workflow. Perfect for users transitioning from Linux or wanting a more efficient window management system.

## Configuration File

- `aerospace.toml` - Main configuration file that should be symlinked to `~/.aerospace.toml`

## Key Features

### i3-Compatible Keybindings
All keybindings use `Alt` (Option) as the modifier key, just like i3 uses `Mod1` or `Mod4`:
- Consistent with i3 muscle memory
- Doesn't conflict with macOS system shortcuts (which use Command)
- Natural for users coming from Linux

### Workspace Management
- **10 workspaces** numbered 1-10 (like i3)
- **Multi-monitor support** with automatic workspace assignment:
  - Workspaces 1-5 → Monitor 1 (primary external)
  - Workspaces 6-10 → Monitor 2 (secondary/built-in)
- **Workspace switching** with `Alt+1` through `Alt+0`
- **Move windows** to workspaces with `Alt+Shift+1` through `Alt+Shift+0`

### Window Navigation
- **Vim-style navigation** using `j/k/l/;` keys
- **Focus wrapping** - navigation wraps around workspace boundaries
- **Move windows** with `Alt+Shift+j/k/l/;`

### Layout Management
- **Tiling layouts** for automatic window arrangement
- **Horizontal/Vertical splits** like i3
- **Accordion modes** (h_accordion/v_accordion) similar to i3's tabbed/stacking
- **Floating windows** support
- **Fullscreen mode**

### Mouse Integration
- Mouse follows focus when switching monitors
- Lazy centering to reduce cursor jumping

## Keyboard Shortcuts

### Essential Bindings

#### Window Management
- `Alt+Enter` - Open new terminal (Ghostty)
- `Alt+f` - Toggle fullscreen
- `Alt+Shift+Space` - Toggle between floating and tiling

#### Navigation
- `Alt+j` - Focus window to the left
- `Alt+k` - Focus window below
- `Alt+l` - Focus window above
- `Alt+;` - Focus window to the right

#### Moving Windows
- `Alt+Shift+j` - Move window left
- `Alt+Shift+k` - Move window down
- `Alt+Shift+l` - Move window up
- `Alt+Shift+;` - Move window right

#### Layouts
- `Alt+h` - Split horizontal
- `Alt+v` - Split vertical
- `Alt+s` - Vertical accordion (like i3 stacking)
- `Alt+w` - Horizontal accordion (like i3 tabbed)
- `Alt+e` - Tiles layout (horizontal/vertical toggle)

#### Workspaces
- `Alt+1` to `Alt+0` - Switch to workspace 1-10
- `Alt+Shift+1` to `Alt+Shift+0` - Move window to workspace 1-10

#### System
- `Alt+Shift+c` - Reload configuration
- `Alt+r` - Enter resize mode

### Resize Mode

When in resize mode (`Alt+r`):
- `h` - Decrease width by 50px
- `j` - Increase height by 50px
- `k` - Decrease height by 50px
- `l` - Increase width by 50px
- `Enter` or `Esc` - Exit resize mode

## Multi-Monitor Setup

The configuration automatically assigns workspaces to monitors:

**Monitor 1 (Primary External):**
- Workspaces 1, 2, 3, 4, 5
- Typically your main work monitor

**Monitor 2 (Secondary/Built-in):**
- Workspaces 6, 7, 8, 9, 10
- Built-in MacBook display or second external monitor

This ensures consistent workspace locations regardless of monitor connection/disconnection.

## Installation

1. Install AeroSpace:
```bash
brew install --cask nikitabobko/tap/aerospace
```

2. Symlink the configuration:
```bash
ln -sf ~/workspace/dotfiles/aerospace/aerospace.toml ~/.aerospace.toml
```

3. Start AeroSpace:
```bash
open -a AeroSpace
```

4. Reload configuration:
```bash
aerospace reload-config
# Or use Alt+Shift+c
```

## Configuration Details

### Normalizations (Disabled)
```toml
enable-normalization-flatten-containers = false
enable-normalization-opposite-orientation-for-nested-containers = false
```
Disabled to match i3 behavior more closely. i3 doesn't do automatic container normalization.

### Mouse Behavior
```toml
on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
```
When you switch monitors (by moving focus), the mouse follows to the center of the new monitor.

### Terminal Application
```toml
alt-enter = 'exec-and-forget osascript -e ...'
```
Opens Ghostty terminal. Change this if you use a different terminal:
- For iTerm2: `tell application "iTerm2"`
- For Kitty: `tell application "Kitty"`
- For Terminal: `tell application "Terminal"`

## Workflow Examples

### Basic Window Management
1. Open a terminal: `Alt+Enter`
2. Split horizontally: `Alt+h`
3. Open another app
4. Navigate between windows: `Alt+j/k/l/;`
5. Move windows around: `Alt+Shift+j/k/l/;`

### Workspace Workflow
1. Switch to workspace 2: `Alt+2`
2. Open browser and code editor
3. Switch to workspace 3: `Alt+3`
4. Open communication apps
5. Move a window from workspace 3 to 2: `Alt+Shift+2`

### Multi-Monitor Workflow
1. Main work on workspaces 1-3 (external monitor)
2. Communications on workspace 6 (laptop screen)
3. Monitoring/terminals on workspace 7 (laptop screen)
4. Quick access with `Alt+1`, `Alt+6`, `Alt+7`

## Differences from i3

### Not Yet Supported
- `focus parent` / `focus child` - Not implemented in AeroSpace
- `focus toggle_tiling_floating` - Redundant in AeroSpace's model
- Scratchpad workspace - Not implemented

### Different Behavior
- **Accordion modes** instead of stacking/tabbed (similar but different)
- **No window borders** by default (macOS window decorations)
- **Native macOS windows** (not X11)

### Advantages over i3
- **Native macOS app support** (notifications, menu bar, etc.)
- **Better macOS integration** (Spaces, Mission Control compatibility)
- **GPU acceleration** (native macOS rendering)

## Troubleshooting

### AeroSpace Not Starting
```bash
# Check if running
ps aux | grep -i aerospace

# Start manually
open -a AeroSpace

# Check logs
tail -f ~/Library/Logs/AeroSpace/aerospace.log
```

### Keybindings Not Working
1. Grant accessibility permissions:
   - System Settings → Privacy & Security → Accessibility
   - Add and enable AeroSpace
2. Reload config: `Alt+Shift+c`
3. Restart AeroSpace

### Workspaces Not Switching
- Ensure AeroSpace has accessibility permissions
- Check for keybinding conflicts with other apps
- Verify the configuration file is valid: `aerospace validate-config`

### Windows Not Tiling
- Some apps don't support tiling (they force floating mode)
- System apps may have restrictions
- Try toggling `Alt+Shift+Space` to force tiling

## Customization

### Change Terminal Application
Edit the `alt-enter` binding in `aerospace.toml`:
```toml
alt-enter = '''exec-and-forget osascript -e '
tell application "YourTerminal"
    do script
    activate
end tell'
'''
```

### Change Keybindings
Modify the `[mode.main.binding]` section. Example:
```toml
# Use cmd instead of alt
cmd-1 = 'workspace 1'
cmd-shift-1 = 'move-node-to-workspace 1'
```

### Add More Workspaces
Add workspace-to-monitor assignments:
```toml
[workspace-to-monitor-force-assignment]
11 = 1  # Add workspace 11 to monitor 1
```

And add keybindings:
```toml
alt-minus = 'workspace 11'
alt-shift-minus = 'move-node-to-workspace 11'
```

## Resources

- [AeroSpace Official Site](https://github.com/nikitabobko/AeroSpace)
- [AeroSpace Documentation](https://nikitabobko.github.io/AeroSpace/)
- [i3 User's Guide](https://i3wm.org/docs/userguide.html) (for comparison)
- [i3 Reference Config](https://github.com/i3/i3/blob/next/etc/config)

## Tips and Tricks

### Quick Workspace Setup
Create a startup script to automatically organize your apps:
```bash
# Move apps to specific workspaces on startup
aerospace move-node-to-workspace --window-id $(aerospace list-windows | grep "Browser" | awk '{print $1}') 1
aerospace move-node-to-workspace --window-id $(aerospace list-windows | grep "Slack" | awk '{print $1}') 6
```

### Integrate with Sketchybar
AeroSpace works great with [Sketchybar](https://github.com/FelixKratz/SketchyBar) for a status bar similar to i3bar.

### Command-Line Control
```bash
# List all windows
aerospace list-windows

# List workspaces
aerospace list-workspaces

# Move window to workspace
aerospace move-node-to-workspace 3

# Focus window
aerospace focus --window-id <id>
```

## Philosophy

This configuration aims to provide a **keyboard-first**, **efficient**, and **predictable** window management experience. The goal is to spend less time arranging windows and more time being productive.

Key principles:
- **Keyboard-driven** - Mouse is optional
- **Predictable** - Windows behave consistently
- **Fast** - No animations, instant response
- **i3-compatible** - Familiar for Linux users
