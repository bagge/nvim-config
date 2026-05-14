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
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

-- Global to store the name of the active hydra. Used to not have to require
-- hydra in lualine.lua.
vim.g.active_hydra = nil

vim.cmd.syntax("on")
