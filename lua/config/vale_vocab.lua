local M = {}

local VOCAB_NAME = "User"

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function strip_quotes(value)
  if #value >= 2 then
    local first = value:sub(1, 1)
    local last = value:sub(-1)
    if (first == '"' and last == '"') or (first == "'" and last == "'") then
      return value:sub(2, -2)
    end
  end
  return value
end

local function is_absolute_path(path)
  return path:match("^/") ~= nil or path:match("^%a:[/\\]") ~= nil or path:match("^\\\\") ~= nil
end

local function existing_file(path)
  if path == nil or path == "" then
    return nil
  end

  local expanded = vim.fn.expand(path)
  local stat = vim.uv.fs_stat(expanded)
  if stat ~= nil and stat.type == "file" then
    return vim.fn.fnamemodify(expanded, ":p")
  end
end

local function env_or(name, fallback)
  local value = vim.env[name]
  if value ~= nil and value ~= "" then
    return value
  end
  return fallback
end

local function global_vale_config()
  local explicit_config = existing_file(vim.env.VALE_CONFIG_PATH)
  if explicit_config ~= nil then
    return explicit_config
  end

  local sysname = vim.uv.os_uname().sysname
  if sysname == "Windows_NT" then
    local local_app_data = env_or("LOCALAPPDATA", vim.fn.expand("~/AppData/Local"))
    return existing_file(vim.fs.joinpath(local_app_data, "vale", ".vale.ini"))
  end

  if sysname == "Darwin" then
    return existing_file(
      vim.fs.joinpath(vim.fn.expand("~/Library/Application Support"), "vale", ".vale.ini")
    )
  end

  local config_home = env_or("XDG_CONFIG_HOME", vim.fn.expand("~/.config"))
  return existing_file(vim.fs.joinpath(config_home, "vale", ".vale.ini"))
end

local function active_vale_config()
  local buffer_name = vim.api.nvim_buf_get_name(0)
  local start_path = buffer_name ~= "" and vim.fs.dirname(buffer_name) or vim.uv.cwd()
  local project_config = vim.fs.find(".vale.ini", {
    path = start_path,
    upward = true,
    type = "file",
  })[1]

  return project_config or global_vale_config()
end

local function read_lines(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if ok then
    return lines
  end
  return nil
end

local function write_lines(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(lines, path)
end

local function styles_path(config_path, lines)
  for _, line in ipairs(lines) do
    local value = line:match("^%s*StylesPath%s*=%s*(.-)%s*$")
    if value ~= nil then
      value = vim.fn.expand(strip_quotes(trim(value)))
      if not is_absolute_path(value) then
        return vim.fs.joinpath(vim.fs.dirname(config_path), value)
      end
      return value
    end
  end
end

local function global_styles_path()
  local config_path = global_vale_config()
  if config_path == nil then
    return vim.fs.joinpath(
      env_or("XDG_DATA_HOME", vim.fn.expand("~/.local/share")),
      "vale",
      "styles"
    )
  end

  local lines = read_lines(config_path)
  if lines == nil then
    return vim.fs.joinpath(vim.fs.dirname(config_path), "styles")
  end

  return styles_path(config_path, lines) or vim.fs.joinpath(vim.fs.dirname(config_path), "styles")
end

local function split_vocab(value)
  local entries = {}
  for entry in value:gmatch("[^,]+") do
    local name = strip_quotes(trim(entry))
    if name ~= "" then
      table.insert(entries, name)
    end
  end
  return entries
end

local function contains(list, value)
  for _, item in ipairs(list) do
    if item == value then
      return true
    end
  end
  return false
end

local function ensure_styles_path(config_path, lines, path)
  if styles_path(config_path, lines) ~= nil then
    return lines
  end

  table.insert(lines, 1, "StylesPath = " .. path)
  write_lines(config_path, lines)
  return lines
end

local function ensure_vocab_enabled(config_path, lines)
  local insert_at

  for index, line in ipairs(lines) do
    if line:match("^%s*%[") then
      insert_at = insert_at or index
      break
    end

    local value = line:match("^%s*Vocab%s*=%s*(.-)%s*$")
    if value ~= nil then
      local vocabularies = split_vocab(value)
      if contains(vocabularies, VOCAB_NAME) then
        return lines
      end

      table.insert(vocabularies, VOCAB_NAME)
      lines[index] = "Vocab = " .. table.concat(vocabularies, ", ")
      write_lines(config_path, lines)
      return lines
    end

    if line:match("^%s*StylesPath%s*=") then
      insert_at = index + 1
    end
  end

  table.insert(lines, insert_at or (#lines + 1), "Vocab = " .. VOCAB_NAME)
  write_lines(config_path, lines)
  return lines
end

local function current_text()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local ok, region = pcall(vim.fn.getregion, vim.fn.getpos("."), vim.fn.getpos("v"), {
      type = mode,
    })
    if ok and #region > 0 then
      return trim(table.concat(region, " "):gsub("%s+", " "))
    end
  end

  return vim.fn.expand("<cword>")
end

local function append_unique(path, value)
  local lines = read_lines(path) or {}
  table.insert(lines, value)
  table.sort(lines, function(left, right)
    return left:lower() < right:lower()
  end)

  local seen = {}
  local unique = {}
  for _, line in ipairs(lines) do
    if line == "" or line:match("^%s*#") then
      table.insert(unique, line)
    else
      if not seen[line] then
        seen[line] = true
        table.insert(unique, line)
      end
    end
  end

  write_lines(path, unique)
end

local function restart_vale_ls()
  for _, client in ipairs(vim.lsp.get_clients({ name = "vale_ls" })) do
    client:stop()
  end
end

function M.add_word()
  local default = current_text()
  if default == "" then
    vim.notify("No word selected for Vale vocabulary", vim.log.levels.WARN)
    return
  end

  vim.ui.input({ prompt = "Add to Vale vocabulary: ", default = default }, function(input)
    local entry = input ~= nil and trim(input) or ""
    if entry == "" then
      return
    end

    local config_path = active_vale_config()
    if config_path == nil then
      vim.notify("No Vale configuration found", vim.log.levels.ERROR)
      return
    end

    local config_lines = read_lines(config_path)
    if config_lines == nil then
      vim.notify("Could not read Vale configuration: " .. config_path, vim.log.levels.ERROR)
      return
    end

    local target_styles_path = styles_path(config_path, config_lines) or global_styles_path()
    config_lines = ensure_styles_path(config_path, config_lines, target_styles_path)

    local vocab_path =
      vim.fs.joinpath(target_styles_path, "config", "vocabularies", VOCAB_NAME, "accept.txt")

    ensure_vocab_enabled(config_path, config_lines)
    append_unique(vocab_path, entry)
    restart_vale_ls()

    vim.notify("Added '" .. entry .. "' to Vale vocabulary: " .. vocab_path)
  end)
end

return M
