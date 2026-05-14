local hint = [[
 _n_: next hunk   _s_: stage hunk        _R_: Reset hunk
 _p_: prev hunk   _u_: undo last stage   _P_: preview hunk
 ^ ^              _q_: exit
]]

local saved_view = nil

local function reset_hunk()
  local gitsigns = require("gitsigns")
  gitsigns.reset_hunk()
end

local function open_all_folds()
  saved_view = vim.fn.winsaveview()
  vim.cmd("silent! %foldopen!")
end

local function restore_view()
  if saved_view == nil then
    return
  end

  vim.fn.winrestview(saved_view)
  saved_view = nil
  vim.cmd("normal! zv")
end

local function create_hydras()
  local Hydra = require("hydra")
  local hydra_state = require("config.hydra_state")

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
        open_all_folds()
        hydra_state.set_active("Git")
        local gitsigns = require("gitsigns")
        gitsigns.toggle_linehl(true)
        gitsigns.toggle_deleted(true)
      end,
      on_exit = function()
        restore_view()
        hydra_state.clear_active()
        local gitsigns = require("gitsigns")
        gitsigns.toggle_linehl(false)
        gitsigns.toggle_deleted(false)
      end,
    },
    heads = {
      { "n", ":Gitsigns next_hunk<cr>", { desc = "Next hunk" } },
      { "p", ":Gitsigns prev_hunk<cr>", { desc = "Previous hunk" } },
      { "R", reset_hunk, { desc = "Reset hunk" } },
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
  lazy = true,
  dependencies = {
    "lewis6991/gitsigns.nvim",
  },
  config = function()
    require("hydra").setup({})
    create_hydras()
  end,
  -- Use the same keys as the body of the hydra
  keys = {
    {
      "<leader>h",
      function()
        require("hydra").enter("Git hunks")
      end,
      desc = "Git hunks",
    },
  },
}
