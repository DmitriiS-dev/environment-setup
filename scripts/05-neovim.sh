#!/usr/bin/env bash
# ==============================================================================
# 05-neovim.sh: Neovim installation (ensuring v0.10+ / v0.11+) and dotfile sync
# Installs official pre-compiled Neovim binary and copies the repo nvim/ config to ~/.config/nvim.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status (-e),
# treat unset variables as an error when substituting (-u),
# and prevent errors in a pipeline from being masked (-o pipefail).
set -euo pipefail

# Locate directory path of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helper functions (logging, architecture detection, PATH verification)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

# Determine system architecture (linux-x86_64 vs linux-arm64) for binary downloads
detect_arch

# Ensure ~/.local/bin is available
ensure_local_bin

# Print setup banner
log_info "Setting up Neovim (v0.10+ / v0.11+)..."

# Flag to track whether we must download and install a fresh Neovim release
NEED_NVIM=false

# Check if neovim is completely missing
if ! command -v nvim >/dev/null 2>&1; then
    # Neovim not found; mark for installation
    NEED_NVIM=true
else
    # Parse existing Neovim semantic version string (e.g. 0.9.5 or 0.10.4)
    NVIM_VER=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+' | head -n 1 || echo "0.0")

    # Extract major version number (e.g. 0)
    MAJOR=$(echo "$NVIM_VER" | cut -d. -f1)

    # Extract minor version number (e.g. 9 or 10)
    MINOR=$(echo "$NVIM_VER" | cut -d. -f2)

    # Neovim 0.10.0+ is required for built-in vim.pack and OSC 52 remote clipboard support
    if [ "$MAJOR" -lt 1 ] && [ "$MINOR" -lt 10 ]; then
        # Warn user that system repo package is too old
        log_warn "Installed Neovim version ($NVIM_VER) is older than 0.10.0. Upgrading to latest prebuilt release..."
        # Mark for upgrade
        NEED_NVIM=true
    fi
fi

# Download and extract the latest official pre-compiled Neovim binary if required
if [ "$NEED_NVIM" = true ] && [ -n "$NVIM_ARCH" ]; then
    # Inform user of download
    log_info "Installing latest stable Neovim ($NVIM_ARCH)..."

    # URL to the official prebuilt tarball from Neovim GitHub releases
    NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_ARCH}.tar.gz"

    # Download archive to /tmp using curl
    curl -fsSL -o /tmp/nvim.tar.gz "$NVIM_URL"

    # Ensure ~/.local directory exists (tarball unpacks into bin/, share/, lib/)
    mkdir -p "$HOME/.local"

    # Extract tarball directly into ~/.local, stripping the top-level directory folder
    tar -xzf /tmp/nvim.tar.gz -C "$HOME/.local" --strip-components=1

    # Clean up the downloaded temporary archive
    rm -f /tmp/nvim.tar.gz

    # Confirm installation by querying newly installed binary version
    log_success "Neovim installed successfully: $($HOME/.local/bin/nvim --version | head -n 1)"
fi

# Locate root of environment-setup repository relative to this script
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Verify that the nvim/ configuration folder exists in the cloned repository
if [ -d "$REPO_ROOT/nvim" ]; then
    # Inform user of config copy
    log_info "Configuring Neovim at ~/.config/nvim..."

    # Create Neovim user configuration folder
    mkdir -p "$HOME/.config/nvim"

    # Recursively copy all config files (init.lua, lockfiles, docs) into ~/.config/nvim
    cp -r "$REPO_ROOT/nvim/"* "$HOME/.config/nvim/" 2>/dev/null || true

    # Confirm config synchronization
    log_success "Neovim configuration copied to ~/.config/nvim"
else
    # Warn if the config directory was not found
    log_warn "No nvim config directory found at $REPO_ROOT/nvim"
fi
