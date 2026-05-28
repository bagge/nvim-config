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

local cargo_vale_ls = vim.fn.expand("~/.cargo/bin/vale-ls")
local cmd = supports_mason_vale_ls() and { "vale-ls" } or { cargo_vale_ls }

return {
  cmd = cmd,
  filetypes = { "asciidoc", "markdown", "text", "tex", "rst", "html", "xml" },
  root_markers = { ".vale.ini" },
  init_options = {
    installVale = false,
  },
}
