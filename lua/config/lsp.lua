vim.lsp.enable({
  "ansiblels",
  "bashls",
  "lua_ls",
  "gopls",
  "efm",
  "starpls",
  "yamlls",
  "pyright",
})

-- Set up diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
  },
  virtual_lines = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.setloclist()
end, { desc = "Set diagnostics to location list" })
vim.keymap.set("n", "<leader>D", function()
  vim.diagnostic.setqflist()
end, { desc = "Set diagnostics to quickfix list" })
--vim.keymap.set('n', '<leader>F',
--  function()
--    vim.lsp.buf.format()
--  end,
--  { desc = "Format buffer" }
--)
