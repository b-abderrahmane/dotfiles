# Karabiner-Elements Configuration

Karabiner-Elements is a powerful keyboard customizer for macOS. This configuration enables a Linux-like keyboard experience while preserving macOS-specific functionality where needed.

## Purpose

The main goal is to unify keyboard shortcuts between macOS and Linux systems, making it easier to context-switch between environments. The key modification is mapping Control to Command in GUI applications while preserving native Unix shortcuts in terminals.

## Configuration Files

- `karabiner.json` - Main configuration file that should be symlinked to `~/.config/karabiner/karabiner.json`
- `control_to_commands_except_terminals.json` - Standalone rule file (for importing into Karabiner UI)

## Key Mappings

### Control → Command (Context-Aware)

**In GUI Applications:**
- `Ctrl+C` → `Cmd+C` (Copy)
- `Ctrl+V` → `Cmd+V` (Paste)
- `Ctrl+X` → `Cmd+X` (Cut)
- `Ctrl+Z` → `Cmd+Z` (Undo)
- `Ctrl+A` → `Cmd+A` (Select All)
- `Ctrl+F` → `Cmd+F` (Find)
- `Ctrl+S` → `Cmd+S` (Save)
- `Ctrl+W` → `Cmd+W` (Close Tab/Window)
- `Ctrl+T` → `Cmd+T` (New Tab)
- `Ctrl+Q` → `Cmd+Q` (Quit)
- And all other Ctrl combinations

**In Terminal Applications (Preserved):**
Terminal apps keep native Unix shortcuts:
- `Ctrl+C` - SIGINT (kill process)
- `Ctrl+D` - EOF
- `Ctrl+Z` - Suspend process
- `Ctrl+R` - Reverse search
- `Ctrl+A/E` - Move to beginning/end of line
- And all other Unix terminal shortcuts

### Supported Terminal Applications

The configuration excludes these terminal emulators from Control → Command mapping:
- Terminal.app (com.apple.Terminal)
- iTerm2 (com.googlecode.iterm2)
- Alacritty (io.alacritty)
- Kitty (net.kovidgoyal.kitty)
- WezTerm (com.github.wez.wezterm)
- Warp (dev.warp.Warp, dev.warp.Warp-Stable)
- Ghostty (com.mitchellh.ghostty)

## Why This Mapping?

### Problem
- macOS uses Command for system shortcuts (Cmd+C, Cmd+V)
- Linux uses Control for the same shortcuts (Ctrl+C, Ctrl+V)
- Terminals use Control for Unix commands (Ctrl+C = kill, Ctrl+Z = suspend)

### Solution
- Map Control → Command in GUI apps for consistent muscle memory
- Preserve Control in terminals for proper Unix command behavior
- Get the best of both worlds

## Installation

1. Install Karabiner-Elements:
```bash
brew install --cask karabiner-elements
```

2. Backup existing configuration (if any):
```bash
mv ~/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json.backup
```

3. Symlink this configuration:
```bash
ln -sf ~/workspace/dotfiles/karabiner/karabiner.json ~/.config/karabiner/karabiner.json
```

4. Karabiner should automatically detect and reload the configuration

## Verifying the Configuration

1. Open a GUI app (browser, text editor)
   - Try `Ctrl+C` to copy - should work
   - Try `Ctrl+V` to paste - should work

2. Open a terminal
   - Try `Ctrl+C` with a running process - should send SIGINT
   - Try `Ctrl+R` - should trigger reverse search
   - Try `Cmd+C` to copy text - should work

## Customization

### Adding More Terminal Apps

If you use other terminal emulators, add their bundle identifier to the list:

1. Find the bundle ID:
```bash
osascript -e 'id of app "YourTerminalApp"'
```

2. Add to both manipulators in the `bundle_identifiers` array in `karabiner.json`:
```json
"bundle_identifiers": [
    "^com\\.apple\\.Terminal$",
    "^your\\.new\\.terminal$"
]
```

### Adding More Rules

You can add additional rules to the `complex_modifications.rules` array. Each rule can have:
- `description` - What the rule does
- `manipulators` - Array of key mappings
- `enabled` - Set to false to disable without deleting

Example structure:
```json
{
    "description": "Your rule description",
    "manipulators": [
        {
            "type": "basic",
            "from": {
                "key_code": "source_key",
                "modifiers": {"mandatory": ["modifier"]}
            },
            "to": [{"key_code": "target_key"}]
        }
    ]
}
```

## Troubleshooting

### Changes Not Taking Effect
1. Check Karabiner-Elements is running
2. Verify the symlink: `ls -la ~/.config/karabiner/karabiner.json`
3. Check Karabiner-EventViewer to see if keys are being captured
4. Reload config from Karabiner-Elements menu bar icon

### Some Apps Not Working
- Some apps may need to be restarted after configuration changes
- Some apps (especially security-related) may require granting Karabiner accessibility permissions

### Terminal Apps Not Recognized
- Verify the bundle identifier is correct: `osascript -e 'id of app "TerminalName"'`
- Restart the terminal app after configuration changes
- Check Karabiner's application permissions

## Resources

- [Karabiner-Elements Official Site](https://karabiner-elements.pqrs.org/)
- [Karabiner Documentation](https://karabiner-elements.pqrs.org/docs/)
- [Complex Modifications Gallery](https://ke-complex-modifications.pqrs.org/)

## Notes

- The configuration uses `frontmost_application_unless` to exclude terminals
- Both left and right Control keys are mapped
- The `optional: ["any"]` modifier allows Control to work with other modifiers
- Virtual keyboard is set to ISO layout (can be changed in the config)
