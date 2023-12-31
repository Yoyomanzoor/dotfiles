## Set values
# Hide welcome message & ensure we are reporting fish as shell
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -x SHELL /usr/bin/fish

## Export variable need for qt-theme
if type "qtile" >> /dev/null 2>&1
   set -x QT_QPA_PLATFORMTHEME "qt5ct"
end

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low


## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
  source ~/.fish_profile
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end


## Starship prompt
if status --is-interactive
   source ("/usr/local/bin/starship" init fish --print-full-init | psub)
end


## Advanced command-not-found hook
# source /usr/share/doc/find-the-command/ftc.fish


## Functions
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | trim-right /)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

## Useful aliases

alias conda 'mamba'

# Replace ls with exa
alias ls 'exa -al --color=always --group-directories-first --icons' # preferred listing
alias la 'exa -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll 'exa -l --color=always --group-directories-first --icons'  # long format
alias lt 'exa -aT --color=always --group-directories-first --icons' # tree listing
alias l. 'exa -ald --color=always --group-directories-first --icons .*' # show only dotfiles

# Replace some more things with better alternatives
alias cat 'batcat' 


# Common use
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'
alias big 'expac -H M "%m\t%n" | sort -h | nl'     # Sort installed packages according to size in MB (expac must be installed)
alias dir 'dir --color=auto'
alias egrep 'grep -E --color=auto'
alias fgrep 'grep -F --color=auto'
alias grep 'grep --color=auto'
alias grubup 'sudo update-grub'
alias hw 'hwinfo --short'                          # Hardware Info
alias ip 'ip -color'
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'
alias rmpkg 'sudo apt remove '
alias tarnow 'tar -acf '
alias untar 'tar -zxvf '
alias vdir 'vdir --color=auto'
alias wget 'wget -c '

# Help people new to Arch
alias please 'sudo'
alias tb 'nc termbin.com 9999'
alias helpme 'echo "To print basic information about a command use tldr <command>"'

# Cleanup orphaned packages
alias cleanup 'sudo apt autoremove'

# Get the error messages from journalctl
alias jctl 'journalctl -p 3 -xb'

# Recent installed packages

## Run fastfetch if session is interactive
if status --is-interactive && type -q fastfetch
   fastfetch --load-config neofetch
end

#### Sumeed

alias vpn '/opt/cisco/anyconnect/bin/vpn connect umvpn.umnet.umich.edu/umvpn-split-tunnel-alt'

####

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/yoyomanzoor/mambaforge/bin/conda
    eval /home/yoyomanzoor/mambaforge/bin/conda "shell.fish" "hook" $argv | source
end

if test -f "/home/yoyomanzoor/mambaforge/etc/fish/conf.d/mamba.fish"
    source "/home/yoyomanzoor/mambaforge/etc/fish/conf.d/mamba.fish"
end
# <<< conda initialize <<<

