local hint =  [[
 _n_: next hunk   _s_: stage hunk        _R_: Reset hunk
 _p_: prev hunk   _u_: undo last stage   _P_: preview hunk
 ^ ^              _q_: exit
]]

local patched_highlight_func = nil

patch_highlight_func = function()
  if patched_highlight_func == nil then
    patched_highlight_func = require("lualine.highlight").get_mode_suffix
    require("lualine.highlight").get_mode_suffix = function()
      return "_replace"
    end
  end
end

restore_highlight_func = function()
  if patched_highlight_func ~= nil then
    require("lualine.highlight").get_mode_suffix = patched_highlight_func
    patched_highlight_func = nil
  end
end

create_hydras = function()
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
         vim.bo.modifiable = false
         vim.g.active_hydra = "Git"
         patch_highlight_func()
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
         restore_highlight_func()
         local gitsigns = require('gitsigns')
         --gitsigns.toggle_signs(false)
         gitsigns.toggle_linehl(false)
         gitsigns.toggle_deleted(false)
      end,
    },
    heads = {
      { "n", ":Gitsigns next_hunk<cr>", { desc = "Next hunk" } },
      { "p", ":Gitsigns prev_hunk<cr>", { desc = "Previous hunk" } },
      { "R", ":Gitsigns reset_hunk<cr>", { desc = "Reset hunk" } },
      { "s", ":Gitsigns stage_hunk<cr>", { desc = "Stage hunk" } },
      { "u", ":Gitsigns undo_stage_hunk<cr>", { desc = "Undo stage hunk" } },
      { "P", ":Gitsigns preview_hunk<cr>", { desc = "Preview hunk" } },
      { "q", nil, { exit = true, nowait = true } },
      { ";", nil, { exit = true, nowait = true, desc = false } },
      { "<Esc>", nil, { exit = true, nowait = true, desc = false } },
    },
  })
end

return {
    "nvimtools/hydra.nvim",
    config = function()
      require("hydra").setup({})
      create_hydras()
    end
}
