vim.pack.add({ 'https://github.com/nvim-lualine/lualine.nvim' })
local lualine = require('lualine')

local hide_in_width = function()
  if vim.fn.winwidth(0) > 100 then
    return true
  end
  return false
end

local mode_map = {
  ['V-LINE'] = 'VIL',
  ['V-BLOCK'] = 'VIB',
  ['COMMAND'] = 'CMD',
  ['S-LINE'] = 'SLI',
  ['S-BLOCK'] = 'SBL',
}

local mode = {
  'mode',
  fmt = function(str)
    return mode_map[str] or str:sub(1, 3)
  end
}

local filename = {
  'filename',
  file_status = true,
  path = 1
}

local filename_inactive = {
  'filename',
  path = 1
}

local diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  sections = { 'error', 'warn' },
  symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
  colored = false,
  update_in_insert = false,
  always_visible = false,
  cond = hide_in_width,
}

local diff = {
  'diff',
  colored = false,
  symbols = { added = ' ', modified = ' ', removed = ' ' },
  cond = hide_in_width,
}

lualine.setup({
  options = {
    icons_enabled = true,
    theme = 'auto',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    disabled_filetypes = { 'alpha', 'neo-tree', 'fzf' },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { mode },
    lualine_b = { { 'branch' } },
    lualine_c = { filename },
    lualine_x = { diagnostics, diff, { 'encoding', cond = hide_in_width }, { 'filetype', cond = hide_in_width } },
    lualine_y = { { 'location' } },
    lualine_z = { { 'progress' } },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { filename_inactive },
    lualine_x = { { 'location', padding = 0 } },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = { 'fugitive' },
})
