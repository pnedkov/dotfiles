#
# ~/.bashrc
#

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

# user-specific binaries
[[ -d ~/.bin && -z $TMUX ]] && PATH=${PATH}:~/.bin

# aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias g='git'

# exports
export TERM=xterm-256color
export EDITOR=vim
export LESS='-F -R --use-color -Dd+r$Du+b$'
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"

# fix git-completion for the 'g' alias
if [ -f /usr/share/git/completion/git-completion.bash ]; then
    source /usr/share/git/completion/git-completion.bash
    __git_complete g __git_main
fi

# set the primary prompt (PS1)
if [ `id -u` = 0 ] ; then
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

# start tmux automatically
#if [ -x "$(command -v tmux)" ] && [ -z "${TMUX}" ]; then
#    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
#fi

# enable forward search with Ctrl-S
stty -ixon

genpass() {
    [[ -z "$1" ]] && l=16 || l=$1
    openssl rand -base64 4096 | tr -cd '[[:alnum:]]' | head -c $l ; echo
}
