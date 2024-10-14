-- Highlight for trailing white space
vim.api.nvim_create_autocmd({"ColorScheme"}, {
	  pattern = {"*"},
	  command = "highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen",
    })
vim.cmd[[match ExtraWhitespace /\s\+$/]]
vim.cmd[[syntax on]]
-- Line numbers
vim.opt.number = true

-- Tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 0
vim.opt.expandtab = true

vim.opt.colorcolumn = "80"
vim.cmd[[highlight ColorColumn guibg=#222222]]
vim.cmd[[imap jj <Esc>]]

-- Leader key
vim.keymap.set('n', '<Space>', '', {})
vim.g.mapleader = " "

-- Fzf-lua shorthand commands, as an alternative to leader keymaps
vim.api.nvim_create_user_command(
  "B",
  function() require('fzf-lua').buffers() end,
  { desc = "Fzf buffers" })

vim.api.nvim_create_user_command(
  "F",
  function() require('fzf-lua').files() end,
  { desc = "Fzf files" })
