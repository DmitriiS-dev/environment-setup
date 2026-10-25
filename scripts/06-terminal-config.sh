#!/usr/bin/env bash
# ==============================================================================
# 06-terminal-config.sh: Configure Fish shell, tmux, and default login shell
# Sets up friendly shell aliases, multiplexer bindings, and sets Fish as default shell.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status (-e),
# treat unset variables as an error when substituting (-u),
# and prevent errors in a pipeline from being masked (-o pipefail).
set -euo pipefail

# Locate directory path of current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helper functions
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

# Ensure sudo permissions are set up
setup_sudo

# Ensure ~/.local/bin exists in environment
ensure_local_bin

# ------------------------------------------------------------------------------
# 1. Fish Shell Configuration
# ------------------------------------------------------------------------------

# Inform user that Fish configuration is being generated
log_info "Configuring Fish Shell at ~/.config/fish/config.fish..."

# Create ~/.config/fish configuration directory if missing
mkdir -p "$HOME/.config/fish"

# Define target config.fish path variable
FISH_CONFIG="$HOME/.config/fish/config.fish"

# Write out fresh Fish configuration using a heredoc
cat << 'EOF' > "$FISH_CONFIG"
# ==============================================================================
# Fish Shell Configuration
# ==============================================================================

# Ensure ~/.local/bin and ~/.atuin/bin are on PATH globally within Fish
fish_add_path -g $HOME/.local/bin
if test -d $HOME/.atuin/bin
    fish_add_path -g $HOME/.atuin/bin
end

# If eza is installed, create modern aliases for ls with icons and git flags
if type -q eza
    alias ls='eza --icons'
    alias ll='eza -la --icons --git'
    alias lt='eza --tree --level=2 --icons'
end

# If neovim is installed, set it as default system editor and alias vim/vi to nvim
if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    alias vim='nvim'
    alias vi='nvim'
end

# If atuin is installed, initialize shell history hook inside Fish
if type -q atuin
    atuin init fish | source
end
EOF

# Print confirmation that config.fish was written successfully
log_success "Fish shell configuration written to $FISH_CONFIG"

# ------------------------------------------------------------------------------
# 2. Tmux Configuration
# ------------------------------------------------------------------------------

# Inform user that tmux configuration is being generated
log_info "Configuring tmux at ~/.tmux.conf..."

# Target tmux configuration path in user home directory
TMUX_CONF="$HOME/.tmux.conf"

# Write out clean, responsive ~/.tmux.conf file
cat << 'EOF' > "$TMUX_CONF"
# ==============================================================================
# tmux configuration - fast, modern, and vim-friendly
# ==============================================================================

# Configure terminal emulator type to support full 256 colors
set -g default-terminal "xterm-256color"

# Enable TrueColor (24-bit color) passthrough
set -ag terminal-overrides ",xterm-256color:Tc"

# Enable mouse support for clicking windows, resizing panes, and scrolling history
set -g mouse on

# Increase terminal history scrollback buffer to 50,000 lines
set -g history-limit 50000

# Remove escape key delay (0ms) so switching modes in Vim is instantaneous
set -s escape-time 0

# Set base index for windows to 1 instead of 0 for easier keyboard reach
set -g base-index 1

# Set base index for panes to 1 instead of 0
setw -g pane-base-index 1

# Bind prefix + | to split window vertically in current directory
bind | split-window -h -c "#{pane_current_path}"

# Bind prefix + - to split window horizontally in current directory
bind - split-window -v -c "#{pane_current_path}"

# Unbind default split keys (" and %) in favor of | and -
unbind '"'
unbind %

# Vim-style navigation keys between panes (prefix + h, j, k, l)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Shortcut to reload ~/.tmux.conf instantly without restarting session (prefix + r)
bind r source-file ~/.tmux.conf \; display "tmux config reloaded!"

# Custom statusbar colors (dark gray background, light gray text)
set -g status-style "bg=#1e1e1e,fg=#cccccc"

# Set left status segment maximum character length
set -g status-left-length 30

# Set right status segment maximum character length
set -g status-right-length 50

# Left statusbar widget: show active session name in bold cyan
set -g status-left "#[fg=#4ec9b0,bold] #S #[default] "

# Right statusbar widget: show current date and time
set -g status-right "#[fg=#9cdcfe]%Y-%m-%d #[fg=#ce9178]%H:%M #[default]"
EOF

# Print confirmation that tmux configuration was written
log_success "tmux configuration written to $TMUX_CONF"

# ------------------------------------------------------------------------------
# 3. Set Default Shell to Fish
# ------------------------------------------------------------------------------

# Check if fish binary is installed on system
if command -v fish >/dev/null 2>&1; then
    # Get absolute filesystem path to the fish executable
    FISH_PATH="$(command -v fish)"

    # Verify if fish path is registered in /etc/shells (required for chsh)
    if ! grep -qxF "$FISH_PATH" /etc/shells 2>/dev/null; then
        # Append fish binary path to /etc/shells with sudo if missing
        echo "$FISH_PATH" | $SUDO tee -a /etc/shells >/dev/null || true
    fi

    # Lookup the current user's default login shell
    CURRENT_SHELL="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || echo "$SHELL")"

    # If current default shell is not fish, change it
    if [ "$CURRENT_SHELL" != "$FISH_PATH" ]; then
        # Notify user of shell change
        log_info "Changing default login shell to fish ($FISH_PATH)..."

        # Try changing shell without password via sudo first, then fallback to unprivileged chsh
        $SUDO chsh -s "$FISH_PATH" "$USER" 2>/dev/null || chsh -s "$FISH_PATH" "$USER" 2>/dev/null || log_warn "Could not change default shell automatically with chsh. You can run 'chsh -s $(which fish)' manually."
    fi
fi
