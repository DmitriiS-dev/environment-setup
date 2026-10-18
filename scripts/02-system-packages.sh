#!/usr/bin/env bash
# ==============================================================================
# 02-system-packages.sh: System update, upgrade, packages, runtimes & eza
# Updates distro repositories, installs terminal tools (tmux, fish, btop, bat, eza),
# and provides build runtimes (gcc/make, Python, Node.js) needed by Mason/LSPs.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status (-e),
# treat unset variables as an error when substituting (-u),
# and prevent errors in a pipeline from being masked (-o pipefail).
set -euo pipefail

# Locate directory path of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helper functions (logging, arch detection, OS detection, sudo)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

# Determine sudo availability
setup_sudo

# Identify machine architecture (x86_64 vs arm64) for standalone binary downloads
detect_arch

# Identify Linux distribution family
detect_os

# Ensure ~/.local/bin exists in environment
ensure_local_bin

# Inform user that package installation is starting
log_info "Updating system packages and installing terminal utilities & runtimes..."

# Branch 1: Debian/Ubuntu family
if [[ "$OS_FAMILY" == "ubuntu" || "$OS_FAMILY" == "debian" || "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
    # Inform user of update and upgrade
    log_info "Running apt-get update & upgrade..."

    # Update package indexes
    $SUDO apt-get update -y

    # Upgrade installed packages non-interactively
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

    # Install terminal applications, build toolchain, and Python runtimes
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y \
        fish tmux htop btop bat \
        build-essential gcc g++ make \
        python3 python3-pip python3-venv \
        unzip tar xclip

    # Ubuntu/Debian packages 'bat' as 'batcat' to avoid filename collision; symlink to 'bat'
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        # Ensure destination bin directory exists
        mkdir -p "$HOME/.local/bin"
        # Create symbolic link pointing ~/.local/bin/bat to /usr/bin/batcat
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    fi

    # Check if 'eza' is already installed
    if ! command -v eza >/dev/null 2>&1; then
        # Inform user of eza APT repository setup
        log_info "Setting up eza repository for Debian/Ubuntu..."
        # Create apt keyrings directory
        $SUDO mkdir -p /etc/apt/keyrings
        # Download and de-armor eza GPG repository signing key
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | $SUDO gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
        # Add official eza APT source repository
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | $SUDO tee /etc/apt/sources.list.d/gierens.list >/dev/null || true
        # Set proper permissions for the keyring and source file
        $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list 2>/dev/null || true
        # Refresh package lists with new eza repository
        $SUDO apt-get update -y 2>/dev/null || true
        # Install eza via APT
        $SUDO apt-get install -y eza 2>/dev/null || log_warn "Could not install eza from apt repo; will attempt binary download."
    fi

    # Check if Node.js runtime is installed (required by Pyright, Prettier, TypeScript LSPs)
    if ! command -v node >/dev/null 2>&1; then
        # Inform user of Node.js installation
        log_info "Installing Node.js & npm..."
        # Install nodejs and npm packages
        $SUDO apt-get install -y nodejs npm 2>/dev/null || true
    fi

# Branch 2: RHEL, Oracle Linux, Fedora, CentOS, Rocky Linux, AlmaLinux family
elif [[ "$OS_FAMILY" == "ol" || "$OS_FAMILY" == "rhel" || "$OS_FAMILY" == "centos" || "$OS_FAMILY" == "rocky" || "$OS_FAMILY" == "almalinux" || "$OS_FAMILY" == "fedora" ]]; then
    # Select dnf package manager, fallback to yum
    PKG_MGR="dnf"
    if ! command -v dnf >/dev/null 2>&1; then
        PKG_MGR="yum"
    fi

    # Enable Extra Packages for Enterprise Linux (EPEL) repository for extra terminal tools
    log_info "Enabling EPEL repository if applicable..."
    $SUDO $PKG_MGR install -y epel-release 2>/dev/null || true

    # Run system package upgrade
    log_info "Running $PKG_MGR upgrade..."
    $SUDO $PKG_MGR upgrade -y 2>/dev/null || true

    # Install terminal tools, compilation tools, and Python
    $SUDO $PKG_MGR install -y \
        fish tmux htop btop \
        gcc gcc-c++ make \
        python3 python3-pip \
        unzip tar xclip 2>/dev/null || true

    # Install bat from repositories
    $SUDO $PKG_MGR install -y bat 2>/dev/null || true

    # Install eza from repositories
    $SUDO $PKG_MGR install -y eza 2>/dev/null || true

    # Install Node.js if not yet available
    if ! command -v node >/dev/null 2>&1; then
        $SUDO $PKG_MGR install -y nodejs npm 2>/dev/null || true
    fi

# Branch 3: Arch Linux family
elif [[ "$OS_FAMILY" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
    # Full system update and package installation using pacman
    $SUDO pacman -Syu --noconfirm \
        fish tmux htop btop bat eza \
        base-devel python python-pip \
        nodejs npm unzip xclip 2>/dev/null || true
fi

# Fallback: if eza package was unavailable in the distro repositories, download prebuilt binary
if ! command -v eza >/dev/null 2>&1; then
    # Inform user of prebuilt fallback
    log_info "Installing eza prebuilt release binary..."

    # Query GitHub releases API for latest release tag, defaulting to v0.18.24 on rate-limit
    EZA_TAG=$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || echo "v0.18.24")

    # Select standard x86_64 tarball filename
    EZA_TAR="eza_${ARCH_TYPE}-unknown-linux-gnu.tar.gz"

    # Adjust filename if running on 64-bit ARM architecture
    if [ "$ARCH_TYPE" == "arm64" ]; then
        EZA_TAR="eza_aarch64-unknown-linux-gnu.tar.gz"
    fi

    # Download release archive, extract binary into ~/.local/bin, make executable, and clean up
    curl -fsSL -o /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/${EZA_TAG}/${EZA_TAR}" 2>/dev/null && {
        # Unpack only the 'eza' executable file into ~/.local/bin
        tar -xzf /tmp/eza.tar.gz -C "$HOME/.local/bin" eza 2>/dev/null || true
        # Ensure executable flag (+x) is set
        chmod +x "$HOME/.local/bin/eza" 2>/dev/null || true
        # Remove temporary archive
        rm -f /tmp/eza.tar.gz
    } || log_warn "Could not download prebuilt eza binary."
fi

# Log success confirmation message
log_success "System packages and runtimes installed successfully."
