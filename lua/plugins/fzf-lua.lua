return {
  "ibhagwan/fzf-lua",
  lazy = true, -- Have it loaded to have the commands available
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>b", ":FzfLua buffers<cr>", desc = "Fuzzy search buffers", noremap = true },
    { "<leader>f", ":FzfLua files<cr>", desc = "Fuzzy search files", noremap = true },
    { "<leader>ll", ":FzfLua live_grep<cr>", desc = "Live grep", noremap = true },
    { "<leader>lg", ":FzfLua grep<cr>", desc = "Grep", noremap = true },
    { "<leader>lr", ":FzfLua resume<cr>", desc = "Resume", noremap = true },
    { "<leader>lo", ":FzfLua oldfiles<cr>", desc = "Search old files", noremap = true },
    { "<leader>lw", ":FzfLua grep_cword<cr>", desc = "Search word under cursor", noremap = true },
    { "<leader>lb", ":FzfLua blines<cr>", desc = "Search current buffer", noremap = true },
    {
      "<leader>lW",
      ":FzfLua grep_cWORD<cr>",
      desc = "Search whitespace delimited word under cursor",
      noremap = true,
    },
  },
  cmd = {
    "FzfLua",
  },
}
