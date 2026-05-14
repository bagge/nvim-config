# Neovim configuration

Personal Neovim configuration targeting Neovim `0.12.x`.

The config is managed by `lazy.nvim`, commits `lazy-lock.json` for plugin
reproducibility, and uses Mason for external language servers, formatters,
linters, and the `tree-sitter` CLI.

## Requirements

- Neovim `0.12.x`
- Git, required by the lazy.nvim bootstrap and plugin installs
- `curl`, `tar`, and a C compiler for Treesitter parser installation
- `rg`, used by `grepprg` and `fzf-lua`

The first Neovim start bootstraps `lazy.nvim` automatically. External tools are
installed by Mason after the plugins are restored.

## Restore And Update

After cloning or updating this config, restore the pinned plugin set:

```sh
nvim --headless "+Lazy! restore" +qa
```

Or run this interactively from Neovim:

```vim
:Lazy restore
```

Install external tools declared in [mason.lua](lua/plugins/mason.lua):

```vim
:MasonToolsInstall
```

The Mason tool list includes LSP servers, formatters, linters, and
`tree-sitter-cli`. Neovim prepends Mason's `bin` directory to `PATH`, so tools
installed by Mason are visible to LSP, formatting, and Treesitter parser
installation.

Only refresh pinned plugin versions intentionally:

```vim
:Lazy update
```

Review `lazy-lock.json` diffs together with the config changes that required the
plugin update.

## Maintenance Checks

Run the local check suite before and after config changes:

```sh
make check
```

The default suite checks Lua syntax, verifies headless startup, and runs focused
Neovim health checks for lazy.nvim, LSP, and Treesitter.

Formatting is checked separately because there is still older style debt in
files not touched by every change:

```sh
make check-format
```

## Preferences

| Setting | Value |
| ------- | ----- |
| Leader | Space |
| Insert escape | `jj` |
| Colorscheme | Dracula |
| Sign column | Always visible |
| Color column | 80 |
| Indentation default | 4 spaces |
| Grep backend | `rg --vimgrep` |

Language-specific overrides live in `after/ftplugin/`.

## Plugins

### Core And Tooling

| Plugin | Purpose |
| ------ | ------- |
| `lazy.nvim` | Plugin manager and lockfile restore/update workflow |
| `mason.nvim` | External tool installer |
| `mason-tool-installer.nvim` | Declarative Mason tool installation |
| `lazydev.nvim` | Lua development support for Neovim config files |

### LSP, Completion, Formatting

| Plugin | Purpose |
| ------ | ------- |
| `blink.cmp` | Completion engine |
| `blink-copilot` | Copilot source for completion |
| `blink-emoji.nvim` | Emoji completion source |
| `copilot.vim` | GitHub Copilot integration |
| `LuaSnip` | Snippet engine |
| `friendly-snippets` | Snippet collection |
| `conform.nvim` | Formatting |

### Languages

| Plugin | Purpose |
| ------ | ------- |
| `nvim-treesitter` | Parser management and Treesitter queries |
| `treesitter-parser-registry` | Parser registry used by current Treesitter setup |

Configured language focus: Lua, Go, Python, Bash, YAML/Ansible, and
Bazel/Starlark.

### Git

| Plugin | Purpose |
| ------ | ------- |
| `vim-fugitive` | Git commands |
| `gitsigns.nvim` | Git signs, blame, hunk actions |
| `hydra.nvim` | Temporary Git hunk action mode |

### Navigation And Search

| Plugin | Purpose |
| ------ | ------- |
| `fzf-lua` | File, buffer, and grep pickers |
| `nvim-bqf` | Better quickfix window |
| `neo-tree.nvim` | File tree and Git status tree |
| `smart-splits.nvim` | Window movement and resizing shared with Kitty |
| `kitty-scrollback.nvim` | Kitty scrollback integration |

### UI And Editing

