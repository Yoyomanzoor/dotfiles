# Arch Linux on WSL — Windows Terminal dotfiles

Branch: `arch-wsl`, derived from `hyprland-wallbash` at `0a168b4`.
This branch contains Neovim, tmux, sesh, Fish, Zathura, Fastfetch, Yazi,
and the helpers those configurations call. It does not install a Linux desktop,
HyDE, Hyprland, Kitty, or a terminal emulator inside WSL.

## 1. Windows prerequisites

Use WSL 2 and an up-to-date Windows Terminal. In PowerShell:

```powershell
wsl --version
wsl --list --verbose
wsl --update
```

If Arch is still WSL 1, convert it with `wsl --set-version <distribution-name> 2`.
Use the exact name shown by `wsl --list --verbose`.
After saving work in all WSL distributions, `wsl --shutdown` restarts WSL;
reopen Arch afterward.

Install a Nerd Font **in Windows**, then select it in Windows Terminal's Arch
profile, Appearance → Font face. For example, install JetBrainsMono Nerd Font
from https://www.nerdfonts.com/font-downloads. Installing the font only inside
Arch does not change Windows Terminal's font. The Neovim config assumes icons
are available; set `vim.g.have_nerd_font = false` if you prefer no Nerd Font.

In Windows Terminal, remove/reassign bindings that capture Ctrl+Space, Ctrl+T,
Ctrl+H/J/K/L, or Alt+Shift+H/J/K/L if they conflict. tmux also accepts **F12**
as an alternate prefix. Windows Terminal's Ctrl+Shift+C/V can remain Windows
copy/paste. For mouse text selection while tmux owns the mouse, hold Shift.
Do not force `TERM=screen-256color` in Fish: tmux sets its own terminal type.

Windows interoperability must be enabled. From Arch:

```bash
command -v powershell.exe
command -v wslpath
```

If `powershell.exe` is missing, check `/etc/wsl.conf`. Merge these settings
with your existing file (do not overwrite your user or other WSL settings):

```ini
[interop]
enabled=true
appendWindowsPath=true
```

Then save work, run `wsl --shutdown` from PowerShell, and reopen Arch.
The clipboard helper preserves UTF-8 and does not require WSLg or wl-clipboard.

## 2. Core Arch packages

The following commands are Bash commands. Run `bash` first if necessary.
Run them as your regular Arch user, using sudo only for Pacman:

```bash
sudo pacman -Syu
sudo pacman -S --needed \
  git base-devel curl wget unzip cmake ninja \
  neovim tree-sitter-cli \
  fish tmux fzf ripgrep fd \
  yazi fastfetch bat eza zoxide starship lazygit w3m \
  nodejs npm yarn go \
  python python-pip python-pipx
```

Use current Arch packages: the rewritten Tree-sitter plugin requires Neovim
**0.12+** and Tree-sitter CLI **0.26.1+**. Install the CLI using Pacman,
not the old npm 0.25 workaround from the desktop setup. Check:

```bash
nvim --version
tree-sitter --version
```

Dependencies by purpose:

| Packages | Used by |
| --- | --- |
| `base-devel`, `git`, `curl`, `unzip` | Lazy/Mason downloads, native Telescope/LuaSnip builds, R.nvim builds |
| `tree-sitter-cli`, `nodejs` | Parser generation/compilation |
| `ripgrep`, `fd`, `fzf`, `bat`, `eza` | Search, session picker, session previews, file picker |
| `nodejs`, `npm`, `yarn` | Language servers, Copilot's Node mode, Markdown preview build |
| `fish`, `starship`, `zoxide` | Interactive shell, prompt, directory history used by sesh |
| `tmux`, `go` | Multiplexer and installation of sesh |
| `python` | Windows opening/clipboard bridge and Neovim provider |
| `lazygit`, `w3m` | Existing Neovim Git UI and text web browser |

No AUR helper is necessary. Install sesh through its upstream Go module:

```bash
mkdir -p ~/.local/bin
GOBIN="$HOME/.local/bin" go install github.com/joshmedeski/sesh/v2@latest
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
sesh --version
```

Fish adds those directories automatically. Repeat the Go command to update
sesh; `pacman -Syu` does not update Go-installed programs.

## 3. Install this branch

Keep the repository in the Linux filesystem, rather than under `/mnt/c`,
for Linux filesystem behavior and faster plugin/build operations:

```bash
mkdir -p ~/src
git clone --branch arch-wsl --single-branch \
  https://github.com/Yoyomanzoor/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles
bash scripts/install.sh
```

The installer links exactly the seven app directories, the supplied helper
programs into `~/.local/bin`, and `~/.tmux.conf` so an existing legacy tmux file
does not shadow the new config. Existing files are moved into a unique directory
under `~/.local/state/dotfiles-backups/`; repeated installation is idempotent.
It does not install packages, change your login shell, edit Windows settings,
or kill an existing tmux server. The links track this checkout: keep it in place.
The installer respects `XDG_CONFIG_HOME`; the tmux reload shortcut uses the
standard `~/.config` layout shown here.

