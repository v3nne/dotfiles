-- Window
map('n', '<leader>we', '<C-w>=', '[E]qual width & height')
map('n', '<leader>wc', '<cmd>close<CR>', '[C]lose')
map('n', '<leader>wh', '<cmd>hide<CR>', '[H]ide')
map('n', '<leader>ws', ':split<CR>', '[S]plit Horizontally')
map('n', '<leader>wv', ':vsplit<CR>', 'Split [V]ertically')

-- Buffer
map('n', '<leader>bk', ':bd<CR>', '[K]ill')

map('n', '<C-s>', ':w<CR>', 'Write with Ctrl+s')
map('n', '<C-q>', ':qa<CR>', 'Quit with Ctrl+q')

map('n', '<C-d>', '<C-d>zz', 'Keep cursor centered after scrolling')
map('n', '<C-u>', '<C-u>zz', 'Keep cursor centered after scrolling')

-- map('n', '<C-o>', '<C-o>zz', 'Keep cursor centered when navigating jump list')
-- map('n', '<C-i>', '<C-i>zz', 'Keep cursor centered when navigating jump list')

-- map('n', 'n', 'nzz', 'Keep cursor centered after jumping to next searched word')
-- map('n', 'N', 'Nzz', 'Keep cursor centered after jumping to prev searched word')

map('n', '<Esc>', '<cmd>nohlsearch<CR>', 'Clear search highlighting')

map('v', '<', '<gv', 'Keep selection when indenting')
map('v', '>', '>gv', 'Keep selection when indenting')

map('v', 'J', ":m '>+1<CR>gv=gv", 'Move selected lines with Shift+j')
map('v', 'K', ":m '<-2<CR>gv=gv", 'Move selected lines with Shift+k')

map('n', '<leader>q', vim.diagnostic.setloclist, 'Diagnostic [Q]uickfix')
map('n', 'D', vim.diagnostic.open_float, 'Open flaoting diagnostics')

map('t', 'jk', '<C-\\><C-n>', 'Exit terminal mode')

map('n', '<leader>tN', '<cmd>tabnew<cr>',   '[N]ew tab')
map('n', '<leader>tk', '<cmd>tabclose<cr>', '[K]ill tab')
map('n', '<leader>tn', '<cmd>tabnext<cr>',  '[N]ext tab')
map('n', '<leader>tp', '<cmd>tabprev<cr>',  '[P]rev tab')

map('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', 'Git [D]iff')

local function open_lazygit_for_current_repo()
  local buf = vim.api.nvim_buf_get_name(0)
  local start_dir = (buf ~= '' and vim.fs.dirname(buf)) or vim.fn.getcwd()
  local root = vim.fs.root(start_dir, '.git')

  if not root then
    vim.notify('No git repo found from: ' .. start_dir, vim.log.levels.WARN)
    return
  end

  Snacks.lazygit({ cwd = root })
end

local function list_git_repos(base_dir)
  local repos = {}

  for name, entry_type in vim.fs.dir(base_dir) do
    if entry_type == 'directory' then
      local candidate = base_dir .. '/' .. name
      local git_dir = candidate .. '/.git'
      if vim.uv.fs_stat(git_dir) then
        repos[#repos + 1] = candidate
      end
    end
  end

  table.sort(repos)
  return repos
end

local function pick_repo_and_open_lazygit()
  local base_dir = vim.fn.getcwd()
  local repos = list_git_repos(base_dir)

  if #repos == 0 then
    vim.notify('No git repos found in: ' .. base_dir, vim.log.levels.WARN)
    return
  end

  vim.ui.select(repos, {
    prompt = 'Pick repository for lazygit',
    format_item = function(item)
      return vim.fn.fnamemodify(item, ':t') .. '  (' .. item .. ')'
    end,
  }, function(choice)
    if choice then
      Snacks.lazygit({ cwd = choice })
    end
  end)
end

map('n', '<leader>gg', open_lazygit_for_current_repo, 'Lazy[G]it (current repo)')
map('n', '<leader>gG', pick_repo_and_open_lazygit, 'Lazygit [G]it repo picker')
