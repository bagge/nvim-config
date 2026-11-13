local silent_movement = function(direction)
  return vim.cmd("silent! SmartCursorMove" .. direction)
end

return {
  "smart-splits-nvim/smart-splits.nvim",
  lazy = false,
  dependencies = {
    {
      "smart-splits-nvim/backend-kitty",
      module = "smart-splits-backend-kitty",
      build = "./kitten/install_relative_resize.lua",
    },
  },
  opts = {
    move = {
      at_edge = "stop",
    },
    mux = {
      backend = "smart-splits-backend-kitty",
    },
  },
  keys = {
    {
      "<A-h>",
      ":SmartResizeLeft<cr>",
      desc = "Resize left",
      noremap = true,
    },
    {
      "<A-j>",
      ":SmartResizeDown<cr>",
      desc = "Resize down",
      noremap = true,
    },
    {
      "<A-k>",
      ":SmartResizeUp<cr>",
      desc = "Resize up",
      noremap = true,
    },
    {
      "<A-l>",
      ":SmartResizeRight<cr>",
      desc = "Resize right",
      noremap = true,
    },
    {
      "<C-h>",
      function()
        silent_movement("Left")
      end,
      desc = "Move cursor left",
      noremap = true,
    },
    {
      "<C-j>",
      function()
        silent_movement("Down")
      end,
      desc = "Move cursor down",
      noremap = true,
    },
    {
      "<C-k>",
      function()
        silent_movement("Up")
      end,
      desc = "Move cursor up",
      noremap = true,
    },
    {
      "<C-l>",
      function()
        silent_movement("Right")
      end,
      desc = "Move cursor right",
      noremap = true,
    },
    {
      "<leader><leader>h",
      ":SmartSwapLeft<cr>",
      desc = "Swap buffer left",
      noremap = true,
    },
    {
      "<leader><leader>j",
      ":SmartSwapDown<cr>",
      desc = "Swap buffer down",
      noremap = true,
    },
    {
      "<leader><leader>k",
      ":SmartSwapUp<cr>",
      desc = "Swap buffer up",
      noremap = true,
    },
    {
      "<leader><leader>l",
      ":SmartSwapRight<cr>",
      desc = "Swap buffer right",
      noremap = true,
    },
  },
}