Launch Fish with `fish`. For a persistent login-shell change, optionally run:

```bash
chsh -s /usr/bin/fish
```

Alternatively set the Windows Terminal profile command line to
`wsl.exe -d <distribution-name> --exec /usr/bin/fish -l`.

## 4. Python, Molten, and Jupytext

Install provider dependencies **before** the first Neovim launch:

```bash
sudo pacman -S --needed \
  python-pynvim python-jupyter-client python-ipykernel \
  ipython python-matplotlib python-nbformat python-pillow
pipx install jupytext
pipx ensurepath
/usr/bin/python -m ipykernel install --user --name python3 --display-name 'Python 3'
/usr/bin/python -c 'import pynvim, jupyter_client; print("provider OK")'
jupyter kernelspec list
```

Neovim's provider is explicitly `/usr/bin/python`; activating a research
virtual environment does not replace it. For a separate analysis environment,
install `ipykernel` and your analysis libraries there, then register it:

```bash
/path/to/environment/bin/python -m ipykernel install --user \
  --name research --display-name 'Python (research)'
```

Use `:MoltenInit research` in Neovim. Standard text output works in Windows
Terminal and tmux. This branch removes `image.nvim`/Kitty graphics. Molten
image outputs open using the Windows default image viewer; SVG/other optional
formats may require extra Python libraries. Use `:MoltenImagePopup` explicitly
if needed. IPython's terminal command uses the noninteractive Agg plotting
backend; open saved figures with `wsl-open figure.png`. This avoids assuming
a Linux GUI plotting backend is present.

No global `sudo pip` or `pip --break-system-packages` is needed.

## 5. Optional R and Quarto workflows

R integration is retained and falls back to the standard R console if radian
is absent. To use it:

```bash
sudo pacman -S --needed r visidata
pipx install radian
radian --version
```

Start R once and install the packages needed for R Markdown/Quarto into your
personal R library when prompted:

```r
install.packages(c("knitr", "rmarkdown"), repos = "https://cloud.r-project.org")
```

R.nvim builds its own helper and `nvimcom` package. Allow the initial setup to
finish. The configured external data-frame viewer is `tmux new-window vd`,
so run Neovim inside tmux for that feature. `visidata` supplies `vd`.

For Quarto, install the current Linux x86_64 or ARM64 tarball as appropriate
from https://quarto.org/docs/download/ and put its `bin` directory on PATH.
Follow https://quarto.org/docs/get-started/ for the Linux tarball instructions.
Then:

```bash
quarto --version
quarto check
# Optional for PDF rendering:
quarto install tinytex
```

The Quarto plugin is retained, but the original commented-out Quarto-to-Molten
runner keymaps are not enabled. Molten's explicit evaluation commands remain
available in Quarto files. `quarto preview file.qmd` uses `BROWSER=wsl-open`.

## 6. Zathura and WSLg

Zathura is a **Linux GUI app**, not a terminal PDF reader. To run it on Windows,
WSL 2 must provide WSLg (or you must supply an X server yourself). Windows
Terminal does not provide that display server. WSLg runs individual Linux GUI
windows without installing Hyprland or a Linux desktop.

```bash
sudo pacman -S --needed zathura zathura-pdf-mupdf ttf-dejavu
echo "$WAYLAND_DISPLAY"
echo "$DISPLAY"
zathura /path/to/file.pdf
```

Do not overwrite DISPLAY or WAYLAND_DISPLAY with a manually guessed value.
If both are empty, check the Windows WSLg installation. `wsl-pdf file.pdf`
uses Zathura when installed and a display is advertised; otherwise it opens
the Windows default PDF viewer. If a stale DISPLAY points to a broken server,
fix WSLg or use `wsl-open file.pdf` directly.

The configured Zathura selection clipboard is handled by WSLg. The separate
Neovim/tmux clipboard bridge works even when WSLg is absent.

## 7. Yazi and previews

```bash
sudo pacman -S --needed chafa ffmpegthumbnailer poppler 7zip jq imagemagick
```

These supply image/text fallback rendering, video thumbnails, PDF previews,
archive handling, and JSON/image helpers. They are optional for navigating
files. Current Windows Terminal supports some image protocols, but WSL/ConPTY,
tmux, and Neovim's embedded terminal have different limitations. This branch
does not require inline images; Chafa is the portable fallback. Do not set
`TERM=xterm-kitty` to try to enable graphics.

`y` in Fish launches Yazi and changes the shell's directory when it exits.
Text files open in Neovim, PDFs through `wsl-pdf`, and other files through
`wsl-open`. For a multi-selection, the external Windows/PDF opener opens the
first selected item; the Neovim editor receives all selected files.
File preview generation stays inside WSL. Fastfetch uses a built-in text logo
and WSL-relevant modules rather than Hyprland/display hardware assumptions.

