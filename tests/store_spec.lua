local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local store = require("grepscope.store")

local T = new_set()

local tmpdir

T = new_set({
  hooks = {
    pre_case = function()
      tmpdir = vim.fn.tempname()
      vim.fn.mkdir(tmpdir, "p")
      -- Override stdpath("data") by patching store internals
      -- We test via a temporary project root instead
    end,
    post_case = function()
      if tmpdir then
        vim.fn.delete(tmpdir, "rf")
      end
    end,
  },
})

T["save and load"] = new_set()

T["save and load"]["round-trips glob patterns"] = function()
  local root = tmpdir .. "/my-project"
  store.save(root, { "*.ts", "!*.test.ts" })
  eq({ "*.ts", "!*.test.ts" }, store.load(root))
end

T["save and load"]["returns empty table when no file exists"] = function()
  local root = tmpdir .. "/nonexistent"
  eq({}, store.load(root))
end

T["save and load"]["handles empty globs"] = function()
  local root = tmpdir .. "/empty-project"
  store.save(root, {})
  eq({}, store.load(root))
end

T["save and load"]["overwrites previous patterns"] = function()
  local root = tmpdir .. "/overwrite-project"
  store.save(root, { "*.lua" })
  store.save(root, { "*.rs", "*.toml" })
  eq({ "*.rs", "*.toml" }, store.load(root))
end

T["load"] = new_set()

T["load"]["handles corrupted JSON gracefully"] = function()
  local project = require("grepscope.project")
  local key = project.key(tmpdir .. "/corrupt")
  local dir = vim.fn.stdpath("data") .. "/grepscope"
  vim.fn.mkdir(dir, "p")
  local path = dir .. "/" .. key .. ".json"
  local f = io.open(path, "w")
  f:write("not valid json{{{")
  f:close()
  eq({}, store.load(tmpdir .. "/corrupt"))
  -- Clean up
  os.remove(path)
end

T["load"]["handles wrong type for globs field"] = function()
  local project = require("grepscope.project")
  local key = project.key(tmpdir .. "/wrongtype")
  local dir = vim.fn.stdpath("data") .. "/grepscope"
  vim.fn.mkdir(dir, "p")
  local path = dir .. "/" .. key .. ".json"
  local f = io.open(path, "w")
  f:write(vim.json.encode({ globs = "not-a-table" }))
  f:close()
  eq({}, store.load(tmpdir .. "/wrongtype"))
  -- Clean up
  os.remove(path)
end

return T
