#!/usr/bin/env bash
# ==============================================================================
# 03-security.sh: UFW / Firewall configuration
# Configures host firewall rules to permit SSH (port 22), HTTP (80), and HTTPS (443).
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

# Determine sudo availability
setup_sudo

# Identify Linux distribution
detect_os

# Announce firewall configuration phase
log_info "Configuring firewall rules..."

# Branch 1: Debian/Ubuntu family using UFW
if [[ "$OS_FAMILY" == "ubuntu" || "$OS_FAMILY" == "debian" || "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
    # Install Uncomplicated Firewall (ufw) non-interactively
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y ufw

    # Log specific firewall setup message
    log_info "Configuring UFW firewall rules..."

    # Allow incoming SSH traffic by service name, or fall back to port 22/tcp to prevent lockout
    $SUDO ufw allow ssh comment 'Allow SSH' || $SUDO ufw allow 22/tcp

    # Allow incoming HTTP web traffic on port 80
    $SUDO ufw allow 80/tcp comment 'Allow HTTP'

    # Allow incoming HTTPS encrypted web traffic on port 443
    $SUDO ufw allow 443/tcp comment 'Allow HTTPS'

    # Enable the firewall without prompting for interactive confirmation (--force)
    $SUDO ufw --force enable

    # Log confirmation of enabled firewall rules
    log_success "UFW firewall configured and enabled (allowed: SSH/22, HTTP/80, HTTPS/443)"

# Branch 2: RHEL, Oracle Linux, Fedora family
elif [[ "$OS_FAMILY" == "ol" || "$OS_FAMILY" == "rhel" || "$OS_FAMILY" == "centos" || "$OS_FAMILY" == "rocky" || "$OS_FAMILY" == "almalinux" || "$OS_FAMILY" == "fedora" ]]; then
    # Choose dnf if available, else yum
    PKG_MGR="dnf"
    if ! command -v dnf >/dev/null 2>&1; then
        PKG_MGR="yum"
    fi

    # Attempt to install ufw on EPEL-enabled Enterprise Linux systems
    if $SUDO $PKG_MGR install -y ufw 2>/dev/null; then
        # Allow SSH port 22
        $SUDO ufw allow 22/tcp || true
        # Allow HTTP port 80
        $SUDO ufw allow 80/tcp || true
        # Allow HTTPS port 443
        $SUDO ufw allow 443/tcp || true
        # Enable UFW non-interactively
        $SUDO ufw --force enable 2>/dev/null || true
        log_success "UFW firewall configured and enabled (allowed: 22, 80, 443)"
    # Otherwise fallback to native Enterprise Linux firewalld service
    elif command -v firewall-cmd >/dev/null 2>&1 || $SUDO $PKG_MGR install -y firewalld 2>/dev/null; then
        # Enable and start firewalld systemd daemon immediately
        $SUDO systemctl enable --now firewalld 2>/dev/null || true
        # Allow SSH service persistently across reboots
        $SUDO firewall-cmd --permanent --add-service=ssh 2>/dev/null || true
        # Allow HTTP service persistently
        $SUDO firewall-cmd --permanent --add-service=http 2>/dev/null || true
        # Allow HTTPS service persistently
        $SUDO firewall-cmd --permanent --add-service=https 2>/dev/null || true
        # Reload firewall daemon to apply the newly configured permanent rules
        $SUDO firewall-cmd --reload 2>/dev/null || true
        log_success "firewalld configured (allowed: ssh, http, https)"
    fi

# Branch 3: Arch Linux
elif [[ "$OS_FAMILY" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
    # Install ufw through pacman
    $SUDO pacman -S --noconfirm ufw 2>/dev/null || true

    # If ufw installed successfully, open ports and enable
    if command -v ufw >/dev/null 2>&1; then
        # Allow SSH
        $SUDO ufw allow 22/tcp || true
        # Allow HTTP
        $SUDO ufw allow 80/tcp || true
        # Allow HTTPS
        $SUDO ufw allow 443/tcp || true
        # Enable UFW non-interactively
        $SUDO ufw --force enable 2>/dev/null || true
        log_success "UFW firewall configured and enabled (allowed: 22, 80, 443)"
    fi
fi
