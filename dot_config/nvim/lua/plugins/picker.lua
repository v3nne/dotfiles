vim.pack.add({
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-file-browser.nvim',
})


local telescope = require('telescope')
local actions = require('telescope.actions')
local fb_actions = telescope.extensions.file_browser.actions

local telescope_navigation = {
  ['<down>'] = actions.move_selection_next,
  ['<up>'] = actions.move_selection_previous,
  ['<right>'] = actions.select_default,
  ['<C-d>'] = actions.preview_scrolling_down,
  ['<C-u>'] = actions.preview_scrolling_up,
}

telescope.setup({
  defaults = {
    borderchars = {
      prompt = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      results = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
    sorting_strategy = 'ascending',
    layout_strategy = 'horizontal',
    layout_config = {
      prompt_position = 'top',
      horizontal = {
        width = 0.90,
        height = 0.90,
        preview_width = 0.60,
        results_width = 0.40,
      },
    },
    mappings = {
      i = telescope_navigation,
      n = telescope_navigation,
    },
  },
  pickers = {
    buffers = {
      mappings = {
        i = { ['<C-x>'] = actions.delete_buffer },
        n = { ['<C-x>'] = actions.delete_buffer },
      },
    },
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
    file_browser = {
      hidden = { file_browser = true, folder_browser = true },
      mappings = {
        ['i'] = {
          ['<Left>'] = fb_actions.goto_parent_dir,
          ['<C-a>'] = fb_actions.create,
          ['<C-r>'] = fb_actions.rename,
        },
        ['n'] = {
          ['<Left>'] = fb_actions.goto_parent_dir,
          ['<a>'] = fb_actions.rename,
        },
      },
    },
  },
})

pcall(telescope.load_extension, 'file_browser')

-- Backdrop for telescope (mirrors snacks.lazygit backdrop)
local tele_backdrop = { buf = nil, win = nil }

local function open_telescope_backdrop()
  if tele_backdrop.win and vim.api.nvim_win_is_valid(tele_backdrop.win) then return end
  tele_backdrop.buf = vim.api.nvim_create_buf(false, true)
  tele_backdrop.win = vim.api.nvim_open_win(tele_backdrop.buf, false, {
    relative = 'editor',
    width = vim.o.columns,
    height = vim.o.lines,
    row = 0,
    col = 0,
    style = 'minimal',
    focusable = false,
    zindex = 45,
  })
  vim.api.nvim_set_option_value('winblend', 60, { win = tele_backdrop.win })
  vim.api.nvim_set_option_value('winhighlight', 'Normal:TelescopeBackdrop', { win = tele_backdrop.win })
end

local function close_telescope_backdrop()
  if tele_backdrop.win and vim.api.nvim_win_is_valid(tele_backdrop.win) then
    vim.api.nvim_win_close(tele_backdrop.win, true)
  end
  if tele_backdrop.buf and vim.api.nvim_buf_is_valid(tele_backdrop.buf) then
    vim.api.nvim_buf_delete(tele_backdrop.buf, { force = true })
  end
  tele_backdrop.win = nil
  tele_backdrop.buf = nil
end

vim.api.nvim_set_hl(0, 'TelescopeBackdrop', { bg = '#000000' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopePrompt',
  callback = function()
    open_telescope_backdrop()
    vim.api.nvim_create_autocmd('BufUnload', {
      buffer = vim.api.nvim_get_current_buf(),
      once = true,
      callback = close_telescope_backdrop,
    })
  end,
})

map('n', '<leader>e', function()
  require('telescope').extensions.file_browser.file_browser {
    path = '%:p:h',
    select_buffer = true,
  }
end, 'File [E]xplorer')




local fzf = require('fzf-lua')

local ignore_list = {
  'node_modules',
  '.sst',
  '.venv',
  '.git'
}

local function get_fd_opts()
  local excludes = {}
  for _, item in ipairs(ignore_list) do
    table.insert(excludes, '--exclude ' .. item)
  end

  return table.concat(excludes, ' ')
end

-- Setup fzf-lua
fzf.setup {
  'default-title',
  winopts = {
    height = 0.90,
    width = 0.90,
    backdrop = 60,
    border = 'single',
    preview = {
      border = 'single',
    },
  },
  keymap = {
    builtin = {
      ['<right>'] = 'select',
      ['<C-d>'] = 'preview-page-down',
      ['<C-u>'] = 'preview-page-up',
    },
    fzf = {
      ['right'] = 'accept',
    },
  },
  files = {
    prompt = 'Files❯ ',
    git_icons = true,
    file_icons = true,
    fd_opts = get_fd_opts()
  },
  grep = {
    prompt = 'Grep❯ ',
    git_icons = true,
    file_icons = true,
    fd_opts = get_fd_opts()
  },
}

-- Keymaps
map('n', '<leader>sh', fzf.helptags, '[H]elp')
map('n', '<leader>sk', fzf.keymaps, '[K]eymaps')
map('n', '<leader>sf', fzf.files, '[F]iles')
map('n', '<leader>ss', fzf.builtin, '[S]elect fzf-lua')
map('n', '<leader>sw', fzf.grep_cword, 'current [W]ord')
map('n', '<leader>sg', fzf.live_grep, '[G]rep')
map('n', '<leader>sd', fzf.diagnostics_document, '[D]iagnostics')
map('n', '<leader>sr', fzf.resume, '[R]esume')
map('n', '<leader>sR', fzf.oldfiles, '[R]ecent Files')
map('n', '<leader><leader>', fzf.buffers, '[ ] Find existing buffers')
map('n', '<leader>/', fzf.blines, '[/] Fuzzy search buffer')

-- Search in open files
map('n', '<leader>s/', function()
  fzf.live_grep {
    cmd = 'rg --column --line-number --no-heading --color=always --smart-case',
    prompt = 'Grep Open Buffers❯ ',
    filespec = vim.fn.join(
      vim.tbl_map(
        function(buf)
          return vim.api.nvim_buf_get_name(buf)
        end,
        vim.tbl_filter(function(buf)
          return vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= ''
        end, vim.api.nvim_list_bufs())
      ),
      ' '
    ),
  }
end, '[/] open buffers')

-- Search Neovim config files
map('n', '<leader>sn', function()
  fzf.files { cwd = vim.fn.stdpath 'config' }
end, '[N]eovim files')


-- Add this after your colorscheme is set
-- vim.api.nvim_create_autocmd('ColorScheme', {
--   callback = function()
--     print("running autocmd 2: " .. vim.o.background)
--     local is_light = vim.o.background == 'light'
--     if is_light then
--       -- Light theme adjustments
--       vim.api.nvim_set_hl(0, 'FzfLuaCursor', { bg = '#C8C093', fg = '#1F1F28' })
--       vim.api.nvim_set_hl(0, 'FzfLuaCursorLine', { bg = '#E5DDB0' })
--     end
--   end,
-- })
