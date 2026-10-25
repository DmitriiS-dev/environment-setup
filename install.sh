#!/usr/bin/env bash
# ==============================================================================
# Environment Setup: Main Installer
# Run after cloning the repository:
#   git clone https://github.com/DmitriiS-dev/environment-setup.git
#   cd environment-setup && ./install.sh
# ==============================================================================

# Exit immediately if a command exits with a non-zero status (-e),
# treat unset variables as an error when substituting (-u),
# and prevent errors in a pipeline from being masked (-o pipefail).
set -euo pipefail

# Determine the absolute directory where this installer script resides on the filesystem
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load shared helper functions (logging, architecture detection, OS detection, sudo)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/common.sh"

# Check if root or sudo privileges are available and assign the $SUDO prefix variable
setup_sudo

# Detect machine CPU architecture (x86_64 vs aarch64/ARM64)
detect_arch

# Detect Linux OS distribution family (Debian/Ubuntu, RHEL/Fedora/Oracle Linux, Arch)
detect_os

# Ensure the user's local binary directory (~/.local/bin) exists and is included in $PATH
ensure_local_bin

# Display an informative banner indicating which OS and CPU architecture were identified
log_info "Starting environment setup for $OS_FAMILY ($ARCH_TYPE)..."

# Step 1: Ensure baseline tools (curl, wget, ca-certificates) are installed
bash "$SCRIPT_DIR/scripts/01-prereqs.sh"

# Step 2: Update system packages, install CLI tools (tmux, btop, htop, eza) & runtimes (Node, Python, GCC)
bash "$SCRIPT_DIR/scripts/02-system-packages.sh"

# Step 3: Install & configure firewall rules (UFW/firewalld allowing SSH/22, HTTP/80, HTTPS/443)
bash "$SCRIPT_DIR/scripts/03-security.sh"

# Step 4: Install Atuin shell history tracker
bash "$SCRIPT_DIR/scripts/04-atuin.sh"

# Step 5: Install/upgrade Neovim (v0.10+) and synchronize the nvim configuration folder to ~/.config/nvim
bash "$SCRIPT_DIR/scripts/05-neovim.sh"

# Step 6: Configure Fish shell, tmux configuration, and switch default login shell to fish
bash "$SCRIPT_DIR/scripts/06-terminal-config.sh"

# Print a blank line for visual separation
echo ""

# Print completion header banner with colored bold green text
echo -e "${GREEN}${BOLD}========================================================================${RESET}"
echo -e "${GREEN}${BOLD}             🎉 Setup Completed Successfully! 🎉                       ${RESET}"
echo -e "${GREEN}${BOLD}========================================================================${RESET}"

# Print an empty line
echo ""

# Display a checklist of all components installed and configured
echo -e "Installed & configured tools:"
echo -e "  • ${BOLD}curl & wget${RESET} (baseline tools and certificates)"
echo -e "  • ${BOLD}Neovim${RESET} (with blink.cmp, fzf-lua, mini.nvim, OSC 52 clipboard)"
echo -e "  • ${BOLD}Fish Shell${RESET} (configured at ~/.config/fish/config.fish)"
echo -e "  • ${BOLD}Atuin${RESET} (encrypted SQLite command history search via Ctrl+R)"
echo -e "  • ${BOLD}tmux${RESET} (configured with mouse support & vim navigation)"
echo -e "  • ${BOLD}eza${RESET} (modern replacement for ls)"
echo -e "  • ${BOLD}btop & htop${RESET} (system resource monitors)"
echo -e "  • ${BOLD}UFW Firewall${RESET} (configured with SSH, HTTP/80, and HTTPS/443 allowed)"

# Print another empty line
echo ""

# Provide the user with the next command to execute to enter their new shell
echo -e "To jump right into your new environment, run:"
echo -e "  ${BOLD}fish${RESET}"

# Final newline
echo ""
