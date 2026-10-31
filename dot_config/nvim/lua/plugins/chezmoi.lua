-- Source dir + tmp-buffer flag must be set before the plugin loads.
vim.g['chezmoi#source_dir_path'] = vim.fn.expand('~/.local/share/chezmoi')
vim.g['chezmoi#use_tmp_buffer'] = 1

vim.pack.add({ 'https://github.com/alker0/chezmoi.vim' })
