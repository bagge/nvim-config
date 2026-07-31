local M = {}

local date_fields = {
  created = "➕",
  scheduled = "⏳",
  due = "📅",
  done = "✅",
}

local priorities = {
  ["🔺"] = 1,
  ["⏫"] = 2,
  ["🔼"] = 3,
  ["🔽"] = 5,
  ["⏬"] = 6,
}

local task_patterns = {
  "^(%s*[-*+]%s+)%[([^%]])%](.*)$",
  "^(%s*%d+[.)]%s+)%[([^%]])%](.*)$",
}

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function parse_parts(line)
  for _, pattern in ipairs(task_patterns) do
    local prefix, state, body = line:match(pattern)
    if prefix then
      return prefix, state, body
    end
  end
end

local function find_date(line, emoji)
  return line:match(emoji .. "%s*(%d%d%d%d%-%d%d%-%d%d)")
end

local function remove_metadata(body)
  for _, emoji in pairs(date_fields) do
    body = body:gsub("%s*" .. emoji .. "%s*%d%d%d%d%-%d%d%-%d%d", "")
  end
  for emoji in pairs(priorities) do
    body = body:gsub("%s*" .. emoji, "")
  end
  return trim(body)
end

---@param line string
---@param context? { path: string, relative_path: string, line: integer, inferred_created: string? }
---@return table?
function M.parse_line(line, context)
  local prefix, state, body = parse_parts(line)
  if not prefix then
    return nil
  end

  context = context or {}
  local priority = 4
  for emoji, value in pairs(priorities) do
    if body:find(emoji, 1, true) then
      priority = value
      break
    end
  end

  local relative_path = context.relative_path or context.path or ""
  local folder = vim.fs.dirname(relative_path)
  if folder == "." then
    folder = ""
  end

  local created = find_date(body, date_fields.created) or context.inferred_created
  local done_date = find_date(body, date_fields.done)
  local done = state == "x" or state == "X"

  return {
    id = ("%s:%d"):format(relative_path, context.line or 0),
    path = context.path,
    relative_path = relative_path,
    folder = folder,
    line = context.line,
    raw = line,
    prefix = prefix,
    state = state,
    done = done,
    description = remove_metadata(body),
    created = created,
    created_inferred = created ~= nil and find_date(body, date_fields.created) == nil,
    scheduled = find_date(body, date_fields.scheduled),
    due = find_date(body, date_fields.due),
    done_date = done_date,
    priority = priority,
  }
end

---@param line string
---@param date? string
---@return string?, string?
function M.toggle_done(line, date)
  local prefix, state, body = parse_parts(line)
  if not prefix or (state ~= " " and state ~= "x" and state ~= "X") then
    return nil, "Line is not an open or completed Markdown task"
  end

  body = body:gsub("%s*✅%s+%d%d%d%d%-%d%d%-%d%d%s*$", "")

  if state == " " then
    body = body:gsub("%s+$", "")
    return prefix .. "[x]" .. body .. " ✅ " .. (date or os.date("%Y-%m-%d"))
  end

  return prefix .. "[ ]" .. body
end

---@param line string
---@param field "scheduled"|"due"
---@param date string
---@return string?, string?
function M.set_date(line, field, date)
  local prefix, state, body = parse_parts(line)
  local emoji = date_fields[field]
  if not prefix or not emoji then
    return nil, "Line is not a Markdown task"
  end

  local pattern = emoji .. "%s*%d%d%d%d%-%d%d%-%d%d"
  if body:find(emoji, 1, true) then
    body = body:gsub(pattern, emoji .. " " .. date, 1)
  else
    body = body:gsub("%s+$", "") .. " " .. emoji .. " " .. date
  end

  return prefix .. "[" .. state .. "]" .. body
end

return M
