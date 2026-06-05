return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local autopairs = require("nvim-autopairs")

    autopairs.setup()

    autopairs.remove_rule("`")
    autopairs.remove_rule("```")
    autopairs.remove_rule("```.*$")
  end,
}
