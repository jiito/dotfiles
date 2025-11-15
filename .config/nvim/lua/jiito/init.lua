require("jiito.remap")
require("jiito.lsp")

-- Prettier on save 
-- Autocmd to format on save using Lua
vim.cmd[[
  augroup FormatAutogroup
    autocmd!
    autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.json,*.html,*.css Neoformat
  augroup END
]]

-- turn off copilot in markdown files

vim.cmd[[
  autocmd FileType markdown Copilot disable
]]

