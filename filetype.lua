vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  filename = {
    [".gitlab-ci.yml"] = "yaml.gitlab",
    [".gitlab-ci.yaml"] = "yaml.gitlab",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["values.yml"] = "yaml.helm-values",
    ["values.yaml"] = "yaml.helm-values",
  },
  pattern = {
    [".*/playbooks/.*%.yaml"] = "yaml.ansible",
    [".*/playbooks/.*%.yml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.yaml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.yml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.yaml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.yml"] = "yaml.ansible",
    [".*%.go%.tmpl"] = "gotmpl",
  },
})
