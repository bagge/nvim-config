local parsers = {
  "luadoc",
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

local bundled_parser_languages = {
  "vimdoc",
  "vim",
  "lua",
  "markdown",
  "markdown_inline",
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

local function bundled_parser_path(language)
  local nvim_prefix = vim.fn.fnamemodify(vim.v.progpath, ":p:h:h")
  local parser_path = vim.fs.joinpath(nvim_prefix, "lib", "nvim", "parser", language .. ".so")

  if vim.uv.fs_stat(parser_path) then
    return parser_path
  end
end

local function prefer_bundled_parsers()
  -- Keep Neovim-shipped parsers aligned with Neovim-shipped runtime queries.
  for _, language in ipairs(bundled_parser_languages) do
    local parser_path = bundled_parser_path(language)

    if parser_path then
      pcall(vim.treesitter.language.add, language, { path = parser_path })
    end
  end
end

local function tree_sitter_cli_path()
  for _, directory in ipairs(vim.split(vim.env.PATH or "", ":", { plain = true, trimempty = true })) do
    local executable = vim.fs.joinpath(directory, "tree-sitter")

    if vim.fn.executable(executable) == 1 then
      local result = vim.system({ executable, "--version" }, { text = true }):wait()

      if result.code == 0 then
        return executable
      end
    end
  end
end

local function activate_tree_sitter_cli()
  local executable = tree_sitter_cli_path()

  if not executable then
    return false
  end

  local directory = vim.fn.fnamemodify(executable, ":h")
  local current_path = vim.env.PATH or ""

  if current_path ~= directory and not vim.startswith(current_path, directory .. ":") then
    vim.env.PATH = directory .. ":" .. current_path
  end

  return true
end

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = function()
    if activate_tree_sitter_cli() then
      vim.cmd.TSUpdate()
    end
  end,
  dependencies = {
    "neovim-treesitter/treesitter-parser-registry",
  },
  config = function()
    require("nvim-treesitter").setup()

    prefer_bundled_parsers()

    vim.treesitter.language.register("bash", "sh")
    vim.treesitter.language.register("starlark", "bzl")

    if activate_tree_sitter_cli() then
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
