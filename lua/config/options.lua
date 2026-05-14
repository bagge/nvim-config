-- Disable startup message.
vim.opt.shortmess:append({ s = true, I = true })

-- Line numbers.
vim.opt.number = true

-- Indentation.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 0
vim.opt.expandtab = true

vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "yes"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.cmd.syntax("on")
