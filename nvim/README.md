# Neovim config

Modern rewrite of the old `.vimrc` (2015 Vundle/YCM/cscope era → 2026 lazy.nvim/LSP/treesitter).
The old `.vimrc` is kept in the repo root as a reference / museum piece.

## What changed

| Old (`.vimrc`)                     | New                                  |
| ---------------------------------- | ------------------------------------ |
| Vundle                             | lazy.nvim (self-bootstrapping)       |
| YouCompleteMe / jedi / python-mode | native LSP via Mason                 |
| syntastic                          | native LSP diagnostics               |
| cscope (`,g` `,s` `,c` `,t`)       | LSP + telescope (same keys)          |
| ctrlp / MRU                        | telescope (`C-f`, `C-b`)             |
| NERDTree (`F4`)                    | nvim-tree (`F4`)                     |
| tagbar (`F8`)                      | aerial (`F8`)                        |
| vim-clang-format / clang-format.py | conform.nvim (`<leader>f`, `C-\`)    |
| per-language syntax plugins        | treesitter                           |
| vim-airline                        | lualine                              |

## Install

```sh
# 1. Install Neovim (>= 0.10). On Ubuntu, the apt version is usually too old:
sudo snap install nvim --classic          # or use the appimage / ppa

# 2. Point Neovim at this config
ln -s ~/src/mysettings/nvim ~/.config/nvim

# 3. Launch. lazy.nvim bootstraps itself, then run:
nvim
#   :Lazy           -> installs all plugins
#   :Mason          -> confirms LSP servers/formatters installed
#   :TSUpdate       -> installs treesitter parsers
```

Mason auto-installs the language servers (`clangd`, `gopls`, `pyright`, `ruff`,
`ts_ls`, `lua_ls`). Formatters used by conform that you may want on `$PATH`:
`clang-format`, `goimports`/`gofumpt`, `prettier`, `stylua` (Mason can install
most via `:MasonInstall`).

## Truecolor inside tmux (important)

This config sets `termguicolors`. You're currently on `screen-256color` with no
`COLORTERM`, so colors will look washed out under tmux until you enable truecolor
passthrough. Add to `~/.tmux.conf`:

```tmux
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
```

Then `tmux kill-server` and restart. Verify inside nvim with `:checkhealth`.

## Key mappings (carried over from the old config)

Leader is `,` (unchanged).

| Key            | Action                          |
| -------------- | ------------------------------- |
| `,g`           | go to definition                |
| `,s`           | find references                 |
| `,c`           | incoming calls (callers)        |
| `,i`           | implementations                 |
| `,t`           | live grep across project        |
| `K`            | hover docs                      |
| `,rn`          | rename symbol                   |
| `,ca`          | code action                     |
| `,f` / `C-\`   | format buffer/selection         |
| `C-f`          | find files                      |
| `C-b` / `Spc-b`| recent files                    |
| `F4`           | toggle file tree                |
| `F8`           | toggle symbol outline           |
| `,w`           | flash motion jump               |
| `,n`           | clear search highlight          |
| `Spc-w`/`Spc-q`| write / quit                    |
| `S-Tab`        | next window                     |
| `C-h/j/k/l`    | move across vim splits + tmux   |
| `F5` (in Go)   | `go run %`                      |
| `:FormatToggle`| toggle format-on-save           |
</content>
