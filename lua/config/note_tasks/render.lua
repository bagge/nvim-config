local query = require("config.note_tasks.query")
local store = require("config.note_tasks.store")

local M = {}

local namespace = vim.api.nvim_create_namespace("config_note_tasks")
local scheduled = {}
local max_virtual_tasks = 30

local function task_chunks(task)
  local checkbox = task.done and "☒ " or "☐ "
  local location = ("  %s:%d"):format(task.relative_path, task.line)
  local dates = ""
  if task.scheduled then
    dates = dates .. "  ⏳ " .. task.scheduled
  end
  if task.due then
    dates = dates .. "  📅 " .. task.due
  end
  return {
    { "  " .. checkbox, task.done and "Comment" or "DiagnosticOk" },
    { task.description ~= "" and task.description or "(empty task)", "Normal" },
    { dates, "Special" },
    { location, "Comment" },
  }
end

local function find_blocks(lines)
  local blocks = {}
  local opening
  for index, line in ipairs(lines) do
    if not opening and line:match("^%s*```tasks%s*$") then
      opening = index
    elseif opening and line:match("^%s*```%s*$") then
      local instructions = {}
      for query_line = opening + 1, index - 1 do
        instructions[#instructions + 1] = lines[query_line]
      end
      blocks[#blocks + 1] = {
        opening = opening,
        closing = index,
        instructions = instructions,
      }
      opening = nil
    end
  end
  return blocks
end

local function virtual_lines(result)
  local output = {
    {
      {
        ("  ── %d task%s ──"):format(result.total, result.total == 1 and "" or "s"),
        "Title",
      },
    },
  }
  local shown = 0

  for _, group in ipairs(query.groups(result)) do
    if group.name then
      output[#output + 1] = { { "  " .. group.name, "Directory" } }
    end
    for _, task in ipairs(group.tasks) do
      if shown == max_virtual_tasks then
        break
      end
      output[#output + 1] = task_chunks(task)
      shown = shown + 1
    end
    if shown == max_virtual_tasks then
      break
    end
  end

  if result.total == 0 then
    output[#output + 1] = { { "  No matching tasks", "Comment" } }
  elseif result.total > shown then
    output[#output + 1] = {
      {
        ("  … %d more; use <leader>nq for the dashboard"):format(result.total - shown),
        "Comment",
      },
    }
  end

  for _, warning in ipairs(result.warnings) do
    output[#output + 1] = { { "  " .. warning, "WarningMsg" } }
  end
  return output
end

local function result_anchor(block, line_count)
  if block.closing < line_count then
    -- Anchor above the first line after the fence. render-markdown conceals
    -- fence delimiters in normal mode, so an extmark on the closing fence
    -- would disappear along with it.
    return block.closing, true
  elseif block.closing - block.opening > 1 then
    -- At end-of-file there is no following line. Use the final instruction,
    -- which is not concealed, and render immediately below it.
    return block.closing - 2, false
  end

  return math.max(block.opening - 2, 0), false
end

function M.render(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  elseif vim.bo[bufnr].filetype ~= "markdown" then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, block in ipairs(find_blocks(lines)) do
    local result = query.evaluate(store.tasks(), block.instructions)
    local anchor_row, virt_lines_above = result_anchor(block, #lines)
    vim.api.nvim_buf_set_extmark(bufnr, namespace, anchor_row, 0, {
      virt_lines = virtual_lines(result),
      virt_lines_above = virt_lines_above,
      virt_lines_overflow = "scroll",
      priority = 120,
    })
  end
end

function M.schedule(bufnr)
  scheduled[bufnr] = (scheduled[bufnr] or 0) + 1
  local generation = scheduled[bufnr]
  vim.defer_fn(function()
    if scheduled[bufnr] ~= generation then
      return
    end
    scheduled[bufnr] = nil
    vim.schedule(function()
      M.render(bufnr)
    end)
  end, 120)
end

function M.render_loaded()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "markdown" then
      M.schedule(bufnr)
    end
  end
end

M._find_blocks = find_blocks
M._result_anchor = result_anchor

return M
