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

-- Set CMD-S to save
vim.keymap.set('n', '<D-s>', ':w<CR>', { noremap = true, silent = true })

