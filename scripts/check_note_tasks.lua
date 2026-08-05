local parser = require("config.note_tasks.parser")
local query = require("config.note_tasks.query")
local render = require("config.note_tasks.render")
local note_tasks = require("config.note_tasks")
local dashboard = require("config.note_tasks.dashboard")

local parsed =
  assert(parser.parse_line("- [ ] Write report ⏫ ➕ 2026-07-28 ⏳ 2026-07-30 📅 2026-08-01", {
    path = "/tmp/notes/daily/2026-07-28.md",
    relative_path = "daily/2026-07-28.md",
    line = 12,
  }))
assert(parsed.description == "Write report")
assert(parsed.created == "2026-07-28")
assert(parsed.scheduled == "2026-07-30")
assert(parsed.due == "2026-08-01")
assert(parsed.priority == 2)
assert(not parsed.done)

local undated = assert(parser.parse_line("- [ ] Undated task", {
  path = "/tmp/notes/daily/2026-07-20.md",
  relative_path = "daily/2026-07-20.md",
  line = 4,
}))
assert(undated.created == nil)

local completed = assert(parser.toggle_done("- [ ] Write report ➕ 2026-07-28", "2026-07-30"))
assert(completed == "- [x] Write report ➕ 2026-07-28 ✅ 2026-07-30")
local reopened = assert(parser.toggle_done(completed, "2026-07-31"))
assert(reopened == "- [ ] Write report ➕ 2026-07-28")

local scheduled = assert(parser.set_date("- [ ] Write report", "scheduled", "2026-07-31"))
assert(scheduled == "- [ ] Write report ⏳ 2026-07-31")

