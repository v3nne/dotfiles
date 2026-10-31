vim.pack.add({
  'https://github.com/coder/claudecode.nvim',
  'https://github.com/folke/snacks.nvim',
})

-- Only enable the terminal module; disable everything else to avoid
-- conflicting with existing alternatives.
require('snacks').setup({
  terminal    = {},
  animate     = { enabled = false },
  bigfile     = { enabled = false },
  bufdelete   = { enabled = false },
  dashboard   = { enabled = false },
  debug       = { enabled = false },
  dim         = { enabled = false },
  explorer    = { enabled = false },
  git         = { enabled = false },
  gitbrowse   = { enabled = false },
  image       = { enabled = false },
  indent      = { enabled = false },
  input       = { enabled = false },
  lazygit     = {},
  notifier    = { enabled = false },
  picker      = { enabled = false },
  profiler    = { enabled = false },
  quickfile   = { enabled = false },
  rename      = { enabled = false },
  scope       = { enabled = false },
  scratch     = { enabled = false },
  scroll      = { enabled = false },
  statuscolumn = { enabled = false },
  toggle      = { enabled = false },
  words       = { enabled = false },
  zen         = { enabled = false },
})

require('claudecode').setup({
  terminal_cmd = 'claude',
  terminal = {
    provider = 'snacks',
    split_side = 'right',
    split_width_percentage = 0.4,
    auto_close = false,
    show_native_term_exit_tip = true,
    env = {},
    snacks_win_opts = {},
  },
  diff_opts = {
    layout                = 'vertical',
    open_in_new_tab       = true,
    keep_terminal_focus   = false,
    hide_terminal_in_new_tab = true,
    on_new_file_reject    = 'keep_empty',
  },
})

map('n', '<M-c>', '<CMD>ClaudeCode<CR>', 'Claude Code Toggle')
map('v', '<leader>cs', '<CMD>ClaudeCodeSend<CR>', 'Claude Code [S]end selection')
map('n', '<leader>cf', '<CMD>ClaudeCodeAdd %<CR>', 'Claude Code add current [F]ile')
map('n', '<leader>cr', '<cmd>ClaudeCode --resume<cr>', '[R]esume Claude')
map('n', '<leader>cC', '<cmd>ClaudeCode --continue<cr>', '[C]ontinue Claude')
map('n', '<leader>cm', '<cmd>ClaudeCodeSelectModel<cr>', 'Select Claude [M]odel')


local smart_resize = require('utils').smart_resize

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(args)
    if not vim.api.nvim_buf_get_name(args.buf):match('claude') then return end
    local buf = args.buf
    local function bmap(lhs, rhs)
      vim.keymap.set('t', lhs, rhs, { buffer = buf, silent = true })
    end
    bmap('<M-h>', '<Cmd>TmuxNavigateLeft<CR>')
    bmap('<M-j>', '<Cmd>TmuxNavigateDown<CR>')
    bmap('<M-k>', '<Cmd>TmuxNavigateUp<CR>')
    bmap('<M-l>', '<Cmd>TmuxNavigateRight<CR>')
    bmap('<M-\\>', '<Cmd>TmuxNavigatePrevious<CR>')
    bmap('<M-H>', function() smart_resize('H') end)
    bmap('<M-L>', function() smart_resize('L') end)
    bmap('<M-K>', function() smart_resize('K') end)
    bmap('<M-J>', function() smart_resize('J') end)

    bmap('<M-c>', '<CMD>ClaudeCode<CR>')
  end,
})


-- Lualine components -------------------------------------------------------

local function is_not_claude()
  return not vim.api.nvim_buf_get_name(0):match('^term://.*claude')
end

-- Read per-session state written by ~/.claude/statusline-command.sh (keyed by
-- the Claude process PID, which equals the terminal job's PID).
---@class ClaudeState
---@field session_id string
---@field transcript_path string
---@field cwd string
---@field session_name string
---@field model { id: string, display_name: string }
---@field workspace { current_dir: string, project_dir: string, added_dirs: table }
---@field version string
---@field output_style { name: string }
---@field cost { total_cost_usd: number, total_duration_ms: number, total_api_duration_ms: number, total_lines_added: number, total_lines_removed: number }
---@field context_window { total_input_tokens: number, total_output_tokens: number, context_window_size: number, current_usage: { input_tokens: number, output_tokens: number, cache_creation_input_tokens: number, cache_read_input_tokens: number }, used_percentage: number, remaining_percentage: number }
---@field exceeds_200k_tokens boolean
---@field rate_limits { five_hour: { used_percentage: number, resets_at: number }, seven_day: { used_percentage: number, resets_at: number } }

---@return ClaudeState | nil
local function get_claude_state()
  local chan = vim.bo.channel
  if not chan or chan == 0 then return nil end
  local ok_pid, pid = pcall(vim.fn.jobpid, chan)
  if not ok_pid or not pid or pid == 0 then return nil end

  local f = io.open('/tmp/claude-nvim/' .. pid .. '.json', 'r')
  if not f then return nil end
  local contents = f:read('*a')
  f:close()

  local ok, data = pcall(vim.json.decode, contents)
  if not ok then return nil end
  return data
end

local function claude_model()
  if is_not_claude() then return '' end
  local data = get_claude_state()
  if data and data.model then
    return data.model.display_name or data.model.id or ''
  end
  return ''
end

local spinner_frames = { "", "", "", "", "", "" } -- don't remove this!

local function claude_session_usage()
  if is_not_claude() then return '' end
  local state = get_claude_state()
  if state and state.rate_limits and state.rate_limits.five_hour and state.rate_limits.five_hour.used_percentage ~= nil then
    local rl = state.rate_limits.five_hour
    local result = rl.used_percentage .. '%%'
    if rl.resets_at and rl.resets_at ~= vim.NIL then
      result = result .. ' │ ' .. os.date('%H:%M', rl.resets_at)
    end
    return result
  end
  local idx = math.floor(vim.loop.hrtime() / 1e9) % #spinner_frames + 1
  return spinner_frames[idx]
end

local function claude_context_usage()
  if is_not_claude() then return '' end
  local state = get_claude_state()
  if state and state.context_window then
    local value = state.context_window.used_percentage
    if value ~= nil and value ~= vim.NIL then
      return value .. '%%'
    end
  end
  return '0%%'
end

local function claude_title()
  if is_not_claude() then return '' end
  if vim.b.term_title:match('^term://.*claude') then return '' end
  return vim.b.term_title or ''
end

return {
  is_not_claude = is_not_claude,
  model         = claude_model,
  session_usage = claude_session_usage,
  context_usage = claude_context_usage,
  title         = claude_title,
}
