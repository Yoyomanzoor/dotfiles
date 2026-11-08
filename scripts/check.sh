#!/usr/bin/env bash
set -uo pipefail
failed=0
for exe in nvim fish tmux sesh fzf fd rg git make cc curl unzip node npm yarn \
    python fastfetch yazi bat eza zoxide starship \
    powershell.exe wslpath wsl-clipboard wsl-open wsl-pdf fzf-sesh nvim-pick; do
    if command -v "$exe" >/dev/null; then
        printf 'OK       %s\n' "$exe"
    else
        printf 'MISSING  %s\n' "$exe"
        failed=1
    fi
done
for exe in jupytext ipython radian R quarto zathura chafa pdftoppm lazygit tree-sitter; do
    command -v "$exe" >/dev/null || printf 'OPTIONAL %s\n' "$exe"
done
printf '\nWSLg display: %s / %s\n' "${WAYLAND_DISPLAY:-unset}" "${DISPLAY:-unset}"
printf 'Check nvim >= 0.12 and tree-sitter >= 0.26.1; then run :checkhealth in nvim.\n'
exit "$failed"
