Just whatever my current nvim-config happens to be...

## Reproducing the plugin set

This config uses lazy.nvim and commits `lazy-lock.json` so the plugin set can be
restored later.

- Run `:Lazy restore` after cloning or updating this config to install the
  pinned plugin versions from `lazy-lock.json`.
- Run `:Lazy update` only when intentionally refreshing plugin versions.
- Review `lazy-lock.json` diffs together with config changes; those diffs are
  the record of plugin version changes.

After restoring plugins, run `:MasonToolsInstall` to install the external LSP
servers, formatters, and linters declared in the Mason tool list.

Treesitter parser installation also requires the `tree-sitter` CLI, version
`0.26.1` or newer, plus `tar`, `curl`, and a C compiler in `PATH`.

## Maintenance checks

Run the local check suite before and after config changes:

```sh
make check
```

The default suite checks Lua syntax, verifies headless startup, and runs focused
Neovim health checks. Formatting can be checked separately:

```sh
make check-format
```
