#!/usr/bin/env bash
# Link only this branch's seven applications and WSL helper programs.
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
config=${XDG_CONFIG_HOME:-$HOME/.config}
backup=
link() {
    local source=$1 target=$2
    if [[ -L $target && $(readlink -f -- "$target") == "$source" ]]; then
        return
    fi
    if [[ -e $target || -L $target ]]; then
        if [[ -z $backup ]]; then
            mkdir -p "$HOME/.local/state/dotfiles-backups"
            backup=$(mktemp -d "$HOME/.local/state/dotfiles-backups/arch-wsl.XXXXXXXX")
        fi
        mkdir -p "$backup/$(dirname -- "${target#"$HOME"/}")"
        mv -- "$target" "$backup/${target#"$HOME"/}"
    fi
    mkdir -p "$(dirname -- "$target")"
    ln -s -- "$source" "$target"
}
for app in nvim tmux sesh fish zathura fastfetch yazi; do
    link "$repo/.config/$app" "$config/$app"
done
for script in "$repo"/.local/bin/*; do
    link "$script" "$HOME/.local/bin/$(basename -- "$script")"
done
# tmux reads ~/.tmux.conf before the XDG config. Prevent an old file shadowing it.
link "$repo/.config/tmux/tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/Downloads"
printf 'Installed Arch WSL dotfiles from %s\n' "$repo"
[[ -z $backup ]] || printf 'Previous files saved in %s\n' "$backup"
printf 'Restart Fish and start a new tmux server/session. See README.md for dependencies.\n'
