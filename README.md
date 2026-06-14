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
- [tmux](./tmux/) - Terminal multiplexer, with a themed status bar (battery, CPU load/cores, RAM & disk used/total, LAN IP, DNS server, clock) driven by [`tmux/statusbar.sh`](./tmux/statusbar.sh)
- [zsh](./zsh/) - Shell configuration (oh-my-zsh)

### Shell Prompt
- [Starship](./starship/) - Loaded by `zsh/zshrc` when installed (otherwise falls back to the oh-my-zsh theme). Shows directory, git branch/status, **Kubernetes context** when one is set, command duration, and contextual language versions. Needs a Nerd Font for the glyphs.

### Editor / Agent
- [Claude Code](./claude/) - `settings.json` plus a custom `statusline.py` status line

### Other Tools
- [i3](./i3/) - Linux i3 configuration for reference

## Installation

The repo is the source of truth: each tool's config lives in its own directory
here and is **symlinked into place** by `install.sh`, so edits in the repo take
effect live. The symlink map lives in [`lib/links.sh`](./lib/links.sh).

1. Clone the repository:
```bash
git clone <your-repo-url> ~/workspace/dotfiles
cd ~/workspace/dotfiles
```

2. Check prerequisites (read-only — installs nothing, just reports gaps and
   prints an install hint for each):
```bash
./check.sh
```

3. Install the recommended tools (macOS / Homebrew):
```bash
brew install --cask nikitabobko/tap/aerospace karabiner-elements ghostty
brew install tmux starship
brew install --cask font-jetbrains-mono-nerd-font   # Nerd Font for prompt/status-bar glyphs
```

4. Symlink everything into place. Idempotent — correct links are left untouched,
   drift is fixed, and any pre-existing real file is backed up to `<target>.bak`
   first. Preview without touching anything via `--dry-run`:
```bash
./install.sh --dry-run   # show the plan
./install.sh             # apply
```

5. Reload the relevant app after edits: tmux `prefix + r`, AeroSpace `Alt+Shift+c`,
   Ghostty/Kitty restart. New shells pick up the prompt automatically.

> **Adding a tool:** drop its config in a new top-level directory and add one
> line to the symlink map in `lib/links.sh` — don't edit the scripts.
> Machine-local zsh (PATH, secrets) goes in `~/.zshrc.local` (untracked); see
> [CLAUDE.md](./CLAUDE.md) for the full design notes.

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

### tmux (prefix = `Ctrl+b`)
- `prefix r` - Reload config
- `prefix |` / `prefix -` - Split vertical / horizontal (keeps current dir)
- `prefix h/j/k/l` - Focus pane left/down/up/right
- `prefix H/J/K/L` - Resize pane (repeatable)
- `v` / `y` in copy-mode - Begin selection / yank
- Status bar shows battery · CPU (load/cores) · RAM (used/total) · disk (used/total) · IP · DNS · date/time · host

### Shell Prompt (Starship)
- Directory · git branch & status · Kubernetes context (when set) · command duration · language versions
- Configured in [`starship/starship.toml`](./starship/starship.toml); edit and open a new shell to see changes

## Contributing

Feel free to fork and adapt to your needs. PRs welcome for improvements!

## License

MIT
