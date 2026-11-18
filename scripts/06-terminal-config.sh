#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
setup_sudo
ensure_local_bin

mkdir -p "$HOME/.config/fish"
cp "$REPO_ROOT/config/fish/config.fish" "$HOME/.config/fish/config.fish"
cp "$REPO_ROOT/config/tmux.conf" "$HOME/.tmux.conf"
log_success "Fish and tmux configurations copied."

if ! has fish; then
    log_error "Fish is not installed; cannot configure the default shell."
    exit 1
fi

fish_path="$(command -v fish)"
if ! grep -qxF "$fish_path" /etc/shells; then
    printf '%s\n' "$fish_path" | run_root tee -a /etc/shells >/dev/null
fi

current_user="${USER:-$(id -un)}"
current_shell="$(getent passwd "$current_user" | cut -d: -f7)"
if [ "$current_shell" != "$fish_path" ]; then
    if ! run_root chsh -s "$fish_path" "$current_user" && ! chsh -s "$fish_path" "$current_user"; then
        log_warn "Could not change the default shell. Run: chsh -s $fish_path"
    fi
fi
