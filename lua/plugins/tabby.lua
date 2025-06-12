return {
  "nanozuki/tabby.nvim",
  lazy = true,
  opts = {
    preset = "tab_only",
    lualine_theme = "auto",
    line = function(line)
      local color = require("dracula.palette")
      local theme = {
        fill = "TabLineFill",
        -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
        head = "TabLine",
        current_tab = "TabLineSel",
        tab = "TabLine",
        win = { fg = "#000000", bg = color.bg },
        tail = "TabLine",
      }

      return {
        {
          { "  ", hl = theme.head },
          " ",
        },
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and theme.current_tab or theme.tab
          local sym = tab.is_current() and "" or "󰆣"

          return {
            line.sep("", hl, theme.fill),
            sym,
            tab.number(),
            tab.name(),
            line.sep("", hl, theme.fill),
            hl = hl,
            margin = " ",
          }
        end),
      }
    end,
  },
  keys = {
    { "<leader>ta", ":$tabnew<CR>", desc = "Add tab", noremap = true },
    { "<leader>tc", ":tabclose<CR>", desc = "Close tab", noremap = true },
    { "<leader>to", ":tabonly<CR>", desc = "Close all other tabs", noremap = true },
    {
      "<leader>tr",
      function()
        local newname = vim.fn.input("Rename tab to: ")
        vim.cmd("TabRename " .. newname)
      end,
      desc = "Close all other tabs",
      noremap = true,
    },
    { "<leader>tn", ":tabn<CR>", desc = "Goto next tab", noremap = true },
    { "<leader>tp", ":tabp<CR>", desc = "Goto previous tab", noremap = true },
    { "<leader>tmp", ":-tabmove<CR>", desc = "Move tab backward", noremap = true },
    { "<leader>tmn", ":+tabmove<CR>", desc = "Move tab forward", noremap = true },
  },
}
