return {
  "ibhagwan/fzf-lua",
  lazy = true, -- Have it loaded to have the commands available
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>b", ":FzfLua buffers<cr>", desc = "Fuzzy search buffers", noremap = true },
    { "<leader>f", ":FzfLua files<cr>", desc = "Fuzzy search files", noremap = true },
    { "<leader>ll", ":FzfLua live_grep<cr>", desc = "Live grep", noremap = true },
    { "<leader>lg", ":FzfLua live_grep_glob<cr>", desc = "Live grep with glob", noremap = true },
    { "<leader>lr", ":FzfLua live_grep<cr>", desc = "Resume live grep", noremap = true },
  },
  cmd = {
    "FzfLua",
  },
}
