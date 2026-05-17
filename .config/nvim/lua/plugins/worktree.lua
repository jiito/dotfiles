return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>gw", "", desc = "+worktree" },
    {
      "<leader>gws",
      function() require("config.worktree").pick() end,
      desc = "Switch worktree",
    },
    {
      "<leader>gwn",
      function() require("config.worktree").create() end,
      desc = "New worktree",
    },
  },
}
