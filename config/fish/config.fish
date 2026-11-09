# Add user-installed tools to Fish's global PATH.
fish_add_path -g $HOME/.local/bin
if test -d $HOME/.atuin/bin
    fish_add_path -g $HOME/.atuin/bin
end

# Use eza for directory listings when available.
if type -q eza
    alias ls='eza --icons'
    alias ll='eza -la --icons --git'
    alias lt='eza --tree --level=2 --icons'
end

# Use bat as a cat-compatible file viewer, including Debian's batcat name.
if type -q bat
    alias cat='bat --paging=never'
else if type -q batcat
    alias bat='batcat'
    alias cat='batcat --paging=never'
end

# Set up fzf key bindings and completions across packaged versions.
if type -q fzf
    if fzf --fish >/dev/null 2>&1
        fzf --fish | source
    else
        for fzf_script in /usr/share/fzf/key-bindings.fish /usr/share/fzf/shell/key-bindings.fish /usr/share/doc/fzf/examples/key-bindings.fish
            if test -r $fzf_script
                source $fzf_script
                break
            end
        end
        for fzf_script in /usr/share/fzf/completion.fish /usr/share/fzf/shell/completion.fish /usr/share/doc/fzf/examples/completion.fish
            if test -r $fzf_script
                source $fzf_script
                break
            end
        end
    end
end

# Initialize zoxide smart directory navigation.
if type -q zoxide
    zoxide init fish | source
end

# Prefer Neovim for editing when installed.
if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    alias vim='nvim'
    alias vi='nvim'
end

# Initialize Atuin shell history when installed.
if type -q atuin
    atuin init fish | source
end
