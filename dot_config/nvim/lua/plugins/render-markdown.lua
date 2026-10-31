vim.pack.add({ 'https://github.com/MeanderingProgrammer/render-markdown.nvim' })

local ok, render_markdown = pcall(require, 'render-markdown')
if not ok then return end

render_markdown.setup({
  file_types = { 'markdown', 'codecompanion' },
})
