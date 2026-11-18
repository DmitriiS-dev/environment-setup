# Environment Setup

A shared terminal development setup for Ubuntu/Debian, Fedora/RHEL/Oracle Linux,
Arch, and Linux distributions running under WSL. Plain Bash and Lua; no framework
or configuration generator.

## Install

Install Git with your distribution's package manager, then:

```bash
git clone https://github.com/DmitriiS-dev/environment-setup.git
cd environment-setup
bash install.sh
bash check.sh
```

**The installer upgrades system packages, overwrites the installed Neovim,
Fish and tmux configs, changes the login shell to Fish, and enables a firewall
allowing SSH/22, HTTP/80 and HTTPS/443.** Back up personal configs first.
Firewall setup needs host privileges; a restricted container may reject it.
Failed required steps stop the installer instead of reporting success.

Individual steps remain runnable, for example:

```bash
bash scripts/05-neovim.sh          # Install Neovim if needed, then copy its config
bash scripts/06-terminal-config.sh # Copy Fish/tmux configs and set the login shell
```

## Included

| Area | Shared features |
| --- | --- |
| Shell | Fish, eza aliases, Atuin history (`Ctrl+R`) |
| Terminal | tmux, true colour, mouse support, Vim-style pane navigation |
| Editor | Neovim **0.12+**, native `vim.pack`, file tree, fuzzy search, Git tools |
| Language tools | Treesitter, Mason, LSP, completion, diagnostics and formatting |
| Runtimes | C compiler, Python with pip/venv, Node/npm, Go, unzip |
| Utilities | curl, wget, certificates, btop, htop |
| Firewall | UFW, with firewalld fallback on RHEL-family systems |

Plugins and Mason tools install on Neovim's first launch. See
[Neovim keybindings](nvim/KEYBINDINGS.md) for editor shortcuts.

## Where to make changes

```text
install.sh                 Ordered setup steps
check.sh                   Read-only health checks and summary
scripts/
  common.sh                Logging, paths, privilege and OS detection
  os/
    debian.sh              apt packages and eza repository
    rhel.sh                dnf/yum packages and firewall fallback
    arch.sh                pacman packages
  01-prereqs.sh            Download tools and certificates
  02-system-packages.sh    Shared packages plus the selected OS adapter
  03-security.sh           Shared firewall rules
  04-atuin.sh              Atuin installation
  05-neovim.sh             Neovim installation and config copy
  06-terminal-config.sh    Terminal config copy and login shell
  install-eza.sh           Release-binary fallback
  checks/                  Tools, configs and firewall health checks
config/
  fish/config.fish         Shared Fish config
  tmux.conf                Shared tmux config
nvim/
  init.lua                 Explicit module load order
  lua/config/              Focused editor modules (see below)
tests/
  shell.sh                 Mocked installer checks; no system changes
  nvim.lua                 Isolated Lua configuration checks
```

OS differences stay in the three adapters: package names, package-manager
commands and firewall selection. Common features and terminal configs stay
shared. To add a distribution, map its ID/ID_LIKE in `detect_os` and add or reuse
an adapter. Unsupported distributions fail with a clear message.

Neovim modules are plain Lua files, loaded explicitly rather than discovered
automatically:

| Change | File under `nvim/lua/config/` |
| --- | --- |
| Editor settings, general shortcuts, events | `options.lua`, `keymaps.lua`, `autocmds.lua` |
| Theme and restrained Python colours | `theme.lua` |
| Plugin list and versions | `plugins.lua` |
| Parsers and syntax | `treesitter.lua` |
| File tree and search | `files.lua` |
| Editing helpers and buffer tabs | `editing.lua` |
| Statusline, minimap, Which-Key and panels | `ui.lua` |
| Git features and shortcuts | `git.lua` |
| Mason tools and prerequisite warnings | `tools.lua` |
| Diagnostics, scrollbar and floating previews | `diagnostics.lua` |
| Completion | `completion.lua` |
| Language servers and Python environments | `lsp/init.lua`, `lsp/python.lua` |
| LSP shortcuts and format-on-save | `lsp/keymaps.lua`, `lsp/formatting.lua` |
| Windows/WSL/container/SSH clipboard | `clipboard.lua` |
| Bottom terminal and platform-specific shell | `terminal.lua` |

Copy the **whole `nvim/` directory**, not just `init.lua`, when applying updates.
The installer already does this.

## Development checks

```bash
bash tests/shell.sh
nvim --clean --headless -l tests/nvim.lua
```

The tests mock privileged commands and use temporary files; they do not upgrade
packages, change the firewall, or change the login shell. `bash check.sh` inspects
the actual installation, continues after failures, and returns nonzero if any
required checks fail. Optional tools or inaccessible firewall status produce
warnings.

## Using the setup

Start `fish` and launch `nvim .` in your project. In tmux, the prefix is
`Ctrl+B`: `|` and `-` split panes, `h/j/k/l` move between them, and `r` reloads
the config. `atuin register` or `atuin login` enables history sync.

The font belongs to the terminal application on your workstation, not Neovim
or tmux. A Nerd Font such as **JetBrainsMono Nerd Font Mono** preserves file
icons; select it in the terminal's profile settings.

### Clipboard in containers and over SSH

OSC 52 copies yanked text to the host clipboard through a compatible terminal.
Container clipboard reads cannot reliably read the Windows clipboard: enter
Insert mode and use your terminal's paste shortcut (for example
`Ctrl+Shift+V` in Windows Terminal). Neovim's clipboard-register paste reuses
the last text yanked inside Neovim without asking the terminal for clipboard
access.

### Sidebar redraw artifacts

If scrolling the file tree shows duplicated rows and `Ctrl+L` clears them, the
display is stale, not the files. Redraw before clicking: the displayed filename
may not match the entry under the mouse.

The shared tmux config advertises `tmux-256color`. After updating
`~/.tmux.conf`, run `tmux source-file ~/.tmux.conf` and open a **new tmux window**;
existing panes retain their old `TERM`. Do not force this value outside tmux.

If the artifact persists, compare `nvim .` inside and outside tmux in the same
container. If it only occurs inside tmux, check/update tmux and your host
terminal application. Otherwise try `nvim --clean '+set mouse=a' .` to compare
against Neovim's built-in directory browser without plugins.
