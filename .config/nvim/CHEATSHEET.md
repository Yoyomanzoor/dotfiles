# Neovim Cheat Sheet — Your Config

> **Leader = `Space`**, **LocalLeader = `Space`** (both).
> `relativenumber` is on, so motions like `5j`, `12G`, `d3k` are your bread and butter.
> Press **`<Space>`** and wait — **which-key** pops up showing every leader mapping. **`<leader>sk`** searches all keymaps.

This is a [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) base with heavy customization. Plugin manager is **lazy.nvim**.

---

## 0. The 10 Highest-Yield Keystrokes

| Key | Action | Why it matters |
|-----|--------|----------------|
| `<Space>` then wait | which-key menu | Discover/learn every mapping live |
| `<leader>sf` | Find files (Telescope) | Open anything fast |
| `<leader>sg` | Live grep | Search file *contents* across project |
| `<leader><leader>` | Switch buffer | Jump between open files |
| `f` / `F` | Hop to char on line | Replaces clunky `fx;;;` |
| `<leader>jj` | Hop to any word on screen | Teleport the cursor |
| `gd` / `gr` | Go to definition / references | Core code navigation |
| `<leader>ca` | LSP code action | Quick fixes & refactors |
| `gcc` | Toggle comment line | Comment in one keystroke |
| `<leader>tt` | Toggle terminal | REPL / shell without leaving nvim |

---

## 1. Setup — Getting Languages Working

First-run housekeeping commands:

| Command | Purpose |
|---------|---------|
| `:Lazy` | Plugin manager UI (`U` to update, `S` to sync, `?` for help) |
| `:Mason` | Install/manage LSP servers, linters, formatters (`g?` for help) |
| `:checkhealth` | Diagnose missing dependencies (providers, tools) |
| `:UpdateRemotePlugins` | Required after installing Molten (Python notebooks) |

**LSPs auto-installed by Mason** (via `init.lua`): `pyright`, `clangd`, `gopls`, `rust_analyzer`, `markdown_oxide`, `htmx`, `ts_ls`, `lua_ls`. Plus `stylua` (Lua formatter) and `markdownlint` (markdown linter).

**Format on save is ON** for everything except C/C++ (via conform.nvim, LSP fallback).

### Python
- **LSP**: `pyright` — auto-installs, just open a `.py` file. Verify with `:LspInfo`.
- **REPL (quick)**: `<leader>tp` → toggles an **IPython** split. `<leader>tl` sends current line, `<leader>tv` sends visual selection, `<leader>tm` sends the whole file.
- **Notebooks (Molten)**: needs `pip install pynvim jupyter` + a kernel, then `:UpdateRemotePlugins` once.
  - `<leader>mi` → `:MoltenInit` (pick kernel)
  - `<leader>ml` eval line · `<leader>me` eval operator/motion · `<leader>mv` eval visual (visual mode)
  - `<leader>mr` re-eval cell · `<leader>ms` enter output window · `<leader>mq` hide output · `<leader>md` delete cell · `<leader>mx` open output in browser
- **jupytext.nvim**: opens `.ipynb` files transparently as markdown.
- Note: Python uses pyright's LSP formatting on save (black/isort are commented out in `python.lua`).

### R
- **REPL**: R.nvim with **radian** as the R console (install: `pip install -U radian`). For the LSP/completion, install the R `languageserver` package: `install.packages("languageserver")`.
- Open any `.R` / `.Rmd` / `.qmd` and use the **LocalLeader (`Space`)** maps below (buffer-local, active only in R files):

| Key | Action |
|-----|--------|
| `<localleader>rf` | Start R (radian) |
| `<localleader>rq` | Quit R |
| `<localleader>l` | Send current line to R |
| `<localleader>d` | Send line **and** move down |
| `<localleader>pp` | Send paragraph |
| `<localleader>ss` | Send selection (visual mode) |
| `<localleader>aa` | Send/source whole file |
| `<localleader>ro` | Toggle object browser |
| `<localleader>rh` | Help for word under cursor |
| `<localleader>rv` | View data.frame (opens `vd`/visidata in a tmux window) |

> `cmp-r` gives R completions automatically. `csv.vim` improves `.csv` viewing. To see all R maps: `:h R.nvim` mappings section.

### RMarkdown / Quarto
- **Path that's active in your config**: jupytext + Molten. Press **`<C-p>`** anywhere to spawn a floating Quarto IPython notebook (auto-runs `MoltenInit` + `QuartoActivate`).
- Use the Molten `<leader>m*` maps above to execute code chunks.
- ⚠️ `quarto-nvim` (the LSP-in-chunks integration) is **commented out** in `init.lua`. If you want chunk LSP/diagnostics + `<leader>qc` run-cell maps, uncomment `require("custom.plugins.quarto")` and the quarto block in `python.lua`.

### Markdown
- **Live rendering in buffer**: `render-markdown.nvim` runs automatically (`conceallevel=1`).
- **Browser preview**: `:MarkdownPreview` / `:MarkdownPreviewStop` (needs `yarn`; builds on install).
- **Tables**: `:EditMarkdownTable` opens a friendly table editor.
- **Linting**: `markdownlint` runs on save/enter (install via Mason or `npm i -g markdownlint-cli`).
- `markdown.nvim` adds inline editing helpers (lists, links) — see `:h markdown.nvim`.

