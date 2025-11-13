vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>s", vim.cmd.w)

-- Copy to clipboard
vim.keymap.set('v', '<leader>y', '"+y',  { noremap = true, silent = true, desc = 'Copy to clipboard' })
vim.keymap.set('n', '<leader>Y', '"+yg_', { noremap = true, silent = true, desc = 'Copy to EOL to clipboard' })
vim.keymap.set('n', '<leader>y', '"+y',  { noremap = true, silent = true, desc = 'Copy (motion) to clipboard' })
vim.keymap.set('n', '<leader>yy', '"+yy', { noremap = true, silent = true, desc = 'Copy line to clipboard' })

-- Paste from clipboard
vim.keymap.set('n', '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('n', '<leader>P', '"+P', { noremap = true, silent = true, desc = 'Paste before from clipboard' })
vim.keymap.set('v', '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('v', '<leader>P', '"+P', { noremap = true, silent = true, desc = 'Paste before from clipboard' })
