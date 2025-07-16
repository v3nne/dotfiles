-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)


-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
require("config.keymaps")
require("config.options")


-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "gruvbox-material", "gruvbox", "gruvbox-dark" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
  ui = {
    border = "single",
  }
})


-- Makes the which-key and lazy window transparent
-- local int_to_hex = require("utils").int_to_hex
-- local normal_float = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
-- local float_border = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
-- local float_title = vim.api.nvim_get_hl(0, { name = "FloatTitle" })
--
-- -- the hl's also has `ctermfg` & `ctermbg` but not according to the lsp
-- vim.api.nvim_set_hl(0, "NormalFloat", { fg = int_to_hex(normal_float.fg) })
-- vim.api.nvim_set_hl(0, "FloatBorder", { fg = int_to_hex(float_border.fg) })
-- vim.api.nvim_set_hl(0, "FloatTitle", { fg = int_to_hex(float_title.fg) })
