-- vim.pack.add({
--   'https://github.com/olimorris/codecompanion.nvim',
--   -- 'https://github.com/MeanderingProgrammer/render-markdown.nvim'
-- })

-- require('render-markdown').setup({
--   ft = { 'markdown', 'codecompanion' }
-- })

-- require('codecompanion').setup({
--   strategies = {
--     chat = {
--       adapter = 'anthropic',
--       model = 'claude-haiku-4-5-20251001',
--     },
--   },
--   opts = {
--     log_level = 'DEBUG',
--   },
-- })
--
-- map({ 'n', 'v' }, '<M-c>', '<CMD>CodeCompanionChat Toggle<CR>', 'Toggle AI [C]hat')
-- map('v', '<M-a>', '<CMD>CodeCompanionChat Add<CR>', '[A]dd selected text to chat')
-- map({ 'n', 'v' }, '<leader>ca', '<CMD>CodeCompanionActions<CR>', '[C]ode Companion [A]ctions')

-- api_key = 'ANTHROPIC_API_KEY',
-- claude-haiku-4-5-20251001
-- claude-sonnet-4-5-20250929
