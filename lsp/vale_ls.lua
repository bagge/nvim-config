local function supports_mason_vale_ls()
  if vim.uv.os_uname().sysname ~= "Linux" then
    return true
  end

  local output = vim.fn.system({ "getconf", "GNU_LIBC_VERSION" })
  if vim.v.shell_error ~= 0 then
    return false
  end

  local major, minor = output:match("glibc%s+(%d+)%.(%d+)")
  major, minor = tonumber(major), tonumber(minor)
  return major ~= nil and minor ~= nil and (major > 2 or (major == 2 and minor >= 39))
end

local cargo_vale_ls = vim.fn.expand("~/.local/bin/vale-ls")
local cmd = supports_mason_vale_ls() and { "vale-ls" } or { cargo_vale_ls }

local function existing_config(path)
  if path == nil or path == "" then
    return nil
  end

  local resolved_path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  local stat = vim.uv.fs_stat(resolved_path)
  if stat ~= nil and stat.type == "file" then
    return resolved_path
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
  local explicit_config = existing_config(vim.env.VALE_CONFIG_PATH)
  if explicit_config ~= nil then
    return explicit_config
  end

  local sysname = vim.uv.os_uname().sysname
  local config_path

  if sysname == "Windows_NT" then
    local local_app_data = env_or("LOCALAPPDATA", vim.fn.expand("~/AppData/Local"))
    config_path = vim.fs.joinpath(local_app_data, "vale", ".vale.ini")
  elseif sysname == "Darwin" then
    config_path =
      vim.fs.joinpath(vim.fn.expand("~/Library/Application Support"), "vale", ".vale.ini")
  else
    local config_home = env_or("XDG_CONFIG_HOME", vim.fn.expand("~/.config"))
    config_path = vim.fs.joinpath(config_home, "vale", ".vale.ini")
  end

  return existing_config(config_path)
end

local function add_global_config_fallback(params, config)
  if config.root_dir ~= nil then
    return
  end

  local config_path = global_vale_config()
  if config_path == nil then
    return
  end

  config.init_options = vim.tbl_extend("force", config.init_options or {}, {
    configPath = config_path,
  })
  params.initializationOptions = config.init_options
end

return {
  cmd = cmd,
  filetypes = { "asciidoc", "markdown", "text", "tex", "rst", "html", "xml" },
  root_markers = { ".vale.ini" },
  before_init = add_global_config_fallback,
  init_options = {
    installVale = false,
  },
}
