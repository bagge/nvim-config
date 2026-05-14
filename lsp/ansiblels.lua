local ansible_path = vim.env.ANSIBLE_LS_ANSIBLE_PATH or vim.fn.exepath('ansible')

local settings = {
  ansible = {
    python = {
      interpreterPath = 'python3',
    },
    ansible = {
      useFullyQualifiedCollectionNames = true,
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
}

if ansible_path ~= '' then
  settings.ansible.ansible.path = ansible_path
end

return {
  cmd = { 'ansible-language-server', '--stdio' },
  settings = settings,
  filetypes = { 'yaml.ansible' },
  root_markers = { 'ansible.cfg', '.ansible-lint' },
}
