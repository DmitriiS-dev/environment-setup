# Environment Setup

Quick, automated setup script for Linux environments (Ubuntu, Debian, Oracle Linux, Fedora, Arch) and WSL, tailored for terminal development with **Neovim**, **Fish shell**, **Atuin**, **tmux**, and modern CLI tools.

## Pre-Installation:
Setup for git:
```bash
sudo apt update
sudo apt install git -y
```

## Installation

Clone the repository and run `install.sh`:

```bash
git clone https://github.com/DmitriiS-dev/environment-setup.git
cd environment-setup
chmod +x install.sh
./install.sh
```

## Verify Your Setup

After installation completes, verify everything with:

```bash
chmod +x check.sh
./check.sh
```

For a step-by-step interactive walkthrough testing every tool and shortcut, check out the [Verification Guide](VERIFY.md).

---

## What Gets Installed & Configured

### 1. Baseline Tools & Prerequisites
* **curl, wget & certificates**: Baseline web and download tools installed first.

### 2. Terminal Shell & Environment
* **Fish Shell**: Modern, user-friendly interactive shell with syntax highlighting and autosuggestions.
* **Atuin**: Magically records your shell command history into an encrypted SQLite database. Search across commands and directories with `Ctrl+R`.
* **tmux**: Terminal multiplexer configured with 24-bit TrueColor support, mouse scrolling, vim keybindings, and easy window/pane splits (`|` and `-`).

### 3. Modern CLI Utilities
* **eza**: Modern, colorful replacement for `ls` with filetype indicators, git status, and tree views.
* **btop & htop**: Beautiful and powerful interactive system monitors for CPU, memory, disks, and processes.

### 4. Firewall & Security
* **UFW Firewall**: Configured and enabled out of the box with safe inbound rules for **SSH** (port 22), **HTTP** (port 80), and **HTTPS** (port 443).

### 5. Neovim & Development Stack
* **Neovim 0.10+ / 0.11+**: Fast native plugin loading (`blink.cmp`, `fzf-lua`, `mini.nvim`, `diffview`, `trouble`, etc.).
* **Clipboard over SSH**: Configured with OSC 52 so copying in Neovim over SSH works directly to your local workstation's clipboard.
* **Clipboard in Podman/Docker**: Uses OSC 52 to copy yanked text to the host clipboard through a compatible terminal. Container clipboard reads cannot reliably read Windows clipboard contents: enter Insert mode and use your terminal's paste shortcut (for example Ctrl+Shift+V in Windows Terminal). Neovim's `p` and clipboard-register paste reuse the last text yanked inside Neovim without requesting terminal clipboard access.
* **LSP Runtimes**: Node.js/npm, Python 3 with pip/venv support, Go (for gofumpt), a C compiler (`gcc`/`build-essential`), and unzip for Mason and Treesitter.

---

## Project Structure

The installer is modularized into separate scripts under `scripts/`, making each component easy to read, test, or run independently:

```text
environment-setup/
├── install.sh                     # Main installer entrypoint
├── check.sh                       # Automated health check & verification suite
├── VERIFY.md                      # Hands-on interactive manual testing guide
├── scripts/
│   ├── common.sh                  # Shared logging, sudo handling, and OS/arch detection
│   ├── 01-prereqs.sh              # Ensures curl, wget, and certificates are installed first
│   ├── 02-system-packages.sh      # System upgrade, packages, runtimes (Node, Python), & eza
│   ├── 03-security.sh             # UFW / firewall rules (SSH, HTTP 80, HTTPS 443)
│   ├── 04-atuin.sh                # Atuin shell history installation
│   ├── 05-neovim.sh               # Neovim (v0.10+) binary & configuration sync
│   └── 06-terminal-config.sh      # Fish shell configuration, tmux.conf, default shell setup
└── nvim/                          # Neovim dotfiles & Lua configurations
```

---

## Post-Install Tips

1. **Start Fish**:
   ```bash
   fish
   ```
   *(If not already switched to your default shell)*.

2. **Atuin History Search**:
   * Press `Up` or `Ctrl+R` inside Fish to bring up the interactive Atuin search.
   * To sync your history across other devices, run `atuin register` or `atuin login`.

3. **Tmux Basics**:
   * Prefix key is `Ctrl+B`.
   * `Ctrl+B` then `|` splits vertically.
   * `Ctrl+B` then `-` splits horizontally.
   * `Ctrl+B` then `h/j/k/l` moves between panes.
   * Mouse scrolling and clicking are enabled out of the box.

4. **Launch Neovim**:
   ```bash
   nvim
   ```
   Plugins and Mason tools will install automatically on first launch.

### Neovim sidebar redraw artifacts

If scrolling the file tree shows duplicated rows and `Ctrl+L` clears them, the
display is stale; this does not mean files have been duplicated. Until redrawn,
the visible filename may not match the entry under the mouse, so redraw before
opening anything.

The generated tmux config uses `default-terminal "tmux-256color"` so applications
see tmux's capabilities rather than those of an xterm. For an existing setup,
change that line in `~/.tmux.conf`, run `tmux source-file ~/.tmux.conf`, then open
a **new tmux window** and restart Neovim there. Existing panes keep their old
`TERM`. `echo $TERM` in the new window should print `tmux-256color`; do not force
this value outside tmux.

If the artifact persists, compare `nvim .` inside and outside tmux in the same
container. If it only happens inside tmux, check/update tmux and the Windows
terminal application. If it also happens outside tmux, try
`nvim --clean '+set mouse=a' .` to distinguish a terminal/Neovim issue from this
plugin configuration (the clean session uses the built-in directory browser).

Neovim's platform-specific clipboard handling and bottom-terminal configuration
live in `nvim/lua/config/clipboard.lua` and `nvim/lua/config/terminal.lua`;
`init.lua` loads them automatically. Copy the whole `nvim/` directory when
updating the installed config, not just `init.lua`.
