#!/usr/bin/env bash
# ==============================================================================
# common.sh: Shared helper functions and environment detection
# Included by all modular setup scripts for consistent logging, permissions, and OS checks.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status (-e),
# treat unset variables as an error when substituting (-u),
# and prevent errors in a pipeline from being masked (-o pipefail).
set -euo pipefail

# ANSI color codes for terminal output formatting
BOLD="\033[1m"       # Bold text style
GREEN="\033[0;32m"   # Success green color
BLUE="\033[0;34m"    # Informational blue color
YELLOW="\033[0;33m"  # Warning yellow color
RED="\033[0;31m"     # Error red color
RESET="\033[0m"      # Reset all formatting back to terminal default

# Print an informational message prefixed with a blue arrow (==>)
log_info() {
    echo -e "${BLUE}${BOLD}==>${RESET} ${BOLD}$1${RESET}"
}

# Print a success confirmation message prefixed with a green arrow (==>)
log_success() {
    echo -e "${GREEN}${BOLD}==>${RESET} ${GREEN}$1${RESET}"
}

# Print a warning message in yellow
log_warn() {
    echo -e "${YELLOW}${BOLD}WARNING:${RESET} $1"
}

# Print a critical error message in red
log_error() {
    echo -e "${RED}${BOLD}ERROR:${RESET} $1"
}

# Resolve whether 'sudo' needs to be prepended to package manager commands
setup_sudo() {
    # Initialize SUDO variable as empty string
    SUDO=""

    # Check if current effective user ID is not 0 (0 means root)
    if [ "$(id -u)" -ne 0 ]; then
        # Check if the 'sudo' binary exists on the system PATH
        if command -v sudo >/dev/null 2>&1; then
            # Set the prefix to 'sudo' so subsequent commands execute with root permissions
            SUDO="sudo"
        else
            # Exit with an error if user is non-root and sudo is unavailable
            log_error "This script requires root privileges or sudo to install system packages."
            exit 1
        fi
    fi

    # Export SUDO so subshells and invoked commands inherit it
    export SUDO
}

# Detect CPU architecture to download appropriate pre-compiled binaries
detect_arch() {
    # Retrieve machine hardware name (e.g. x86_64, aarch64)
    ARCH="$(uname -m)"

    # Match hardware architecture against known platforms
    case "$ARCH" in
        # Intel/AMD 64-bit processors
        x86_64|amd64)
            ARCH_TYPE="x86_64"
            NVIM_ARCH="linux-x86_64"
            ;;
        # ARM 64-bit processors (common on Oracle Cloud Ampere A1 shapes)
        aarch64|arm64)
            ARCH_TYPE="arm64"
            NVIM_ARCH="linux-arm64"
            ;;
        # Any other CPU architecture
        *)
            log_warn "Unknown architecture $ARCH, some prebuilt binaries may fall back to package managers."
            ARCH_TYPE="$ARCH"
            NVIM_ARCH=""
            ;;
    esac

    # Export detected architecture variables for child scripts
    export ARCH ARCH_TYPE NVIM_ARCH
}

# Inspect /etc/os-release to detect the Linux distribution family
detect_os() {
    # Initialize variables
    OS_FAMILY=""
    OS_LIKE=""

    # Check if standard Linux OS release file exists
    if [ -f /etc/os-release ]; then
        # Source the key-value pairs from os-release (contains ID, ID_LIKE, NAME, etc.)
        # shellcheck disable=SC1091
        . /etc/os-release

        # Distribution ID (e.g. ubuntu, debian, ol, rhel, fedora, arch)
        OS_FAMILY="$ID"

        # Upstream distribution family if derivative (e.g. "debian" for Ubuntu, or "rhel fedora" for Rocky/CentOS)
        OS_LIKE="${ID_LIKE:-}"
    else
        # Fail early if run on a non-standard or unsupported system
        log_error "Could not detect operating system (/etc/os-release not found)."
        exit 1
    fi

    # Export OS identifiers for branching in installer scripts
    export OS_FAMILY OS_LIKE
}

# Ensure the local user's personal binary directory exists and is present in $PATH
ensure_local_bin() {
    # Create ~/.local/bin directory if it does not already exist (-p creates parent folders safely)
    mkdir -p "$HOME/.local/bin"

    # Check whether ~/.local/bin is already part of the current PATH variable
    case ":$PATH:" in
        # If already present anywhere in PATH, do nothing
        *":$HOME/.local/bin:"*) ;;
        # If missing from PATH, prepend it so user-installed binaries take priority
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac

    # Also include ~/.atuin/bin if present
    if [ -d "$HOME/.atuin/bin" ]; then
        case ":$PATH:" in
            *":$HOME/.atuin/bin:"*) ;;
            *) export PATH="$HOME/.atuin/bin:$PATH" ;;
        esac
    fi
}