### LaTeX
- **Symbol completion**: type `\alpha`, `\sum`, etc. and `cmp-latex-symbols` completes the unicode/symbol. Works in insert mode via the completion menu.
- **Citations**: `:Telescope bibtex` inserts citations from your `.bib` files.
- Treesitter highlights `latex` / `bibtex`. (No vimtex compiler is configured — compile externally, e.g. `latexmk`.)

### Bash
- Treesitter `bash` highlighting is on. There's **no `bashls` LSP** in the server list — if you want completion/diagnostics, add `bashls = {}` to the `servers` table (and `shfmt` for formatting) via Mason. Otherwise it works as a well-highlighted plain buffer.

---

## 2. Navigating Code (fastest paths)

### Within a file
| Key | Action |
|-----|--------|
| `f{char}` / `F{char}` | **Hop** forward/back to a char on the current line (homerow labels) |
| `t{char}` / `T{char}` | **Hop** till a char (offset by one) |
| `<leader>jj` | **Hop** to any word on screen |
| `<leader>jl` | **Hop** to any line |
| `<leader>jn` | **Hop** to any treesitter node |
| `<leader>/` | Fuzzy search **within current buffer** |
| `<C-d>` / `<C-u>` | Smooth half-page scroll (neoscroll) |
| `]c` / `[c` | Next / previous git change |
| `<leader>O` | Toggle **Outline** (symbol tree of file) |

> The function/class you're inside is pinned at the top of the window (treesitter-context).

### Across the project
| Key | Action |
|-----|--------|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep (search contents) |
| `<leader>sw` | Grep the word under cursor |
| `<leader>s/` | Live grep but only open files |
| `<leader>sa` | Find files starting from `~` |
| `<leader>sn` | Find files in your nvim config |
| `<leader>s.` | Recent files |
| `<leader><leader>` | Open buffers |
| `<leader>sr` | **Resume** last Telescope search |
| `<leader>sb` | File browser (Telescope) |
| `<leader>ff` / `<leader>-` | Open **Yazi** file manager |

### Code intelligence (LSP)
| Key | Action |
|-----|--------|
| `gd` | Go to definition (`<C-t>` / `<C-o>` to jump back) |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `<leader>D` | Go to type definition |
| `K` | Hover docs |
| `<leader>ds` | Document symbols (this file) |
| `<leader>cs` | Workspace symbols (whole project) |
| `<leader>sd` | Search diagnostics |
| `<leader>q` | Put diagnostics in location list |

### Windows / splits / tmux
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move between splits **and** tmux panes seamlessly |
| `<C-\>` | Jump to last active pane |
| `<leader>v` | Vertical split · `<leader>h` horizontal split |
| `<A-h/j/k/l>` | Resize current window · `<A-r>` equalize |
| `<leader>bh/bl/bj/bk` | Move window left/right/down/up |
| `<leader>bo` | Close all other windows |
| `X` | Close (delete) current buffer |
| `Q` | Save and quit |

---

## 3. Refactoring Code (best methods)

| Key | Action |
|-----|--------|
| `<leader>rn` | **Rename symbol** across the whole project (LSP) |
| `<leader>ca` | **Code action** — extract, import, fix, quickfix (cursor on symbol/error) |
| `<leader>fb` | Format buffer explicitly (also auto on save) |
| `:%s/old/new/g` | Project-style substitute — **previews live in a split** (`inccommand=split`) |
| `gr` | Find all references before renaming manually |
| `<leader>cs` | Workspace symbols to locate things to refactor |
| `<leader>tu` | **Undotree** — visualize/branch your undo history when a refactor goes wrong |

### Treesitter incremental selection (refactor by structure)
Select smarter than `viw`:
| Key | Action |
|-----|--------|
| `<leader><CR>` | Start selection / grow to scope |
| `<leader><Tab>` | Grow selection by one node |
| `<leader><BS>` | Shrink selection by one node |

Then operate on it (`d`, `y`, `c`, surround, comment...).

### Surround (two plugins available)
**mini.surround** (`s`-prefixed):
- `saiw)` — surround inner word with `()`
- `sd'` — delete surrounding `'`
- `sr)'` — replace surrounding `)` with `'`

**nvim-surround** (vim-surround style):
- `ys{motion}{char}` — e.g. `ysiw"` wrap word in quotes
- `cs{old}{new}` — `cs"'` change `"` to `'`
- `ds{char}` — delete surround
- `S{char}` — in visual mode, surround selection

---

## 4. Most Interesting / Useful Commands by Category

### AI
| Key / Cmd | Action |
|-----------|--------|
| `<M-j>` | **Accept Copilot** suggestion (auto-triggers as ghost text) |
| `<M-]>` / `<M-[>` | Next / previous Copilot suggestion |
| `:Copilot auth` | Sign in to Copilot |
| `:AvanteAsk` / `:AvanteToggle` | **Avante** AI chat sidebar (Cursor-like, configured with OpenAI `gpt-4o`) |
| `:AvanteEdit` | AI edit on selection |

