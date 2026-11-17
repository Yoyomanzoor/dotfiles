# Arch WSL: no HyDE, GUI shell hooks, hardcoded user, or automatic credentials.
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER wsl-open
fish_add_path -g $HOME/.local/bin $HOME/go/bin

if status is-interactive
    set -g fish_greeting
    fish_vi_key_bindings
    if type -q starship
        starship init fish | source
    end
    if type -q zoxide
        zoxide init fish | source
    end
    if type -q eza
        alias ls 'eza --group-directories-first --icons=auto'
        alias l 'eza -al --group-directories-first --icons=auto'
        alias ll 'eza -lh --group-directories-first --icons=auto'
        alias lt 'eza --tree --icons=auto'
    end
    if type -q bat
        alias cat bat
    end
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a n nvim
    abbr -a v nvim
    abbr -a t 'tmux new-session -A -s work'
    abbr -a ss fzf-sesh
    abbr -a open wsl-open
    # Ctrl+Alt avoids Windows Terminal's Ctrl+Shift shortcuts.
    bind -M insert \e\cn 'commandline -r nvim; commandline -f execute'
    bind -M insert \e\cy 'commandline -r y; commandline -f execute'
    bind -M insert \e\cs 'commandline -r fzf-sesh; commandline -f execute'
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/miniconda3/bin/conda
    eval /opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/miniconda3/etc/fish/conf.d/conda.fish"
        . "/opt/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

