local dashboard = require("config.note_tasks.dashboard")
local parser = require("config.note_tasks.parser")
local render = require("config.note_tasks.render")
local store = require("config.note_tasks.store")

local M = {}

local configured = false

function M.open_dashboard()
  dashboard.open()
end

function M.new_task()
  if vim.bo.filetype ~= "markdown" then
    vim.notify("New tasks can only be created in Markdown buffers", vim.log.levels.INFO)
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local current_line = vim.api.nvim_get_current_line()
  local indent = current_line:match("^(%s*)") or ""
  local task_line = indent .. "- [ ]  ➕ " .. os.date("%Y-%m-%d")

  if current_line:match("^%s*$") then
    vim.api.nvim_set_current_line(task_line)
  else
    vim.api.nvim_buf_set_lines(0, row, row, false, { task_line })
    row = row + 1
  end

  vim.api.nvim_win_set_cursor(0, { row, #indent + #"- [ ] " })
  vim.cmd("startinsert")
end

function M.toggle_task_done()
  local line = vim.api.nvim_get_current_line()
  local replacement, err = parser.toggle_done(line)
  if not replacement then
    vim.notify(err, vim.log.levels.INFO)
    return
  end

  vim.api.nvim_set_current_line(replacement)
  store.invalidate()
  render.render_loaded()
end

function M.refresh()
  store.invalidate()
  render.render_loaded()
end

function M.setup()
  if configured then
    return
  end
  configured = true

  vim.api.nvim_create_user_command("NoteTasks", dashboard.open, {
    desc = "Open the notes task dashboard",
  })
  vim.api.nvim_create_user_command("NoteTaskNew", M.new_task, {
    desc = "Insert a new task with today's created date",
  })
  vim.api.nvim_create_user_command("NoteTasksRefresh", M.refresh, {
    desc = "Refresh the notes task index and inline results",
  })

  local group = vim.api.nvim_create_augroup("config_note_tasks", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = group,
    pattern = "*.md",
    callback = function(args)
      render.schedule(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    pattern = "*.md",
    callback = function(args)
      local path = vim.api.nvim_buf_get_name(args.buf)
      if store.in_vault(path) then
        store.invalidate()
      end
      render.schedule(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufDelete" }, {
    group = group,
    pattern = "*.md",
    callback = function(args)
      local path = vim.api.nvim_buf_get_name(args.buf)
      if store.in_vault(path) then
        store.invalidate()
        render.render_loaded()
      end
    end,
  })
end

return M
