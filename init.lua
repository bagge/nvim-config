require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.note_tasks").setup()
require("config.lazy")

-- Enabling syntax detects the command-line buffer's filetype. Do this only
-- after lazy.nvim has registered its FileType handlers so filetype plugins
-- also load when Neovim is started with a file argument.
vim.cmd.syntax("on")

require("config.commands")

vim.cmd.colorscheme("dracula")

require("config.lsp")
