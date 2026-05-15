return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  priority = 1000,
  opts = {
    preset = "modern",
  },
  keys = {
    {
      "<leader>dt",
      function()
        require("tiny-inline-diagnostic").toggle()
      end,
      desc = "Toggle inline diagnostics",
    },
  },
}
