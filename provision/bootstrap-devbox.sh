#!/usr/bin/env bash
#
# Bootstrap a fresh devbox VM with my dev environment.
#
# Runs AS THE ADMIN USER on first boot (invoked by cloud-init), but is safe to
# run again by hand. The admin user has passwordless sudo on an Azure VM, so the
# apt/chsh steps work non-interactively.
#
# Idempotent: every step checks before doing.

set -euo pipefail

REPO="$HOME/src/mysettings"
log() { printf '\n=== %s ===\n' "$*"; }

log "apt packages"
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  zsh tmux git curl unzip \
  build-essential python3 python3-pip \
  ripgrep fzf bat

log "node 18+ (Ubuntu 22.04's apt nodejs is v12 - too old for claude / mason LSPs)"
need_node=1
if command -v node >/dev/null 2>&1; then
  ver="$(node -v | sed 's/v\([0-9]*\).*/\1/')"
  [ "${ver:-0}" -ge 18 ] && need_node=0
fi
if [ "$need_node" = 1 ]; then
  # No '|| true' here: if Node fails, the box can't run claude, so fail loudly.
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
fi
echo "node $(node -v)  npm $(npm -v)"

log "oh-my-zsh + powerlevel10k"
export RUNZSH=no CHSH=no
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
ZCUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ -d "$ZCUSTOM/themes/powerlevel10k" ] \
  || git clone --depth=1 https://github.com/romkatv/powerlevel10k "$ZCUSTOM/themes/powerlevel10k"

log "clone/refresh mysettings"
if [ -d "$REPO/.git" ]; then
  git -C "$REPO" pull --ff-only || true
else
  git clone "${REPO_URL:-https://github.com/youruser/mysettings.git}" "$REPO"
fi

log "symlink dotfiles + devbox"
mkdir -p "$HOME/.config" "$HOME/.local/bin"
ln -sf  "$REPO/.zshrc"          "$HOME/.zshrc"
ln -sf  "$REPO/.tmux.conf"      "$HOME/.tmux.conf"
ln -sfn "$REPO/nvim"            "$HOME/.config/nvim"
ln -sf  "$REPO/scripts/devbox"  "$HOME/.local/bin/devbox"

log "neovim (official tarball -> ~/.local)"
if ! command -v nvim >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/nvim" ]; then
  curl -fsSL -o /tmp/nvim.tgz \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  rm -rf "$HOME/.local/nvim-linux-x86_64"
  tar -C "$HOME/.local" -xzf /tmp/nvim.tgz
  ln -sf "$HOME/.local/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
fi

log "neovim plugin bootstrap (headless; build-essential lets treesitter compile)"
"$HOME/.local/bin/nvim" --headless "+Lazy! sync" +qa || true

log "uv (the .zshrc references it; optional)"
command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh || true

log "claude code CLI"
command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash || true

log "default shell -> zsh"
sudo chsh -s "$(command -v zsh)" "$USER" || true

log "DONE"
cat <<'EOF'

Bootstrap complete. Two manual follow-ups:
  1. Run `claude` once and log in (your MAX subscription).
  2. If you'll use `devbox` from this VM, no config needed (it self-discovers
     via IMDS). On your Mac, set ~/.config/devbox.env (see scripts/DEVBOX.md).
EOF
