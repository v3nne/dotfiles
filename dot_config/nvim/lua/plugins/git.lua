vim.pack.add({
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/sindrets/diffview.nvim'
})

require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  }
})


local diff_actions = require("diffview.actions")

require('diffview').setup({
  file_panel = {
    win_config = {
      position = 'left',
      width = 35,
    },
    listing_style = 'list',
  },
  hooks = {
    diff_buf_read = function(bufnr)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      -- Only disable LSP for the old version (left pane) which uses diffview:// scheme
      if bufname:match('^diffview://') then
        vim.diagnostic.enable(false, { bufnr = bufnr })
        vim.api.nvim_create_autocmd('LspAttach', {
          buffer = bufnr,
          callback = function(args)
            vim.lsp.buf_detach_client(bufnr, args.data.client_id)
          end,
        })
      end
    end,
    view_opened = function()
      -- Close the file panel when diffview opens
      vim.cmd('DiffviewToggleFiles')
    end,
  },
  view = {
    default = {
      layout = 'diff2_horizontal', -- side-by-side diff (left: old, right: new)
    },
    merge_tool = {
      layout = 'diff3_horizontal',
    },
    file_history = {
      layout = 'diff2_horizontal',
    },
  },
  keymaps = {
    view = {
      ['q'] = '<Cmd>DiffviewClose<CR>',
      ['<leader>e'] = '<Cmd>DiffviewToggleFiles<CR>',
      ['<leader>l'] = diff_actions.cycle_layout,
    },
    file_panel = {
      ['q'] = '<Cmd>DiffviewClose<CR>',
      ['<leader>e'] = '<Cmd>DiffviewToggleFiles<CR>',
      ['<Right>'] = function()
        diff_actions.select_entry()
        diff_actions.toggle_files()
      end
    },
    file_history_panel = {
      ['q'] = '<Cmd>DiffviewClose<CR>',
      ['<leader>e'] = '<Cmd>DiffviewToggleFiles<CR>',
    },
  },
})

