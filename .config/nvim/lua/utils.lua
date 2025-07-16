local M = {}

---Takes an integer representation of a color
---hex value and turns it into hex code
---@param int integer
---@return string
M.int_to_hex = function(int)
  return string.format("#%06x", int)
end


return M
