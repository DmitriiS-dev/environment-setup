#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
setup_environment

log_info "Configuring firewall rules..."
install_firewall

case "$FIREWALL" in
    ufw)
        run_root ufw allow 22/tcp
        run_root ufw allow 80/tcp
        run_root ufw allow 443/tcp
        run_root ufw --force enable
        ;;
    firewalld)
        run_root systemctl enable --now firewalld
        for service in ssh http https; do
            run_root firewall-cmd --permanent --add-service="$service"
        done
        run_root firewall-cmd --reload
        ;;
    *)
        log_error "Unsupported firewall: $FIREWALL"
        exit 1
        ;;
esac
log_success "$FIREWALL configured and enabled (SSH/22, HTTP/80, HTTPS/443)."
