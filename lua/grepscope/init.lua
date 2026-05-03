local M = {}

---@param opts? grepscope.Config
function M.setup(opts)
  require("grepscope.config").setup(opts)
end

---@param opts? table
function M.grep(opts)
  local picker = require("grepscope.picker")
  opts = picker.inject("Grep", opts)
  Snacks.picker.grep(opts)
end

---@param opts? table
function M.grep_word(opts)
  local picker = require("grepscope.picker")
  opts = picker.inject("Grep Word", opts)
  Snacks.picker.grep_word(opts)
end

return M
