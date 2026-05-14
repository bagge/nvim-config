local files = vim.fn.globpath(vim.fn.getcwd(), "**/*.lua", false, true)
table.sort(files)

local failed = false

for _, file in ipairs(files) do
  local ok, err = loadfile(file)
  if not ok then
    failed = true
    print(("%s: %s"):format(file, err))
  end
end

if failed then
  vim.cmd.cquit()
end

print(("lua syntax ok (%d files)"):format(#files))
