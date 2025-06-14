local hint = [[
 _n_: next hunk   _s_: stage hunk        _R_: Reset hunk
 _p_: prev hunk   _u_: undo last stage   _P_: preview hunk
 ^ ^              _q_: exit
]]

local patched_highlight_func = nil

Patch_highlight_func = function()
  if patched_highlight_func == nil then
    patched_highlight_func = require("lualine.highlight").get_mode_suffix
    require("lualine.highlight").get_mode_suffix = function()
      return "_replace"
    end
  end
end

Restore_highlight_func = function()
  if patched_highlight_func ~= nil then
    require("lualine.highlight").get_mode_suffix = patched_highlight_func
    patched_highlight_func = nil
  end
end

Reset_hunk = function()
  -- vim.bo.modifiable = true
  local gitsigns = require('gitsigns')
  gitsigns.reset_hunk()
  -- vim.bo.modifiable = false
end

Create_hydras = function()
  local Hydra = require("hydra")

  Hydra({
    name = "Git hunks",
    mode = { "n" },
    body = "<leader>h",
    hint = hint,
    config = {
      invoke_on_body = true,
      color = "pink",
      hint = {
        type = "window",
        float_opts = {
          border = "rounded",
        },
        position = "bottom",
      },
      on_enter = function()
        vim.cmd 'mkview'
        vim.cmd 'silent! %foldopen!'
        -- vim.bo.modifiable = false
        vim.g.active_hydra = "Git"
        Patch_highlight_func()
        local gitsigns = require('gitsigns')
        -- gitsigns.toggle_signs(true)
        gitsigns.toggle_linehl(true)
        gitsigns.toggle_deleted(true)
      end,
      on_exit = function()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd 'loadview'
        vim.api.nvim_win_set_cursor(0, cursor_pos)
        vim.cmd 'normal zv'
        vim.g.active_hydra = nil
        Restore_highlight_func()
        local gitsigns = require('gitsigns')
        --gitsigns.toggle_signs(false)
        gitsigns.toggle_linehl(false)
        gitsigns.toggle_deleted(false)
      end,
    },
    heads = {
      { "n",     ":Gitsigns next_hunk<cr>",       { desc = "Next hunk" } },
      { "p",     ":Gitsigns prev_hunk<cr>",       { desc = "Previous hunk" } },
      { "R",     Reset_hunk,                      { desc = "Reset hunk" } },
      { "s",     ":Gitsigns stage_hunk<cr>",      { desc = "Stage hunk" } },
      { "u",     ":Gitsigns undo_stage_hunk<cr>", { desc = "Undo stage hunk" } },
      { "P",     ":Gitsigns preview_hunk<cr>",    { desc = "Preview hunk" } },
      { "q",     nil,                             { exit = true, nowait = true } },
      { ";",     nil,                             { exit = true, nowait = true, desc = false } },
      { "<Esc>", nil,                             { exit = true, nowait = true, desc = false } },
    },
  })
end

return {
  "nvimtools/hydra.nvim",
  lazy = true,
  dependencies = {
    "lewis6991/gitsigns.nvim",
  },
  config = function()
    require("hydra").setup({})
    Create_hydras()
  end,
  -- Use the same keys as the body of the hydra
  keys = {
    { "<leader>h", ":lua require('hydra').enter('Git hunks')<cr>", desc = "Git hunks" },
  },
}
