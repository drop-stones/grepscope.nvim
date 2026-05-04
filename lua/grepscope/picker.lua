local project = require("grepscope.project")
local store = require("grepscope.store")

local M = {}

--- Build a title string from the base title and glob patterns.
---@param base string
---@param globs string[]
---@return string
function M.title(base, globs)
  if #globs == 0 then
    return base
  end
  return base .. " [" .. table.concat(globs, " ") .. "]"
end

--- Parse a space-separated glob string into a list.
---@param input string
---@return string[]
function M.parse_globs(input)
  local globs = {}
  for g in input:gmatch("%S+") do
    globs[#globs + 1] = g
  end
  return globs
end

--- Create the edit_filter action for the picker.
---@param cwd string
---@param base_title string
---@param globs string[] current globs (mutable reference)
---@return fun(picker: any)
function M.edit_filter_action(cwd, base_title, globs)
  return function(picker)
    local initial = table.concat(globs, " ")
    vim.ui.input({ prompt = "Glob filter: ", default = initial }, function(input)
      if input == nil then
        return
      end
      local new_globs = M.parse_globs(input)

      -- Update globs in-place
      for i = #globs, 1, -1 do
        globs[i] = nil
      end
      for i, g in ipairs(new_globs) do
        globs[i] = g
      end

      store.save(cwd, new_globs)
      picker.opts.glob = #new_globs > 0 and new_globs or nil
      picker.title = M.title(base_title, new_globs)
      picker:update_titles()
      picker:find()
    end)
  end
end

--- Resolve the project root for storage.
---@return string
function M.resolve_root()
  return project.root()
end

--- snacks picker source config function.
--- Dynamically injects glob patterns, title, and edit_filter action.
--- Intended to be set as the `config` field in snacks source config.
---@param opts snacks.picker.Config
---@return snacks.picker.Config
function M.config(opts)
  local root = M.resolve_root()
  local globs = store.load(root)
  local base_title = Snacks.picker.util.title(opts.source or "grep")

  opts.title = M.title(base_title, globs)
  opts.glob = #globs > 0 and globs or nil

  opts.actions = opts.actions or {}
  opts.actions.edit_filter = M.edit_filter_action(root, base_title, globs)

  return opts
end

return M
