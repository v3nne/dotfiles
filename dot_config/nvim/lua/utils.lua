local M = {}

---@param m string|table
---@param lhs string
---@param rhs string|function
---@param desc? string
function M.map(m, lhs, rhs, desc)
  local opts = { noremap = true, silent = true }

  if desc and desc ~= '' then
    opts.desc = desc
  end

  vim.keymap.set(m, lhs, rhs, opts)
end

function M.in_zellij()
  return vim.env.ZELLIJ ~= nil and vim.fn.executable('zellij') == 1
end

function M.zellij_action(...)
  if not M.in_zellij() then return false end

  local cmd = { 'zellij', 'action' }
  vim.list_extend(cmd, { ... })

  return vim.fn.jobstart(cmd, { detach = true }) > 0
end

local tmux_flags = { H = '-L 4', L = '-R 4', K = '-U 2', J = '-D 2' }
local zellij_resize = { H = 'left', L = 'right', K = 'up', J = 'down' }
local nvim_resize = {
  H = function()
    if vim.fn.winnr() ~= vim.fn.winnr('h') then
      return 'vertical resize +4'
    else
      return 'vertical resize -4'
    end
  end,
  L = function()
    if vim.fn.winnr() ~= vim.fn.winnr('l') then
      return 'vertical resize +4'
    else
      return 'vertical resize -4'
    end
  end,
  K = function()
    local cur = vim.fn.winnr()
    if cur ~= vim.fn.winnr('k') then return 'resize +2' end
    if cur ~= vim.fn.winnr('j') then return 'resize -2' end
  end,
  J = function()
    local cur = vim.fn.winnr()
    if cur ~= vim.fn.winnr('j') then return 'resize +2' end
    if cur ~= vim.fn.winnr('k') then return 'resize -2' end
  end,
}

function M.smart_resize(key)
  if vim.fn.winnr('$') > 1 then
    local cmd = nvim_resize[key]()
    if cmd then
      vim.cmd(cmd)
      return
    end
  end

  if M.in_zellij() then
    M.zellij_action('resize', 'increase', zellij_resize[key])
  elseif vim.env.TMUX ~= nil then
    vim.fn.system('tmux resize-pane ' .. tmux_flags[key])
  end
end

return M
