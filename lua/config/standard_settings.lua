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

options = { noremap = true }

vim.keymap.set('n', '<leader>tt', ':NvimTreeToggle<cr>', options)
vim.keymap.set('n', '<leader>tf', ':NvimTreeFindFile<cr>', options)
vim.keymap.set('n', '<leader>b', ':FzfLua buffers<cr>', options)
vim.keymap.set('n', '<leader>f', ':FzfLua files<cr>', options)
