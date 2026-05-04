# grepscope.nvim

Project-scoped, persistent glob filters for [snacks.nvim](https://github.com/folke/snacks.nvim) grep picker.

![demo](https://raw.githubusercontent.com/wiki/drop-stones/grepscope.nvim/demo/demo.gif)

## ✨ Features

- 💾 **Persistent glob patterns** per project — set once, applied every time you grep
- ⚡ **In-place editing** — change filters without closing the picker
- 🔧 **No `setup()` needed** — integrates via snacks' source config, giving you full control
- 📁 **Project-aware** — glob patterns are stored per project root

## 📦 Requirements

- Neovim >= 0.10
- [snacks.nvim](https://github.com/folke/snacks.nvim)

## 🚀 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ "drop-stones/grepscope.nvim" },
{
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        grep = {
          config = function(opts) return require("grepscope").config(opts) end,
          win = { input = { keys = { ["<C-e>"] = { "edit_filter", mode = { "i", "n" } } } } },
        },
        grep_word = {
          config = function(opts) return require("grepscope").config(opts) end,
          win = { input = { keys = { ["<C-e>"] = { "edit_filter", mode = { "i", "n" } } } } },
        },
      },
    },
  },
}
```

> [!tip]
> Run `:checkhealth grepscope` to verify your setup.

## 🔤 Pattern Format

Patterns use [ripgrep](https://github.com/BurntSushi/ripgrep)'s
`-g` glob syntax. Multiple patterns are separated by spaces.

| Syntax | Meaning |
|---|---|
| `<glob>` | Include files matching the glob |
| `!<glob>` | Exclude files matching the glob |

### Examples

| Input | Effect |
|---|---|
| `*.lua` | Search only Lua files |
| `!*_spec.lua` | Exclude spec files |
| `*.lua !*_spec.lua` | Search Lua files, but exclude specs |

The active filter is shown in the picker title: `Grep [*.lua !*_spec.lua]`

To clear the filter, open the editor and submit an empty string.

## 🛠️ API

### `require("grepscope").config(opts)`

A snacks picker source config function. Set it as the `config` field in
`opts.picker.sources.grep` (and `grep_word`).

### `edit_filter` action

Registered automatically by `config()`. Bind it to a key in `win.input.keys`
to let users edit glob patterns inside the picker.

## 📄 License

MIT