> Avante needs `OPENAI_API_KEY` in your environment.

### Commenting
| Key | Action |
|-----|--------|
| `gcc` | Toggle line comment |
| `gbc` | Toggle block comment |
| `gc{motion}` | Comment a motion (e.g. `gcap` a paragraph, `gc3j`) |
| `gc` (visual) | Comment selection |
| `gco` / `gcO` | Add comment line below / above |
| `gcA` | Add comment at end of line |

### Editing & completion
| Key | Action |
|-----|--------|
| `<CR>` | Confirm completion |
| `<Tab>` / `<S-Tab>` | Next / previous completion item |
| `<C-Space>` | Manually trigger completion |
| `<C-b>` / `<C-f>` | Scroll completion docs |
| `<C-l>` / `<C-h>` | Jump forward/back through snippet placeholders |
| `<Tab>` / `<S-Tab>` (insert) | **Tabout** — jump out of `)`, `]`, `}`, quotes |
| `;` | Mapped to `:` — enter command mode without Shift |
| `<Esc>` | Clear search highlight |

### Selecting text
- Treesitter incremental selection (see §3): `<leader><CR>` / `<leader><Tab>` / `<leader><BS>`.
- **mini.ai** smarter text objects:
  - `vaq` / `viq` — around/inside any quote
  - `vab` / `vib` — around/inside any bracket
  - `cinq` — change **inside next** quote
  - `vif` / `vaf` — function call argument region (with treesitter)
  - works with `i`/`a` + `n`/`l` (next/last) for distant objects

### Working through nodes (treesitter)
- `<leader>jn` — Hop to any node.
- `<leader><Tab>` / `<leader><BS>` — expand/shrink by node.
- `<leader>O` — Outline view to jump between functions/classes.

### Formatting
| Key / Cmd | Action |
|-----------|--------|
| `<leader>fb` | Format buffer (async, LSP fallback) |
| (auto) | Format on save for all but C/C++ |
| `:ConformInfo` | See which formatter is used for this filetype |

### Git
| Key | Action |
|-----|--------|
| `<leader>gg` | **Lazygit** floating UI |
| `<leader>gs` | Telescope git status |
| `<leader>gf` | Git files · `<leader>gc` commits · `<leader>gb` branches |
| `]c` / `[c` | Next / previous hunk |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk (works in visual too) |
| `<leader>hp` | Preview hunk · `<leader>hv` preview |
| `<leader>hb` | Blame line · `<leader>tb` toggle inline blame |
| `<leader>hS` / `<leader>hR` | Stage / reset whole buffer |
| `<leader>hd` / `<leader>hD` | Diff vs index / last commit |

### Terminal / REPL
| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle terminal (vertical split) |
| `<leader>tp` | Toggle IPython REPL |
| `<C-p>` | Floating Quarto+Molten notebook |
| `<leader>tl` | Send current line to terminal |
| `<leader>tv` | Send visual selection (visual mode) |
| `<leader>tm` | Send whole file to terminal |
| `<Esc>` (in term) | Exit terminal mode → normal mode |
| `<C-h/j/k/l>` (in term) | Move to another window |

### Debugging (DAP)
| Key | Action |
|-----|--------|
| `<F5>` | Start / continue |
| `<F1>` / `<F2>` / `<F3>` | Step into / over / out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<F7>` | Toggle DAP UI |

### Notes / Obsidian
| Key | Action |
|-----|--------|
| `<leader>on` | Today's daily note |
| `<leader>ow` | Today's note in WelchLab vault |
| `<leader>ot` | Browse tags · `<leader>oc` table of contents |
| `<leader>op` | Paste image into note |
| `<leader>ch` | Toggle checkbox |
| `<CR>` (on link) | Follow link / smart action · `gf` follow link |

### Web (w3m, in-editor browser)
| Key | Action |
|-----|--------|
| `<leader>e` | `:W3m ` search the web · `<leader>E` address bar |
| `<leader>ws` / `<leader>wv` | Search in split / vsplit |
| `<leader>wr` reload · `<leader>wh` history | |
| `<leader>wy` yank URL · `<leader>wm` bookmark · `<leader>w"` open bookmark | |

### Misc quality-of-life
| Key / Cmd | Action |
|-----------|--------|
| `<F11>` | **NoNeckPain** — center the buffer |
| `<leader>sc` | Pick & persist colorscheme |
| `:TimerStart 25m` | Pomodoro timer (nvim-notify pop-up) |
| `<leader>cw` | Yazi in nvim's working dir |
| `yap` then watch | Yanked text flashes (highlight on yank) |

---

## Learning Strategy

1. **Live with which-key**: press `<Space>` and pause. The menu teaches you incrementally.
2. **Master Hop first** (`f`, `<leader>jj`) — it eliminates the most cursor friction.
3. **Then Telescope** (`<leader>sf`, `<leader>sg`) — fastest file/content access.
4. **Then LSP nav** (`gd`, `gr`, `<leader>rn`, `<leader>ca`).
5. `<leader>sk` is your escape hatch — fuzzy-search every keymap when you forget one.