## 8. First Neovim launch

```bash
nvim
```

Inside Neovim:

```vim
:Lazy restore
:Mason
:UpdateRemotePlugins
```

Wait for installations/builds and restart Neovim after remote registration.
The config uses current Mason/native LSP setup. Mason installs clangd, gopls,
pyright, rust_analyzer, markdown_oxide, htmx, ts_ls, lua_ls, Stylua, and
markdownlint; the debug plugin requests Delve. You do not need duplicate
Pacman installations of these servers. Parser installs are asynchronous;
after they finish, reopen a source file or run `:edit` to activate highlighting.
The Tree-sitter rewrite no longer has the old incremental-selection keymaps.

For Copilot, authenticate explicitly (authentication no longer runs as a
plugin build hook):

```vim
:Copilot auth
:Copilot status
```

Copilot needs an eligible GitHub account. Avante is not enabled.
Your Obsidian integration is enabled only if one of your existing vault roots
is present. Restore `~/Documents/MedSchool` and/or
`~/Documents/Welch-Lab-Notebook`, or edit the workspace paths in
`.config/nvim/lua/custom/plugins/obsidian.lua`. The guard uses these two roots;
update it too if you use different paths. Image pasting from a Windows
clipboard into an Obsidian attachment is not configured; use Yazi/file import
or add a dedicated image clipboard bridge. Text clipboard integration works.

The committed `lazy-lock.json` records the plugin revisions downloaded during
Neovim 0.12.6 bootstrap and startup checks. Use `:Lazy restore` to keep those
versions; `:Lazy update` deliberately advances them. The Windows clipboard,
WSLg GUI behavior, and optional language runtimes still need verification on
your Windows host. LuaRocks is disabled; the unused Oxocarbon theme that invoked
a separate build toolchain was removed.

## 9. tmux / sesh usage and validation

```bash
bash ~/src/dotfiles/scripts/check.sh
fastfetch
tmux new-session -A -s work
```

| Keys / command | Action |
| --- | --- |
| Ctrl+Space, or F12 | tmux prefix |
| Prefix then Enter | New window in current directory |
| Prefix then `v` / `s` | Side-by-side / stacked panes |
| Ctrl+H/J/K/L | Move between Neovim splits and tmux panes |
| Alt+Shift+H/J/K/L | Resize panes |
| Prefix then `t`, or Ctrl+T | sesh picker |
| Prefix then `L` | Previous sesh session |
| Prefix then Ctrl+V, `v`, movement, `y` | Select/copy to Windows clipboard |
| Prefix then `r` | Reload tmux config |
| `ss` in Fish | sesh picker, including outside tmux |
| `open file.pdf` in Fish | Windows default app |
| `wsl-pdf file.pdf` | Zathura when WSLg is available, otherwise Windows |
| `Space s f` / `Space s g` in Neovim | File/content search |
| `Space f f` in Neovim | Yazi |
| `Space g g` in Neovim | LazyGit |
| `Space t p` in Neovim | IPython |
| `:MoltenInit python3` | Start default notebook kernel |
| `:MarkdownPreview` in Markdown | Preview in Windows browser |

The installer does not replace an already running tmux server's options.
Reload the config in your existing session, or use a separate server to try
it without disturbing other sessions:

```bash
tmux -L arch-wsl -f ~/.config/tmux/tmux.conf new-session -s work
```

In Neovim run `:checkhealth`, `:checkhealth provider`,
`:checkhealth vim.lsp`, `:ConformInfo`, and `:messages`.
For a manual end-to-end clipboard test, copy `αβ 🧬` in Neovim and paste it
into Notepad, then copy multiline text in Notepad and use `"+p` in Neovim.
The helpers invoke Windows PowerShell per clipboard operation; this can have
startup latency. Windows interop and GUI/clipboard behavior require testing
on the target Windows host.

Sources: [WSLg](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps),
[Neovim clipboard](https://neovim.io/doc/user/provider/),
[Tree-sitter](https://github.com/nvim-treesitter/nvim-treesitter),
[sesh](https://github.com/joshmedeski/sesh),
[Yazi image limitations](https://yazi-rs.github.io/docs/image-preview/).

## Repository validation

`python3 scripts/test_wsl.py` checks configuration parsing, installer backup
and idempotence, Unicode byte handling through mocked Windows programs, and
path/URL argument isolation. Lua 5.1 compilation, Fish parsing, and ShellCheck
passed. A headless Neovim 0.12.6 startup passed after dependency downloads;
parser compilation and Python/Markdown plugin builds require the documented
target packages. The validation host cannot run a tmux server or Windows
programs, so pane interaction and real Windows/WSLg integration were not tested.
