vim.pack.add({ 'https://github.com/folke/which-key.nvim' })

require('which-key').setup({
  delay = 1000,
  preset = 'helix',
  spec = {
    { '<leader>s', group = '[S]earch' },
    { '<leader>t', group = '[T]oggle' },
    -- { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { '<leader>a', group = 'AI', mode = { 'n', 'v' } },
    { '<leader>w', group = '[W]indow' },
    { '<leader>b', group = '[B]uffer' },
    { '<leader>g', group = '[G]it' },
    { '<leader>c', group = '[C]laude' },
  },
  win = {
    border = 'single',
  }
})

vim.api.nvim_set_hl(0, 'WhichKeyBorder', { bg = 'NONE' })