local task_buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(task_buffer)
vim.bo[task_buffer].filetype = "markdown"
note_tasks.new_task()
vim.cmd("stopinsert")
assert(vim.api.nvim_get_current_line() == "- [ ]  ➕ " .. os.date("%Y-%m-%d"))
assert(vim.api.nvim_win_get_cursor(0)[2] == #"- [ ] ")

vim.api.nvim_buf_set_lines(task_buffer, 0, -1, false, { "  Context" })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
note_tasks.new_task()
vim.cmd("stopinsert")
local task_buffer_lines = vim.api.nvim_buf_get_lines(task_buffer, 0, -1, false)
assert(task_buffer_lines[1] == "  Context")
assert(task_buffer_lines[2] == "  - [ ]  ➕ " .. os.date("%Y-%m-%d"))
assert(vim.api.nvim_win_get_cursor(0)[1] == 2)
assert(vim.api.nvim_win_get_cursor(0)[2] == #"  - [ ] ")
vim.api.nvim_buf_delete(task_buffer, { force = true })

local tasks = {
  {
    relative_path = "daily/2026-07-28.md",
    folder = "daily",
    line = 1,
    done = false,
    description = "Scheduled",
    created = "2026-07-28",
    scheduled = "2026-07-30",
    priority = 4,
  },
  {
    relative_path = "projects/report.md",
    folder = "projects",
    line = 2,
    done = false,
    description = "Due tomorrow",
    created = "2026-07-29",
    due = "2026-07-31",
    priority = 2,
  },
  {
    relative_path = "projects/report.md",
    folder = "projects",
    line = 3,
    done = true,
    description = "Completed today",
    created = "2026-07-20",
    done_date = "2026-07-30",
    priority = 4,
  },
  {
    relative_path = "projects/older.md",
    folder = "projects",
    line = 1,
    done = true,
    description = "Completed yesterday",
    created = "2026-07-20",
    done_date = "2026-07-29",
    priority = 4,
  },
}

local agenda = query.evaluate(tasks, {
  "not done",
  "(scheduled before tomorrow) OR (due before tomorrow)",
  "sort by priority",
}, { today = "2026-07-30" })
assert(agenda.total == 1)
assert(agenda.tasks[1].description == "Scheduled")

local historical = query.evaluate(tasks, {
  "created on or before 2026-07-30",
  "(not done) OR (done on or after 2026-07-30)",
}, { today = "2026-07-30" })
assert(historical.total == 3)

local recent = query.evaluate(tasks, {
  "done",
  "sort by done reverse",
  "limit to 1 task",
})
assert(recent.total == 2)
assert(#recent.tasks == 1)
assert(recent.tasks[1].description == "Completed today")

local blocks = render._find_blocks({
  "# Daily",
  "",
  "```tasks",
  "not done",
  "group by folder",
  "```",
})
assert(#blocks == 1)
assert(blocks[1].opening == 3)
assert(blocks[1].closing == 6)
assert(blocks[1].instructions[1] == "not done")
local eof_anchor, eof_above = render._result_anchor(blocks[1], 6)
assert(eof_anchor == 4)
assert(not eof_above)
local followed_anchor, followed_above = render._result_anchor(blocks[1], 7)
assert(followed_anchor == 6)
assert(followed_above)

local store = require("config.note_tasks.store")
local original_tasks = store.tasks
store.tasks = function()
  return tasks
end

local bufnr = vim.api.nvim_create_buf(false, true)
vim.bo[bufnr].filetype = "markdown"
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
  "# Tasks",
  "",
  "```tasks",
  "not done",
  "group by folder",
  "```",
  "",
})
render.render(bufnr)
local marks = vim.api.nvim_buf_get_extmarks(bufnr, -1, 0, -1, {
  details = true,
  type = "virt_lines",
})
assert(#marks == 1)
assert(#marks[1][4].virt_lines > 1)
assert(marks[1][2] == 6)
assert(marks[1][4].virt_lines_above)
vim.api.nvim_buf_delete(bufnr, { force = true })
store.tasks = original_tasks

local source_path = vim.fn.tempname() .. ".md"
vim.fn.writefile({ "# Test", "- [ ] Window picker task" }, source_path)
local dashboard_task = {
  path = source_path,
  relative_path = "daily/2026-08-04.md",
  folder = "daily",
  line = 2,
  raw = "- [ ] Window picker task",
  done = false,
  description = "Window picker task",
  created = "2026-08-04",
  priority = 4,
}
local recent_dashboard_tasks = {}
for index = 1, 11 do
  recent_dashboard_tasks[index] = {
    path = source_path,
    relative_path = ("daily/2026-07-%02d.md"):format(index),
    folder = "daily",
    line = 2,
    raw = "- [x] Completed task",
    done = true,
    description = ("Completed %02d"):format(index),
    created = ("2026-07-%02d"):format(index),
    done_date = ("2026-07-%02d"):format(index),
    priority = 4,
  }
end
store.tasks = function()
  return vim.list_extend({ dashboard_task }, recent_dashboard_tasks)
end

local target_win = vim.api.nvim_get_current_win()
vim.cmd("topleft vsplit")
local tree_win = vim.api.nvim_get_current_win()
local tree_buffer = vim.api.nvim_create_buf(false, true)
vim.bo[tree_buffer].filetype = "neo-tree"
vim.api.nvim_win_set_buf(tree_win, tree_buffer)
vim.api.nvim_set_current_win(target_win)
vim.cmd("belowright split")
local bottom_editor_win = vim.api.nvim_get_current_win()
vim.api.nvim_set_current_win(tree_win)
local tree_height = vim.api.nvim_win_get_height(tree_win)
local window_count = #vim.api.nvim_tabpage_list_wins(0)
dashboard.open()
local dashboard_win = vim.api.nvim_get_current_win()
assert(dashboard_win ~= target_win)
assert(vim.bo.filetype == "notetasks")
assert(#vim.api.nvim_tabpage_list_wins(0) == window_count + 1)
assert(vim.api.nvim_win_get_height(tree_win) == tree_height)
assert(
  vim.api.nvim_win_get_position(dashboard_win)[1]
    > vim.api.nvim_win_get_position(bottom_editor_win)[1]
)

vim.api.nvim_set_current_win(target_win)
dashboard.open()
assert(vim.api.nvim_get_current_win() == dashboard_win)
assert(#vim.api.nvim_tabpage_list_wins(0) == window_count + 1)

local dashboard_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
assert(not dashboard_text:find("Completed 11", 1, true))
local completed_mapping = vim.fn.maparg("c", "n", false, true)
assert(type(completed_mapping.callback) == "function")
completed_mapping.callback()
dashboard_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
assert(dashboard_text:find("Recently completed (10 of 11)", 1, true))
assert(dashboard_text:find("Completed 11", 1, true) < dashboard_text:find("Completed 10", 1, true))
assert(not dashboard_text:find("Completed 01", 1, true))
completed_mapping.callback()
dashboard_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
assert(not dashboard_text:find("Completed 11", 1, true))

local task_row
for row, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
  if line:find("Window picker task", 1, true) then
    task_row = row
    break
  end
end
assert(task_row)
vim.api.nvim_win_set_cursor(0, { task_row, 0 })

local original_picker = package.loaded["window-picker"]
package.loaded["window-picker"] = {
  pick_window = function()
    return target_win
  end,
}
local enter_mapping = vim.fn.maparg("<CR>", "n", false, true)
assert(type(enter_mapping.callback) == "function")
enter_mapping.callback()
assert(vim.api.nvim_get_current_win() == target_win)
assert(vim.api.nvim_buf_get_name(0) == source_path)
assert(vim.api.nvim_win_get_cursor(0)[1] == 2)
assert(vim.api.nvim_win_is_valid(dashboard_win))

dashboard.open()
assert(vim.api.nvim_get_current_win() == dashboard_win)
assert(#vim.api.nvim_tabpage_list_wins(0) == window_count + 1)
vim.api.nvim_win_close(dashboard_win, true)
vim.api.nvim_win_close(tree_win, true)
vim.api.nvim_win_close(bottom_editor_win, true)
package.loaded["window-picker"] = original_picker
store.tasks = original_tasks
vim.fn.delete(source_path)

print("note task checks passed")
