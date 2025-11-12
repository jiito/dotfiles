
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function() 
	use 'wbthomason/packer.nvim'

	-- Telescope 
	use {
		'nvim-telescope/telescope.nvim',
		requires = {{'nvim-lua/plenary.nvim'} }
	}
	use {
		'neovim/nvim-lspconfig'
	}
	 -- Add nvim-cmp
	 use {
		 'hrsh7th/nvim-cmp',
		 requires = {
			 'hrsh7th/cmp-buffer',
			 'hrsh7th/cmp-nvim-lsp',
			 'hrsh7th/cmp-path',
			 'hrsh7th/cmp-nvim-lua',
			 'saadparwaiz1/cmp_luasnip',
			 'L3MON4D3/LuaSnip',
			 'rafamadriz/friendly-snippets'
		 }
	 }
	 use {
		 "sbdchd/neoformat"
	 }

	 use ({
		 'rose-pine/neovim', 
		 as = 'rose-pine', 
		 config = function()
			 vim.cmd('colorscheme rose-pine')
		 end
	 })

	 use(
		 'nvim-treesitter/nvim-treesitter',
		 {run = ':TSUpdate'}
	 )

	 use('mbbill/undotree')
	 use('theprimeagen/harpoon')
	 use('tpope/vim-fugitive')
	 use('williamboman/mason.nvim')
	 use('williamboman/mason-lspconfig.nvim')

end)
