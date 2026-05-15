local command = function(cmd, args)
  return function()
    vim.api.nvim_cmd({ cmd = cmd, args = args or {} }, {})
  end
end

return {
  "nanozuki/tabby.nvim",
  lazy = false,
  dependencies = {
    "Mofiqul/dracula.nvim",
  },
  opts = {
    preset = "tab_only",
    lualine_theme = "auto",
    line = function(line)
      local theme = {
        fill = "TabLineFill",
        head = "TabLineFill",
        current_tab = "TabLineSel",
        tab = "TabLine",
      }

      local tab_is_modified = function(tab)
        for _, win in ipairs(tab.wins().wins) do
          if win.buf().is_changed() then
            return true
          end
        end

        return false
      end

      return {
        {
          { " tabs ", hl = theme.head },
        },
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and theme.current_tab or theme.tab
          local icon = tab.is_current() and "" or "󰆣"
          local modified = tab_is_modified(tab) and " ●" or ""

          return {
            line.sep("", hl, theme.fill),
            icon,
            tab.in_jump_mode() and tab.jump_key() or tab.number(),
            tab.name(),
            modified,
            line.sep("", hl, theme.fill),
            hl = hl,
            margin = " ",
          }
        end),
        hl = theme.fill,
      }
    end,
  },
  keys = {
    {
      "<leader>ta",
      function()
        vim.cmd("$tabnew")
      end,
      desc = "Add tab",
      noremap = true,
    },
    { "<leader>tc", command("tabclose"), desc = "Close tab", noremap = true },
    { "<leader>to", command("tabonly"), desc = "Close all other tabs", noremap = true },
    {
      "<leader>tr",
      function()
        local newname = vim.fn.input("Rename tab to: ")
        if newname == "" then
          return
        end
        vim.api.nvim_cmd({ cmd = "TabRename", args = { newname } }, {})
      end,
      desc = "Rename tab",
      noremap = true,
    },
    { "<leader>tj", command("Tabby", { "jump_to_tab" }), desc = "Jump to tab", noremap = true },
    { "<leader>tn", command("tabnext"), desc = "Goto next tab", noremap = true },
    { "<leader>tp", command("tabprevious"), desc = "Goto previous tab", noremap = true },
    { "<leader>tmp", command("tabmove", { "-" }), desc = "Move tab backward", noremap = true },
    { "<leader>tmn", command("tabmove", { "+" }), desc = "Move tab forward", noremap = true },
  },
}
