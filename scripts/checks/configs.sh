#!/usr/bin/env bash

log_info "Shell and editor configuration"
current_user="${USER:-$(id -un)}"
if current_shell="$(getent passwd "$current_user" | cut -d: -f7)" && [[ "$current_shell" == *fish ]]; then
    pass "Fish is the default login shell"
else
    warn "Fish is not the default login shell; run chsh -s /path/to/fish"
fi

fish_config="$HOME/.config/fish/config.fish"
if check_file "$fish_config"; then
    if grep -q 'atuin init fish' "$fish_config"; then
        pass "Fish initializes Atuin"
    else
        fail "Fish configuration is missing Atuin initialization"
    fi
    check_setting "$fish_config" "alias ls='eza" "Fish eza aliases"
fi

if check_file "$HOME/.tmux.conf"; then
    check_setting "$HOME/.tmux.conf" 'mouse on' "tmux mouse support"
    check_setting "$HOME/.tmux.conf" 'default-terminal.*tmux-256color' "tmux terminal capabilities"
fi

check_file "$HOME/.config/nvim/init.lua"
if [ -f "$HOME/.config/nvim/nvim-pack-lock.json" ]; then
    pass "Neovim plugin lockfile exists"
else
    warn "Neovim plugin lockfile is missing"
fi
