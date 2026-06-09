# mysettings

My personal dev environment — terminal, editor, and dev-VM workflow.
Originally a 2015 Vim/tmux/zsh setup; modernized in 2026.

## What's here

| File / dir | What it is |
| --- | --- |
| `nvim/` | **Neovim** config (lazy.nvim + native LSP via Mason + treesitter + telescope). See `nvim/README.md`. |
| `.zshrc` | **zsh** config (oh-my-zsh + powerlevel10k, vi-mode, fzf, truecolor). |
| `.tmux.conf` | **tmux** config (vi keys, mouse, 24-bit truecolor passthrough). |
| `scripts/devbox` | **devbox CLI** — start/deallocate an Azure dev VM and bring up a phone-reachable Claude session. See `scripts/DEVBOX.md`. |
| `scripts/` | helpers — `clang-format.py`, `vim_switch_scheme.vim`, VNC/setup utilities. |
| `tests/` | test suite for the devbox CLI (`bash tests/test_devbox.sh`). |
| `.vimrc`, `.my_zshrc` | the original 2015–2016 Vim/zsh configs, kept for reference. |

## Quick start

```sh
git clone <this-repo> ~/src/mysettings

# shells
ln -sf ~/src/mysettings/.zshrc     ~/.zshrc
ln -sf ~/src/mysettings/.tmux.conf ~/.tmux.conf

# neovim  (needs Neovim >= 0.10; lazy.nvim + Mason self-bootstrap on first launch)
ln -sf ~/src/mysettings/nvim ~/.config/nvim

# devbox CLI  (see scripts/DEVBOX.md for the Mac/VM split + Azure setup)
ln -sf ~/src/mysettings/scripts/devbox ~/.local/bin/devbox
```

## Notes

- **Truecolor:** the configs assume a 24-bit terminal (iTerm2, etc.). Inside tmux,
  the `Tc` overrides in `.tmux.conf` carry it through over SSH.
- **Secrets stay out of this (public) repo.** Machine-specific config lives in
  `~/.config/devbox.env` (untracked); only `scripts/devbox.env.example` is committed.

No warranties — copy and adapt as you like.
