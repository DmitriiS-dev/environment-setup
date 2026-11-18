#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
setup_environment

# Used by the selected OS adapter.
# shellcheck disable=SC2034
COMMON_PACKAGES=(fish tmux htop btop unzip tar xclip)

log_info "Installing terminal utilities and development runtimes..."
install_system_packages
if ! has eza; then
    bash "$COMMON_DIR/install-eza.sh"
fi
log_success "System packages and runtimes are ready."
