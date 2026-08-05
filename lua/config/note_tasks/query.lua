local M = {}

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function resolve_date(value, today)
  if value == "today" then
    return today
  elseif value == "tomorrow" then
    return os.date(
      "%Y-%m-%d",
      os.time({
        year = tonumber(today:sub(1, 4)),
        month = tonumber(today:sub(6, 7)),
        day = tonumber(today:sub(9, 10)) + 1,
      })
    )
  end
  return value:match("^%d%d%d%d%-%d%d%-%d%d$")
end

local function date_predicate(field, operator, value, today)
  local date = resolve_date(value, today)
  if not date then
    return nil
  end

  return function(task)
    local task_date = task[field]
    if not task_date then
      return false
    elseif operator == "before" then
      return task_date < date
    elseif operator == "on or before" then
      return task_date <= date
    elseif operator == "after" then
      return task_date > date
    elseif operator == "on or after" then
      return task_date >= date
    elseif operator == "on" then
      return task_date == date
    end
    return false
  end
end

local function atomic_predicate(instruction, today)
  if instruction == "not done" then
    return function(task)
      return not task.done
    end
  elseif instruction == "done" then
    return function(task)
      return task.done
    end
  end

  local excluded_path = instruction:match("^path does not include%s+(.+)$")
  if excluded_path then
    return function(task)
      return not task.relative_path:lower():find(excluded_path:lower(), 1, true)
    end
  end

  local included_path = instruction:match("^path includes%s+(.+)$")
  if included_path then
    return function(task)
      return task.relative_path:lower():find(included_path:lower(), 1, true) ~= nil
    end
  end

  local field, remainder = instruction:match("^(%a+)%s+(.+)$")
  local operator, value
  if remainder then
    for _, candidate in ipairs({ "on or before", "on or after", "before", "after", "on" }) do
      local candidate_value = remainder:match("^" .. candidate .. "%s+(.+)$")
      if candidate_value then
        operator = candidate
        value = candidate_value
        break
      end
    end
  end
  if field and operator and vim.tbl_contains({ "created", "scheduled", "due", "done" }, field) then
    if field == "done" then
      field = "done_date"
    end
    return date_predicate(field, operator, value, today)
  end
end

local function predicate_for(instruction, today)
  local left, right = instruction:match("^%((.-)%)%s+OR%s+%((.-)%)$")
  if left and right then
    local left_predicate = atomic_predicate(trim(left), today)
    local right_predicate = atomic_predicate(trim(right), today)
    if left_predicate and right_predicate then
      return function(task)
        return left_predicate(task) or right_predicate(task)
      end
    end
  end
  return atomic_predicate(instruction, today)
end

local function compare_values(left, right, descending)
  if left == right then
    return nil
  elseif left == nil then
    return false
  elseif right == nil then
    return true
  elseif descending then
    return left > right
  end
  return left < right
end

local sort_fields = {
  priority = "priority",
  due = "due",
  scheduled = "scheduled",
  created = "created",
  done = "done_date",
  description = "description",
  path = "relative_path",
}

---@param tasks table[]
---@param instructions string[]
---@param context? { today: string? }
---@return table
function M.evaluate(tasks, instructions, context)
  context = context or {}
  local today = context.today or os.date("%Y-%m-%d")
  local predicates = {}
  local sorts = {}
  local warnings = {}
  local group_by
  local limit

  for _, original in ipairs(instructions) do
    local instruction = trim(original)
    if instruction ~= "" and instruction:sub(1, 1) ~= "#" then
      local sort_name = instruction:match("^sort by%s+(.+)$")
      local sort_descending = false
      if sort_name and sort_name:match("%s+reverse$") then
        sort_name = sort_name:match("^(.-)%s+reverse$")
        sort_descending = true
      end
      local group_name = instruction:match("^group by%s+([%w ]+)$")
      local requested_limit = instruction:match("^limit to%s+(%d+)%s+tasks?$")
      if sort_name and sort_fields[sort_name] then
        sorts[#sorts + 1] = {
          field = sort_fields[sort_name],
          descending = sort_descending,
        }
      elseif group_name == "folder" or group_name == "path" then
        group_by = group_name
      elseif requested_limit then
        limit = tonumber(requested_limit)
      else
        local predicate = predicate_for(instruction, today)
        if predicate then
          predicates[#predicates + 1] = predicate
        else
          warnings[#warnings + 1] = "Unsupported query instruction: " .. instruction
        end
      end
    end
  end

  local matched = {}
  for _, task in ipairs(tasks) do
    local include = true
    for _, predicate in ipairs(predicates) do
      if not predicate(task) then
        include = false
        break
      end
    end
    if include then
      matched[#matched + 1] = task
    end
  end

  table.sort(matched, function(left, right)
    for _, sort in ipairs(sorts) do
      local comparison = compare_values(left[sort.field], right[sort.field], sort.descending)
      if comparison ~= nil then
        return comparison
      end
    end
    if left.relative_path == right.relative_path then
      return left.line < right.line
    end
    return left.relative_path < right.relative_path
  end)

  local total = #matched
  if limit and #matched > limit then
    local limited = {}
    for index = 1, limit do
      limited[index] = matched[index]
    end
    matched = limited
  end

  return {
    tasks = matched,
    total = total,
    group_by = group_by,
    warnings = warnings,
  }
end

function M.groups(result)
  if not result.group_by then
    return { { name = nil, tasks = result.tasks } }
  end

  local groups = {}
  local order = {}
  for _, task in ipairs(result.tasks) do
    local name = result.group_by == "folder" and task.folder or task.relative_path
    if name == "" then
      name = "(vault root)"
    end
    if not groups[name] then
      groups[name] = {}
      order[#order + 1] = name
    end
    groups[name][#groups[name] + 1] = task
  end

  table.sort(order)
  local output = {}
  for _, name in ipairs(order) do
    output[#output + 1] = { name = name, tasks = groups[name] }
  end
  return output
end

return M
