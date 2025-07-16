require("config.lazy")


-- VIM TMUX INTEGRATION --
local opts = { noremap = true, silent = true }
local modes = { 'n','i','v','t' }

for _, m in ipairs(modes) do
  vim.keymap.set(m, '<A-H>', '<Cmd>TmuxResizeLeft<CR>',  opts)
  vim.keymap.set(m, '<A-J>', '<Cmd>TmuxResizeDown<CR>',  opts)
  vim.keymap.set(m, '<A-K>', '<Cmd>TmuxResizeUp<CR>',    opts)
  vim.keymap.set(m, '<A-L>', '<Cmd>TmuxResizeRight<CR>', opts)
end

for _, m in ipairs(modes) do
  vim.keymap.set(m, '<A-h>', '<Cmd>TmuxNavigateLeft<CR>', opts)
  vim.keymap.set(m, '<A-j>', '<Cmd>TmuxNavigateDown<CR>', opts)
  vim.keymap.set(m, '<A-k>', '<Cmd>TmuxNavigateUp<CR>', opts)
  vim.keymap.set(m, '<A-l>', '<Cmd>TmuxNavigateRight<CR>', opts)
  vim.keymap.set(m, '<A-\\>', '<Cmd>TmuxNavigatePrevious<CR>', opts)
end


