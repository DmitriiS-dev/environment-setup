#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
ensure_local_bin

if ! has atuin; then
    installer="$(mktemp)"
    trap 'rm -f "$installer"' EXIT
    log_info "Installing Atuin..."
    curl --proto '=https' --tlsv1.2 -fsSL https://setup.atuin.sh -o "$installer"
    bash "$installer" --no-modify-path
    if [ -x "$HOME/.atuin/bin/atuin" ] && [ ! -e "$HOME/.local/bin/atuin" ]; then
        ln -s "$HOME/.atuin/bin/atuin" "$HOME/.local/bin/atuin"
    fi
fi

if ! has atuin; then
    log_error "Atuin installation completed, but its executable is missing."
    exit 1
fi
log_success "Atuin is ready: $(atuin --version)"
