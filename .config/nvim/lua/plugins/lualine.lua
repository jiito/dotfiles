return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local function worktree()
      return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    end
    table.insert(opts.sections.lualine_c, 1, {
      worktree,
      color = { fg = "#f7768e", gui = "bold" },
    })
    return opts
  end,
}
