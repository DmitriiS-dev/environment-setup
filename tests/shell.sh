#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Child processes exercise entry-point error handling without inherited errexit rules.
case "${1:-}" in
    --security | --terminal | --health)
        mode="$1"
        # Mocks are invoked indirectly by the sourced feature scripts.
        # shellcheck disable=SC2317
        source() {
            builtin source "$@"
            if [[ "$1" == */common.sh ]]; then
                run_root() {
                    printf '%s\n' "$*" >>"$TEST_COMMAND_LOG"
                    if [ "$*" = "${TEST_FAIL_COMMAND:-}" ]; then return 1; fi
                    if [ "$1" = tee ]; then cat >/dev/null; fi
                }
                setup_sudo() { SUDO=""; }
                setup_environment() { FIREWALL="${TEST_FIREWALL:-ufw}"; }
                install_firewall() { :; }
                if [ "$mode" = --health ]; then
                    detect_os() { OS_FAMILY="test"; }
                    detect_arch() { ARCH_TYPE="test"; }
                    use_local_bin() { :; }
                    has() { return 1; }
                fi
                if [ "$mode" = --terminal ]; then
                    fish() { :; }
                    getent() { printf 'test:x:1000:1000::/home/test:fish\n'; }
                fi
            fi
        }
        case "$mode" in
            --security) builtin source "$ROOT/scripts/03-security.sh" ;;
            --terminal) builtin source "$ROOT/scripts/06-terminal-config.sh" ;;
            --health) builtin source "$ROOT/check.sh" ;;
        esac
        exit
        ;;
esac

set -euo pipefail
tmp="$(mktemp -d /tmp/environment-setup-tests.XXXXXX)"
trap 'rm -rf -- "$tmp"' EXIT
export TEST_COMMAND_LOG="$tmp/commands"
touch "$TEST_COMMAND_LOG"

# shellcheck source=../scripts/common.sh
source "$ROOT/scripts/common.sh"

assert_logged() {
    if ! grep -qF -- "$*" "$TEST_COMMAND_LOG"; then
        printf 'Expected command not recorded: %s\n' "$*" >&2
        exit 1
    fi
}

# Simulate os-release in memory, without changing the host's /etc files.
source() {
    if [ "$1" = /etc/os-release ]; then
        ID="$TEST_ID"
        ID_LIKE="$TEST_LIKE"
    else
        builtin source "$@"
    fi
}
for row in 'ubuntu::debian' 'linuxmint:ubuntu debian:debian' 'fedora::rhel' \
    'ol::rhel' 'rocky:rhel centos:rhel' 'derivative:fedora:rhel' \
    'arch::arch' 'manjaro:arch:arch'; do
    IFS=: read -r TEST_ID TEST_LIKE expected <<<"$row"
    detect_os
    [ "$OS_GROUP" = "$expected" ]
done
TEST_ID=unsupported TEST_LIKE=""
if detect_os 2>"$tmp/output"; then
    printf 'Unsupported OS was accepted\n' >&2
    exit 1
fi

nvim() { printf 'NVIM v%s\n' "$mock_version"; }
mock_version=0.11.9
if neovim_is_supported; then
    printf 'Unsupported Neovim version was accepted\n' >&2
    exit 1
fi
for mock_version in 0.12.0 0.13.0-dev 1.0.0; do
    neovim_is_supported
done
unset -f nvim

run_root() {
    printf '%s\n' "$*" >>"$TEST_COMMAND_LOG"
    if [ "${fail_ufw:-0}" = 1 ] && [[ "$*" == *" install -y ufw" ]]; then return 1; fi
}
has() {
    case "$1" in
        node | npm) return 1 ;;
        dnf) [ "${manager:-dnf}" = dnf ] ;;
        *) return 0 ;;
    esac
}
# shellcheck disable=SC2034
COMMON_PACKAGES=(fish tmux htop btop unzip tar xclip)
builtin source "$ROOT/scripts/os/debian.sh"
install_prerequisites
install_system_packages
install_firewall
[ "$FIREWALL" = ufw ]
assert_logged 'env DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs npm'
assert_logged 'python3 python3-pip python3-venv golang-go'

for manager in dnf yum; do
    builtin source "$ROOT/scripts/os/rhel.sh"
    install_prerequisites
    install_system_packages
    fail_ufw=1
    install_firewall 2>"$tmp/output"
    [ "$FIREWALL" = firewalld ]
    assert_logged "$manager install -y firewalld"
done
builtin source "$ROOT/scripts/os/arch.sh"
install_prerequisites
install_system_packages
install_firewall
assert_logged 'pacman -Syu --needed --noconfirm'
assert_logged 'eza base-devel python python-pip go nodejs npm'
printf 'PASS: OS detection and apt/dnf/yum/pacman adapters\n'

for TEST_FIREWALL in ufw firewalld; do
    TEST_FIREWALL="$TEST_FIREWALL" bash "$0" --security >"$tmp/output"
done
assert_logged 'ufw allow 22/tcp'
assert_logged 'ufw --force enable'
assert_logged 'firewall-cmd --permanent --add-service=ssh'
assert_logged 'firewall-cmd --reload'
if TEST_FAIL_COMMAND='ufw allow 80/tcp' bash "$0" --security >"$tmp/output" 2>&1; then
    printf 'Failed firewall command did not stop the installer\n' >&2
    exit 1
fi
if grep -q 'configured and enabled' "$tmp/output"; then
    printf 'Failed firewall setup reported success\n' >&2
    exit 1
fi
printf 'PASS: shared firewall rules and required-command failures\n'

HOME="$tmp/home" bash "$0" --terminal >"$tmp/output"
cmp "$ROOT/config/fish/config.fish" "$tmp/home/.config/fish/config.fish"
cmp "$ROOT/config/tmux.conf" "$tmp/home/.tmux.conf"
printf 'PASS: terminal templates copy unchanged\n'

if HOME="$tmp/empty-home" bash "$0" --health >"$tmp/output" 2>&1; then
    printf 'Missing required tools did not fail the health check\n' >&2
    exit 1
fi
grep -q 'Neovim 0.12+' "$tmp/output"
grep -q 'Firewall' "$tmp/output"
grep -q 'Passed:.*Failed:' "$tmp/output"
printf 'PASS: health checks collect failures through the final summary\n'
