local M = {}

local active_name = nil

local function refresh_lualine()
  local lualine = package.loaded["lualine"]
  if lualine == nil then
    return
  end

  pcall(lualine.refresh, { place = { "statusline" } })
end

function M.set_active(name)
  active_name = name
  refresh_lualine()
end

function M.clear_active()
  active_name = nil
  refresh_lualine()
end

function M.get_active()
  return active_name
end

return M
