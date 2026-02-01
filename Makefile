SHELL := /bin/sh
TARGET ?= $(HOME)

STOW  ?= stow
STOW_FLAGS ?= -t $(TARGET)
PACKAGES ?= bash git tmux vim zsh

.PHONY: help show check install uninstall restow dry

help:
	@printf '%s\n' \
	  'dotfiles Makefile (GNU Stow)' \
	  '' \
	  'Targets:' \
	  '  make install     stow packages into $(HOME)' \
	  '  make uninstall   remove stowed links' \
	  '  make restow      re-apply (use after changes)' \
	  '  make dry         show what would happen' \
	  '  make show        show packages used' \
	  '' \
	  'Overrides:' \
	  '  make install PACKAGES="zsh tmux"' \
	  '  make install STOW_FLAGS="--dotfiles -v"' \
	  ''

show:
	@echo "STOW_FLAGS: $(STOW_FLAGS)"
	@echo "PACKAGES:   $(PACKAGES)"

check:
	@command -v $(STOW) >/dev/null 2>&1 || { \
		echo "❌ '$(STOW)' is not installed."; \
		echo "Install GNU Stow:"; \
		echo "  macOS:   brew install stow"; \
		echo "  Linux:   sudo pacman -S stow # Arch btw"; \
		echo "  FreeBSD: pkg install stow"; \
		exit 1; \
	}

install: check
	@echo "→ stow -S $(PACKAGES)"
	@$(STOW) $(STOW_FLAGS) $(PACKAGES)

uninstall: check
	@echo "→ stow -D $(PACKAGES)"
	@$(STOW) $(STOW_FLAGS) -D $(PACKAGES)

restow: check
	@echo "→ stow -R $(PACKAGES)"
	@$(STOW) $(STOW_FLAGS) -R $(PACKAGES)

dry: check
	@echo "→ stow -n -v $(PACKAGES)"
	@$(STOW) $(STOW_FLAGS) -n -v $(PACKAGES)

