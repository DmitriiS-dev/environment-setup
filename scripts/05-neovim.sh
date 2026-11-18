#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
detect_arch
ensure_local_bin

if ! neovim_is_supported; then
    if [ -z "$NVIM_ARCH" ]; then
        log_error "No Neovim release binary configured for $ARCH_TYPE."
        exit 1
    fi
    archive="$(mktemp)"
    trap 'rm -f "$archive"' EXIT
    log_info "Installing Neovim 0.12+ ($NVIM_ARCH)..."
    curl -fSL "https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_ARCH}.tar.gz" -o "$archive"
    tar -xzf "$archive" -C "$HOME/.local" --strip-components=1
    hash -r
    if ! neovim_is_supported; then
        log_error "The downloaded Neovim is older than 0.12 or cannot run."
        exit 1
    fi
fi

mkdir -p "$HOME/.config/nvim"
cp -R "$REPO_ROOT/nvim/." "$HOME/.config/nvim/"
log_success "Neovim configuration copied to ~/.config/nvim."
