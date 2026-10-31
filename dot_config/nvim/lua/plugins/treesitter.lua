local languages = {
  'bash',
  'python',
  'ruby',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
  'vue',
  'typescript',
  'tsx',
  'javascript',
  'css',
  'scss',
  'json',
  'yaml',
}

vim.pack.add({ {
  src = 'https://github.com/nvim-treesitter/nvim-treesitter',
  version = 'main',
} })

local ok, treesitter = pcall(require, 'nvim-treesitter')
if not ok or type(treesitter.setup) ~= 'function' or type(treesitter.install) ~= 'function' then
  vim.notify(
    'nvim-treesitter is still on the incompatible master branch; run '
      .. ':lua vim.pack.update({ "nvim-treesitter" }) and approve the update',
    vim.log.levels.ERROR
  )
  return
end

treesitter.setup({
  install_dir = vim.fn.stdpath('data') .. '/site',
})
treesitter.install(languages)

local installed_languages = {}
for _, language in ipairs(languages) do
  installed_languages[language] = true
end

local language_aliases = {
  sh = 'bash',
  typescriptreact = 'tsx',
}

vim.api.nvim_create_autocmd('FileType', {
  callback = function(event)
    local filetype = vim.bo[event.buf].filetype
    if filetype:find('chezmoitmpl', 1, true) then return end

    local language = language_aliases[filetype] or vim.treesitter.language.get_lang(filetype)
    if not installed_languages[language] then return end

    if filetype ~= 'ruby' then
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    local parser = vim.treesitter.get_parser(event.buf, language)
    if not parser then return end

    vim.treesitter.start(event.buf, language)
  end,
})
