require("config.lazy")

vim.cmd[[colorscheme dracula]]

vim.lsp.enable('ansiblels')
vim.lsp.enable('bashls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('gopls')
vim.lsp.enable('efm')
vim.lsp.enable('bzl')

-- Set up diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
  },
  virtual_lines = {
    current_line = true,
--    severity = { min = vim.diagnostic.severity.WARN },
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})


