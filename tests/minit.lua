#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"

local lazy_bootstrap_url =
	"https://raw.githubusercontent.com/folke/lazy.nvim/306a05526ada86a7b30af95c5cc81ffba93fef97/bootstrap.lua"
local bootstrap = vim.fn.system({ "curl", "-fsSL", lazy_bootstrap_url })
if vim.v.shell_error ~= 0 or not bootstrap or bootstrap == "" then
	error("Failed to download lazy.nvim bootstrap from: " .. lazy_bootstrap_url, 0)
end
local bootstrap_fn, load_err = load(bootstrap, "bootstrap.lua")
if not bootstrap_fn then
	error("Failed to load lazy.nvim bootstrap: " .. tostring(load_err), 0)
end
bootstrap_fn()

require("lazy.minit").setup({
	spec = {
		{
			"echasnovski/mini.test",
			opts = {
				collect = {
					find_files = function()
						return #_G.arg > 0 and _G.arg or vim.fn.globpath("tests", "**/*_spec.lua", true, true)
					end,
				},
			},
		},
		{ dir = vim.uv.cwd() },
	},
})

require("mini.test").run()
