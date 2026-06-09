# mysettings task runner. Run `make` (or `make help`) to list targets.
SHELL := /bin/bash
REPO  := $(CURDIR)

.PHONY: help install test lint scan fmt check

help:  ## list targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sort | awk -F':.*## ' '{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

install:  ## symlink dotfiles, nvim, and devbox into place
	mkdir -p ~/.config ~/.local/bin
	ln -sf  $(REPO)/.zshrc          ~/.zshrc
	ln -sf  $(REPO)/.tmux.conf      ~/.tmux.conf
	ln -sfn $(REPO)/nvim            ~/.config/nvim
	ln -sf  $(REPO)/scripts/devbox  ~/.local/bin/devbox
	@echo "Linked. For devbox, also: cp scripts/devbox.env.example ~/.config/devbox.env && edit it."

test:  ## run the devbox test suite
	bash tests/test_devbox.sh

lint:  ## shellcheck the maintained scripts
	shellcheck scripts/devbox scripts/devbox-bootstrap-identity.sh provision/bootstrap-devbox.sh tests/test_devbox.sh

scan:  ## scan the full git history for secrets
	gitleaks git . --no-banner

fmt:  ## terraform fmt
	terraform -chdir=provision fmt

check: test lint scan  ## run all checks (test + lint + scan)

.DEFAULT_GOAL := help
