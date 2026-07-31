local parser = require("config.note_tasks.parser")
local query = require("config.note_tasks.query")
local render = require("config.note_tasks.render")

local parsed =
  assert(parser.parse_line("- [ ] Write report ⏫ ➕ 2026-07-28 ⏳ 2026-07-30 📅 2026-08-01", {
    path = "/tmp/notes/daily/2026-07-28.md",
    relative_path = "daily/2026-07-28.md",
    line = 12,
    inferred_created = "2026-07-28",
  }))
assert(parsed.description == "Write report")
assert(parsed.created == "2026-07-28")
assert(parsed.scheduled == "2026-07-30")
assert(parsed.due == "2026-08-01")
assert(parsed.priority == 2)
assert(not parsed.done)

local inferred = assert(parser.parse_line("- [ ] Legacy task", {
  path = "/tmp/notes/daily/2026-07-20.md",
  relative_path = "daily/2026-07-20.md",
  line = 4,
  inferred_created = "2026-07-20",
}))
assert(inferred.created == "2026-07-20")
assert(inferred.created_inferred)

local completed = assert(parser.toggle_done("- [ ] Write report ➕ 2026-07-28", "2026-07-30"))
assert(completed == "- [x] Write report ➕ 2026-07-28 ✅ 2026-07-30")
local reopened = assert(parser.toggle_done(completed, "2026-07-31"))
assert(reopened == "- [ ] Write report ➕ 2026-07-28")

local scheduled = assert(parser.set_date("- [ ] Write report", "scheduled", "2026-07-31"))
assert(scheduled == "- [ ] Write report ⏳ 2026-07-31")

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

print("note task parser and query checks passed")
