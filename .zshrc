#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# User-specific binaries
[[ -d ~/bin && -z $TMUX && ${PATH} != *"${HOME}/bin"* ]] && PATH=${PATH}:${HOME}/bin

# Enable homebrew completions
BREW_PREFIX=$HOMEBREW_PREFIX
[[ -z $BREW_PREFIX ]] && BREW_PREFIX=$(brew --prefix)

if type brew &>/dev/null; then
  FPATH="$BREW_PREFIX/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

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
setopt SHARE_HISTORY          # share history between sessions
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
alias v='vim'
alias grep='grep --color=always'
alias diff='diff --color=always'
alias ip="ifconfig | grep 'inet '"
alias dmesg='dmesg -L=always'

# bat
if [ -x "$(command -v bat)" ]; then
  alias cat='bat -p'
fi

# eza
if [ -x "$(command -v eza)" ]; then
  alias ls="e"
  alias ll="el"
  alias lla="ela"
  alias llt="et"
  alias e="eza -g --icons --git --time-style '+%Y %b %e %H:%M'"
  alias el="eza -lg --icons --git --time-style '+%Y %b %e %H:%M'"
  alias ela="eza -lga --icons --git --time-style '+%Y %b %e %H:%M'"
  alias et="eza --tree"
fi

# neovim
if [ -x "$(command -v nvim)" ]; then
  alias nv='nvim'
  alias vimdiff='nvim -d'
  export EDITOR=nvim
fi

# aws
if [ -x "$(command -v aws)" ]; then
  alias whoaws='aws sts get-caller-identity'
fi

# git
if [ -x "$(command -v git)" ]; then
  alias g='git'
fi

# docker
if [ -x "$(command -v docker)" ]; then
  alias d='docker'
fi

# kubectl
if [ -x "$(command -v kubectl)" ]; then
  alias k='kubectl'
fi

# kubectx
if [ -x "$(command -v kubectx)" ]; then
  alias kctx='kubectx'
fi

# kubens
if [ -x "$(command -v kubens)" ]; then
  alias kns='kubens'
fi

# terraform
if [ -x "$(command -v terraform)" ]; then
  alias t='terraform'
fi

#
# Powerlevel10k
#

# powerlevel10k theme
if [[ -r "$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    source $BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#
# zsh plugins
#
zsh_plugins=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
)

for zsh_plugin in "${zsh_plugins[@]}"; do
    zsh_plugin_file="$BREW_PREFIX/share/$zsh_plugin/$zsh_plugin.zsh"

    [[ -r "$zsh_plugin_file" ]] && source "$zsh_plugin_file"
done

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

# zsh-suggestions settings
#bindkey '^ ' autosuggest-accept

# Set up fzf key bindings and fuzzy completion
if [ -x "$(command -v fzf)" ]; then
  source <(fzf --zsh)
fi

#
# Functions
#

genpass() {
  [[ -z "$1" ]] && l=16 || l=$1
  openssl rand -base64 4096 | tr -cd '[[:alnum:]]' | head -c $l
  echo
}

ccat() {
    if [[ -z "$1" ]]; then
        echo "Usage: ${funcstack[1]} <file1> [file2 ...]"
        return 1
    fi

    sed '/^\s*#/d; /^\s*$/d' "$@"
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

