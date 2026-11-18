#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
detect_arch
ensure_local_bin

case "$ARCH_TYPE" in
    x86_64) target=x86_64-unknown-linux-gnu ;;
    arm64) target=aarch64-unknown-linux-gnu ;;
    *)
        log_error "No eza binary configured for $ARCH_TYPE."
        exit 1
        ;;
esac

archive="$(mktemp)"
trap 'rm -f "$archive"' EXIT
log_info "Installing the latest eza release binary..."
curl -fSL "https://github.com/eza-community/eza/releases/latest/download/eza_${target}.tar.gz" -o "$archive"
tar -xzf "$archive" -C "$HOME/.local/bin" ./eza
chmod +x "$HOME/.local/bin/eza"
"$HOME/.local/bin/eza" --version
