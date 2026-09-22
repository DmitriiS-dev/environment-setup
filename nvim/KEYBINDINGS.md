# Neovim Keybindings

Leader key: `Space`

Modes:

- `N` = Normal mode
- `I` = Insert mode
- `V` = Visual mode
- `T` = Terminal mode

Press `Space` and wait for Which-Key to show available leader mappings. Some LSP mappings only appear after a language server attaches to the current buffer.

## Daily Shortcuts

| Keys | Mode | Action |
| --- | --- | --- |
| `Space Space` | N | Find files in the project |
| `Space fc` | N | Command palette: search and run Neovim commands |
| `Space fg` | N | Search text across the project |
| `Ctrl+F` | N | Incrementally find text in the current file |
| `Space e` | N | Toggle file tree |
| `Space t` | N | Toggle the bottom terminal |
| `Ctrl+`` | N/T | Toggle the bottom terminal when supported by the terminal |
| `Ctrl+'` | N/T | Toggle bottom terminal alias |
| `Ctrl+@` | N/T | Ctrl-backtick terminal alias on Windows terminals |
| `Ctrl+S` | N/I | Save the current file |
| `Ctrl+C` | V | Copy selection to the Windows clipboard |
| `Ctrl+V` | N/I/V | Paste from the Windows clipboard |
| `Ctrl+O` | N | Jump back after following a definition or file |
| `Ctrl+I` | N | Jump forward after jumping back |
| `gf` | N | Go to LSP symbol definition; falls back to file navigation |
| `gd` | N | Go to LSP definition |
| `Space go` | N | Use native file-under-cursor navigation |
| `gF` | N | Open file under cursor at its specified line |
| `K` | N | Show hover documentation |
| `Space lp` | N | Show function parameter/signature help |
| `Alt+Enter` | N/I | Show LSP code actions and quick fixes |
| `Space mm` | N | Toggle the real code minimap |
| `Space zz` | N | Toggle Zen Mode |

## Search And Files

| Keys | Mode | Action |
| --- | --- | --- |
| `Space Space` | N | Find files with fzf-lua |
| `Space ff` | N | Find files with fzf-lua |
| `Space fb` | N | Search open buffers |
| `Space fh` | N | Search Neovim help tags |
| `Space fc` | N | Search commands and run one |
| `Space fg` | N | Search project text with ripgrep |
| `Ctrl+F` | N | Find in the current file; results update and navigate as you type |
| `Space fx` | N | Diagnostics for the current document |
| `Space fX` | N | Diagnostics across the workspace |
| `gf` | N | LSP definition first, native file navigation as fallback |
| `Space go` | N | Native file-under-cursor navigation |
| `gF` | N | Native file-under-cursor navigation with line support |

Select a project-search result with `Enter` to open it at the matching line. While using `Ctrl+F`, press `Enter`, then use `n` and `N` to move through matches.

## Completion Suggestions

| Keys | Mode | Action |
| --- | --- | --- |
| `Down` / `Ctrl+J` | I | Select the next completion suggestion |
| `Up` / `Ctrl+K` | I | Select the previous completion suggestion |
| `Enter` | I | Accept the selected suggestion |
| `Ctrl+Space` | I | Open or close completion suggestions |
| `Tab` / `Shift+Tab` | I | Move forward or backward through snippet placeholders |

## LSP And Python

These mappings are buffer-local and appear after BasedPyright or another LSP attaches.

| Keys | Mode | Action |
| --- | --- | --- |
| `gd` | N | Go to definition |
| `gD` | N | Go to declaration |
| `Space gd` | N | Find definitions with fzf-lua |
| `Space gS` | N | Open the definition in a vertical split |
| `Space lf` | N | LSP Saga finder: definitions, references, implementations |
| `Space lh` | N | LSP Saga hover documentation |
| `Space lp` | N | Show function signature and parameter hints |
| `Space la` | N | LSP Saga code actions |
| `Space lr` | N | LSP Saga rename symbol |
| `Space lo` | N | LSP Saga symbol outline |
| `Space ld` | N | LSP Saga diagnostics for the current line |
| `Space ca` | N | Standard LSP code actions |
| `Alt+Enter` | N/I | Standard LSP code actions and auto-imports |
| `Space rn` | N | Rename symbol |
| `K` | N | Hover documentation |
| `Space fr` | N | Find references |
| `Space ft` | N | Find type definitions |
| `Space fs` | N | Document symbols |
| `Space fw` | N | Workspace symbols |
| `Space fi` | N | Find implementations |
| `Space oi` | N | Organize imports, when supported by the LSP |

For Python, use `gd`, `gf`, or `Space gd` on an enum, class, function, or imported symbol. BasedPyright detects `.venv`, `venv`, `env`, or `.env` in the project, including when the file is opened from Diffview.

## Diagnostics

| Keys | Mode | Action |
| --- | --- | --- |
| `Space d` | N | Diagnostics at the cursor |
| `Space D` | N | Diagnostics for the current line |
| `Space dl` | N | Show line diagnostics |
| `Space nd` | N | Jump to the next diagnostic |
| `Space pd` | N | Jump to the previous diagnostic |
| `Space q` | N | Open the diagnostic location list |
| `Space td` | N | Toggle diagnostics |
| `Space xx` | N | Trouble: workspace diagnostics |
| `Space xX` | N | Trouble: current-buffer diagnostics |
| `Space xs` | N | Trouble: document symbols |
| `Space xq` | N | Trouble: quickfix list |
| `Space fx` | N | fzf-lua: document diagnostics |
| `Space fX` | N | fzf-lua: workspace diagnostics |

