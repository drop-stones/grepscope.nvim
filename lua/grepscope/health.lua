local M = {}

function M.check()
  vim.health.start("grepscope.nvim")

  -- Check snacks.nvim
  local has_snacks = pcall(require, "snacks")
  if has_snacks then
    vim.health.ok("snacks.nvim is available")
  else
    vim.health.error("snacks.nvim is not available", { "Install snacks.nvim" })
  end

  -- Check snacks picker source config (user config is in Snacks.config.picker)
  if has_snacks then
    local picker_config = Snacks.config and Snacks.config.picker or {}
    local sources = picker_config.sources or {}
    local advice = "Add `config = function(opts) return require('grepscope').config(opts) end`"
    for _, source in ipairs({ "grep", "grep_word" }) do
      local has_config = sources[source] and sources[source].config
      if has_config then
        vim.health.ok("sources." .. source .. ".config is set")
      else
        vim.health.warn("sources." .. source .. ".config is not set", { advice .. " to opts.picker.sources." .. source })
      end
    end
  end

  -- Check storage directory
  local store_dir = vim.fn.stdpath("data") .. "/grepscope"
  if vim.fn.isdirectory(store_dir) == 1 then
    vim.health.ok("Storage directory exists: " .. store_dir)
  else
    vim.health.ok("Storage directory will be created on first save: " .. store_dir)
  end

  -- Show current project info
  local project = require("grepscope.project")
  local root = project.root()
  local key = project.key(root)
  vim.health.info("Project root: " .. root)
  vim.health.info("Project key: " .. key)

  -- Show current glob patterns
  local store = require("grepscope.store")
  local globs = store.load(root)
  if #globs > 0 then
    vim.health.info("Current globs: " .. table.concat(globs, " "))
  else
    vim.health.info("Current globs: (none)")
  end
end

return M