| Plugin | Purpose |
| ------ | ------- |
| `lualine.nvim` | Statusline |
| `tabby.nvim` | Tabline |
| `indent-blankline.nvim` | Indentation guides |
| `nvim-autopairs` | Automatic pair insertion |
| `nvim-web-devicons` | Icons used by UI plugins |

### Themes

| Plugin | Purpose |
| ------ | ------- |
| `dracula.nvim` | Active colorscheme |
| `bamboo.nvim` | Optional colorscheme |
| `gruvbox.nvim` | Optional colorscheme |
| `nightfox.nvim` | Optional colorscheme |
| `tokyonight.nvim` | Optional colorscheme |

### Dependencies

Some plugins are installed as dependencies rather than configured directly:
`plenary.nvim`, `nui.nvim`, `window-picker`, and `fzf`.

## Keybindings

`<leader>` is Space.

### General

| Keybinding | Mode | Description |
| ---------- | ---- | ----------- |
| `jj` | Insert | Exit insert mode |
| `:B` | Command | Open buffer picker |
| `:F` | Command | Open file picker |

### Search

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>b` | Fuzzy search buffers |
| `<leader>f` | Fuzzy search files |
| `<leader>ll` | Live grep |
| `<leader>lg` | Live grep with glob |
| `<leader>lr` | Resume live grep |

### Windows

| Keybinding | Description |
| ---------- | ----------- |
| `<C-h>` | Move cursor to window left |
| `<C-j>` | Move cursor to window below |
| `<C-k>` | Move cursor to window above |
| `<C-l>` | Move cursor to window right |
| `<A-h>` | Resize window left |
| `<A-j>` | Resize window down |
| `<A-k>` | Resize window up |
| `<A-l>` | Resize window right |
| `<leader><leader>h` | Swap buffer left |
| `<leader><leader>j` | Swap buffer down |
| `<leader><leader>k` | Swap buffer up |
| `<leader><leader>l` | Swap buffer right |

### Tabs

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>ta` | Add tab |
| `<leader>tc` | Close tab |
| `<leader>to` | Close all other tabs |
| `<leader>tr` | Rename tab |
| `<leader>tn` | Go to next tab |
| `<leader>tp` | Go to previous tab |
| `<leader>tmp` | Move tab backward |
| `<leader>tmn` | Move tab forward |

### File Tree

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>tt` | Toggle Neo-tree |
| `<leader>tf` | Reveal current file in Neo-tree |
| `<leader>ts` | Show Neo-tree Git status |

### Git

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>gb` | Toggle current line blame |
| `<leader>h` | Enter Git hunk Hydra |

Inside the Git hunk Hydra:

| Keybinding | Description |
| ---------- | ----------- |
| `n` | Next hunk |
| `p` | Previous hunk |
| `s` | Stage hunk |
| `u` | Undo last staged hunk |
| `R` | Reset hunk |
| `P` | Preview hunk |
| `q`, `;`, `<Esc>` | Exit Hydra |

### Diagnostics And Formatting

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>d` | Send diagnostics to the location list |
| `<leader>D` | Send diagnostics to the quickfix list |
| `<leader>F` | Format current buffer |

## Layout

Top-level config entrypoint:

| File | Purpose |
| ---- | ------- |
| `init.lua` | Loads config modules, plugins, colorscheme, and LSP setup |
| `lua/config/options.lua` | Editor options |
| `lua/config/keymaps.lua` | Core keymaps |
| `lua/config/autocmds.lua` | Core autocmds and highlights |
| `lua/config/commands.lua` | User commands |
| `lua/config/lazy.lua` | lazy.nvim bootstrap and setup |
| `lua/config/lsp.lua` | LSP enablement and diagnostic behavior |
| `lua/plugins/*.lua` | Plugin specs |
| `lsp/*.lua` | Per-server LSP configs |
| `after/ftplugin/*.lua` | Filetype-local settings |
