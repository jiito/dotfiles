return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewFileHistory",
    "DiffviewRefresh",
  },
  keys = {
    { "<leader>gh", "", desc = "+diffview" },
    {
      "<leader>ghd",
      function()
        local base = vim.trim(vim.fn.system("git rev-parse --verify --quiet origin/main"))
        if base == "" then
          base = vim.trim(vim.fn.system("git rev-parse --verify --quiet origin/master"))
        end
        if base == "" then
          vim.notify("no origin/main or origin/master", vim.log.levels.ERROR)
          return
        end
        vim.cmd("DiffviewOpen " .. base .. "...HEAD")
      end,
      desc = "Diff worktree vs origin/main (PR view)",
    },
    { "<leader>ghD", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree (uncommitted)" },
    { "<leader>ghh", "<cmd>DiffviewFileHistory<cr>", desc = "Repo file history" },
    { "<leader>ghf", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file history" },
    { "<leader>ghc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    { "<leader>ght", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle file panel" },
    { "<leader>ghf", ":DiffviewFileHistory<cr>", mode = "v", desc = "Range history" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      merge_tool = { layout = "diff3_mixed" },
    },
    keymaps = {
      view = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },
      file_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },
    },
  },
}
