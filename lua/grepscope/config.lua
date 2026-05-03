local M = {}

---@class grepscope.Config
---@field key string Keybinding to edit glob filter inside picker
---@field root_markers string[] Markers for project root detection
local defaults = {
  key = "<C-e>",
  root_markers = {
    ".git",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "Makefile",
    ".hg",
  },
}

---@type grepscope.Config
M.values = vim.deepcopy(defaults)

---@param opts? grepscope.Config
function M.setup(opts)
  M.values = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
end

return M
