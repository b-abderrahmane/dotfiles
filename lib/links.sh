#!/usr/bin/env bash
# Shared symlink map: repo-relative source  ->  absolute target path.
# Sourced by install.sh (to create links) and check.sh (to report status).
#
# Each entry: "<os>|<repo source>|<target>"
#   <os> = all | mac | linux   (which platforms the link applies to)
# Targets may contain ~ and are expanded at use sites.

DOTFILES_LINKS=(
  "all|zsh/zshrc|~/.zshrc"
  "all|tmux/tmux.conf|~/.tmux.conf"
  "all|kitty/kitty.conf|~/.config/kitty/kitty.conf"
  # Claude Code: shared harness config + custom status line. Machine-local
  # overrides/secrets go in ~/.claude/settings.local.json (untracked).
  "all|claude/settings.json|~/.claude/settings.json"
  "all|claude/statusline.py|~/.claude/statusline.py"

  "mac|aerospace/aerospace.toml|~/.aerospace.toml"
  "mac|ghostty/config|~/Library/Application Support/com.mitchellh.ghostty/config"
  # Full Karabiner profile — the Ctrl→Cmd rule is baked in, so it auto-applies
  # (no UI import needed). control_to_commands_except_terminals.json stays in the
  # repo only as a standalone rule for manual import on machines that want it.
  "mac|karabiner/karabiner.json|~/.config/karabiner/karabiner.json"

  "linux|i3/config|~/.config/i3/config"
  "linux|ghostty/config|~/.config/ghostty/config"
)

# Detect platform -> sets DOTFILES_OS to "mac" or "linux".
case "$(uname -s)" in
  Darwin) DOTFILES_OS="mac" ;;
  Linux)  DOTFILES_OS="linux" ;;
  *)      DOTFILES_OS="unknown" ;;
esac

# Expand a leading ~ to $HOME (links never use ~user form).
dotfiles_expand() { printf '%s' "${1/#\~/$HOME}"; }

# Returns 0 if a link entry applies to the current platform.
dotfiles_link_applies() { [ "$1" = "all" ] || [ "$1" = "$DOTFILES_OS" ]; }
