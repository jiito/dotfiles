local M = {}

local function list_worktrees()
  local out = vim.fn.systemlist("git worktree list --porcelain")
  local items, cur = {}, {}
  for _, line in ipairs(out) do
    if line:match("^worktree ") then
      cur = { path = line:sub(10) }
    elseif line:match("^branch ") then
      cur.branch = line:sub(8):gsub("^refs/heads/", "")
    elseif line:match("^HEAD ") then
      cur.head = line:sub(6, 13)
    elseif line == "" and cur.path then
      cur.text = string.format("%-40s  %s", cur.branch or cur.head or "?", cur.path)
      table.insert(items, cur)
      cur = {}
    end
  end
  if cur.path then
    cur.text = string.format("%-40s  %s", cur.branch or cur.head or "?", cur.path)
    table.insert(items, cur)
  end
  return items
end

function M.pick()
  Snacks.picker.pick({
    source = "git_worktrees",
    title = "Git Worktrees",
    items = list_worktrees(),
    format = function(item) return { { item.text } } end,
    confirm = function(picker, item)
      picker:close()
      vim.cmd.tcd(item.path)
      vim.notify("cwd → " .. item.path, vim.log.levels.INFO)
      Snacks.picker.files({ cwd = item.path })
    end,
  })
end

function M.create()
  vim.ui.input({ prompt = "New branch name: " }, function(branch)
    if not branch or branch == "" then return end
    local root = vim.trim(vim.fn.system("git rev-parse --show-toplevel"))
    if root == "" then
      vim.notify("not in a git repo", vim.log.levels.ERROR)
      return
    end
    local path = vim.fn.fnamemodify(root, ":h") .. "/" .. vim.fn.fnamemodify(root, ":t") .. "-" .. branch
    local base = vim.trim(vim.fn.system("git rev-parse --verify --quiet origin/main"))
    if base == "" then
      base = vim.trim(vim.fn.system("git rev-parse --verify --quiet origin/master"))
    end
    local cmd = string.format(
      "git worktree add -b %s %s %s",
      vim.fn.shellescape(branch),
      vim.fn.shellescape(path),
      base ~= "" and base or "HEAD"
    )
    vim.notify(cmd)
    vim.fn.system(cmd)
    if vim.v.shell_error == 0 then
      vim.cmd.tcd(path)
      Snacks.picker.files({ cwd = path })
    else
      vim.notify("worktree add failed", vim.log.levels.ERROR)
    end
  end)
end

return M
