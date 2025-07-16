 return {
  -- use a dummy name; Lazy will treat it as a local plugin because of `dir`
  name = "lsp_config_picker",
  -- point at the directory containing your lua/ subfolder
  dir = vim.fn.stdpath('config'),
  -- only load once you actually call :LspConfig
  cmd = "LspConfig",
  config = function()
    require('lsp_config_picker').setup()
  end,
}
