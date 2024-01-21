#
# ~/.bashrc
#

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

# user-specific binaries
[[ -d ~/.bin && -z $TMUX && ${PATH} != *"${HOME}/.bin"* ]] && PATH=${PATH}:${HOME}/.bin

# exports
export TERM=screen-256color
export LESS='-Q -F -R --use-color -Dd+r$Du+b$'
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"
export EDITOR=vim

# aliases
alias ..='cd ..'
alias ls='ls --color=auto'
alias ll='ls -l'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias dmesg='dmesg -L=always'

# eza
if [ -x $(command -v eza) ]; then
  alias ls="e"
  alias ll="el"
  alias e="eza -g --git --time-style '+%Y %b %e %H:%M'"
  alias el="eza -lg --git --time-style '+%Y %b %e %H:%M'"
  alias ela="eza -lga --git --time-style '+%Y %b %e %H:%M'"
  alias et="eza --tree"
fi

# pacman
if [ $(id -u) = 0 ]; then
  alias pacup="pacman -Syyu"
  alias pacsearch="pacman -Ss"
  alias pacinfo="pacman -Si"
  alias pacowns="pacman -Qo"
  alias paclist="pacman -Ql"
fi

# neovim
if [ -x $(command -v nvim) ]; then
  alias nv='nvim'
  alias vimdiff='nvim -d'
  export EDITOR=nvim
fi

# aws
if [ -x $(command -v aws) ]; then
  alias whoaws='aws sts get-caller-identity'
fi

# git
if [ -x $(command -v git) ]; then
  alias g='git'
  git_compl_file="/usr/share/git/completion/git-completion.bash"
  if [ -f "$git_compl_file" ]; then
    source "$git_compl_file"
    complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g
  fi
fi

# docker
if [ -x $(command -v docker) ]; then
  alias d='docker'
  docker_compl_file="/usr/share/bash-completion/completions/docker"
  if [ -f "$docker_compl_file" ]; then
    source "$docker_compl_file"
    complete -o default -F __start_docker d
  fi
fi

# kubectl
if [ -x $(command -v kubectl) ]; then
  alias k='kubectl'
  kubectl_compl_file="/usr/share/bash-completion/completions/kubectl"
  if [ -f "$kubectl_compl_file" ]; then
    source "$kubectl_compl_file"
    complete -o default -F __start_kubectl k
  fi
fi

# terraform
if [ -x $(command -v terraform) ]; then
  alias t='terraform'
  terraform_compl_file="/usr/share/bash-completion/completions/terraform"
  if [ -f "$terraform_compl_file" ]; then
    source "$terraform_compl_file"
    complete -C '/usr/bin/terraform' t
  fi
fi

# set the primary prompt (PS1)
if [ $(id -u) = 0 ]; then
  PS1="\[\033[38;5;12m\][\[$(tput sgr0)\]\[\033[38;5;9m\]\u\[$(tput sgr0)\]\[\033[38;5;12m\]@\[$(tput sgr0)\]\[\033[38;5;7m\]\h\[$(tput sgr0)\]\[\033[38;5;12m\]]\[$(tput sgr0)\]\[\033[38;5;15m\]: \[$(tput sgr0)\]\[\033[38;5;7m\]\w\[$(tput sgr0)\]\[\033[38;5;12m\]>\[$(tput sgr0)\]\[\033[38;5;9m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
else
  PS1="\[\033[38;5;12m\][\[$(tput sgr0)\]\[\033[38;5;10m\]\u\[$(tput sgr0)\]\[\033[38;5;12m\]@\[$(tput sgr0)\]\[\033[38;5;7m\]\h\[$(tput sgr0)\]\[\033[38;5;12m\]]\[$(tput sgr0)\]\[\033[38;5;15m\]: \[$(tput sgr0)\]\[\033[38;5;7m\]\w\[$(tput sgr0)\]\[\033[38;5;12m\]>\[$(tput sgr0)\]\[\033[38;5;10m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
fi

# start bash-git-promp if available
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
  GIT_PROMPT_ONLY_IN_REPO=1
  GIT_PROMPT_SHOW_UPSTREAM=1
  GIT_PROMPT_THEME=Single_line_NoExitState
  source "$HOME/.bash-git-prompt/gitprompt.sh"
fi

# start tmux automatically - not the best idea after all
#if [ -x "$(command -v tmux)" ] && [ -z "${TMUX}" ]; then
#    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
#fi

# enable forward search with Ctrl-S
stty -ixon

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
printf '\033[2 q'
