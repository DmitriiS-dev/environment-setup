#!/usr/bin/env bash
# ==============================================================================
# 01-prereqs.sh: Install baseline prerequisites (curl, git, wget, ca-certificates)
# Ensures bootstrap tools exist before doing further package installations.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status (-e),
# treat unset variables as an error when substituting (-u),
# and prevent errors in a pipeline from being masked (-o pipefail).
set -euo pipefail

# Resolve the absolute directory path where this specific script file is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the shared helper script (contains logging, sudo detection, OS checks)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

# Determine if sudo is required and verify user has permissions to run privileged commands
setup_sudo

# Inspect /etc/os-release to identify the Linux distribution family (e.g. Ubuntu, Oracle Linux, Arch)
detect_os

# Print a friendly status message to standard output indicating what phase is running
log_info "Ensuring base prerequisites (curl, git, wget, ca-certificates) are installed..."

# Branch 1: Debian and Ubuntu family distributions
if [[ "$OS_FAMILY" == "ubuntu" || "$OS_FAMILY" == "debian" || "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
    # Refresh the local package index lists so the package manager knows about the latest versions
    $SUDO apt-get update -y

    # Install curl, git, wget, and SSL/TLS certificates non-interactively without prompting for user input
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget git ca-certificates

# Branch 2: Red Hat family distributions (Oracle Linux, RHEL, CentOS, Rocky Linux, AlmaLinux, Fedora)
elif [[ "$OS_FAMILY" == "ol" || "$OS_FAMILY" == "rhel" || "$OS_FAMILY" == "centos" || "$OS_FAMILY" == "rocky" || "$OS_FAMILY" == "almalinux" || "$OS_FAMILY" == "fedora" ]]; then
    # Default modern RHEL/Fedora package manager to dnf
    PKG_MGR="dnf"

    # Fall back to yum if dnf is not present on older Enterprise Linux releases
    if ! command -v dnf >/dev/null 2>&1; then
        # Switch the package manager command to yum
        PKG_MGR="yum"
    fi

    # Install curl, wget, git, and certificates using the resolved package manager (dnf or yum)
    $SUDO $PKG_MGR install -y curl wget git ca-certificates

# Branch 3: Arch Linux and Arch-based distributions
elif [[ "$OS_FAMILY" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
    # Refresh package databases (-y) and install prerequisites (-S) without asking for confirmation (--noconfirm)
    $SUDO pacman -Sy --noconfirm curl wget git ca-certificates
fi

# Print a success confirmation message showing that the prerequisite installation is finished
log_success "Base prerequisites (curl, git) are ready."
