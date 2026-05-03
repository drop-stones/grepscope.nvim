local project = require("grepscope.project")

local M = {}

--- Get the storage directory path.
---@return string
local function store_dir()
  return vim.fn.stdpath("data") .. "/grepscope"
end

--- Get the storage file path for a given project root.
---@param root string
---@return string
local function store_path(root)
  local key = project.key(root)
  return store_dir() .. "/" .. key .. ".json"
end

--- Load glob patterns for the given project root.
---@param root string
---@return string[]
function M.load(root)
  local path = store_path(root)
  local f = io.open(path, "r")
  if not f then
    return {}
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if ok and data and data.globs then
    return data.globs
  end
  return {}
end

--- Save glob patterns for the given project root.
---@param root string
---@param globs string[]
function M.save(root, globs)
  local dir = store_dir()
  vim.fn.mkdir(dir, "p")
  local path = store_path(root)
  local f = io.open(path, "w")
  if not f then
    vim.notify("[grepscope] Failed to write " .. path, vim.log.levels.ERROR)
    return
  end
  f:write(vim.json.encode({ globs = globs }))
  f:close()
end

return M
