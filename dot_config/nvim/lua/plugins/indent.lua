vim.pack.add({
  { src = 'https://github.com/NMAC427/guess-indent.nvim' },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
})

require('guess-indent').setup({})

require('ibl').setup({
  indent = {
    char = '▏',
  },
  scope = {
    show_start = false,
    show_end = false,
    show_exact_scope = false,
  },
  exclude = {
    filetypes = {
      'help',
      'startify',
      'dashboard',
      'packer',
      'neogitstatus',
      'NvimTree',
      'Trouble',
    },
  },
})
