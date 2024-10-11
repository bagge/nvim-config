return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  build = "./kitty/install-kittens.bash",
  keys = {
    { "<A-h>", ":SmartResizeLeft<cr>", desc = "Resize left", noremap = true },
    { "<A-j>", ":SmartResizeDown<cr>", desc = "Resize left", noremap = true },
    { "<A-k>", ":SmartResizeUp<cr>", desc = "Resize left", noremap = true },
    { "<A-l>", ":SmartResizeRight<cr>", desc = "Resize left", noremap = true },
    { "<C-h>", ":SmartCursorMoveLeft<cr>", desc = "Move cursor left", noremap = true },
    { "<C-j>", ":SmartCursorMoveDown<cr>", desc = "Move cursor left", noremap = true },
    { "<C-k>", ":SmartCursorMoveUp<cr>", desc = "Move cursor left", noremap = true },
    { "<C-l>", ":SmartCursorMoveRight<cr>", desc = "Move cursor left", noremap = true },
    { "<leader><leader>h", ":SmartSwapLeft<cr>", desc = "Swap buffer left", noremap = true },
    { "<leader><leader>j", ":SmartSwapDown<cr>", desc = "Swap buffer left", noremap = true },
    { "<leader><leader>k", ":SmartSwapUp<cr>", desc = "Swap buffer left", noremap = true },
    { "<leader><leader>l", ":SmartSwapRight<cr>", desc = "Swap buffer left", noremap = true },
  },
}
