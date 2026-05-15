return {
  "lewis6991/gitsigns.nvim",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = true,
  },
  keys = {
    {
      "<leader>gb",
      ":Gitsigns toggle_current_line_blame<CR>",
      desc = "Toggle current line blame",
      noremap = true,
    },
  },
}
