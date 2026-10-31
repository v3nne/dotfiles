vim.pack.add({ 'https://github.com/christoomey/vim-tmux-navigator' })

local utils = require('utils')

local directions = {
  h = { wincmd = 'h', zellij = 'left', tmux = 'TmuxNavigateLeft' },
  j = { wincmd = 'j', zellij = 'down', tmux = 'TmuxNavigateDown' },
  k = { wincmd = 'k', zellij = 'up', tmux = 'TmuxNavigateUp' },
  l = { wincmd = 'l', zellij = 'right', tmux = 'TmuxNavigateRight' },
}

local function navigate(key)
  local direction = directions[key]

  if not utils.in_zellij() then
    vim.cmd(direction.tmux)
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. direction.wincmd)

  if vim.api.nvim_get_current_win() == current_win then
    utils.zellij_action('move-focus', direction.zellij)
  end
end

if utils.in_zellij() then
  local group = vim.api.nvim_create_augroup('ZellijIntegration', { clear = true })

  vim.api.nvim_create_autocmd({ 'VimEnter', 'FocusGained' }, {
    group = group,
    callback = function() utils.zellij_action('switch-mode', 'locked') end,
  })

  vim.api.nvim_create_autocmd({ 'VimLeavePre', 'FocusLost' }, {
    group = group,
    callback = function() utils.zellij_action('switch-mode', 'normal') end,
  })
end

map('n', '<M-h>', function() navigate('h') end)
map('n', '<M-j>', function() navigate('j') end)
map('n', '<M-k>', function() navigate('k') end)
map('n', '<M-l>', function() navigate('l') end)
map('n', '<M-\\>', function()
  if utils.in_zellij() then
    utils.zellij_action('focus-previous-pane')
  else
    vim.cmd('TmuxNavigatePrevious')
  end
end)

local smart_resize = utils.smart_resize

map('n', '<M-H>', function() smart_resize('H') end)
map('n', '<M-L>', function() smart_resize('L') end)
map('n', '<M-K>', function() smart_resize('K') end)
map('n', '<M-J>', function() smart_resize('J') end)
