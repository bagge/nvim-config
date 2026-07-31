local parser = require("config.note_tasks.parser")
local query = require("config.note_tasks.query")
local store = require("config.note_tasks.store")

local M = {}

local dashboard_name = "note-tasks://dashboard"
local row_tasks = {}

local function current_task()
  return row_tasks[vim.api.nvim_win_get_cursor(0)[1]]
end

local function task_line(task)
  local checkbox = task.done and "☒" or "☐"
  local dates = {}
  if task.scheduled then
    dates[#dates + 1] = "⏳ " .. task.scheduled
  end
  if task.due then
    dates[#dates + 1] = "📅 " .. task.due
  end
  if task.done_date then
    dates[#dates + 1] = "✅ " .. task.done_date
  end
  local suffix = #dates > 0 and "  " .. table.concat(dates, "  ") or ""
  return ("  %s %s%s  %s:%d"):format(
    checkbox,
    task.description ~= "" and task.description or "(empty task)",
    suffix,
    task.relative_path,
    task.line
  )
end

local function dashboard_buffer()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(bufnr) == dashboard_name then
      return bufnr
    end
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(bufnr, dashboard_name)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "notetasks"
  return bufnr
end

local function set_lines(bufnr, lines)
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
end

function M.refresh()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(bufnr) ~= dashboard_name then
    return
  end

  local result = query.evaluate(store.tasks(), {
    "not done",
    "sort by priority",
    "sort by due",
    "sort by scheduled",
    "sort by created",
  })

  local lines = {
    "Note Tasks",
    "",
    ("%d open tasks · <CR> jump · x complete/reopen · s schedule · d due · r refresh · q close"):format(
      result.total
    ),
    "",
  }
  row_tasks = {}

  local grouped = {}
  for _, task in ipairs(result.tasks) do
    local name = task.folder ~= "" and task.folder or "(vault root)"
    grouped[name] = grouped[name] or {}
    grouped[name][#grouped[name] + 1] = task
  end
  local folders = vim.tbl_keys(grouped)
  table.sort(folders)

  for _, folder in ipairs(folders) do
    lines[#lines + 1] = folder
    for _, task in ipairs(grouped[folder]) do
      lines[#lines + 1] = task_line(task)
      row_tasks[#lines] = task
    end
    lines[#lines + 1] = ""
  end

  if result.total == 0 then
    lines[#lines + 1] = "No open tasks."
  end

  set_lines(bufnr, lines)
end

local function update_current(transform)
  local task = current_task()
  if not task then
    vim.notify("Cursor is not on a task", vim.log.levels.INFO)
    return
  end

  local ok, message = store.update(task, transform)
  if not ok then
    vim.notify(message, vim.log.levels.ERROR)
    return
  end
  if message then
    vim.notify(message, vim.log.levels.INFO)
  end
  M.refresh()
end

local function jump_to_current()
  local task = current_task()
  if not task then
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(task.path))
  vim.api.nvim_win_set_cursor(0, { task.line, 0 })
  vim.cmd("normal! zz")
end

local function prompt_for_date(field)
  local task = current_task()
  if not task then
    vim.notify("Cursor is not on a task", vim.log.levels.INFO)
    return
  end

  local value = vim.fn.input(
    (field == "scheduled" and "Scheduled date: " or "Due date: "),
    task[field] or os.date("%Y-%m-%d")
  )
  if value == "" then
    return
  elseif not value:match("^%d%d%d%d%-%d%d%-%d%d$") then
    vim.notify("Use a date in YYYY-MM-DD format", vim.log.levels.ERROR)
    return
  end

  update_current(function(line)
    return parser.set_date(line, field, value)
  end)
end

local function set_keymaps(bufnr)
  local options = { buffer = bufnr, silent = true }
  vim.keymap.set(
    "n",
    "<CR>",
    jump_to_current,
    vim.tbl_extend("force", options, { desc = "Jump to task" })
  )
  vim.keymap.set("n", "x", function()
    update_current(function(line)
      return parser.toggle_done(line)
    end)
  end, vim.tbl_extend("force", options, { desc = "Complete or reopen task" }))
  vim.keymap.set("n", "s", function()
    prompt_for_date("scheduled")
  end, vim.tbl_extend("force", options, { desc = "Schedule task" }))
  vim.keymap.set("n", "d", function()
    prompt_for_date("due")
  end, vim.tbl_extend("force", options, { desc = "Set task due date" }))
  vim.keymap.set("n", "r", function()
    store.invalidate()
    M.refresh()
  end, vim.tbl_extend("force", options, { desc = "Refresh tasks" }))
  vim.keymap.set(
    "n",
    "q",
    "<cmd>close<cr>",
    vim.tbl_extend("force", options, { desc = "Close tasks" })
  )
end

function M.open()
  local bufnr = dashboard_buffer()
  if vim.api.nvim_get_current_buf() ~= bufnr then
    vim.cmd("botright new")
    vim.api.nvim_win_set_buf(0, bufnr)
  end
  set_keymaps(bufnr)
  M.refresh()
end

return M
