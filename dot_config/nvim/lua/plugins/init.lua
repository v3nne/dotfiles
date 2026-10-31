-- Auto-load all plugin configs
local plugin_dir = vim.fn.stdpath('config') .. '/lua/plugins'
local files = vim.fn.readdir(plugin_dir, function(item)
  return item:match('%.lua$') and item ~= 'init.lua'
end)

for _, file in ipairs(files) do
  local module = 'plugins.' .. file:gsub('%.lua$', '')
  require(module)
end
