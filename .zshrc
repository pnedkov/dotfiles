#
# ~/.zshrc
#

# Return if non-interactive
[[ -o interactive ]] || return

# User-specific binaries
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

# Supported OS
case "$(uname -s)" in
  Linux)   is_linux=1 ;; # Arch btw
  Darwin)  is_macos=1 ;;
  FreeBSD) is_freebsd=1 ;;
esac

# Enable completions
autoload -Uz compinit
compinit

# Turn off all beeps
unsetopt BEEP

# History settings
export HISTFILE=~/.zhistory   # History savefile location
export HISTSIZE=1000000       # Number of history items to save in memory
export SAVEHIST=1000000       # Number of history items to save in file
setopt APPEND_HISTORY         # multiple sessions append to same history file (rather than last)
setopt HIST_IGNORE_ALL_DUPS   # when adding a new entry delete older duplicates
setopt HIST_IGNORE_DUPS       # don't add a new entry if it's an immediate duplicate
setopt INC_APPEND_HISTORY     # adds history incrementally to share it across sessions
unsetopt SHARE_HISTORY        # share history between sessions
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_VERIFY
setopt HIST_REDUCE_BLANKS

# Exports
export TERM=xterm-256color
export LESS='-Q -F -R --use-color -Dd+r$Du+c$'
export MANPAGER="less -R --use-color -Dd+r -Du+c"
export MANROFFOPT="-P -c"
export EDITOR=vim

#
# Aliases
#
alias ..='cd ..'
alias ls='ls --color=always'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
alias lld='ls -ld'
alias lln='ls -ln'
alias v='vim'
alias grep='grep --color=always'
alias diff='diff --color=always'
alias ip="ifconfig | grep 'inet '"
alias dmesg='dmesg -L=always'
(( ${+is_macos} )) && (( $+commands[brew] )) && alias bup='brew update && brew upgrade'

# bat
(( $+commands[bat] )) && alias cat='bat -p'

# eza
if (( $+commands[eza] )); then
  local eza_common='--icons --git --time-style "+%Y %b %e %H:%M"'

  alias ls="e"
  alias ll="el"
  alias lla="ela"
  alias llt="et"
  alias e="eza -g $eza_common"
  alias el="eza -lg $eza_common"
  alias ela="eza -lga $eza_common"
  alias et="eza --tree"
fi

# neovim
if (( $+commands[nvim] )); then
  alias nv='nvim'
  alias vimdiff='nvim -d'
  export EDITOR=nvim
fi

# aws
(( $+commands[aws] )) && alias whoaws='aws sts get-caller-identity'

# git
(( $+commands[git] )) && alias g='git'

# docker
(( $+commands[docker] )) && alias d='docker'

# kubectl
(( $+commands[kubectl] )) && alias k='kubectl'

# terraform
(( $+commands[terraform] )) && alias t='terraform'

#
# zsh plugins
#
zsh_plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
)

plugin_dir=''

if (( ${+is_macos} )); then
  (( $+commands[brew] )) && (( ${+HOMEBREW_PREFIX} )) && plugin_dir="$HOMEBREW_PREFIX/share"
elif (( ${+is_linux} )); then
  plugin_dir='/usr/share/zsh/plugins'
elif (( ${+is_freebsd} )); then
  plugin_dir='/usr/local/share'
fi

[[ -n $plugin_dir ]] && for plugin in $zsh_plugins; do
  plugin_file="$plugin_dir/$plugin/$plugin.zsh"
  [[ -r $plugin_file ]] && source "$plugin_file"
done

# include . and .. in the list of possible completions
zstyle ':completion:*' special-dirs true

#
# Key bindings
#

# Use emacs key bindings
bindkey -e

# [Ctrl-Delete] - delete whole word backwards
bindkey '^H' backward-kill-word

#bindkey "^[[A" history-search-backward
#bindkey "^[[B" history-search-forward
bindkey '^R' history-incremental-search-backward

bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# zsh-suggestions settings
#bindkey '^ ' autosuggest-accept

# fzf
(( $+commands[fzf] )) && source <(fzf --zsh)

# Starship
(( $+commands[starship] )) && eval "$(starship init zsh)"

#
# Functions
#

# Generate passwords
genpass() {
  if (( $# > 1 )); then
    print -u2 "Usage: ${funcstack[1]} [length]"
    return 1
  fi

  local len=${1:-16}
  [[ $len == <-> ]] || len=16

  LC_ALL=C openssl rand -base64 4096 |
    tr -cd '[:alnum:]' |
    head -c "$len"
  echo
}

# Print only non-empty and non-commented lines
ccat() {
  if (( $# == 0 )); then
    print -u2 "Usage: ${funcstack[1]} <file1> [file2 ...]"
    return 1
  fi

  # Drop comment-only lines and blank/whitespace-only lines
  sed -E '/^[[:space:]]*#/d; /^[[:space:]]*$/d' -- "$@"
}

#
# Experimental
#

# Enable forward search with Ctrl-S
#stty -ixon


# Set cursor
# 0 -> blinking block
# 1 -> blinking block (default)
# 2 -> steady block
# 3 -> blinking underline
# 4 -> steady underline
# 5 -> blinking bar (xterm)
# 6 -> steady bar (xterm)
#printf '\033[2 q'

# Start tmux automatically
#if [ -x "$(command -v tmux)" ] && [ -z "${TMUX}" ]; then
#    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
#fi

