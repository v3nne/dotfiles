vim.pack.add({ 'https://github.com/rmagatti/auto-session' })

local ignore_patterns = {
  "*clickhouse_data/",
  "*redis_data/",
  "*/node_modules/",
  "*/target/",
  "*.tmp",
  "*/.git/",
}


-- Function to check if a path matches any ignore pattern
local function should_ignore(filepath)
  if not filepath or filepath == "" then
    return false
  end

  for _, pattern in ipairs(ignore_patterns) do
    -- Convert glob pattern to Lua pattern
    local lua_pattern = pattern:gsub("%*", ".*"):gsub("%-", "%%-")
    if filepath:match(lua_pattern) then
      return true
    end
  end

  return false
end


-- Function to close ignored buffers
local function close_ignored_buffers()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local bufname = vim.api.nvim_buf_get_name(buf)
      if should_ignore(bufname) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
end


require('auto-session').setup({
  suppressed_dirs = {
    "/",
    "~/",
    "~/Projects",
    "~/Downloads",
    "/Users/venne/dev/work/repos/ta-stocks-be/redis_data",
    "/Users/venne/dev/work/repos/ta-stocks-be/clickhouse_data"
  },
  -- pre_save_cmds = { close_ignored_buffers }
})

