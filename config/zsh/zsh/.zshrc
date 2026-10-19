#
# ~/.config/zsh/.zshrc
#

# Return if non-interactive
[[ -o interactive ]] || return

# =============================================================================
# Environment
# =============================================================================

# Supported OS
case "$(uname -s)" in
  Linux)   is_linux=1 ;; # Arch btw
  Darwin)  is_macos=1 ;;
  FreeBSD) is_freebsd=1 ;;
esac

# Keep PATH entries unique, preserving the first occurrence
typeset -U PATH path

# User-specific binaries
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/.krew/bin" ]] && path=("$HOME/.krew/bin" $path)

# State and cache directories
zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
zsh_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
less_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/less"
if [[ ! -d "$zsh_cache_dir/zcompcache" || ! -d "$zsh_state_dir" || ! -d "$less_state_dir" ]]; then
  mkdir -p -m 700 -- "$zsh_cache_dir/zcompcache" "$zsh_state_dir" "$less_state_dir"
fi

# Exports
export LESS='-Q -F -R --use-color -Dd+r$Du+c$'
export LESSHISTFILE="$less_state_dir/history"
export MANPAGER="less -R --use-color -Dd+r -Du+c"
export MANROFFOPT="-P -c"

# Cleanup
unset less_state_dir

# =============================================================================
# Shell settings
# =============================================================================

# Turn off all beeps
unsetopt BEEP

# Allow comments in interactive commands
setopt INTERACTIVE_COMMENTS

# History settings
HISTFILE="$zsh_state_dir/history" # History savefile location
HISTSIZE=1000000              # Number of history items to save in memory
SAVEHIST=1000000              # Number of history items to save in file
setopt APPEND_HISTORY         # multiple sessions append to same history file (rather than last)
setopt EXTENDED_HISTORY       # changes the history file format from simple command lines to a structured format with metadata
setopt INC_APPEND_HISTORY     # append commands immediately
setopt HIST_IGNORE_ALL_DUPS   # when adding a new entry delete older duplicates
setopt HIST_IGNORE_DUPS       # don't add a new entry if it's an immediate duplicate
setopt HIST_IGNORE_SPACE      # prevents commands prefixed with a space from being saved to the history
setopt HIST_EXPIRE_DUPS_FIRST # expire duplicate entries first when the history list needs to be trimmed
setopt HIST_VERIFY            # prevents immediate execution when using history expansion (!! and !$)
setopt HIST_REDUCE_BLANKS     # automatically removes superfluous whitespace
setopt HIST_FIND_NO_DUPS      # prevents the display of duplicate history entries
unsetopt SHARE_HISTORY        # no live history imports

# Enable completions
zstyle ':completion:*' menu select
zstyle ':completion:*' cache-path "$zsh_cache_dir/zcompcache"
# Try case-sensitive completion first, then ignore case
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
# Group completion candidates by type with bold headings
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
# Include . and .. in the list of possible completions
zstyle ':completion:*' special-dirs true
autoload -Uz compinit
compinit -d "$zsh_cache_dir/zcompdump"

# Cleanup
unset zsh_state_dir zsh_cache_dir

# =============================================================================
# Aliases
# =============================================================================

alias ..='cd ..'
alias ls='ls --color=auto'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ll -a'
alias lld='ll -d'
alias lln='ll -n'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
(( ${+is_linux} )) && alias dmesg='dmesg -L=always'

# =============================================================================
# Keybindings
# =============================================================================

# Use emacs key bindings
bindkey -e

#bindkey "^[[A" history-search-backward
#bindkey "^[[B" history-search-forward
bindkey '^R' history-incremental-search-backward

bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# =============================================================================
# Tools
# =============================================================================

# tree
(( $+commands[tree] )) && alias tree='tree -I .git'

# Homebrew
(( ${+is_macos} )) && (( $+commands[brew] )) && alias bup='brew update && brew upgrade'

# bat
(( $+commands[bat] )) && alias cat='bat -p'

# eza
if (( $+commands[eza] )); then
  alias ls='eza -g --icons --time-style "+%Y %b %e %H:%M"'
  alias llt='eza --tree --git-ignore'
  alias llta='llt -a'
fi

# Editors
(( $+commands[vim] )) && export EDITOR=vim
if (( $+commands[nvim] )); then
  alias vimdiff='nvim -d'
  export EDITOR=nvim
fi
[[ -n $EDITOR ]] && export VISUAL=$EDITOR

# AWS
(( $+commands[aws] )) && alias whoaws='aws sts get-caller-identity'

# Git
(( $+commands[git] )) && alias g='git'

# Docker
if (( $+commands[docker] )); then
  alias d='docker'

  docker() {
    case "${1-}" in
      psw)
        shift
        command docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Label "com.docker.compose.project.working_dir"}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}\t{{.Networks}}' "$@"
        ;;
      *)
        command docker "$@"
        ;;
    esac
  }
fi

# kubectl
(( $+commands[kubectl] )) && alias k='kubectl'

# Terraform
(( $+commands[terraform] )) && alias t='terraform'

