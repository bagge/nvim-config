require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.note_tasks").setup()
require("config.lazy")
require("config.commands")

vim.cmd.colorscheme("dracula")

require("config.lsp")
