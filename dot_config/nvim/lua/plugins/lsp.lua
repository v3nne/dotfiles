vim.pack.add({
  'https://github.com/folke/lazydev.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/saghen/blink.cmp',
})

require('lazydev').setup({})
require('mason').setup({
  ui = {
    backdrop = 60,
    border = 'single'
  }
})
require('mason-lspconfig').setup({})
require('mason-tool-installer').setup({})
require('fidget').setup({
  progress = {
    display = {
      render_limit = 1,
      done_ttl = 0,
      progress_icon = { pattern = "dots_pulse", period = 1 },
    },
  },
  notification = {
    window = {
      border = "none",
      -- max_width = 20,
      max_height = 1,
      x_padding = 1,
      y_padding = 0,
    },
  },
})
-- {
--   progress = {
--     display = {
--       render_limit = 1,          -- Show only one progress item at a time
--       done_ttl = 0,              -- Remove completed items immediately
--       done_icon = "",            -- No icon when done
--       done_style = "Comment",    -- Style for completed items
--       progress_ttl = math.huge,  -- Keep progress items until done
--       progress_icon = { pattern = "dots", period = 1 }, -- Simple dots spinner
--       progress_style = "Comment",
--       group_style = "Comment",
--       icon_style = "Comment",
--       priority = 30,
--     },
--     ignore = {},
--   },
--   notification = {
--     window = {
--       normal_hl = "Comment",     -- Use comment highlight for less visibility
--       winblend = 0,              -- No transparency
--       border = "none",           -- No border
--       zindex = 45,
--       max_width = 0,             -- Minimal width
--       max_height = 0,            -- Minimal height
--       x_padding = 0,
--       y_padding = 0,
--       align = "bottom",
--       relative = "editor",
--     },
--     view = {
--       stack_upwards = false,
--       icon_separator = "",       -- No separator
--       group_separator = "",      -- No group separator
--       group_separator_hl = "Comment",
--     },
--   },
-- }
require('blink.cmp').setup({})



--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated with
--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--    function will be executed to configure the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('based-lsp-attach', { clear = true }),
  callback = function(event)
    local lsp = vim.lsp
    local lmap = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    lmap('K', function() lsp.buf.hover { border = 'single' } end, 'Hover')

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    lmap('<leader>r', lsp.buf.rename, '[R]ename variable')

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    lmap('ga', lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

    -- Find references for the word under your cursor.
    lmap('gr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')

    -- Jump to the implementation of the word under your cursor.
    --  Useful when your language has ways of declaring types without an actual implementation.
    lmap('gi', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')

    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a function is defined, etc.
    --  To jump back, press <C-t>.
    lmap('gd', function()
      require('fzf-lua').lsp_definitions()
      -- vim.schedule(function() vim.cmd('normal! zt') end) -- Run `zt` after gd
    end, '[G]oto [D]efinition')

    lmap('gV', function()
      vim.cmd('vsplit')
      require('fzf-lua').lsp_definitions()
    end, '[G]oto Definition in [V]ertical Split')

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    lmap('gD', lsp.buf.declaration, '[G]oto [D]eclaration')

    -- Fuzzy find all the symbols in your current document.
    --  Symbols are things like variables, functions, types, etc.
    lmap('gO', require('fzf-lua').lsp_document_symbols, 'Open Document Symbols')

    -- Fuzzy find all the symbols in your current workspace.
    --  Similar to document symbols, except searches over your entire project.
    lmap('gW', require('fzf-lua').lsp_workspace_symbols, 'Open Workspace Symbols')

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    lmap('gt', require('fzf-lua').lsp_typedefs, '[G]oto [T]ype Definition')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = lsp.get_client_by_id(event.data.client_id)
    local methods = lsp.protocol.Methods

    if client and client:supports_method(methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('based-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('based-lsp-detach', { clear = true }),
        callback = function(event2)
          lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'based-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client:supports_method(methods.textDocument_inlayHint, event.buf) then
      lmap('<leader>th', function()
        lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})


-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'single', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = {
    text = {
      -- [vim.diagnostic.severity.ERROR] = ' ',
      -- [vim.diagnostic.severity.WARN] = ' ',
      -- [vim.diagnostic.severity.INFO] = ' ',
      -- [vim.diagnostic.severity.HINT] = '󰌵 ',
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

local capabilities = require('blink.cmp').get_lsp_capabilities()

--  Add any additional override configuration in the following tables. Available keys are:
--  - cmd (table): Override the default command used to start the server
--  - filetypes (table): Override the default list of associated filetypes for the server
--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
--  - settings (table): Override the default settings passed when initializing the server.
--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
local servers = {
  clangd = {},
  -- gopls = {},
  -- rust_analyzer = {},
  -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
  --
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls`) will work just fine
  -- ts_ls = {},
  --

  lua_ls = {
    -- cmd = { ... },
    -- filetypes = { ... },
    -- capabilities = {},
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
  pyright = {},
  ts_ls = {},
  vue_ls = {
    -- filetypes = { 'vue', 'typescript', 'javascript' },
    -- init_options = {
    --   vue = {
    --     hybridMode = false,
    --   },
    -- },
  },
  terraformls = {},
  gopls = {},
  jdtls = {},
}

-- Ensure the servers and tools above are installed
--
-- To check the current status of installed tools and/or manually install
-- other tools, you can run
--    :Mason
--
-- You can press `g?` for help in this menu.
--
-- `mason` had to be setup earlier: to configure its options see the
-- `dependencies` table for `nvim-lspconfig` above.
--
-- You can add other tools here that you want Mason to install
-- for you, so that they are available from within Neovim.
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- 'stylua', -- Used to format Lua code
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

require('mason-lspconfig').setup {
  ensure_installed = {}, -- explicitly set to an empty table (Based.nvim populates installs via mason-tool-installer)
  automatic_installation = false,
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      -- This handles overriding only values explicitly passed
      -- by the server configuration above. Useful when disabling
      -- certain features of an LSP (for example, turning off formatting for ts_ls)
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      require('lspconfig')[server_name].setup(server)
    end,
  },
}

