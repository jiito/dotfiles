-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Leap override — root-cause fix for codeberg fork (andyg/leap.nvim).
--
-- The fork has an internal inconsistency: lua/leap/user.lua's add_default_mappings
-- binds s/S to <Plug>(leap-forward-to) / <Plug>(leap-backward-to), but
-- plugin/init.lua only defines <Plug>(leap-forward) / <Plug>(leap-backward)
-- (the "-to" suffix was dropped, but the default-mappings table wasn't updated).
-- Net effect: out of the box, pressing s/S does nothing because the <Plug>
-- target doesn't exist. gs, x, X are unaffected (their <Plug> names still match).
--
-- Fix: bind s/S to the <Plug> names that actually exist in this fork.
-- add_default_mappings(true) still overwrites our mapping when leap loads, so
-- we re-apply on User LazyLoad. Worth filing upstream at:
--   https://codeberg.org/andyg/leap.nvim
local function set_leap()
  vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "Leap forward", remap = true })
  vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "Leap backward", remap = true })
end
-- Eagerly load leap so its <Plug>(leap-forward)/(leap-backward) targets exist
-- before the first `s` press. Without this, the first `s` falls through to vim's
-- default substitute because the <Plug> target doesn't resolve yet.
-- Loading leap synchronously also runs add_default_mappings() which clobbers s/S
-- to the (broken) <Plug>(leap-forward-to) name — set_leap() below restores ours.
pcall(vim.cmd, "Lazy load leap.nvim")
set_leap()
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(args)
    if args.data == "leap.nvim" then set_leap() end
  end,
})
