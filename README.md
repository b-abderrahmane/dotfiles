# dotfiles

My macOS configuration files for replicating a Linux/i3 window manager experience.

## Philosophy

This configuration aims to bring the efficiency and keyboard-driven workflow of Linux with i3 window manager to macOS. The goal is to minimize mouse usage, maximize productivity through keyboard shortcuts, and maintain consistent keybindings across terminal and GUI applications.

## Key Components

### [AeroSpace](./aerospace/) - Window Manager
AeroSpace is an i3-like tiling window manager for macOS. It provides:
- Workspace-based window organization (10 workspaces)
- Keyboard-driven window navigation and manipulation
- Multi-monitor support with workspace-to-monitor assignments
- i3-compatible keybindings (Alt-based)

See [aerospace/README.md](./aerospace/README.md) for detailed configuration.

### [Karabiner-Elements](./karabiner/) - Keyboard Remapping
Karabiner enables system-wide keyboard modifications to unify shortcuts between macOS and Linux:
- Control → Command mapping (except in terminals)
- Consistent copy/paste shortcuts across all apps
- Terminal exception handling for native Unix shortcuts

See [karabiner/README.md](./karabiner/README.md) for detailed configuration.

### Terminal Configurations
- [Ghostty](./ghostty/) - Modern terminal emulator
- [Kitty](./kitty/) - GPU-accelerated terminal
- [tmux](./tmux/) - Terminal multiplexer
- [zsh](./zsh/) - Shell configuration

### Other Tools
- [i3](./i3/) - Linux i3 configuration for reference

## Installation

### Prerequisites
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install AeroSpace
brew install --cask nikitabobko/tap/aerospace

# Install Karabiner-Elements
brew install --cask karabiner-elements
```

### Setup

1. Clone this repository:
```bash
git clone <your-repo-url> ~/workspace/dotfiles
cd ~/workspace/dotfiles
```

2. Set up Karabiner:
```bash
# Backup existing config if any
mv ~/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json.backup

# Symlink the config
ln -sf ~/workspace/dotfiles/karabiner/karabiner.json ~/.config/karabiner/karabiner.json
```

3. Set up AeroSpace:
```bash
# Symlink the config
ln -sf ~/workspace/dotfiles/aerospace/aerospace.toml ~/.aerospace.toml

# Restart AeroSpace
aerospace reload-config
```

4. Set up other tools as needed (tmux, zsh, etc.)

## Desired macOS Experience

The configuration creates a Linux/i3-like environment on macOS:

- **Window Management**: Tiling windows with keyboard shortcuts (Alt+hjkl navigation)
- **Workspaces**: 10 workspaces distributed across monitors
- **Keyboard-First**: All operations accessible via keyboard
- **Consistent Shortcuts**: Ctrl+C/V/X/Z work everywhere (mapped to Cmd on macOS)
- **Terminal Exception**: Native Unix shortcuts preserved in terminal apps
- **Mouse Optional**: Productivity without reaching for the mouse

## Key Differences from Standard macOS

1. **Alt (Option) is the modifier key** instead of Command for window management
2. **Control acts like Command** in GUI apps (for copy/paste/etc)
3. **Tiling window layout** instead of overlapping windows
4. **Workspace-based workflow** similar to virtual desktops in Linux
5. **Keyboard-driven** instead of mouse/trackpad-centric

## Quick Reference

### Window Management (AeroSpace)
- `Alt+Enter` - New terminal window
- `Alt+1-0` - Switch to workspace 1-10
- `Alt+Shift+1-0` - Move window to workspace 1-10
- `Alt+j/k/l/;` - Focus window left/down/up/right
- `Alt+Shift+j/k/l/;` - Move window left/down/up/right
- `Alt+h` - Split horizontal
- `Alt+v` - Split vertical
- `Alt+f` - Toggle fullscreen
- `Alt+r` - Resize mode

### System-wide Shortcuts (Karabiner)
- `Ctrl+C/V/X/Z` - Copy/paste/cut/undo in GUI apps
- `Ctrl+A` - Select all in GUI apps
- `Ctrl+F` - Find in GUI apps
- Native Unix shortcuts preserved in terminals

## Contributing

Feel free to fork and adapt to your needs. PRs welcome for improvements!

## License

MIT
