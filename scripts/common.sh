#!/usr/bin/env bash

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$COMMON_DIR/.." && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

log_info() { printf '%b==>%b %s\n' "$BLUE" "$RESET" "$*"; }
log_success() { printf '%b==>%b %s\n' "$GREEN" "$RESET" "$*"; }
log_warn() { printf '%bWARNING:%b %s\n' "$YELLOW" "$RESET" "$*" >&2; }
log_error() { printf '%bERROR:%b %s\n' "$RED" "$RESET" "$*" >&2; }
has() { command -v "$1" >/dev/null 2>&1; }

setup_sudo() {
    SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        if ! has sudo; then
            log_error "Root or sudo is required to install system packages."
            return 1
        fi
        SUDO=sudo
    fi
    export SUDO
}

run_root() {
    if [ -n "${SUDO:-}" ]; then
        "$SUDO" "$@"
    else
        "$@"
    fi
}

run_apt_get() {
    run_root env DEBIAN_FRONTEND=noninteractive apt-get "$@"
}

detect_arch() {
    case "$(uname -m)" in
        x86_64 | amd64)
            ARCH_TYPE=x86_64
            NVIM_ARCH=linux-x86_64
            ;;
        aarch64 | arm64)
            ARCH_TYPE=arm64
            NVIM_ARCH=linux-arm64
            ;;
        *)
            ARCH_TYPE="$(uname -m)"
            NVIM_ARCH=""
            ;;
    esac
    export ARCH_TYPE NVIM_ARCH
}

detect_os() {
    local ID="" ID_LIKE=""
    if [ ! -r /etc/os-release ]; then
        log_error "Cannot detect Linux distribution: /etc/os-release is missing."
        return 1
    fi
    # shellcheck disable=SC1091
    source /etc/os-release
    OS_FAMILY="$ID"
    export OS_FAMILY
    case " $ID $ID_LIKE " in
        *" debian "* | *" ubuntu "*) OS_GROUP=debian ;;
        *" rhel "* | *" fedora "* | *" ol "* | *" centos "* | *" rocky "* | *" almalinux "*) OS_GROUP=rhel ;;
        *" arch "*) OS_GROUP=arch ;;
        *)
            log_error "Unsupported Linux distribution: $ID ($ID_LIKE)"
            return 1
            ;;
    esac
}

use_local_bin() {
    export PATH="$HOME/.local/bin:$HOME/.atuin/bin:$PATH"
}

ensure_local_bin() {
    mkdir -p "$HOME/.local/bin"
    use_local_bin
}

setup_environment() {
    setup_sudo || return
    detect_arch
    detect_os || return
    ensure_local_bin || return
    # shellcheck disable=SC1090,SC1091
    source "$REPO_ROOT/scripts/os/$OS_GROUP.sh"
}

neovim_is_supported() {
    has nvim || return 1
    local version
    version="$(nvim --version)" || return 1
    [[ "$version" =~ NVIM\ v([0-9]+)\.([0-9]+) ]] || return 1
    ((BASH_REMATCH[1] >= 1 || BASH_REMATCH[2] >= 12))
}
