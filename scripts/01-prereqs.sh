#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
setup_environment

log_info "Installing curl, wget and certificates..."
install_prerequisites
log_success "Base prerequisites are ready."
