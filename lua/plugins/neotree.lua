return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  keys = {
    { "<leader>tt", ":Neotree toggle<cr>", desc = "Toggle Neotree", noremap = true },
    { "<leader>tf", ":Neotree reveal<cr>", desc = "Find file in Neotree", noremap = true },
  },
}
