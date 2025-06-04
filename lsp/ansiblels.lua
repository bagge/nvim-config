return {
  cmd = { 'ansible-language-server', '--stdio' },
  settings = {
    ansible = {
      python = {
        interpreterPath = 'python3',
      },
      ansible = {
        useFullyQualifiedCollectionNames = true,
        path = '/home/aszakaly/.local/pipx/venvs/ansible-lint/bin/ansible',
      },
      executionEnvironment = {
        enabled = false,
      },
      validation = {
        enabled = true,
        lint = {
          enabled = true,
          path = 'ansible-lint',
        },
      },
    },
  },
  filetypes = { 'yaml.ansible' },
  root_markers = { 'ansible.cfg', '.ansible-lint' },
}
