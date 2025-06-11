vim.lsp.enable('ansiblels')
vim.lsp.enable('bashls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('gopls')
vim.lsp.enable('efm')
vim.lsp.enable('starpls')
vim.lsp.enable('yamlls')
vim.lsp.enable('pyright')

-- Set up diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
  },
  virtual_lines = {
    current_line = true,
    -- severity = { min = vim.diagnostic.severity.WARN },
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.keymap.set('n', '<leader>d',
  function()
    vim.diagnostic.setloclist()
  end,
  { desc = "Set diagnostics to location list" }
)
vim.keymap.set('n', '<leader>D',
  function()
    vim.diagnostic.setqflist()
  end,
  { desc = "Set diagnostics to location list" }
)
--vim.keymap.set('n', '<leader>F',
--  function()
--    vim.lsp.buf.format()
--  end,
--  { desc = "Format buffer" }
--)
