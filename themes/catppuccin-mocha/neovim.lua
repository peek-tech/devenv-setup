-- Neovim theme configuration - Catppuccin Mocha
-- Add this to your init.lua or neovim config

vim.cmd.colorscheme "catppuccin-mocha"

-- Configure catppuccin if plugin is available
local status_ok, catppuccin = pcall(require, "catppuccin")
if status_ok then
  catppuccin.setup({
    flavour = "mocha",
    background = {
      light = "latte",
      dark = "mocha",
    },
    transparent_background = false,
    show_end_of_buffer = false,
    term_colors = true,
    dim_inactive = {
      enabled = false,
      shade = "dark",
      percentage = 0.15,
    },
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      telescope = true,
      notify = false,
      mini = false,
    },
  })
end