# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

Deployment requires GNU Make and Stow.

**macOS (Homebrew)**

```sh
brew install bash bat eza fd fzf git git-delta ripgrep starship stow tmux tree vim watch \
  zsh zsh-autosuggestions zsh-syntax-highlighting
```

Use a Nerd Font for prompt and status-bar icons. Optional macOS terminal setup:

```sh
brew install --cask ghostty font-meslo-lg-nerd-font
```

**Arch Linux**

```sh
sudo pacman -S --needed bash bat eza fd fzf git git-delta make procps-ng ripgrep \
  starship stow tmux tree vim zsh zsh-autosuggestions zsh-syntax-highlighting
```

**FreeBSD**

```sh
doas pkg install bash bat cmdwatch eza fd-find fzf git git-delta gmake ripgrep \
  starship stow tmux tree vim zsh zsh-autosuggestions zsh-syntax-highlighting
```

On FreeBSD, use **`gmake`** instead of `make` in the examples below.

## Install

```sh
git clone https://github.com/pnedkov/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make list
make N git starship tmux vim zsh  # Preview
make git starship tmux vim zsh    # Deploy
```

Select only the packages you want.
Open a new shell after deployment.
If using Ghostty, run `make ghostty`; its configuration uses Meslo LGS Nerd Font Mono.

## Commands

Run from the repository root:

```sh
make                 # Help
make list            # Available packages and their groups
make tmux zsh        # Stow (same as make S tmux zsh)
make R tmux zsh      # Restow links
make D tmux zsh      # Delete links
make N tmux zsh      # Simulate stow
make R N tmux zsh    # Simulate restow
```

Choose one action (`S`, `R`, or `D`); add `N` to simulate without changes.
Letters can appear anywhere, without hyphens, and apply to all selected packages.

## Notes

| Group | Target |
| --- | --- |
| `config/` | `$XDG_CONFIG_HOME` (defaults to `~/.config`) |
| `home/` | `$HOME` |
| `bin/` | `~/.local/bin` |

- **Discovery:** Each top-level directory with a `.stowrc` is a group; its
  subdirectories are packages. New groups and packages need no Makefile changes.
  `make zsh` deploys both `config/zsh` and `home/zsh`. For scripts, add an
  executable at `bin/myscript/myscript`, run `make myscript`, and put
  `~/.local/bin` on your `PATH`.

- **XDG_CONFIG_HOME:** No initial setup is required. The Makefile defaults
  `XDG_CONFIG_HOME` to `~/.config` and creates missing target directories.

- **Git identity:** Set `user.name` and `user.email` per repository. Remotes
  matching `git@github.com:pnedkov/**` also load `[user]` settings from
  `~/.config/git-private/personal.conf`:

  ```gitconfig
  [user]
      name = Your Name
      email = you@example.com
  ```

- **tmux TPM and plugins:** When TPM is missing, starting tmux automatically
  installs TPM and all configured plugins. For plugins added later, press
  `C-Space` then `I`.
  Plugins live in `$XDG_DATA_HOME/tmux/plugins`, falling back to `~/.tmux/plugins`.
