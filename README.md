# mysettings

My personal dev environment — shell, editor, terminal, and a one-command Azure
dev-VM workflow. Started life in 2015 as a Vim/tmux/zsh setup; modernized in 2026
(Neovim + LSP, a `devbox` CLI, and Terraform disaster recovery).

This is a **public** repo. Nothing identifying (VM names, subscription IDs, IPs,
keys) is committed — all machine-specific values live in untracked local files.

---

## Layout

```
.
├── .zshrc                  # zsh: oh-my-zsh + powerlevel10k, vi-mode, fzf, truecolor
├── .tmux.conf              # tmux: vi keys, mouse, 24-bit truecolor passthrough
├── nvim/                   # Neovim config (lazy.nvim + LSP + treesitter)  -> nvim/README.md
│   ├── init.lua
│   └── lazy-lock.json      # pinned, validated plugin versions
├── scripts/
│   ├── devbox              # the devbox CLI (start/stop VM + Claude session)  -> scripts/DEVBOX.md
│   ├── devbox-bootstrap-identity.sh
│   ├── devbox.env.example  # config template (copy to ~/.config/devbox.env)
│   └── …legacy helpers (clang-format.py, vim_switch_scheme.vim, …)
├── provision/              # Terraform + cloud-init to rebuild the VM  -> provision/README.md
│   ├── *.tf, terraform.tfvars.example
│   ├── cloud-init.yaml.tftpl
│   └── bootstrap-devbox.sh
├── tests/test_devbox.sh    # dependency-free test suite for devbox (mocks az/ssh/tmux)
├── Makefile                # make install / test / lint / scan / check
├── .github/workflows/ci.yml  # CI: tests, shellcheck, terraform validate, gitleaks
└── …reference relics (.vimrc, .my_zshrc, putty-monokai.reg, *.yml)
```

---

## The four pieces

### 1. Shell & terminal
- **`.zshrc`** — oh-my-zsh + powerlevel10k, `set -o vi` with `KEYTIMEOUT=1`, fzf,
  `batcat`, history tuning, and `COLORTERM=truecolor`.
- **`.tmux.conf`** — vi copy-mode, mouse, and the `Tc` overrides that pass 24-bit
  truecolor through tmux over SSH (needs a truecolor terminal like iTerm2).

Symlink them: `ln -sf $PWD/.zshrc ~/.zshrc && ln -sf $PWD/.tmux.conf ~/.tmux.conf`.

### 2. Neovim — [`nvim/README.md`](nvim/README.md)
Modern rewrite of the old `.vimrc`: **lazy.nvim**, **native LSP via Mason**,
**treesitter**, **telescope**, **conform**. Old muscle-memory keymaps preserved
(`,g`/`,s`/`,c`, `F4`/`F8`, `C-f`/`C-b`). Validated on Neovim 0.12.2.
`ln -sf $PWD/nvim ~/.config/nvim`, launch `nvim`, plugins self-install.

### 3. `devbox` CLI — [`scripts/DEVBOX.md`](scripts/DEVBOX.md)
One command to run an Azure dev VM cheaply and reach Claude from your phone:

```
devbox up | down | status        # power on / deallocate (stops billing) / state + spend
devbox code [project]            # start VM, bring up a phone-pairable Claude session, open VS Code
devbox claude                    # attach that Claude session (on the VM)
devbox ssh | autoshutdown | help
```

One portable script that auto-detects Mac vs VM (via Azure IMDS). Config lives in
`~/.config/devbox.env` (untracked). See the doc for the Mac/VM split, the
managed-identity setup, and the billing model.

### 4. Disaster recovery — [`provision/README.md`](provision/README.md)
Lost the VM? **Terraform** recreates the Azure resources (VM, static IP + DNS,
NSG, self-deallocate identity, auto-shutdown) and **cloud-init** runs
`bootstrap-devbox.sh` to reinstall tooling and re-apply this repo. `terraform
apply`, wait for cloud-init, `ssh` in, `claude` login — done.

---

## Quick start (fresh machine)

```sh
git clone <this-repo> ~/src/mysettings && cd ~/src/mysettings

# shell + terminal
ln -sf $PWD/.zshrc ~/.zshrc
ln -sf $PWD/.tmux.conf ~/.tmux.conf

# neovim (needs >= 0.10; plugins + LSPs self-bootstrap)
ln -sf $PWD/nvim ~/.config/nvim

# devbox CLI
mkdir -p ~/.local/bin && ln -sf $PWD/scripts/devbox ~/.local/bin/devbox
cp scripts/devbox.env.example ~/.config/devbox.env   # then edit it
```

On a brand-new VM, `provision/bootstrap-devbox.sh` does all of the above
automatically.

## Tests & checks

```sh
make test     # 40 devbox tests (az/ssh/tmux mocked, no external deps)
make lint     # shellcheck the scripts
make scan     # gitleaks secret scan over full git history
make check    # all of the above
make install  # symlink dotfiles + nvim + devbox into place
```

**CI** (`.github/workflows/ci.yml`) runs the tests, shellcheck, `terraform
validate`, and a gitleaks secret scan on every push/PR. A `.pre-commit-config.yaml`
runs gitleaks + shellcheck + `terraform fmt` locally on commit (`pre-commit install`).

## Design principles

- **Secrets stay out of this public repo.** Real values live only in
  `~/.config/devbox.env` and `provision/terraform.tfvars` (both gitignored);
  committed files ship `.example` templates with placeholders.
- **Truecolor end to end** — iTerm2 → SSH → tmux (`Tc`) → nvim (`termguicolors`).
- **One portable `devbox`** that adapts to where it runs instead of two scripts.
- **Verify for real** — devbox has a test suite; the Terraform and Neovim configs
  were validated by actually running them.

## Reference relics (kept, not used)

The original 2015–2017 setup, left for reference: `.vimrc` (Vundle/YouCompleteMe
era), `.my_zshrc`, `putty-monokai.reg`, `siege.yml`/`ap.yml`/`wf.yml` (old load
test / Ansible), `FIXES.md`, `Useful.Commands`, and `scripts/{clang-format.py,
start_vnc.sh, ubuntu_install_pkgs.sh, vim_switch_scheme.vim}`.

No warranties — copy and adapt as you like.
