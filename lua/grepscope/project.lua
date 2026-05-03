local M = {}

--- Default markers for project root detection.
M.root_markers = { ".git", ".hg", "package.json", "Cargo.toml", "go.mod", "Makefile" }

--- Find the project root from cwd.
--- Uses vim.fs.root() with root_markers, falls back to cwd.
---@return string
function M.root()
  local cwd = vim.uv.cwd() or "."
  return vim.fs.root(cwd, M.root_markers) or cwd
end

--- Convert a path to a filesystem-safe key.
---@param path string
---@return string
function M.key(path)
  local key = path:gsub("[/\\:]+", "%%")
  key = key:gsub("^%%+", ""):gsub("%%+$", "")
  return key
end

return M
