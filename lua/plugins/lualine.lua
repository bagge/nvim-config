local format_mode = function()
  local hydra_name = require("config.hydra_state").get_active()
  local mode = require("lualine.utils.mode")

  if hydra_name == nil then
    return mode.get_mode()
  end

  return "⬤ " .. hydra_name .. " (" .. mode.get_mode():sub(1, 1) .. ")"
end

local use_git_hydra_replace_mode_highlight = function()
  local highlight = require("lualine.highlight")

  if highlight.git_hydra_original_get_mode_suffix ~= nil then
    return
  end

  highlight.git_hydra_original_get_mode_suffix = highlight.get_mode_suffix
  highlight.get_mode_suffix = function()
    if require("config.hydra_state").get_active() == "Git" then
      return "_replace"
    end

    return highlight.git_hydra_original_get_mode_suffix()
  end
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function(_, opts)
    use_git_hydra_replace_mode_highlight()
    require("lualine").setup(opts)
  end,
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
