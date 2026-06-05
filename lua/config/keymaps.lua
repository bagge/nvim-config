-- Leader key.
vim.keymap.set("n", "<Space>", "", {})
vim.g.mapleader = " "

vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

vim.keymap.set({ "n", "x" }, "<leader>vw", function()
  require("config.vale_vocab").add_word()
end, { desc = "Add word to Vale vocabulary" })
