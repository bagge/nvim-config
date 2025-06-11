return {
  cmd = { 'efm-langserver' },
  --cmd = {"efm-langserver", "--logfile=/tmp/lsp/efm.log", "--loglevel=20"},
  root_markers = { '.git' },
  filetypes = { "bzl" },
  single_file_support = true,
  settings = {
    rootMarkers = { ".git/" },
    languages = {
      bzl = {
        {
          lintSource = 'buildifier',
          lintCommand = 'buildifier -warnings=-module-docstring,+load -lint=warn -mode=check',
          lintFormats = { '%f:%l: %m' },
          lintStdin = true,
        }
      },
    },
  },
}
