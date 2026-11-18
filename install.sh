#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common.sh"
setup_environment

log_info "Starting environment setup for $OS_FAMILY ($ARCH_TYPE)..."
for step in 01-prereqs 02-system-packages 03-security 04-atuin 05-neovim 06-terminal-config; do
    bash "$COMMON_DIR/$step.sh"
done

log_success "Setup complete: Neovim, Fish, Atuin, tmux, eza, monitors and firewall."
printf '\nRun fish to use your new shell, or bash %s/check.sh to check the installation.\n' "$REPO_ROOT"
