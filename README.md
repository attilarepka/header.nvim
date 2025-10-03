# header.nvim

**Fast, minimal Neovim plugin to automatically add or update copyright and license headers in any programming language.**

![header.nvim demo](vhs/demo.gif)

## Features

- Add new copyright header
- Update existing copyright header
- Add common licenses, see [here](#adding-licenses)
- Use `LICENCE` file from git repository, see [here](#use-license-file-from-git-repository)
- Project specific configuration, see [here](#project-specific-configuration)
- Keybindings, see [here](#keybindings)

## Prerequisites

- Neovim 0.8+

## Installing

with [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({ "attilarepka/header.nvim", config = function() require("header").setup() end})
```

with [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{"attilarepka/header.nvim", config = true}
```

## Setup

The script comes with the following defaults:

```lua
{
    allow_autocmds = true,
    file_name = true,
    author = nil,
    project = nil,
    date_created = true,
    date_created_fmt = "%Y-%m-%d %H:%M:%S",
    date_modified = true,
    date_modified_fmt = "%Y-%m-%d %H:%M:%S",
    line_separator = nil,
    use_block_header = true,
    copyright_text = nil,
    license_from_file = false,
    author_from_git = false,
}
```

### Override configuration

To override the custom configuration, call:

```lua
require("header").setup({
  -- your override config
})
```

Example:

```lua
require("header").setup({
    allow_autocmds = true,
    file_name = true,
    author = "Foo",
    project = "header.nvim",
    date_created = true,
    date_created_fmt = "%Y-%m-%d %H:%M:%S",
    date_modified = true,
    date_modified_fmt = "%Y-%m-%d %H:%M:%S",
    line_separator = "------",
    use_block_header = false,
    copyright_text = {
      "Copyright (c) 2023 Your Name",
      "Your Company",
      "All rights reserved."
    },
    license_from_file = false,
    author_from_git = false,
})
```

### Use LICENSE file from git repository

To automatically include a license header from a `LICENSE`-style file from your Git repository, set `license_from_file` to `true`:

```lua
require("header").setup({
    ...
    license_from_file = true
})
```

When enabled, the plugin will scan your project root for license-related files.
If multiple candidates are found, you will be prompted to select one.
The selected file will be cached for the duration of your current Neovim session to avoid repeated prompts.

**Supported File Patterns**

The following file names are recognized:

- `LICENSE`, `LICENSE.md`, `LICENSE-*`
- `LICENCE`, `LICENCE.md`, `LICENCE-*` (British spelling)
- `COPYING`, `COPYING.md`
- `UNLICENSE`, `UNLICENSE.md`
- `NOTICE`, `NOTICE.md`
- `LEGAL`, `LEGAL.md`

> **⚠️ Matching is case-sensitive by default and limited to the top-level directory.**

**Notes:**
- This feature is useful when working on open-source projects that already include a license file.
- License headers inserted from a file will be commented automatically based on the current filetype.
- If you want to override the selected license file or insert a different one later, you can disable and re-enable the plugin, or restart Neovim.

### Project specific configuration

The default configuration can be overwritten by a local project `.header.nvim` file with the following format:

```json
{
  "allow_autocmds": true,
  "file_name": true,
  "author": "Your Name",
  "project": "Your Project",
  "date_created": true,
  "date_created_fmt": "%Y-%m-%d %H:%M:%S",
  "date_modified": true,
  "date_modified_fmt": "%Y-%m-%d %H:%M:%S",
  "line_separator": "------",
  "use_block_header": true,
  "copyright_text": [
    "Copyright (c) 2023 Your Name",
    "Your Company",
    "All rights reserved."
  ]
}
```

### Keybindings

To setup custom keybindings:

```lua
local header = require("header")

vim.keymap.set("n", "<leader>hh", function() header.add_headers() end)
-- see supported licenses below, method handles case-insensitively
vim.keymap.set("n", "<leader>hm", function() header.add_license_header("mit") end)
```

## Commands

### Adding Headers

- `:AddHeader` Adds brief copyright information

### Adding Licenses

- `:AddLicenseAGPL3` Adds **AGPL3 License**
- `:AddLicenseAPACHE` Adds **Apache License**
- `:AddLicenseBSD2` Adds **BSD2 License**
- `:AddLicenseBSD3` Adds **BSD3 License**
- `:AddLicenseCC0` Adds **CC0 License**
- `:AddLicenseGPL3` Adds **GPL3 License**
- `:AddLicenseISC` Adds **ISC License**
- `:AddLicenseMIT` Adds **MIT License**
- `:AddLicenseMPL` Adds **MPL License**
- `:AddLicenseUNLICENSE` Adds **Unlicense License**
- `:AddLicenseWTFPL` Adds **WTFPL License**
- `:AddLicenseX11` Adds **X11 License**
- `:AddLicenseZLIB` Adds **ZLIB License**

## Autocommand for update date modified when saving a file

```lua
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("mygroup", { clear = true })

autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local header = require("header")
        if header and header.update_date_modified then
            header.update_date_modified()
        else
            vim.notify_once("header.update_date_modified is not available", vim.log.levels.WARN)
        end
    end,
    group = "mygroup",
    desc = "Update header's date modified",
})
```

## Autocommand to add a header when entering an empty file, or creating a new file

```lua
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("mygroup", { clear = true })

autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = "*",
  callback = function()
    local header = require("header")
    if not header then
      vim.notify_once(
        "Could not automatically add header to new file: header module couldn't be found",
        vim.log.levels.ERROR
      )
      return
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local is_empty = #lines == 1 and lines[1] == ""

    if header.config.allow_autocmds and is_empty then
      local original_fmt = header.config.date_created_fmt
      local now = os.date(header.config.date_created_fmt, os.time())

      -- force add_headers to use the current datetime, otherwise it will show 1970-01-01
      header.config.date_created_fmt = now
      header.add_headers()

      header.config.date_created_fmt = original_fmt -- restore the original format
    end
  end,
  group = "mygroup",
  desc = "Add copyright header to new/empty files",
})

```

## Contributing

Contributions are welcome! Open a GitHub [Issue](https://github.com/attilarepka/header.nvim/issues/new/choose) or [Pull request](https://github.com/attilarepka/header.nvim/pulls).

## License

This project is licensed under the [MIT license](LICENSE)
