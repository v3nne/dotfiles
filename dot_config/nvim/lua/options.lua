-- ================== Sensible Defaults ==================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.number = true
vim.o.relativenumber = true
vim.o.swapfile = false
-- Disable cursor blinking globally
vim.opt.guicursor:append 'a:blinkon0'
-- Many colorschemes needs this
vim.o.termguicolors = true
vim.o.showmode = false
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.o.mouse = 'a'
vim.o.undofile = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.confirm = true

-- ==================== Line Wrapping ====================
vim.o.wrap = false -- Don't wrap lines
vim.o.linebreak = true -- Wrap at word boundaries
vim.o.textwidth = 0 -- Don't auto-insert line breaks

-- ===================== Indentation =====================
vim.o.tabstop = 2 -- Number of spaces tabs count for
vim.o.shiftwidth = 2 -- Size of indent
vim.o.softtabstop = 2 -- Number of spaces for <Tab>
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.smartindent = true -- Smart autoindenting
vim.o.shiftround = true -- Round indent to multiple of shiftwidth
vim.o.breakindent = true -- Wrapped lines continue indent



vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('based-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Short hand for opening help texts vertically with `:Vh`
vim.api.nvim_create_user_command('Vh', function(opts)
  vim.cmd('vert help ' .. table.concat(opts.fargs, ' '))
end, { nargs = '*', complete = 'help' })

