## TODO

- [ ] Replace the waifu thing with a prayer time widget
- [x] Prayer times in top bar
- [ ] Remake the Quran thing from KDE setup to sidebar
- [x] Update color changing script to include other tools, like `alacritty`, 

## Setup

[OG](https://github.com/end-4/dots-hyprland/tree/illogical-impulse)

- Arch running hypr
- Terminal: foot, alacritty, kitty
- Shell: fish + starship
- IDE: nvim, vscode, rstudio
- dmenu: ags, anyrun, ags

## Backing up dotfiles

From [this link](https://www.atlassian.com/git/tutorials/dotfiles).

```fish
git init --bare $HOME/.cfg
alias home '/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
home config --local status.showUntrackedFiles no
```

Add this to `fish.config`.

```fish
alias home '/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

Add stuff to config

```fish
home add $FILE
home commit -m "Add $FILE"
home push
```

Init with git

```fish
home remote add origin REMOTE-URL
home remote -v
home push origin main #or whatever branch
```

## Random thoughts

### How changing colors works

The way color schemes work is via the script `$HOME/.config/ags/scripts/color_generation/applycolor.sh`. Check `$HOME/.config/ags/scripts/color_generation/pywal_to_material.scss` and `$HOME/.config/ags/scripts/color_generation/specials/_material_badapple.scss` to get an idea of the colors available. They are set using a `sed` command.

To edit configs for whatever is being edited by `ags`, there are two ways of doing this:
- edit the file in the template folder `$HOME/.config/ags/scripts/templates/`
- make the `applycolor.sh` script edit a file that is imported into the config file, if the tool allows this

For now I'm sticking with the former, even if the latter is more elegant.

### Arabic in terminals

No terminal is great for bidi support. Konsole might be the best, but it does not have an easy text file configuration - configuration is done via GUI. Kitty is a good runner up. Plus Kitty has awesome [documentation](https://sw.kovidgoyal.net/kitty/conf/).

### Alacritty was alalitty but now is ala-not-as-good-as-kitty

Cause of a) no easy documentation for its toml files (they recently switched from yaml to toml) and b) no bidi

### Foot has gotten the boot

Fun terminal, but the fact that I can't figure out `Ctrl C` is not okay


