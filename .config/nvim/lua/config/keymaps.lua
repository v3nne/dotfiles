-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

---@param desc? string
---@return table
local function getOpts(desc)
  local opts = { noremap = true, silent = true }

  if desc ~= nil or desc ~= "" then
     opts.desc = desc
  end

  return opts
end



-- Quite vim with Ctrl+q
vim.keymap.set("n", "<C-q>", ":confirm quit<CR>", getOpts())
vim.keymap.set("i", "<C-q>", "<Esc>:confirm quit<CR>", getOpts())
vim.keymap.set("v", "<C-q>", "<Esc>:confirm quit<CR>", getOpts())

-- save file
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', getOpts("Save file"))

-- Stay in visual mode when indenting
vim.keymap.set('v', '<', '<gv', getOpts())
vim.keymap.set('v', '>', '>gv', getOpts())

-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', getOpts())
vim.keymap.set('n', '<C-u>', '<C-u>zz', getOpts())

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', getOpts())
vim.keymap.set('n', 'N', 'Nzzzv', getOpts())

-- Window management
vim.keymap.set('n', '<leader>ws', '<C-w>s', getOpts("Split horizontally"))
vim.keymap.set('n', '<leader>wv', '<C-w>v', getOpts("Split verically"))
vim.keymap.set('n', '<leader>w=', '<C-w>=', getOpts("Balance window sizes"))
vim.keymap.set('n', '<leader>wq', ':close<CR>', getOpts("Quit window"))

-- Send deleted char with x and X to the black-hole register (so it doesn't save it to clipboard)
vim.keymap.set('n', 'x', '"_x', getOpts())
vim.keymap.set('n', 'X', '"_X', getOpts())
-- Same with s
vim.keymap.set('n', 's', '"_s', getOpts())

-- Buffers
-- vim.keymap.set('n', '<C-PageDown>', ':bnext<CR>', getOpts())
-- vim.keymap.set('n', '<C-PageUp>', ':bprevious<CR>', getOpts())
vim.keymap.set('n', '<leader>bq', ':bdelete!<CR>', getOpts("Quit Buffer"))
vim.keymap.set('n', '<leader>bn', '<cmd> enew <CR>', getOpts("New Buffer"))







-- -- save file without auto-formatting
-- vim.keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>', getOpts())
--
-- -- quit file
-- vim.keymap.set('n', '<C-q>', '<cmd> q <CR>', getOpts())
--
-- -- delete single character without copying into register
-- vim.keymap.set('n', 'x', '"_x', getOpts())
--
--

--
-- -- Resize with arrows
-- --[[ vim.keymap.set('n', '<S-Up>', ':resize -2<CR>', getOpts())
-- vim.keymap.set('n', '<S-Down>', ':resize +2<CR>', getOpts())
-- vim.keymap.set('n', '<S-Left>', ':vertical resize -2<CR>', getOpts())
-- vim.keymap.set('n', '<S-Right>', ':vertical resize +2<CR>', getOpts()) ]]
--
--
-- -- Window management
-- vim.keymap.set('n', '<leader>v', '<C-w>v', getOpts("Split window verically"))
-- vim.keymap.set('n', '<leader>h', '<C-w>s', getOpts("Split window horizontally"))
-- vim.keymap.set('n', '<leader>se', '<C-w>=', getOpts("Make split windows equal widht & height"))
-- vim.keymap.set('n', '<leader>xs', ':close<CR>', getOpts("Close current split"))
--
-- -- Tabs
-- vim.keymap.set('n', '<leader>to', ':tabnew<CR>', getOpts()) -- open new tab
-- vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', getOpts()) -- close current tab
-- vim.keymap.set('n', '<leader>tn', ':tabn<CR>', getOpts()) --  go to next tab
-- vim.keymap.set('n', '<leader>tp', ':tabp<CR>', getOpts()) --  go to previous tab
--
-- -- Toggle line wrapping
-- vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', getOpts())
--
-- -- Stay in indent mode when indenting
-- vim.keymap.set('v', '<', '<gv', getOpts())
-- vim.keymap.set('v', '>', '>gv', getOpts())
--
-- -- Keep last yanked when pasting
-- vim.keymap.set('v', 'p', '"_dP', getOpts())
--
-- -- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })







-- My stuff:

-- Paste with ctrl+v
-- vim.keymap.set('n', '<C-v>', 'p', getOpts())

-- -- Copy with ctrl+c
-- vim.keymap.set('n', '<C-c>', 'y', getOpts())

-- -- Undo with ctrl+Z
-- vim.keymap.set('n', '<C-z>', 'u', getOpts())
-- vim.keymap.set('n', '<C-S-z>', '<C-r>', getOpts())

-- -- Jump word with ctrl+arrowkey
-- vim.keymap.set('n', '<C-Left>', 'b', getOpts())
-- vim.keymap.set('n', '<C-Right>', 'w', getOpts())
-- vim.keymap.set('i', '<C-Left>', '<C-o>b', getOpts())
-- vim.keymap.set('i', '<C-Right>', '<C-o>w', getOpts())

-- -- Delete a word with ctrl+Backspace/Del  
-- vim.keymap.set('n', '<C-BS>', 'db', getOpts())
-- vim.keymap.set('n', '<C-Del>', 'dw', getOpts())
-- vim.keymap.set('i', '<C-BS>', '<C-o>db', getOpts())
-- vim.keymap.set('i', '<C-Del>', '<C-o>dw', getOpts())

