#!/usr/bin/env bash
# ==============================================================================
# 04-atuin.sh: Atuin shell history installation & setup
# Installs Atuin to store shell history in an encrypted SQLite database.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status (-e),
# treat unset variables as an error when substituting (-u),
# and prevent errors in a pipeline from being masked (-o pipefail).
set -euo pipefail

# Locate directory path of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helper functions (logging, PATH verification)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

# Ensure ~/.local/bin exists in case Atuin binary installs there
ensure_local_bin

# Print informational message
log_info "Installing Atuin (magical shell history)..."

# Check if the 'atuin' binary is already installed on the system
if ! command -v atuin >/dev/null 2>&1; then
    # Download and execute the official Atuin installer script over TLS 1.2+
    # Pass '--no-modify-path' because we configure Fish shell integration explicitly in 06-terminal-config.sh
    curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | bash -s -- --no-modify-path || {
        log_warn "Standard Atuin install script had an issue, checking fallback..."
    }
fi

# Verify if atuin binary is now executable on the PATH
if command -v atuin >/dev/null 2>&1; then
    # Print success with version number
    log_success "Atuin installed successfully: $(atuin --version 2>/dev/null || echo 'ready')"
else
    # Warn if the binary was not found after installation attempt
    log_warn "Atuin installation could not be verified automatically."
fi
