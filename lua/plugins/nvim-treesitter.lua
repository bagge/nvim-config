local parsers = {
  "vimdoc",
  "luadoc",
  "vim",
  "lua",
  "markdown",
  "markdown_inline",
  "go",
  "gomod",
  "gowork",
  "gosum",
  "gotmpl",
  "yaml",
  "bash",
  "python",
  "starlark",
}

local highlighted_filetypes = {
  "vim",
  "vimdoc",
  "lua",
  "markdown",
  "go",
  "gomod",
  "gowork",
  "gosum",
  "gotmpl",
  "yaml",
  "yaml.ansible",
  "yaml.docker-compose",
  "yaml.gitlab",
  "yaml.helm-values",
  "sh",
  "bash",
  "python",
  "bzl",
  "starlark",
}

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  dependencies = {
    "neovim-treesitter/treesitter-parser-registry",
  },
  config = function()
    require("nvim-treesitter").setup()

    vim.treesitter.language.register("bash", "sh")
    vim.treesitter.language.register("starlark", "bzl")

    if vim.fn.executable("tree-sitter") == 1 then
      require("nvim-treesitter").install(parsers)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("config_treesitter_highlight", { clear = true }),
      pattern = highlighted_filetypes,
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
