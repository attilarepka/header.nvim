# header.nvim

**header.nvim is a Neovim plugin which adds or updates brief author information
and license headers to the top of the files.**

[![Build status](https://github.com/attilarepka/header.nvim/actions/workflows/tests.yml/badge.svg)](https://github.com/attilarepka/header.nvim/actions)

## Demo

https://github.com/attilarepka/header.nvim/assets/39063661/2fa7f325-407a-42c1-9db5-75c138f4a6ea

## Features

- Add new copyright header
- Update existing copyright header
- Add common licenses

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
    file_name = true,
    author = nil,
    project = nil,
    date_created = true,
    date_created_fmt = "%Y-%m-%d %H:%M:%S",
    date_modified = true,
    date_modified_fmt = "%Y-%m-%d %H:%M:%S",
    line_separator = "------",
    copyright_text = nil,
}
```

To override the custom configuration, call:

```lua
require("header").setup({
  -- your override config
})
```

Example:

```lua
require("header").setup({
    file_name = true,
    author = "Foo",
    project = "header.nvim",
    date_created = true,
    date_created_fmt = "%Y-%m-%d %H:%M:%S",
    date_modified = true,
    date_modified_fmt = "%Y-%m-%d %H:%M:%S",
    line_separator = "------",
    copyright_text = "Copyright 2023",
})
```

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

### Autocommand for update date modified when saving a file

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

## Contributing

Contributions are welcome! Open a GitHub issue or pull request.

## License

This project is licensed under the [MIT license](LICENSE)
