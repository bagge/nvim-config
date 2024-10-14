return {
  "ibhagwan/fzf-lua",
  lazy = True, -- Have it loaded to have the commands available
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>b", ":FzfLua buffers<cr>", desc = "Fuzzy search buffers", noremap = true },
    { "<leader>f", ":FzfLua files<cr>", desc = "Fuzzy search files", noremap = true },
  },
  cmd = {
    "FzfLua",
  },
}
