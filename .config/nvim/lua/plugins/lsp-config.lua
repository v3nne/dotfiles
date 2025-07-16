local servers = {
  lua_ls = {},
  bashls = {},
  nil_ls = {},
  yamlls = {},
  terraformls = {},
  postgres_lsp = {},
  dockerls = {},
  tailwindcss = {},
  ts_ls = {},
  html = {},
  cssls = {},
  jsonls = {},
  eslint = {},
}




return {
  'neovim/nvim-lspconfig',
  dependencies = {
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {{ path = '${3rd}/luv/library', words = { 'vim%.uv' }}},
      },
    },
    {
      'j-hui/fidget.nvim',
      opts = {
        notification = { window = { winblend = 0 }}
      }
    },
    'saghen/blink.cmp',
    { 'mason-org/mason.nvim', opts = {} },
    { 'mason-org/mason-lspconfig.nvim', opts = {
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = false,
    }},
    { 'WhoIsSethDaniel/mason-tool-installer.nvim', opts = {
        ensure_installed = vim.tbl_keys(servers),
    }}
  },
  opts = {
    styles = { border = "single" }
  },
  config = function(_, opts)
    local lspconfig = require("lspconfig")
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    local on_attach = function (client, bufnr)
      local bufmap = function(keys, func, desc, mode)
        mode = mode or "n"
        vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
      end

      bufmap("K", function() vim.lsp.buf.hover(opts.styles) end, "Hover Documentation")
      bufmap("D", function() vim.diagnostic.open_float(opts.styles) end, "Diagnostic Message")

      bufmap("gd", vim.lsp.buf.definition,          "Goto Definition")
      bufmap("gD", vim.lsp.buf.declaration,         "Goto Declaration")
      bufmap("gr", vim.lsp.buf.references,          "Goto References")
      bufmap("<leader>rn", vim.lsp.buf.rename,      "Rename Variable")
      bufmap("<leader>ca", vim.lsp.buf.code_action, "Code Action", {"n", "v"})
    end


    vim.diagnostic.config({
      severity_sort = true,
      float = { border = 'single', source = 'if_many' },
    })


    for server, config in pairs(servers) do
      config = vim.tbl_deep_extend("force", {
        on_attach    = on_attach,
        capabilities = capabilities
      }, config)

      lspconfig[server].setup(config)
    end
  end
}
