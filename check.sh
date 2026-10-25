#!/usr/bin/env bash
# ==============================================================================
# check.sh: Automated Health & Verification Suite
# Runs after ./install.sh to verify every tool, config, runtime, and firewall rule.
# ==============================================================================

# Exit if unset variables are accessed (-u) or pipeline fails (-o pipefail)
# Notice we do NOT use -e so failed checks can be reported without aborting the suite!
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helper functions
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/common.sh"

setup_sudo
detect_arch
detect_os
ensure_local_bin

# Counters to keep score
PASSED=0
FAILED=0
WARNINGS=0

# Helper function to assert a test
pass() {
    echo -e "  [${GREEN}✔ PASS${RESET}] $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "  [${RED}✖ FAIL${RESET}] $1"
    FAILED=$((FAILED + 1))
}

warn() {
    echo -e "  [${YELLOW}▲ WARN${RESET}] $1"
    WARNINGS=$((WARNINGS + 1))
}

echo ""
echo -e "${BOLD}========================================================================${RESET}"
echo -e "${BOLD}       🔍 Running Environment Health Check on $OS_FAMILY ($ARCH_TYPE)       ${RESET}"
echo -e "${BOLD}========================================================================${RESET}"
echo ""

# ------------------------------------------------------------------------------
# 1. Base Prerequisites Check
# ------------------------------------------------------------------------------
log_info "1. Baseline Tools & Web Utilities"

if command -v curl >/dev/null 2>&1; then
    pass "curl is available ($(curl --version | head -n 1 | awk '{print $1, $2}'))"
else
    fail "curl is missing from PATH"
fi

if command -v wget >/dev/null 2>&1; then
    pass "wget is available"
else
    fail "wget is missing from PATH"
fi

# ------------------------------------------------------------------------------
# 2. Modern CLI Utilities
# ------------------------------------------------------------------------------
log_info "2. Modern CLI Utilities"

if command -v eza >/dev/null 2>&1; then
    pass "eza is available ($(eza --version | head -n 2 | tail -n 1 | awk '{print $1, $2}'))"
else
    fail "eza is missing from PATH"
fi

if command -v btop >/dev/null 2>&1; then
    pass "btop is available ($(btop --version 2>&1 | head -n 1))"
else
    fail "btop is missing from PATH"
fi

if command -v htop >/dev/null 2>&1; then
    pass "htop is available ($(htop --version | head -n 1))"
else
    fail "htop is missing from PATH"
fi

# ------------------------------------------------------------------------------
# 3. Shell & History Tracking (Fish & Atuin)
# ------------------------------------------------------------------------------
log_info "3. Shell & Atuin History Tracking"

if command -v fish >/dev/null 2>&1; then
    pass "fish shell is installed ($(fish --version))"
else
    fail "fish shell is missing from PATH"
fi

# Check default login shell
CURRENT_SHELL="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || echo "$SHELL")"
if [[ "$CURRENT_SHELL" == *"fish"* ]]; then
    pass "fish is configured as default login shell ($CURRENT_SHELL)"
else
    warn "default login shell is '$CURRENT_SHELL' (expected fish). Run: chsh -s $(command -v fish || echo '/usr/bin/fish')"
fi

# Check Fish config file
if [ -f "$HOME/.config/fish/config.fish" ]; then
    pass "~/.config/fish/config.fish exists"
    if grep -q "atuin init fish" "$HOME/.config/fish/config.fish"; then
        pass "config.fish initializes Atuin history hook"
    else
        fail "config.fish is missing Atuin initialization hook"
    fi
    if grep -q "alias ls='eza" "$HOME/.config/fish/config.fish"; then
        pass "config.fish contains eza alias"
    else
        warn "config.fish does not define eza aliases"
    fi
else
    fail "~/.config/fish/config.fish does not exist"
fi

# Check Atuin binary
if command -v atuin >/dev/null 2>&1; then
    pass "atuin is available ($(atuin --version 2>/dev/null || echo 'ready'))"
else
    fail "atuin is missing from PATH"
fi

# ------------------------------------------------------------------------------
# 4. Terminal Multiplexer (tmux)
# ------------------------------------------------------------------------------
log_info "4. Terminal Multiplexer (tmux)"

if command -v tmux >/dev/null 2>&1; then
    pass "tmux is installed ($(tmux -V))"
else
    fail "tmux is missing from PATH"
fi

if [ -f "$HOME/.tmux.conf" ]; then
    pass "~/.tmux.conf exists"
    if grep -q "mouse on" "$HOME/.tmux.conf"; then
        pass "tmux mouse mode is enabled"
    else
        warn "tmux mouse mode not found in ~/.tmux.conf"
    fi
    if grep -q "default-terminal.*256color" "$HOME/.tmux.conf"; then
        pass "tmux 256color / TrueColor support configured"
    else
        warn "tmux TrueColor settings not found in ~/.tmux.conf"
    fi
