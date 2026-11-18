#!/usr/bin/env bash

log_info "Tools and runtimes"
for tool in curl wget eza btop htop fish atuin tmux; do
    check_command "$tool"
done

if neovim_is_supported; then
    pass "Neovim 0.12+ is available"
else
    fail "Neovim 0.12+ is required for vim.pack"
fi

if has gcc || has clang; then
    pass "A C compiler is available"
else
    warn "C compiler missing (Treesitter cannot build parsers)"
fi

check_command python3 "needed for BasedPyright and Python tools"
if has python3; then
    if python3 -m pip --version >/dev/null 2>&1 && python3 -c 'import venv, ensurepip' >/dev/null 2>&1; then
        pass "Python pip and venv support are available"
    else
        warn "Python pip/venv support missing (Ubuntu/Debian: install python3-pip python3-venv)"
    fi
fi
check_command unzip "needed to install StyLua and clangd"
check_command go "needed to install gofumpt"
check_command node "needed for JavaScript tools"
check_command npm "needed for JavaScript tools"
