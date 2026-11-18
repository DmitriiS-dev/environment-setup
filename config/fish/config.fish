fish_add_path -g $HOME/.local/bin
if test -d $HOME/.atuin/bin
    fish_add_path -g $HOME/.atuin/bin
end

if type -q eza
    alias ls='eza --icons'
    alias ll='eza -la --icons --git'
    alias lt='eza --tree --level=2 --icons'
end

if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    alias vim='nvim'
    alias vi='nvim'
end

if type -q atuin
    atuin init fish | source
end