else
    fail "~/.tmux.conf does not exist"
fi

# ------------------------------------------------------------------------------
# 5. Neovim & Development Stack
# ------------------------------------------------------------------------------
log_info "5. Neovim & Runtimes"

if command -v nvim >/dev/null 2>&1; then
    NVIM_VER_RAW="$(nvim --version | head -n 1)"
    NVIM_NUM="$(echo "$NVIM_VER_RAW" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1)"
    MAJOR="$(echo "$NVIM_NUM" | cut -d. -f1)"
    MINOR="$(echo "$NVIM_NUM" | cut -d. -f2)"

    if [ "$MAJOR" -ge 1 ] || [ "$MINOR" -ge 10 ]; then
        pass "nvim is version >= 0.10.0 ($NVIM_VER_RAW)"
    else
        fail "nvim is too old ($NVIM_NUM < 0.10.0). Built-in vim.pack & OSC 52 will fail!"
    fi
else
    fail "nvim is missing from PATH"
fi

if [ -f "$HOME/.config/nvim/init.lua" ]; then
    pass "~/.config/nvim/init.lua exists"
else
    fail "~/.config/nvim/init.lua is missing! Did 05-neovim.sh run?"
fi

if [ -f "$HOME/.config/nvim/nvim-pack-lock.json" ]; then
    pass "~/.config/nvim/nvim-pack-lock.json exists"
else
    warn "~/.config/nvim/nvim-pack-lock.json missing"
fi

# Check development runtimes needed by Mason / Treesitter
if command -v gcc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1; then
    pass "C compiler found ($(command -v gcc || command -v clang))"
else
    warn "C compiler (gcc/clang) missing — Treesitter parsers cannot compile"
fi

if command -v python3 >/dev/null 2>&1; then
    pass "python3 is installed ($(python3 --version))"
else
    warn "python3 is missing (needed for Ruff / Basedpyright LSPs)"
fi

if command -v node >/dev/null 2>&1; then
    pass "node is installed ($(node --version))"
else
    warn "node is missing (needed for Prettier / Pyright / TS LSPs)"
fi

if command -v npm >/dev/null 2>&1; then
    pass "npm is installed ($(npm --version))"
else
    warn "npm is missing"
fi

# ------------------------------------------------------------------------------
# 6. Firewall & Security Rules
# ------------------------------------------------------------------------------
log_info "6. Firewall (UFW / firewalld)"

if command -v ufw >/dev/null 2>&1; then
    pass "ufw binary is installed"
    UFW_STATUS="$($SUDO ufw status verbose 2>/dev/null || echo 'inactive')"
    if echo "$UFW_STATUS" | grep -qi "Status: active"; then
        pass "UFW is active and enabled"

        # Check SSH
        if echo "$UFW_STATUS" | grep -qE "(22/tcp|22\s+|ssh)"; then
            pass "Firewall allows SSH (port 22)"
        else
            fail "CRITICAL: SSH port 22 is NOT allowed in UFW! You may get locked out!"
        fi

        # Check HTTP
        if echo "$UFW_STATUS" | grep -qE "(80/tcp|80\s+|http)"; then
            pass "Firewall allows HTTP (port 80)"
        else
            warn "HTTP (port 80) is not listed in UFW rules"
        fi

        # Check HTTPS
        if echo "$UFW_STATUS" | grep -qE "(443/tcp|443\s+|https)"; then
            pass "Firewall allows HTTPS (port 443)"
        else
            warn "HTTPS (port 443) is not listed in UFW rules"
        fi
    else
        warn "UFW is installed but NOT active. Run '$SUDO ufw enable'"
    fi
elif command -v firewall-cmd >/dev/null 2>&1; then
    pass "firewalld binary is installed"
    FW_STATE="$($SUDO firewall-cmd --state 2>/dev/null || echo 'not running')"
    if [ "$FW_STATE" == "running" ]; then
        pass "firewalld is active and running"
    else
        warn "firewalld is not running"
    fi
else
    fail "Neither ufw nor firewalld was found on the system"
fi

# ------------------------------------------------------------------------------
# Summary Scoreboard
# ------------------------------------------------------------------------------
echo ""
echo -e "${BOLD}========================================================================${RESET}"
echo -e "${BOLD}                           Health Check Summary                         ${RESET}"
echo -e "${BOLD}========================================================================${RESET}"
echo -e "  Passed:   ${GREEN}${BOLD}${PASSED}${RESET}"
echo -e "  Warnings: ${YELLOW}${BOLD}${WARNINGS}${RESET}"
echo -e "  Failed:   ${RED}${BOLD}${FAILED}${RESET}"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}🎉 All critical tests passed! Your setup is in tip-top shape.${RESET}"
    exit 0
else
    echo -e "${RED}${BOLD}⚠️  Some checks failed. Review the red items above.${RESET}"
    exit 1
fi
