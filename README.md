# Environment Setup

Quick, automated setup script for Linux environments (Ubuntu, Debian, Oracle Linux, Fedora, Arch) and WSL, tailored for terminal development with **Neovim**, **Fish shell**, **Atuin**, **tmux**, and modern CLI tools.

## Installation

Clone the repository and run `install.sh`:

```bash
git clone https://github.com/DmitriiS-dev/environment-setup.git
cd environment-setup
chmod +x install.sh
./install.sh
```

---

## What Gets Installed & Configured

### 1. Baseline Tools & Prerequisites
* **curl & git**: Guaranteed to be installed first to support repository cloning, binary downloads, and version control.

### 2. Terminal Shell & Environment
* **Fish Shell**: Modern, user-friendly interactive shell with syntax highlighting and autosuggestions.
* **Atuin**: Magically records your shell command history into an encrypted SQLite database. Search across commands and directories with `Ctrl+R`.
* **tmux**: Terminal multiplexer configured with 24-bit TrueColor support, mouse scrolling, vim keybindings, and easy window/pane splits (`|` and `-`).

### 3. Modern CLI Utilities
* **eza**: Modern, colorful replacement for `ls` with filetype indicators, git status, and tree views.
* **bat**: `cat` clone with syntax highlighting and git integration.
* **btop & htop**: Beautiful and powerful interactive system monitors for CPU, memory, disks, and processes.

### 4. Firewall & Security
* **UFW Firewall**: Configured and enabled out of the box with safe inbound rules for **SSH** (port 22), **HTTP** (port 80), and **HTTPS** (port 443).

### 5. Neovim & Development Stack
* **Neovim 0.10+ / 0.11+**: Fast native plugin loading (`blink.cmp`, `fzf-lua`, `mini.nvim`, `diffview`, `trouble`, etc.).
* **Clipboard over SSH**: Configured with OSC 52 so copying in Neovim over SSH works directly to your local workstation's clipboard.
* **LSP Runtimes**: Node.js/npm, Python 3/pip, C compiler (`gcc`/`build-essential`) for Mason and Treesitter.

---

## Project Structure

The installer is modularized into separate scripts under `scripts/`, making each component easy to read, test, or run independently:

```text
environment-setup/
├── install.sh                     # Main installer entrypoint
├── scripts/
│   ├── common.sh                  # Shared logging, sudo handling, and OS/arch detection
│   ├── 01-prereqs.sh              # Ensures curl, git, and certificates are installed first
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
