set -gx EDITOR nvim
set -gx BUNDLE_PATH $HOME/.gems
# set -g fish_greeting

if string match -qir '.*\.utf-?8' -- $LANG $LC_CTYPE
    set -l animal_marine 🐡 🐠 🐟 🐬 🐳 🐋 🦈 🐙 🦑 🦦 🪼 🪸 🦩
    set -l animal_reptile 🐢 🐊
    set -l food_marine 🦐 🦞 🦀

    set fishes $animal_marine $animal_reptile $food_marine

    function fishes_greeting
       echo (random choice $fishes; random choice $fishes; random choice $fishes)
    end

    set fish_greeting (fishes_greeting)
end

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

if status is-interactive
    starship init fish | source
end

# pomodoro
function pomodoro 
  echo $argv[1] | lolcat
  timer "$argv[2]"
end

alias po="pomodoro"
alias wo="pomodoro work 45"
alias br="pomodoro break 10"

# List Directory
alias l 'eza -al --color=always --group-directories-first --icons=auto' # preferred listing
alias ls 'eza -al --color=always --group-directories-first --icons=auto' # preferred listing
alias la 'eza -a --color=always --group-directories-first --icons=auto'  # all files and dirs
alias ll 'eza -lha --color=always --group-directories-first --icons=auto --sort=name'  # long format
alias lt 'eza --icons=auto --tree' # list folder as tree
alias ltt 'eza -aT --color=always --group-directories-first --icons=auto' # tree listing
alias l. 'eza -ald --color=always --group-directories-first --icons=auto .*' # show only dotfiles

# tmux
# abbr tmux 'TERM=screen-256color tmux'

# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

abbr v 'nvim'
abbr n 'nvim'

abbr mpvm 'mpv --no-video '

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -p'

alias cat 'bat'
alias big 'expac -H M "%m\t%n" | sort -h | nl'     # Sort installed packages according to size in MB (expac must be installed)
alias dir 'dir --color=auto'
alias fixpacman 'sudo rm /var/lib/pacman/db.lck'
alias gitpkg 'pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages
alias grep 'ugrep --color=auto'
alias egrep 'ugrep -E --color=auto'
alias fgrep 'ugrep -F --color=auto'
alias grubup 'sudo update-grub'
alias hw 'hwinfo --short'                          # Hardware Info
alias ip 'ip -color'
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'
alias rmpkg 'sudo pacman -Rdd'
alias tarnow 'tar -acf '
alias untar 'tar -zxvf '
alias vdir 'vdir --color=auto'
alias wget 'wget -c '
alias rt 'trash put'
alias tp 'trash put'
alias tl 'trash list'
alias tr 'trash restore'
alias please 'sudo'

alias conda 'micromamba'

# lab things
# ----------
abbr ssh-joanna 'sshfs -o allow_other smanzoor@greatlakes-xfer.arc-ts.umich.edu:/nfs/turbo/umms-sjoanna/smanzoor ~/turbo'
abbr ssh-snitkin 'sshfs -o allow_other smanzoor@greatlakes-xfer.arc-ts.umich.edu:/nfs/turbo/umms-esnitkin/Project_MDHHS_genomics/Analysis/KPC_regional_transmission ~/turbo'
abbr ssh-welch 'sshfs -o allow_other smanzoor@greatlakes-xfer.arc-ts.umich.edu:/nfs/turbo/umms-welchjd/smanzoor ~/turbo'
abbr ssh-home 'sshfs -o allow_other smanzoor@greatlakes-xfer.arc-ts.umich.edu:./ ~/turbo'

alias vpn_connect '/opt/cisco/secureclient/bin/vpn connect umvpn.umnet.umich.edu/umvpn-split-tunnel-alt'
alias vpn_disconnect '/opt/cisco/secureclient/bin/vpn disconnect'
# alias vd '/opt/cisco/secureclient/bin/vpn disconnect'

# alias home '/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'

# Get the error messages from journalctl
alias jctl 'journalctl -p 3 -xb'

# Recent installed packages
alias rip 'expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort | tail -200 | nl'

# idk why this isnt a builtin
function fish_remove_path
  if set -l index (contains -i "$argv" $fish_user_paths)
    set -e fish_user_paths[$index]
    echo "Removed $argv from the path"
  end
end

# git stuff - doesn't work
function commit
   if parameter_is_provided $argv
      git add .
      git commit -am "$argv"
      git push
   else
      newline
      echo "Please provide a commit message:" && newline
      set_color blue; printf "commit "; set_color green; printf "\"this is a commit message\"";
      set_color normal
   end
end

# Fish command history
function history
   builtin history --show-time='%F %T '
end

function backup --argument filename
   cp $filename $filename.bak
end

set -g fish_key_bindings fish_vi_key_bindings
# fix things I broke (via tmux)
bind -M insert \e\ck kill-line

# some more fun bindings
bind -M insert \cn 'nvim'
bind -M insert \cy 'y'
bind -M insert \ca 'taskwarrior-tui'

# projectdo: install projectdo to use
# abbr -a b --function projectdo_build
# abbr -a r --function projectdo_run
# abbr -a e --function projectdo_test
# abbr -a p --function projectdo_tool
alias e='projectdo test'
alias r='projectdo run'
alias b='projectdo build'
alias p='projectdo tool'

function check_git
   if git rev-parse --is-inside-work-tree > /dev/null 2>&1
      lazygit
   end
end
bind -M insert alt-g 'check_git'

zoxide init fish | source

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
set -gx MAMBA_EXE "/usr/bin/micromamba"
set -gx MAMBA_ROOT_PREFIX "/home/yoyomanzoor/.local/share/mamba"
$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
# <<< mamba initialize <<<
