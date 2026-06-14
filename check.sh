#!/usr/bin/env bash
# Verify prerequisites for these dotfiles. Read-only: never changes anything.
# Exits non-zero if a required tool is missing.
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/links.sh
source "$DOTFILES_DIR/lib/links.sh"

green=$'\e[32m'; red=$'\e[31m'; yellow=$'\e[33m'; dim=$'\e[2m'; reset=$'\e[0m'
missing_required=0

ok()   { printf '  %s✓%s %s\n' "$green" "$reset" "$1"; }
warn() { printf '  %s!%s %s %s%s%s\n' "$yellow" "$reset" "$1" "$dim" "${2:-}" "$reset"; }
bad()  { printf '  %s✗%s %s %s%s%s\n' "$red" "$reset" "$1" "$dim" "${2:-}" "$reset"; }

# check <required|optional> <label> <test-cmd...> [-- hint]
check() {
  local level="$1" label="$2"; shift 2
  local hint="" args=()
  while [ $# -gt 0 ]; do [ "$1" = "--" ] && { shift; hint="$*"; break; }; args+=("$1"); shift; done
  if "${args[@]}" >/dev/null 2>&1; then
    ok "$label"
  elif [ "$level" = required ]; then
    bad "$label" "$hint"; missing_required=1
  else
    warn "$label" "$hint"
  fi
}

echo "Prerequisites (${DOTFILES_OS}):"

check required "git"      command -v git      -- "xcode-select --install"
check required "zsh"      command -v zsh      -- "brew install zsh"
check required "oh-my-zsh" test -d "$HOME/.oh-my-zsh" \
  -- 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
check optional "tmux"     command -v tmux     -- "brew install tmux"
check optional "starship (prompt)" command -v starship -- "brew install starship"
check optional "gh (zshrc plugin)" command -v gh -- "brew install gh"

if [ "$DOTFILES_OS" = mac ]; then
  check required "brew"      command -v brew   -- 'see https://brew.sh'
  check optional "aerospace" command -v aerospace -- "brew install --cask nikitabobko/tap/aerospace"
  check optional "ghostty"   test -d /Applications/Ghostty.app -- "brew install --cask ghostty"
  check optional "Karabiner-Elements" test -d /Applications/Karabiner-Elements.app \
    -- "brew install --cask karabiner-elements"
fi

# JetBrainsMono Nerd Font (referenced by ghostty config)
if ls "$HOME"/Library/Fonts/JetBrainsMono*Nerd* /Library/Fonts/JetBrainsMono*Nerd* >/dev/null 2>&1 \
   || fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
  ok "JetBrainsMono Nerd Font"
else
  warn "JetBrainsMono Nerd Font" "brew install --cask font-jetbrains-mono-nerd-font"
fi

echo
if [ "$missing_required" -eq 0 ]; then
  printf '%sAll required prerequisites present.%s\n' "$green" "$reset"
else
  printf '%sMissing required prerequisites — install them before running ./install.sh%s\n' "$red" "$reset"
fi
exit "$missing_required"
