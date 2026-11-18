# Tmux Cheat Sheet

**Prefix:** `Ctrl+B`, release, then press the key.

## Start / return

```sh
tmux new -s work        # start named session
tmux ls                 # list sessions
tmux attach -t work     # rejoin from outside
tmux switch-client -t work  # switch from inside tmux
```

Don't type bare `tmux` inside a session. Use `Ctrl+B`, then `C` for a window.

## Windows

| Keys | Does |
|---|---|
| `Prefix c` | New window |
| `Prefix ,` | Rename window |
| `Prefix 1` / `2` | Go to window |
| `Prefix n` / `p` | Next / previous |
| `Prefix &` | Close window |

## Panes

| Keys | Does |
|---|---|
| `Prefix \|` | Split side-by-side |
| `Prefix -` | Split top/bottom |
| `Prefix h/j/k/l` | Move between panes |
| `Prefix z` | Zoom / unzoom pane |
| `Prefix x` | Close pane |

## Session

| Keys / command | Does |
|---|---|
| `Prefix d` | Detach; session keeps running |
| `tmux kill-session -t work` | End session |

## Neovim + terminal

1. `tmux new -s work -n nvim`
2. Run `nvim .`
3. `Prefix c` to open a terminal window.
4. `Prefix 1` = Neovim; `Prefix 2` = terminal.

