vim.pack.add({ 'https://github.com/echasnovski/mini.nvim' })

-- Better Around/Inside textobjects
--
--  - va)  - [V]isually select [A]round [)]paren
--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require('mini.ai').setup { n_lines = 500 }


-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require('mini.surround').setup()

--
-- local statusline = require 'mini.statusline'
-- -- set use_icons to true if you have a Nerd Font
-- statusline.setup { use_icons = true }
--
-- -- Store the original section_mode function
-- local original_section_mode = statusline.section_mode
--
-- -- Override section_mode to return uppercase text
-- ---@diagnostic disable-next-line: duplicate-set-field
-- statusline.section_mode = function(args)
--   local mode_string = original_section_mode(args)
--   return mode_string:upper()
-- end
--
-- -- You can configure sections in the statusline by overriding their
-- -- default behavior. For example, here we set the section for
-- -- cursor location to LINE:COLUMN
-- ---@diagnostic disable-next-line: duplicate-set-field
-- statusline.section_location = function()
--   return '%2l:%-2v'
-- end
--
--
--
-- local dragonBlack5 = "#393836"
-- local boatYellow2 = "#C0A36E"
-- local canvasRed1 = "#c27672"
-- local canvasBlue1 = "#809ba7"
-- local canvasOrange1 = "#b28d77"
-- local canvasGreen2 = "#7a8c6a"
-- local canvasPink1 = "#9e7e98"
-- local fujiGray = "#727169"
-- local sumiInk4 = "#2A2A37"
-- local sumiInk5 = "#363646"
-- local _fg = dragonBlack5
--
-- -- Customize mode section colors
-- vim.api.nvim_set_hl(0, 'MiniStatuslineModeNormal',  { fg = _fg, bg = boatYellow2, bold = true })
-- vim.api.nvim_set_hl(0, 'MiniStatuslineModeInsert',  { fg = _fg, bg = '#9ece6a', bold = true })
-- vim.api.nvim_set_hl(0, 'MiniStatuslineModeVisual',  { fg = _fg, bg = '#bb9af7', bold = true })
-- vim.api.nvim_set_hl(0, 'MiniStatuslineModeReplace', { fg = _fg, bg = '#f7768e', bold = true })
-- vim.api.nvim_set_hl(0, 'MiniStatuslineModeCommand', { fg = _fg, bg = '#e0af68', bold = true })
-- vim.api.nvim_set_hl(0, 'MiniStatuslineModeOther',   { fg = _fg, bg = '#73daca', bold = true })

