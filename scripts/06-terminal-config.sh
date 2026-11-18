#!/usr/bin/env bash
# ==============================================================================
# 06-terminal-config.sh: Configure Fish shell, tmux, and default login shell
# Sets up friendly shell aliases, multiplexer bindings, and sets Fish as default shell.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status (-e),
# treat unset variables as an error when substituting (-u),
# and prevent errors in a pipeline from being masked (-o pipefail).
set -euo pipefail

# Locate directory path of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helper functions
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

# Ensure sudo permissions are set up
setup_sudo

# Ensure ~/.local/bin exists in environment
ensure_local_bin

# ------------------------------------------------------------------------------
# 1. Fish Shell Configuration
# ------------------------------------------------------------------------------

# Install the readable, version-controlled Fish config file
FISH_CONFIG="$HOME/.config/fish/config.fish"
log_info "Installing Fish configuration to $FISH_CONFIG..."
mkdir -p "$(dirname "$FISH_CONFIG")"
install -m 644 "$SCRIPT_DIR/../config/fish/config.fish" "$FISH_CONFIG"
log_success "Fish configuration installed to $FISH_CONFIG"

# ------------------------------------------------------------------------------
# 2. Tmux Configuration
# ------------------------------------------------------------------------------

# Install the readable, version-controlled tmux config file
TMUX_CONF="$HOME/.tmux.conf"
log_info "Installing tmux configuration to $TMUX_CONF..."
install -m 644 "$SCRIPT_DIR/../config/tmux.conf" "$TMUX_CONF"
log_success "tmux configuration installed to $TMUX_CONF"

# ------------------------------------------------------------------------------
# 3. Set Default Shell to Fish
# ------------------------------------------------------------------------------

if command -v fish >/dev/null 2>&1; then
    FISH_PATH="$(command -v fish)"

    if ! grep -qxF "$FISH_PATH" /etc/shells 2>/dev/null; then
        echo "$FISH_PATH" | $SUDO tee -a /etc/shells >/dev/null || true
    fi

    # Lookup the current user's default login shell
    CURRENT_USER="${USER:-$(id -un)}"
    CURRENT_SHELL="$(getent passwd "$CURRENT_USER" 2>/dev/null | cut -d: -f7 || echo "${SHELL:-}")"

    # If current default shell is not fish, change it
    if [ "$CURRENT_SHELL" != "$FISH_PATH" ]; then
        log_info "Changing default login shell to fish ($FISH_PATH)..."

        # Try changing shell without password via sudo first, then fallback to unprivileged chsh
        $SUDO chsh -s "$FISH_PATH" "$CURRENT_USER" 2>/dev/null || chsh -s "$FISH_PATH" "$CURRENT_USER" 2>/dev/null || log_warn "Could not change default shell automatically with chsh. You can run 'chsh -s $(which fish)' manually."
    fi
fi
