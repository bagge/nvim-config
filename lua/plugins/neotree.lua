return {
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    opts = {
      filter_rules = {
        include_current_win = false,
        autoselect_one = true,
        -- filter using buffer options
        bo = {
          -- if the file type is one of following, the window will be ignored
          filetype = { "neo-tree", "neo-tree-popup", "notify" },
          -- if the buffer type is one of following, the window will be ignored
          buftype = { "terminal", "quickfix" },
        },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "s1n7ax/nvim-window-picker",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    keys = {
      { "<leader>tt", ":Neotree toggle<cr>", desc = "Toggle Neotree", noremap = true },
      { "<leader>tf", ":Neotree reveal<cr>", desc = "Find file in Neotree", noremap = true },
      { "<leader>ts", ":Neotree git_status<cr>", desc = "Git status in Neotree", noremap = true },
    },
    opts = {
      close_if_last_window = true,
      window = {
        width = 35,
        position = "right",
        mappings = {
          ["<cr>"] = "open_with_window_picker",
        },
      },
    },
  },
}
