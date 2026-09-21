#!/bin/sh
set -eu

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/git"
config="$config_dir/id.conf"

if [ -e "$config" ] || [ -L "$config" ]; then
  exit 0
fi

if [ -L "$config_dir" ]; then
  printf 'Git identity setup requires a real directory: %s\n' "$config_dir" >&2
  exit 1
fi

if [ ! -t 0 ]; then
  printf '%s\n' 'Git identity is missing. Run make git in a terminal to set it up.' >&2
  exit 0
fi

command -v git >/dev/null 2>&1 || {
  printf '%s\n' 'Git is required to configure your identity.' >&2
  exit 1
}

printf '\nSet up Git identity in %s\n' "$config"
for field in name email; do
  while :; do
    printf 'Git %s: ' "$field"
    if ! IFS= read -r value; then
      printf '\nGit identity setup skipped. Run make git to retry.\n'
      exit 0
    fi
    case "$value" in
      *[![:space:]]*) break ;;
      *) printf 'Please enter a non-empty %s.\n' "$field" ;;
    esac
  done
  case "$field" in
    name) name=$value ;;
    email) email=$value ;;
  esac
done

umask 077
mkdir -p "$config_dir"
temporary=$(mktemp "$config_dir/.id.conf.XXXXXX")
trap 'rm -f "$temporary"' 0
trap 'exit 1' HUP INT TERM

git config --file "$temporary" user.name "$name"
git config --file "$temporary" user.email "$email"
# Publish the complete file without overwriting an existing identity.
ln "$temporary" "$config"
printf 'Saved Git identity to %s\n' "$config"
