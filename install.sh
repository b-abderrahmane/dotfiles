#!/usr/bin/env bash
# Symlink dotfiles from this repo into their target locations.
# Idempotent: re-running fixes drift and leaves correct links untouched.
# Existing non-symlink files are backed up to <target>.bak before linking.
#
# Usage:
#   ./install.sh            apply changes
#   ./install.sh --dry-run  show what would change, touch nothing
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/links.sh
source "$DOTFILES_DIR/lib/links.sh"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

green=$'\e[32m'; yellow=$'\e[33m'; dim=$'\e[2m'; reset=$'\e[0m'
run() { if [ "$DRY_RUN" = 1 ]; then printf '%s   would: %s%s\n' "$dim" "$*" "$reset"; else "$@"; fi; }

[ "$DRY_RUN" = 1 ] && echo "DRY RUN — no changes will be made"
echo "Platform: $DOTFILES_OS"
echo

for entry in "${DOTFILES_LINKS[@]}"; do
  IFS='|' read -r os src target <<<"$entry"
  dotfiles_link_applies "$os" || continue

  source_path="$DOTFILES_DIR/$src"
  target_path="$(dotfiles_expand "$target")"

  if [ ! -e "$source_path" ]; then
    printf '%s!  missing source, skipping:%s %s\n' "$yellow" "$reset" "$src"
    continue
  fi

  # Already the correct symlink?
  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    printf '✓  %s\n' "$target"
    continue
  fi

  run mkdir -p "$(dirname "$target_path")"

  # Back up an existing real file/dir (or a wrong symlink) before replacing.
  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    if [ -L "$target_path" ]; then
      run rm "$target_path"
    else
      printf '%s   backup: %s -> %s.bak%s\n' "$dim" "$target" "$target" "$reset"
      run mv "$target_path" "$target_path.bak"
    fi
  fi

  run ln -s "$source_path" "$target_path"
  printf '%s→  linked %s%s\n' "$green" "$target" "$reset"
done

echo
echo "Done."
if [ "$DOTFILES_OS" = mac ]; then
  cat <<'EOF'

Manual follow-ups (macOS):
  • Karabiner: karabiner.json is symlinked in full, so the "Ctrl acts like Cmd
    (except terminals)" rule applies automatically — just confirm Karabiner-Elements
    is running and granted Input Monitoring permission.
  • Reload apps to pick up linked configs:
      tmux:      tmux source-file ~/.tmux.conf   (or restart)
      aerospace: alt-shift-c   (reload-config binding)
      ghostty:   restart the app
EOF
fi