The minimap shows source-code structure and highlights diagnostics from Neovim's diagnostic API, including BasedPyright errors.

The right scrollbar always shows error, warning, information, and hint markers across the file. Inline messages are shortened so they stay on-screen; use `Space d`, `Space D`, or `Space xx` for the complete message and problem list.

## Git

| Keys | Mode | Action |
| --- | --- | --- |
| `Space gg` | N | Fugitive Git status |
| `Space gc` | N | Fugitive Git commit |
| `Space gp` | N | Fugitive Git push |
| `Space gl` | N | Fugitive Git log |
| `Space gv` | N | Open VS Code-style Git changes sidebar |
| `Space gs` | N | Open Git source-control sidebar |
| `Space gq` | N | Close Git changes sidebar |
| `Space gh` | N | Open Git file history |
| `]h` | N | Go to next diff hunk |
| `[h` | N | Go to previous diff hunk |
| `Space hs` | N | Stage a diff hunk |
| `Space hp` | N | Toggle diff preview overlay |
| `Space hb` | N | Show Git blame at the cursor |

Useful Fugitive commands:

```vim
:Git status
:Git diff
:Git blame
:Git log
:Git push
```

### Diffview Sidebar

Press `Space gv` or `Space gs` inside a Git repository. Diffview opens a source-control-style panel:

- The left panel lists changed, staged, and untracked files.
- Select a file to see its diff.
- Use `Space gq` to close the panel.
- Use `Space gh` to browse file history.

Inside Diffview, the file panel can be focused with `Tab`, and the selected file can be opened with `Enter`.

The left gutter shows Git changes without opening Diffview: green bars are added lines, yellow bars are changed lines, and red bars are deleted lines. Two sign columns are reserved so Git bars and diagnostic icons remain visible together.

## Open File Tabs

Open buffers are shown across the top of the window like editor tabs in VS Code.

| Keys | Mode | Action |
| --- | --- | --- |
| `]b` | N | Next open file tab |
| `[b` | N | Previous open file tab |
| `Space bd` | N | Close the current file tab |

Modified files show a `+` marker in the top tabline.

## Clipboard And Editing

| Keys | Mode | Action |
| --- | --- | --- |
| `Space p` | V | Paste without replacing the yank register |
| `Space x` | N/V | Delete without replacing the yank register |
| `Ctrl+C` | V | Copy selection to the system clipboard |
| `Ctrl+V` | N/I/V | Paste from the system clipboard |
| `Space pa` | N | Copy the full current file path |
| `Space c` | N | Clear search highlights |
| `n` | N | Next search result, centered |
| `N` | N | Previous search result, centered |
| `Ctrl+D` | N | Half-page down, centered |
| `Ctrl+U` | N | Half-page up, centered |
| `J` | N | Join lines and keep cursor position |
| `Alt+J` | N/V | Move line or selection down |
| `Alt+K` | N/V | Move line or selection up |
| `<` | V | Indent left and reselect |
| `>` | V | Indent right and reselect |
| `j` | N | Move down by display line when text wraps |
| `k` | N | Move up by display line when text wraps |

## Windows And Buffers

| Keys | Mode | Action |
| --- | --- | --- |
| `Ctrl+B` | N | Toggle file tree |
| `Space e` | N | Toggle file tree |
| `Space bn` | N | Next buffer |
| `Space bp` | N | Previous buffer |
| `Space sv` | N | Vertical split |
| `Space sh` | N | Horizontal split |
| `Ctrl+Up` | N | Increase window height |
| `Ctrl+Down` | N | Decrease window height |
| `Ctrl+Left` | N | Decrease window width |
| `Ctrl+Right` | N | Increase window width |
| `Ctrl+O` | N | Jump backward in the jumplist |
| `Ctrl+I` | N | Jump forward in the jumplist |

## Bottom Terminal

| Keys | Mode | Action |
| --- | --- | --- |
| `Space t` | N | Open or close the terminal at the bottom |
| `Ctrl+`` | N/T | Open or close the bottom terminal |
| `Ctrl+'` | N/T | Open or close the bottom terminal |
| `Ctrl+@` | N/T | Open or close the bottom terminal |
| `Esc` | T | Leave terminal insert mode |
| `Ctrl+Q` | T | Close the bottom terminal panel |

On Windows, the terminal prefers PowerShell 7 (`pwsh.exe`), then Windows PowerShell, and finally Neovim's configured shell. It does not require a `SHELL` environment variable.

## Obsidian Notes

| Keys | Mode | Action |
| --- | --- | --- |
| `Space nn` | N | Create a new note |
| `Space nf` | N | Find a note |
| `Space ns` | N | Search notes |
| `Space nt` | N | Open today's note |
| `Space nw` | N | Switch Obsidian workspace |

## Which-Key Groups

Press `Space` and wait:

| Prefix | Group |
| --- | --- |
| `Space f` | Find and diagnostics pickers |
| `Space g` | Git and LSP |
| `Space l` | LSP Saga |
| `Space x` | Trouble and diagnostics |
| `Space z` | Zen Mode |
| `g` | Goto commands such as `gf`, `gF`, `gd`, and `gD` |

## Native Commands Worth Knowing

```vim
:LspInfo       Show attached language servers
:checkhealth   Run Neovim health checks
:messages      Show recent messages
:Inspect       Inspect Treesitter information under the cursor
:Git status    Show Fugitive Git status
:Mason         Open the Mason tool manager
:TSInstall     Install a Treesitter parser
```

This file documents the configuration in `init.lua`. When adding a new mapping, add it here too so the cheat sheet stays current.
