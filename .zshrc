#
# ~/.zshrc
#

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

# user-specific binaries
[[ -d ~/.bin && -z $TMUX && ${PATH} != *"${HOME}/.bin"* ]] && PATH=${PATH}:${HOME}/.bin

# enable homebrew completions
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

# exports
export TERM=screen-256color
export LESS='-Q -F -R --use-color -Dd+r$Du+b$'
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"
export EDITOR=vim

# aliases
alias ..='cd ..'
alias ls='ls --color=auto'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias dmesg='dmesg -L=always'

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

# bat
if [ -x "$(command -v bat)" ]; then
  alias cat='bat -p'
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

# terraform
if [ -x "$(command -v terraform)" ]; then
  alias t='terraform'
fi

# start tmux automatically - not the best idea after all
#if [ -x "$(command -v tmux)" ] && [ -z "${TMUX}" ]; then
#    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
#fi

# enable forward search with Ctrl-S
#stty -ixon

genpass() {
  [[ -z "$1" ]] && l=16 || l=$1
  openssl rand -base64 4096 | tr -cd '[[:alnum:]]' | head -c $l
  echo
}

# set cursor
# 0 -> blinking block
# 1 -> blinking block (default)
# 2 -> steady block
# 3 -> blinking underline
# 4 -> steady underline
# 5 -> blinking bar (xterm)
# 6 -> steady bar (xterm)
#printf '\033[2 q'

# powerlevel10k theme
if [[ -r "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-them" ]]; then
    source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
