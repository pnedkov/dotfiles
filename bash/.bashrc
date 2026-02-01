#
# ~/.bashrc
#

# Return if non-interactive
[[ $- != *i* ]] && return

# Supported OS
case "$(uname -s)" in
  Linux)   is_linux=1 ;; # Arch btw
  Darwin)  is_macos=1 ;; # Why?!
  FreeBSD) is_freebsd=1 ;;
esac

#
# Helpers
#
has() { [[ -n $1 ]] && command -v "$1" >/dev/null 2>&1; }
path_export() { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"; }

# User-specific binaries
[[ -z $TMUX ]] && path_export "$HOME/.local/bin"

# Exports
export TERM=screen-256color
export LESS='-Q -F -R --use-color -Dd+r$Du+b$'
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"
has vim && export EDITOR=vim

# Aliases
alias ..='cd ..'
alias ls='ls --color=auto'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
alias lld='ls -ld'
alias lln='ls -ln'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias dmesg='dmesg -L=always'
has ifconfig && alias ip="ifconfig | grep 'inet '"

# eza
if has eza; then
  eza_common='--icons --git --time-style "+%Y %b %e %H:%M"'

  alias ls="e"
  alias ll="el"
  alias lla="ela"
  alias llt="et"
  alias e="eza -g $eza_common"
  alias el="eza -lg $eza_common"
  alias ela="eza -lga $eza_common"
  alias et="eza --tree --git-ignore"
fi

# pacman
if [[ -f /etc/arch-release && $EUID -eq 0 ]]; then
  alias pacup="pacman -Syyu"
  alias pacsearch="pacman -Ss"
  alias pacinfo="pacman -Si"
  alias pacowns="pacman -Qo"
  alias paclist="pacman -Ql"
fi

# neovim
if has nvim; then
  alias nv='nvim'
  alias vimdiff='nvim -d'
  export EDITOR=nvim
fi

# aws
if has aws ; then
  alias whoaws='aws sts get-caller-identity'
fi

# git
if has git; then
  alias g='git'
  git_compl_file="/usr/share/git/completion/git-completion.bash"
  if [ -f "$git_compl_file" ]; then
    source "$git_compl_file"
    complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g
  fi
fi

# docker
if has docker; then
  alias d='docker'
  docker_compl_file="/usr/share/bash-completion/completions/docker"
  if [ -f "$docker_compl_file" ]; then
    source "$docker_compl_file"
    complete -o default -F __start_docker d
  fi
fi

# kubectl
if has kubectl; then
  alias k='kubectl'
  kubectl_compl_file="/usr/share/bash-completion/completions/kubectl"
  if [ -f "$kubectl_compl_file" ]; then
    source "$kubectl_compl_file"
    complete -o default -F __start_kubectl k
  fi
fi

# terraform
if has terraform; then
  alias t='terraform'
  terraform_compl_file="/usr/share/bash-completion/completions/terraform"
  if [ -f "$terraform_compl_file" ]; then
    source "$terraform_compl_file"
    complete -C '/usr/bin/terraform' t
  fi
fi

# bat
if has bat; then
  alias cat='bat -p'
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


#
# Key bindings
#

# Use emacs key bindings
set -o emacs

# Ctrl-Backspace / Ctrl-H: delete word backward
bind '"\C-h": backward-kill-word'

# Ctrl-R: reverse incremental history search
bind '"\C-r": reverse-search-history'

# Ctrl-Left / Ctrl-Right: word navigation
bind '"\e[1;5D": backward-word'
bind '"\e[1;5C": forward-word'


# start tmux automatically - not the best idea after all
#if [ -x "$(command -v tmux)" ] && [ -z "${TMUX}" ]; then
#    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
#fi

# enable forward search with Ctrl-S
stty -ixon

#
# Functions
#

# Generate passwords
genpass() {
  if (( $# > 1 )); then
    printf 'Usage: %s [length]\n' "${FUNCNAME[0]}" >&2
    return 1
  fi

  local len=${1:-16}
  [[ $len =~ ^[0-9]+$ ]] || len=16

  LC_ALL=C openssl rand -base64 4096 \
    | tr -cd '[:alnum:]' \
    | head -c "$len"
  echo
}

# Print only non-empty and non-commented lines
ccat() {
  if (( $# == 0 )); then
    printf 'Usage: %s <file1> [file2 ...]\n' "${FUNCNAME[0]}" >&2
    return 1
  fi

  # Drop comment-only lines and blank/whitespace-only lines
  sed -E '/^[[:space:]]*#/d; /^[[:space:]]*$/d' -- "$@"
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
