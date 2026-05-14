local function assert_contains(value, needle)
  assert(
    value:find(needle, 1, true) ~= nil,
    ("expected statusline to contain %q:\n%s"):format(needle, value)
  )
end

local function assert_not_contains(value, needle)
  assert(
    value:find(needle, 1, true) == nil,
    ("expected statusline not to contain %q:\n%s"):format(needle, value)
  )
end

require("lazy").load({ plugins = { "lualine.nvim", "hydra.nvim" } })

local hydra_state = require("config.hydra_state")
local lualine = require("lualine")

hydra_state.clear_active()
local normal_statusline = lualine.statusline(true)
assert_not_contains(normal_statusline, "lualine_a_replace")
assert_not_contains(normal_statusline, "lualine_b_replace")

hydra_state.set_active("Git")
local git_statusline = lualine.statusline(true)
assert_contains(git_statusline, "lualine_a_replace")
assert_contains(git_statusline, "lualine_b_replace")
assert_contains(git_statusline, "lualine_transitional_lualine_a_replace_to_lualine_b_replace")

hydra_state.clear_active()
local restored_statusline = lualine.statusline(true)
assert_not_contains(restored_statusline, "lualine_a_replace")
assert_not_contains(restored_statusline, "lualine_b_replace")

print("lualine Git hydra highlight check passed")
