-- Diagnostics keymaps (work without an LSP attached)
vim.keymap.set('n', 'gl', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1,  float = true }) end)

-- LSP keymaps — applied per-buffer when a server attaches
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = { buffer = event.buf }
    vim.keymap.set('n', 'K',  vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
    vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
  end,
})

-- Advertise nvim-cmp's extra capabilities to every LSP server
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- pyright: auto-detect a project-local `.venv` (uv/standard layout) and point
-- pyright at its interpreter so imports from venv packages resolve.
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'pyright: set pythonPath from <root>/.venv',
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= 'pyright' then return end
    local root = client.config.root_dir or vim.fn.getcwd()
    local py = root .. '/.venv/bin/python'
    if vim.fn.filereadable(py) ~= 1 then return end
    client.config.settings = vim.tbl_deep_extend('force', client.config.settings or {}, {
      python = { pythonPath = py },
    })
    -- nil signals pyright to re-pull config via workspace/configuration,
    -- which is what actually makes it re-read pythonPath. Pushing settings
    -- inline is silently ignored after init.
    client:notify('workspace/didChangeConfiguration', { settings = nil })
  end,
})

-- lua_ls: teach it about Neovim's runtime so editing this config is pleasant
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

-- mason: install & manage external tooling
-- mason-lspconfig: bridges mason packages → vim.lsp.enable() for installed servers
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = { 'ts_ls', 'pyright', 'lua_ls' },
  automatic_enable = true,
})

-- nvim-cmp: the completion popup ("IntelliSense")
local cmp = require('cmp')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load() -- friendly-snippets

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>']     = cmp.mapping.abort(),
    ['<CR>']      = cmp.mapping.confirm({ select = false }),
    ['<C-n>']     = cmp.mapping.select_next_item(),
    ['<C-p>']     = cmp.mapping.select_prev_item(),
    ['<C-d>']     = cmp.mapping.scroll_docs(4),
    ['<C-u>']     = cmp.mapping.scroll_docs(-4),
    ['<Tab>']     = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback() end
    end, { 'i', 's' }),
    ['<S-Tab>']   = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback() end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'nvim_lua' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  }),
})
