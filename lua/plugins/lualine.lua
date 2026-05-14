local format_mode = function()
  local hydra_name = require("config.hydra_state").get_active()
  local mode = require("lualine.utils.mode")

  if hydra_name == nil then
    return mode.get_mode()
  end

  return "⬤ " .. hydra_name .. " (" .. mode.get_mode():sub(1, 1) .. ")"
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "auto",
      component_separators = "",
      section_separators = { left = "", right = "" },
      ignore_focus = { "neo-tree" },
      disabled_filetypes = { "neo-tree" },
    },
    sections = {
      lualine_a = {
        {
          "mode",
          fmt = format_mode,
          separator = { left = "", right = "" },
          right_padding = 2,
        },
      },
      lualine_b = { { "filename", path = 1 }, "branch", "diff", "diagnostics" },
      lualine_c = {
        "%=",
      },
      lualine_x = { "encoding", "fileformat" },
      lualine_y = { "filetype", "progress" },
      lualine_z = {
        { "location", separator = { right = "" }, left_padding = 2 },
      },
    },
    inactive_sections = {
      lualine_a = { { "filename", path = 1 } },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { "location" },
    },
  },
}
