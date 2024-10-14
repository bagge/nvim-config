format_mode = function ()
  local mode = require("lualine.utils.mode")
  if vim.g.active_hydra ~= nil then
    return "⬤ " .. vim.g.active_hydra .. " (" .. mode.get_mode():sub(1, 1) .. ")"
  else
    return mode.get_mode()
  end
end

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
      lualine_a = { { "mode", fmt = format_mode, separator = { left = "" , right = "" }, right_padding = 2 } },
      lualine_b = { {"filename", path = 1 }, "branch", "diff", "diagnostics" },
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
      lualine_a = { {"filename", path = 1 } },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { "location" },
    },
  },
}
