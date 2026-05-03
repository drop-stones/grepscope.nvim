# grepscope.nvim

## Overview

A Neovim plugin that applies project-scoped, persistent glob patterns to the
snacks.nvim grep picker. Equivalent to VSCode's "files to include" field.

## Dependencies

- [snacks.nvim](https://github.com/folke/snacks.nvim) (required)
- Neovim >= 0.10 (for `vim.fs.root()`)
- No dependency on LazyVim or other frameworks

## Architecture

### Integration Approach

grepscope integrates via snacks' official `config` field in source config
(`snacks.picker.Config.config`). This is a function called by snacks every time
a picker opens, allowing dynamic injection of glob patterns. No monkey-patching
or wrapper functions needed.

The plugin has **no `setup()` function**. All configuration is done by the user
in their snacks picker source config. This keeps the plugin's responsibility
minimal and gives users full control.

### Core Flow

1. User opens a grep picker (via `<leader>sg`, dashboard "Find Text", etc.)
2. snacks calls `require("grepscope").config(opts)` (registered in source config)
3. grepscope loads saved glob patterns for the current project root
4. Injects patterns into `opts.glob` and updates `opts.title`
5. Registers `edit_filter` action for editing patterns via `vim.ui.input`
6. User presses keybind (configured by user, e.g., `<C-e>`) to edit glob filter
7. On confirm: save patterns, update glob/title in-place, call `picker:find()` (no restart)

### Key Design Decisions

- **No `setup()`, no wrapper functions**: The plugin exposes only `require("grepscope").config` — a snacks source config function. Users wire it into `opts.picker.sources.grep.config` in their snacks spec. This covers all grep callers (keymaps, dashboard, etc.) automatically.
- **Keybinding is the user's responsibility**: grepscope registers the `edit_filter` action, but does not bind any keys. Users set `win.input.keys` in their snacks source config. This avoids default key conflicts (e.g., `<C-g>` conflicts with snacks `toggle_live` and zellij).
- **No picker restart**: snacks picker supports in-place refresh via `picker.opts.glob` mutation + `picker:find()`. Title is updated via `picker.title` + `picker:update_titles()`.
- **`live_grep` is an alias for `grep`** in snacks. Overriding `sources.grep` covers both. Dashboard's "Find Text" (`Snacks.dashboard.pick('live_grep')`) also goes through the same config path.
- **`grep_buffers` is out of scope**: Buffer-only search doesn't benefit from file glob scoping.
- **Project root detection**: `vim.fs.root(cwd, markers)` from `vim.uv.cwd()`. NOT buffer-based (`vim.fs.root(0, ...)`), which would change when opening files in subprojects. Falls back to cwd if no markers found.
- **Base title from `opts.source`**: Always derived via `Snacks.picker.util.title(opts.source)`, never from `opts.title`. This prevents title duplication when snacks calls `config()`.

### Persistence

- **Path**: `stdpath("data")/grepscope/<project_key>.json`
- **Project key**: Project root path with path separators replaced by `%`
- **Project root**: `vim.fs.root(vim.uv.cwd(), markers)` with fallback to cwd
- **Root markers**: `.git`, `.hg`, `package.json`, `Cargo.toml`, `go.mod`, `Makefile`
- **Format**: `{ "globs": ["*.ts", "!*.test.ts"] }`

### Pattern Format

- Space-separated in UI (e.g., `*.ts !*.test.ts`)
- `!` prefix for exclude (passed as `-g !pattern` to rg via snacks)
- Stored as string array internally

### Public API

| Function | Description |
|---|---|
| `require("grepscope").config(opts)` | snacks source config function. Set as `config` field in `opts.picker.sources.grep` |

### File Structure

```
grepscope.nvim/
├── lua/
│   └── grepscope/
│       ├── init.lua       -- Public API: config()
│       ├── picker.lua     -- Source config function, title, edit_filter action
│       ├── project.lua    -- Project root detection + path-to-key conversion
│       └── store.lua      -- Persistence: read/write JSON
├── CLAUDE.md
└── LICENSE
```

### snacks Internals Reference

Glob injection: snacks passes each element of `opts.glob` as `-g <pattern>` to rg.
See: `snacks.nvim/lua/snacks/picker/source/grep.lua`.

Source config `config` field: `fun(opts: snacks.picker.Config): snacks.picker.Config?`
Called after all config layers are merged, once per picker open.
See: `snacks.nvim/lua/snacks/picker/config/init.lua` (`M.get()`).

Config merge order: `defaults` → `user global` → `source-specific` → `per-call opts` → `config()` functions.

## User Config Example (lazy.nvim)

```lua
-- lua/plugins/picker/grepscope.lua
local grepscope_config = function(opts)
  return require("grepscope").config(opts)
end

local grepscope_keys = {
  ["<C-e>"] = { "edit_filter", mode = { "i", "n" } },
}

return {
  {
    "drop-stones/grepscope.nvim",
    dir = "~/repos/nvim/grepscope.nvim",  -- for local dev
  },
  {
    "folke/snacks.nvim",
    dependencies = { "drop-stones/grepscope.nvim" },
    opts = {
      picker = {
        sources = {
          grep = { config = grepscope_config, win = { input = { keys = grepscope_keys } } },
          grep_word = { config = grepscope_config, win = { input = { keys = grepscope_keys } } },
        },
      },
    },
  },
}
```

## TODO

- **Tests**: Unit tests for `store`, `project.root()`, `project.key()`, `picker.parse_globs()`, `picker.title()`
- **README**: User-facing documentation (install, config examples, how it works)

## Coding Guidelines

- Keep code simple and minimal
- Write tests when feasible
- All code, comments, and docs in English
- No dependency on LazyVim or other frameworks
