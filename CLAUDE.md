# grepscope.nvim

## Overview

A Neovim plugin that applies project-scoped, persistent glob patterns to the
snacks.nvim grep picker. Equivalent to VSCode's "files to include" field.

## Dependencies

- [snacks.nvim](https://github.com/folke/snacks.nvim) (required)
- Neovim >= 0.10 (for `vim.fs.root()`)
- No dependency on LazyVim (must work standalone)

## Architecture

### Core Flow

1. User calls `require("grepscope").grep(opts)` or `require("grepscope").grep_word(opts)`
2. Load saved glob patterns for the current project (keyed by `vim.uv.cwd()`)
3. Inject patterns into snacks picker's `glob` option
4. Set picker title to show current patterns (e.g., `Grep [*.ts !*.test.ts]`)
5. Register `<C-e>` action inside the picker to edit patterns via `vim.ui.input`
6. On edit confirm: save patterns, update `picker.opts.glob`, update title, call `picker:find()` (NO restart needed)

### Key Design Decisions

- **No picker restart**: snacks picker supports in-place refresh via `picker.opts.glob` mutation + `picker:find()`. Title is updated via `picker.title` + `picker:update_titles()`.
- **Two wrapper functions**: `grep()` and `grep_word()` are both needed because `grep_word` has distinct options (`--word-regexp`, `regex=false`, `live=false`, pre-filled search). The glob injection logic is shared internally. `grep_buffers` is out of scope (buffer-only search doesn't benefit from file glob scoping).
- **Project identification via `vim.uv.cwd()`**: NOT `vim.fs.root()` or `LazyVim.root.get()`. Reason: buffer-based root detection (like `vim.fs.root(0, ...)`) changes when you open files in subprojects (e.g., opening `grepscope.nvim/init.lua` from `~/repos/nvim` would shift root to `grepscope.nvim`). Using `vim.uv.cwd()` is stable across buffer switches and only changes on explicit `:cd` commands. The `project.lua` module only handles key generation (path-to-filesystem-safe-string conversion), not root detection.
- **`<C-e>` as default key**: `<C-g>` is taken by snacks (`toggle_live`) and may conflict with terminal multiplexers like zellij. `<C-e>` is free in snacks picker input and stands for "edit filter".

### Persistence

- **Path**: `stdpath("data")/grepscope/<project_key>.json`
- **Project key**: `vim.uv.cwd()` with path separators replaced by `%` to be filesystem-safe
- **Format**: `{ "globs": ["*.ts", "!*.test.ts"] }`

### Pattern Format

- Space-separated in UI (e.g., `*.ts !*.test.ts`)
- `!` prefix for exclude (passed as `-g !pattern` to rg via snacks)
- Stored as string array internally

### Picker Integration (snacks internals)

Glob injection: snacks passes each element of `opts.glob` as `-g <pattern>` to rg.
See: `snacks.nvim/lua/snacks/picker/source/grep.lua` lines 62-67.

Custom action registration via `actions` + `win.input.keys`:
```lua
Snacks.picker.grep({
  title = "Grep [*.ts]",
  glob = { "*.ts" },
  actions = {
    edit_filter = function(picker) ... end,
  },
  win = {
    input = {
      keys = {
        ["<C-e>"] = { "edit_filter", mode = { "i", "n" } },
      },
    },
  },
})
```

### Setup Options

```lua
require("grepscope").setup({
  key = "<C-e>",         -- Keybinding to edit glob filter inside picker
  root_markers = {       -- Markers for project root detection (currently unused, reserved)
    ".git",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "Makefile",
    ".hg",
  },
})
```

### Public API

| Function | Description |
|---|---|
| `require("grepscope").setup(opts)` | Configure the plugin |
| `require("grepscope").grep(opts)` | Wrapper around `Snacks.picker.grep()` with glob injection |
| `require("grepscope").grep_word(opts)` | Wrapper around `Snacks.picker.grep_word()` with glob injection |

### File Structure

```
grepscope.nvim/
├── lua/
│   └── grepscope/
│       ├── init.lua       -- setup() and public API (grep, grep_word)
│       ├── config.lua     -- Default config, merged with user opts
│       ├── store.lua      -- Persistence: read/write JSON (takes cwd as argument)
│       ├── project.lua    -- Path-to-key conversion (filesystem-safe)
│       └── picker.lua     -- Snacks picker integration (glob injection, action, title, cwd resolution)
├── CLAUDE.md
└── LICENSE
```

## User's nvim-config Integration

Config location: `~/.config/nvim-config/lua/plugins/picker/grepscope.lua`
Uses `dir = "~/repos/nvim/grepscope.nvim"` for local development.

LazyVim grep keymaps overridden:
- `<leader>/` → `grepscope.grep()`
- `<leader>sg` / `<leader>sG` → `grepscope.grep()` (root / cwd)
- `<leader>sw` / `<leader>sW` → `grepscope.grep_word()` (root / cwd)

Dashboard "Find Text" (`g` key) is NOT yet overridden — it still calls `Snacks.dashboard.pick('live_grep')` directly. Future work: consider overriding snacks source config to inject globs at the source level.

## Future Considerations

- **Snacks source-level override**: Instead of wrapper functions, override `grep`/`grep_word`/`live_grep` source configs in snacks directly. This would cover dashboard and any other caller automatically.
- **Tests**: Add unit tests for `store`, `project.key()`, `picker.parse_globs()`, `picker.title()`.

## Coding Guidelines

- Keep code simple and minimal
- Write tests when feasible
- All code, comments, and docs in English
- No dependency on LazyVim or other frameworks
