local parser = require("config.note_tasks.parser")

local M = {}

local vault_path = vim.fs.normalize(vim.fn.expand("~/notes"))
local cached_tasks

local function is_ignored_directory(path)
  return path == ".git"
    or path:match("^%.git/")
    or path == ".obsidian"
    or path:match("^%.obsidian/")
    or path == "templates"
    or path:match("^templates/")
end

local function markdown_files()
  local files = {}
  if vim.fn.isdirectory(vault_path) == 0 then
    return files
  end

  for name, kind in
    vim.fs.dir(vault_path, {
      depth = 100,
      skip = function(directory)
        return not is_ignored_directory(directory)
      end,
    })
  do
    if kind == "file" and name:sub(-3) == ".md" and not is_ignored_directory(name) then
      files[#files + 1] = name
    end
  end

  table.sort(files)
  return files
end

local function buffer_for_path(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
    return bufnr
  end
end

local function read_lines(path)
  local bufnr = buffer_for_path(path)
  if bufnr then
    return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end

  local ok, lines = pcall(vim.fn.readfile, path)
  return ok and lines or {}
end

local function scan()
  local tasks = {}
  for _, relative_path in ipairs(markdown_files()) do
    local path = vim.fs.joinpath(vault_path, relative_path)
    for line_number, line in ipairs(read_lines(path)) do
      local task = parser.parse_line(line, {
        path = path,
        relative_path = relative_path,
        line = line_number,
      })
      if task then
        tasks[#tasks + 1] = task
      end
    end
  end
  return tasks
end

function M.vault_path()
  return vault_path
end

function M.in_vault(path)
  if not path or path == "" then
    return false
  end
  path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
  return path == vault_path or vim.startswith(path, vault_path .. "/")
end

function M.invalidate()
  cached_tasks = nil
end

function M.tasks()
  if not cached_tasks then
    cached_tasks = scan()
  end
  return cached_tasks
end

local function find_source_line(lines, task)
  local expected = task.line
  if expected and lines[expected] == task.raw then
    return expected
  end

  local best
  local best_distance
  for line_number, line in ipairs(lines) do
    if line == task.raw then
      local distance = math.abs(line_number - (expected or line_number))
      if not best_distance or distance < best_distance then
        best = line_number
        best_distance = distance
      end
    end
  end
  return best
end

---@param task table
---@param transform fun(line: string): string?, string?
---@return boolean, string?
function M.update(task, transform)
  if not task.path then
    return false, "Task has no source path"
  end

  local bufnr = buffer_for_path(task.path)
  if not bufnr then
    bufnr = vim.fn.bufadd(task.path)
    vim.fn.bufload(bufnr)
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local line_number = find_source_line(lines, task)
  if not line_number then
    M.invalidate()
    return false, "Task source changed; refresh the dashboard and try again"
  end

  local replacement, err = transform(lines[line_number])
  if not replacement then
    return false, err
  end

  local was_modified = vim.bo[bufnr].modified
  vim.api.nvim_buf_set_lines(bufnr, line_number - 1, line_number, false, { replacement })

  if not was_modified then
    local ok, write_err = pcall(vim.api.nvim_buf_call, bufnr, function()
      vim.cmd("silent write")
    end)
    if not ok then
      return false, "Task changed in its buffer but could not be written: " .. tostring(write_err)
    end
  end

  M.invalidate()
  return true,
    was_modified and "Updated an already-modified source buffer without writing it" or nil
end

return M
