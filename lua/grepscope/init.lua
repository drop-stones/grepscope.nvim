local M = {}

--- snacks picker source config function.
--- Set this as the `config` field in snacks picker source config.
---@param opts snacks.picker.Config
---@return snacks.picker.Config
function M.config(opts)
  return require("grepscope.picker").config(opts)
end

return M
