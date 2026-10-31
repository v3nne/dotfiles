vim.pack.add({ 'https://github.com/toppair/peek.nvim' })

local ok, peek = pcall(require, 'peek')
if not ok then return end

local function setup_peek(app)
  peek.setup({
    app = app,
    filetype = { 'markdown' },
    theme = 'dark',
  })
end

setup_peek('webview')

local function current_buffer_is_markdown()
  return vim.bo.filetype == 'markdown'
end

local function open_markdown_preview(app)
  if not current_buffer_is_markdown() then
    vim.notify('Peek only opens for markdown buffers', vim.log.levels.WARN)
    return
  end

  setup_peek(app)
  peek.open()
end

local function toggle_markdown_preview()
  if peek.is_open() then
    peek.close()
    return
  end

  open_markdown_preview('webview')
end

local function open_markdown_preview_browser()
  if peek.is_open() then peek.close() end
  open_markdown_preview('browser')
end

local function build_peek()
  if vim.fn.executable('deno') == 0 then
    vim.notify('Deno is required to build peek.nvim', vim.log.levels.ERROR)
    return
  end

  local plugin_dir = vim.fn.stdpath('data') .. '/site/pack/core/opt/peek.nvim'
  vim.notify('Building peek.nvim...')

  vim.system({ 'deno', 'task', '--quiet', 'build:fast' }, {
    cwd = plugin_dir,
    text = true,
  }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify('peek.nvim build complete')
      else
        vim.notify('peek.nvim build failed: ' .. (result.stderr or ''), vim.log.levels.ERROR)
      end
    end)
  end)
end

vim.api.nvim_create_user_command('PeekOpen', function() open_markdown_preview('webview') end, {})
vim.api.nvim_create_user_command('PeekClose', peek.close, {})
vim.api.nvim_create_user_command('PeekToggle', toggle_markdown_preview, {})
vim.api.nvim_create_user_command('PeekBuild', build_peek, {})
vim.api.nvim_create_user_command('PeekOpenBrowser', open_markdown_preview_browser, {})

map('n', '<leader>mp', toggle_markdown_preview, '[P]review markdown')
map('n', '<leader>mP', open_markdown_preview_browser, '[P]review markdown in browser')
