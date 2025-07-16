return {
  {
    'RyanMillerC/better-vim-tmux-resizer',
    lazy = false,
    before = 'vim-tmux-navigator',
    init = function()
      vim.g.tmux_resizer_resize_count = 2
      vim.g.tmux_resizer_vertical_resize_count = 4
    end,
    config = function () end
  },
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
    after = 'better-vim-tmux-resizer',
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
      vim.g.tmux_navigator_no_wrap = 1
    end,
    config = function() end,
  }
}
