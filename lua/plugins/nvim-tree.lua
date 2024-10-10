return {
  "nvim-tree/nvim-tree.lua",
  enabled = false,
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>tt", ":NvimTreeToggle<cr>", desc = "Toggle Nvim-tree", noremap = true },
    { "<leader>tf", ":NvimTreeFindFile<cr>", desc = "Find file in Nvim-tree", noremap = true },
  },
  opts = {},
}
