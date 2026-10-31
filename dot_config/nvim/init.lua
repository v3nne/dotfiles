-- Filter the core "Did not detect DSR response" warning. Neovim probes the
-- terminal at startup and warns if the reply is slow (~2s) — common over SSH.
-- The probe still completes; suppressing only hides the notify.
local _orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == 'string' and msg:find('Did not detect DSR response', 1, true) then
    return
  end
  return _orig_notify(msg, level, opts)
end

_G.map = require('utils').map

vim.pack.add({
  -- Common dependencies
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-lua/plenary.nvim',

  'https://github.com/thesimonho/kanagawa-paper.nvim',
  'https://github.com/rebelot/kanagawa.nvim',
  'https://github.com/catgoose/nvim-colorizer.lua',
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/folke/todo-comments.nvim',

  -- { src = 'https://github.com/' },
  -- vim.pack.add({ 'https://github.com/' })
})


require('options')
require('keymaps')
require('plugins')

require('colorizer').setup({})
require('nvim-autopairs').setup({})
require('todo-comments').setup({ signs = false })

-- local text_fg = '#CEC9AF'
local text_fg = '#B4B09B'

require('kanagawa-paper').setup({
  colors = {
    theme = {
      ink = {
        ui = {
          fg = text_fg,
        },
      },
    },
  },
})


local fix_colors = function ()
  local hls_to_rm_bg = {
    'FloatBorder',
    'NormalFloat',
    'BlinkCmpMenu',
    'BlinkCmpMenuBorder',
    'BlinkCmpSignatureHelp',
    'BlinkCmpSignatureHelpBorder',
    'Pmenu',
    'WhichKeyBorder',
  }
  for _, hl in ipairs(hls_to_rm_bg) do
    local opts = { bg = 'NONE' }
    -- if hl:sub(-6) == 'Border' then
    --   opts.fg = border_color
    -- end
    vim.api.nvim_set_hl(0, hl, opts)
  end
end

vim.cmd.colorscheme 'kanagawa-paper-ink'
fix_colors()
vim.api.nvim_create_autocmd('ColorScheme', { callback = fix_colors })
