return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = auto,
      component_separators = "",
      section_separators = { left = "", right = "" },
      ignore_focus = { "neo-tree" },
      disabled_filetypes = { "neo-tree" },
    },
    sections = {
      lualine_a = { { "mode", separator = { left = "" , right = "" }, right_padding = 2 } },
      lualine_b = { "filename", "branch", "diff", "diagnostics" },
      lualine_c = {
        "%=", --[[ add your center compoentnts here in place of this comment ]]
      },
      lualine_x = { "encoding", "fileformat" },
      lualine_y = { "filetype", "progress" },
      lualine_z = {
        { "location", separator = { right = "" }, left_padding = 2 },
      },
    },
    inactive_sections = {
      lualine_a = { "filename" },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { "location" },
    },
  },
}
