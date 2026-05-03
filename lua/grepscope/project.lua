local M = {}

--- Convert a path to a filesystem-safe key.
---@param path string
---@return string
function M.key(path)
  local key = path:gsub("[/\\:]+", "%%")
  key = key:gsub("^%%+", ""):gsub("%%+$", "")
  return key
end

return M
