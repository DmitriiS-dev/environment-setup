#!/usr/bin/env bash
# Collect every failure instead of stopping at the first one.
set -uo pipefail

# shellcheck source=scripts/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common.sh"
detect_os || exit 1
detect_arch
use_local_bin

PASSED=0
FAILED=0
WARNINGS=0

pass() {
    printf '  %bPASS%b %s\n' "$GREEN" "$RESET" "$*"
    PASSED=$((PASSED + 1))
}
fail() {
    printf '  %bFAIL%b %s\n' "$RED" "$RESET" "$*"
    FAILED=$((FAILED + 1))
}
warn() {
    printf '  %bWARN%b %s\n' "$YELLOW" "$RESET" "$*"
    WARNINGS=$((WARNINGS + 1))
}

# Supplying a reason makes a missing optional tool a warning.
check_command() {
    if has "$1"; then
        pass "$1 is available"
    elif [ -n "${2:-}" ]; then
        warn "$1 is missing ($2)"
    else
        fail "$1 is missing from PATH"
    fi
}

check_file() {
    if [ -f "$1" ]; then
        pass "$1 exists"
    else
        fail "$1 is missing"
        return 1
    fi
}

check_setting() {
    if grep -qE "$2" "$1"; then
        pass "$3"
    else
        warn "$3 not found in $1"
    fi
}

log_info "Environment health check: $OS_FAMILY ($ARCH_TYPE)"
for section in tools configs firewall; do
    # shellcheck disable=SC1090,SC1091
    source "$COMMON_DIR/checks/$section.sh"
done

printf '\nPassed: %s  Warnings: %s  Failed: %s\n' "$PASSED" "$WARNINGS" "$FAILED"
((FAILED == 0))
