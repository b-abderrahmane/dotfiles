# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles. Each top-level directory holds the config for one tool, edited here and symlinked into place by `install.sh`. The repo is the source of truth — targets are symlinks pointing back here, so edits in the repo take effect live. When adding a new tool, follow the existing pattern: one directory per tool containing its native config file, then add a line to the symlink map in `lib/links.sh`.

## Scripts

- `./check.sh` — read-only prerequisite check (tools, apps, oh-my-zsh, Nerd Font). Exits non-zero if a *required* tool is missing; prints an install hint for each gap.
- `./install.sh [--dry-run]` — symlink every applicable config into place. Idempotent (correct links are left untouched, drift is fixed). A pre-existing real file is moved to `<target>.bak` before linking; `--dry-run` prints the plan without touching anything.
- `lib/links.sh` — the single source of truth for the symlink map and OS detection, sourced by both scripts. **Edit this, not the scripts, to add/change a link.** Each entry is `<os>|<repo source>|<target>` where `<os>` is `all`, `mac`, or `linux`.

## Deploying a config

`./install.sh` handles linking. Current map (see `lib/links.sh`):

| OS | Repo path | Target |
| --- | --- | --- |
| all | `zsh/zshrc` | `~/.zshrc` |
| all | `tmux/tmux.conf` | `~/.tmux.conf` |
| all | `kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| all | `claude/settings.json` | `~/.claude/settings.json` |
| all | `claude/statusline.py` | `~/.claude/statusline.py` |
| mac | `aerospace/aerospace.toml` | `~/.aerospace.toml` |
| mac | `ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config` |
| mac | `karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` |
| linux | `i3/config` | `~/.config/i3/config` |
| linux | `ghostty/config` | `~/.config/ghostty/config` |

After editing, reload the relevant app: tmux `prefix + :source-file`, AeroSpace `alt-shift-c` (`reload-config` binding), Ghostty/kitty restart or in-app reload.

**Karabiner**: `install.sh` symlinks the full `karabiner.json`, which has the Ctrl→Cmd rule baked into the profile — so it applies automatically once Karabiner-Elements is running (no UI import). The standalone `control_to_commands_except_terminals.json` is kept in the repo only as an importable rule for machines that don't want the whole profile.

## Cross-cutting design

The key/copy-paste setup spans three files and only makes sense together:

- **Karabiner** (`karabiner.json`, with the same rule also kept standalone in `control_to_commands_except_terminals.json`) remaps Left/Right Control → Command system-wide, *except* in terminal apps (Terminal, iTerm2, Alacritty, kitty, WezTerm, Warp). So in normal apps Ctrl behaves like macOS Cmd.
- Because terminals are excluded from that remap, **Ghostty** keeps real terminal-style `ctrl+shift+c/v` for copy/paste. When editing terminal keybinds, preserve this — copy/paste must not collide with the Cmd-remap behavior.
- If you add a new terminal emulator, add its bundle identifier to the Karabiner `frontmost_application_unless` exclusion list, or Ctrl will be hijacked inside it.

The window-manager bindings are deliberately **i3-style**: `aerospace.toml` (macOS) mirrors `i3/config` (Linux). Keep keybindings consistent across the two when changing either. Note AeroSpace uses `alt-j/k/l/semicolon` for focus (not vim `h/j/k/l`) — `alt-h`/`alt-v` are bound to split horizontal/vertical instead.

## AeroSpace ⟂ macOS Spaces (the #1 source of confusion)

AeroSpace **workspaces are NOT macOS Mission Control Spaces.** AeroSpace is a tiling layer that runs inside a *single* native Space; its workspaces (switched with `alt-1`…`alt-0`, windows moved with `alt-shift-1`…`alt-shift-0`) are invisible to Mission Control and vice-versa. The intended setup is **one native Desktop** with AeroSpace managing everything inside it. When diagnosing "spaces" complaints, first establish whether the user means native Spaces or AeroSpace workspaces — they almost always mean native by accident.

Diagnostics (read-only):
- `aerospace list-monitors`, `aerospace list-workspaces --all`, `aerospace list-windows --all --format '%{workspace} %{app-name} | %{window-title}'`
- Native Space count/types: convert `~/Library/Preferences/com.apple.spaces.plist` with `plutil -convert xml1` and read `SpacesDisplayConfiguration → Management Data → Monitors[].Spaces[].type` (`0` = desktop, `4` = native-fullscreen app). More than one `type 0`, or any `type 4`, means native Spaces are in play.

Common symptoms and causes:
- **"Spaces 3–6 duplicate space 2"** → user created extra native Desktops, or has apps in native fullscreen (green button → each becomes its own native Space). Fix: collapse to one Desktop in Mission Control; use AeroSpace's `alt-f` instead of the green button.
- **"Some windows are sticky / appear on every workspace"** → those windows are not managed by AeroSpace, so it never moves them on workspace switch. Confirm by switching to an empty workspace (`aerospace workspace N`) and seeing what stays; cross-check against `list-windows --all` (sticky apps won't appear). Root cause is usually macOS **"Assign To → All Desktops"** (Dock icon → Options). Gotcha: with a single Desktop macOS *hides* the "Assign To" submenu, so you must temporarily add a 2nd Desktop in Mission Control to set it back to "None". Certain Electron/utility apps (e.g. Claude desktop app, Music, Karabiner-Elements settings) may resist tiling regardless.

Recommended macOS setting (already applied on this user's machine): `defaults write com.apple.dock mru-spaces -bool false; killall Dock` to stop auto-rearranging Spaces. NOTE: `killall Dock` does not always auto-respawn promptly — if the Dock/Mission Control go missing, `launchctl kickstart -k gui/$(id -u)/com.apple.Dock.agent`.

## Notes

- **Machine-local zsh config** goes in `~/.zshrc.local` (untracked), sourced near the top of `zsh/zshrc` via `[ -f ~/.zshrc.local ] && source ~/.zshrc.local`. Per-machine PATH entries (e.g. `$HOME/.local/bin`), secrets, and overrides belong there — do **not** add them to the tracked `zsh/zshrc`, which must stay identical across machines.
- **Claude Code config**: only `~/.claude/settings.json` (shared harness config) and `~/.claude/statusline.py` (the custom status line it invokes) are tracked, under `claude/`. The status-line command uses `~/.claude/statusline.py` (not an absolute `/Users/...` path) so it stays portable. Machine-local Claude overrides/secrets go in `~/.claude/settings.local.json` (untracked, Claude merges it over `settings.json`). Everything else under `~/.claude/` (sessions, history, projects, caches, telemetry, plugins) is runtime state — never track it.
- `zsh/zshrc` depends on oh-my-zsh (`$ZSH="$HOME/.oh-my-zsh"`); current plugin set is `git`.
- Configs assume Apple Silicon Homebrew paths (`/opt/homebrew/bin/zsh`).
- This repo is synced across two Macs: one is the "live" source that pushes comprehensive config to `origin/main`; other machines pull and run `./install.sh`. Before pulling on a machine with local edits, fetch and check `main..origin/main` for overlap (incoming commits often rewrite `README.md`/`zsh/zshrc`).