# fzf (install its keybindings after the baseline bindings above)
if (( $+commands[fzf] )); then
  if (( $+commands[bat] && $+commands[eza] )); then
    export FZF_CTRL_T_OPTS="
      --preview 'if [ -d {} ]; then
        eza --tree --level=2 --follow-symlinks --all --color=always --icons=always --ignore-glob=.git -- {}
      elif [ -f {} ]; then
        bat --style=numbers --color=always --paging=never --line-range=:500 -- {}
      fi'
      --preview-window 'right,50%,border-left,<40(down,50%,border-top)'
      --bind 'ctrl-/:toggle-preview'
    "
  fi
  if (( $+commands[eza] )); then
    export FZF_ALT_C_OPTS="
      --preview 'eza --tree --level=2 --follow-symlinks --all --color=always --icons=always --ignore-glob=.git -- {}'
      --preview-window 'right,50%,border-left,<40(down,50%,border-top)'
      --bind 'ctrl-/:toggle-preview'
    "
  fi
  source <(fzf --zsh)
fi

# Starship
if (( $+commands[starship] )); then
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
  eval "$(starship init zsh)"
fi

# =============================================================================
# Functions
# =============================================================================

# Show IPv4 addresses with interface names and CIDR prefixes
ip4() {
  if (( $+commands[ip] )); then
    command ip -o -4 -color=never address show |
      awk '$3 == "inet" { printf "%-12s %s\n", $2, $4 }'
    return "$(( pipestatus[2] ? pipestatus[2] : pipestatus[1] ))"
  elif (( $+commands[ifconfig] )); then
    command ifconfig | awk '
      function prefix_length(mask, value, i, octets, bits) {
        # Convert hexadecimal or dotted-decimal netmasks to an integer.
        if (mask ~ /^0x/) {
          for (i = 3; i <= length(mask); i++)
            value = value * 16 + index("0123456789abcdef", tolower(substr(mask, i, 1))) - 1
        } else {
          split(mask, octets, /[.]/)
          for (i = 1; i <= 4; i++) value = value * 256 + octets[i]
        }
        while (value) {
          bits += value % 2
          value = int(value / 2)
        }
        return bits + 0
      }
      /^[^[:space:]]/ {
        iface = $1
        sub(/:$/, "", iface)
      }
      $1 == "inet" {
        for (i = 3; i < NF; i++) {
          if ($i == "netmask") {
            printf "%-12s %s/%d\n", iface, $2, prefix_length($(i + 1))
            break
          }
        }
      }
    '
    return "$(( pipestatus[2] ? pipestatus[2] : pipestatus[1] ))"
  else
    printf '%s\n' 'ip4: neither ip nor ifconfig is available.' >&2
    return 1
  fi
}

# Show IPv6 addresses with interface names and CIDR prefixes
ip6() {
  if (( $+commands[ip] )); then
    command ip -o -6 -color=never address show |
      awk '$3 == "inet6" { printf "%-12s %s\n", $2, $4 }'
    return "$(( pipestatus[2] ? pipestatus[2] : pipestatus[1] ))"
  elif (( $+commands[ifconfig] )); then
    command ifconfig | awk '
      /^[^[:space:]]/ {
        iface = $1
        sub(/:$/, "", iface)
      }
      $1 == "inet6" {
        address = $2
        sub(/%.*/, "", address)
        for (i = 3; i < NF; i++) {
          if ($i == "prefixlen") {
            printf "%-12s %s/%d\n", iface, address, $(i + 1)
            break
          }
        }
      }
    '
    return "$(( pipestatus[2] ? pipestatus[2] : pipestatus[1] ))"
  else
    printf '%s\n' 'ip6: neither ip nor ifconfig is available.' >&2
    return 1
  fi
}

# Go to the Git repository root
groot() {
  local root
  root=$(git rev-parse --show-toplevel) || return
  cd -- "$root"
}
alias gcd='groot'

# Generate passwords
genpass() {
  if (( $# > 1 )); then
    print -u2 "Usage: ${funcstack[1]} [length]"
    return 1
  fi

  local len=${1-16} random password
  local LC_ALL=C
  if ! [[ $len =~ ^[1-9][0-9]{0,3}$ ]] || (( len > 1024 )); then
    printf '%s\n' 'Password length must be an integer from 1 to 1024.' >&2
    return 1
  fi

  random=$(openssl rand -base64 4096) || return 1
  password=${random//[^[:alnum:]]/}
  if (( ${#password} < len )); then
    printf '%s\n' 'Could not generate a password of the requested length.' >&2
    return 1
  fi
  printf '%s\n' "${password:0:$len}"
}

# Print only non-empty and non-commented lines
ccat() {
  # Drop comment-only lines and blank/whitespace-only lines
  sed -E '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$@"
}

# =============================================================================
# Experimental
# =============================================================================

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

# =============================================================================
# Local overrides
# =============================================================================

# Apply machine-specific settings before plugins initialize.
for _file in "${XDG_CONFIG_HOME:-$HOME/.config}"/zsh-local/*.zsh(N); do
  source "$_file"
done

# Cleanup
unset _file

# =============================================================================
# Plugins
# =============================================================================

# Load after tools and local widgets, with syntax highlighting last.
zsh_plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
)

case 1 in
  $(( ${+is_macos} ))) plugin_dir="${HOMEBREW_PREFIX:-/opt/homebrew}/share" ;;
  $(( ${+is_linux} ))) plugin_dir='/usr/share/zsh/plugins' ;;
  $(( ${+is_freebsd} ))) plugin_dir='/usr/local/share' ;;
  *) plugin_dir='' ;;
esac

if [[ -n $plugin_dir ]]; then
  for plugin in $zsh_plugins; do
    plugin_file="$plugin_dir/$plugin/$plugin.zsh"
    [[ -r $plugin_file ]] && source "$plugin_file"
  done
fi

# Cleanup
unset zsh_plugins plugin_dir plugin plugin_file
unset is_linux is_macos is_freebsd
