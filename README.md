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
- Context-aware languages: Headers after shebangs (Bash/Python), PHP opening tags, encoding declarations, etc.

## Prerequisites

- Neovim 0.8+

## Installing

with [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({ "attilarepka/header.nvim", config = function() require("header").setup() end})
```

with [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "attilarepka/header.nvim",
    config = function()
        require("header").setup()
    end,
},
```

## Setup

The script comes with the following defaults:

```lua
{
    allow_autocmds = true,
    file_name = true,
    file_full_path = false,
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
    file_name_label = nil,
    author_label = nil,
    project_label = nil,
    date_created_label = nil,
    date_modified_label = nil,
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
    file_full_path = false,
    author = "Foo",
    project = "header.nvim",
    date_created = true,
    date_created_fmt = "%Y-%m-%d %H:%M:%S",
    date_modified = true,
    date_modified_fmt = "%Y-%m-%d %H:%M:%S",
    line_separator = "------",
    use_block_header = false,
    copyright_text = {
      "Copyright (c) 2026 Your Name",
      "Your Company",
      "All rights reserved."
    },
    license_from_file = false,
    author_from_git = false,
    file_name_label = nil,
    author_label = nil,
    project_label = nil,
    date_created_label = nil,
    date_modified_label = nil,
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

### Custom field labels

To override the default label text for any header field, use the corresponding `*_label` option:

```lua
require("header").setup({
    file_name_label = "File",
    author_label = "Author",
    project_label = "Project",
    date_created_label = "Created",
    date_modified_label = "Modified",
})
```
The `:` separator is appended automatically by the plugin.

When a `*_label` option is set to `nil` (the default), the built-in label is used.

### Project specific configuration

The default configuration can be overwritten by a local project `.header.nvim` file with the following format:

```json
{
  "allow_autocmds": true,
  "file_name": true,
  "file_full_path": false,
  "author": "Your Name",
  "project": "Your Project",
  "date_created": true,
  "date_created_fmt": "%Y-%m-%d %H:%M:%S",
  "date_modified": true,
  "date_modified_fmt": "%Y-%m-%d %H:%M:%S",
  "line_separator": "------",
  "use_block_header": true,
  "copyright_text": [
    "Copyright (c) 2026 Your Name",
    "Your Company",
    "All rights reserved."
  ]
}
```

### Keybindings

To setup custom keybindings:

```lua
local header = require("header")

vim.keymap.set("n", "<leader>hh", function() header.add_header() end)
-- see supported licenses below, method handles case-insensitively
vim.keymap.set("n", "<leader>hm", function() header.add_license_header("mit") end)
```

## Supported Languages

### Simple Languages

Headers are inserted at the beginning of the file (or after existing headers).

- C / C++
- Java
- JavaScript
- TypeScript
- C#
- Swift
- Kotlin
- Scala
- Go
- Rust
- Groovy
- Dart
- Lua
- Ruby
- Perl
- Haskell
- CoffeeScript
- R

---

### Context-Aware Languages

Headers are intelligently placed according to language-specific rules.

#### Bash / Shell (`sh`, `bash`, `zsh`)

Headers are inserted after the shebang:

```bash
#!/bin/bash
# Copyright (c) 2026 Your Name
# License information

echo "Hello, World!"
```

If no shebang exists, the header is placed at the top of the file.

---

#### Python (`py`)

Headers are inserted after the shebang and encoding declaration:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Your Name
# License information

import os
```

Both encoding declaration styles are supported:

```python
# coding: utf-8
```

```python
# -*- coding: utf-8 -*-
```

---

#### PHP (`php`)

Headers are inserted inside the PHP opening tag:

```php
<?php
/*
 * Copyright (c) 2026 Your Name
 * License information
 */

echo "Hello, World!";
```

If no PHP opening tag exists, insertion will fail to avoid generating invalid PHP files.

---

#### HTML (`html`)

Uses HTML comment syntax:

```html
<!--
Copyright (c) 2026 Your Name
License information
-->

<!DOCTYPE html>
```

## Commands

### Header

Insert or update the current file header:

```vim
:Header
```

### License Headers

Insert or update a license header:

```vim
:Header mit
:Header gpl3
:Header apache
```

License names are case-insensitive.

### Supported Licenses

- AGPL3
- Apache
- BSD2
- BSD3
- CC0
- GPL3
- ISC
- MIT
- MPL
- Unlicense
- WTFPL
- X11
- ZLIB

## Autocommands

### Update Headers Automatically on Save

Automatically insert or update headers whenever a file is saved:

```lua
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("header.nvim", { clear = true })

autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local header = require("header")

        if header and header.add_header then
            header.add_header()
        else
            vim.notify_once(
                "header.add_header is not available",
                vim.log.levels.WARN
            )
        end
    end,
    group = "header.nvim",
    desc = "Insert or update file header",
})
```

This will:
- insert a header if one does not exist
- update existing header metadata (such as modification dates)

---

### Automatically Add Headers to New Files

Automatically add a header when opening a new or empty file:

```lua
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("header.nvim", { clear = true })

autocmd({ "BufNewFile", "BufReadPost" }, {
    pattern = "*",
    callback = function()
        local header = require("header")

        if not header then
            vim.notify_once(
                "Could not automatically add header: header module not found",
                vim.log.levels.ERROR
            )
            return
        end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local is_empty = #lines == 1 and lines[1] == ""

        if header.config.allow_autocmds and is_empty then
            header.add_header()
        end
    end,
    group = "header.nvim",
    desc = "Automatically add header to new files",
})
```

## Contributing

Contributions are welcome!

Please open an issue before working on larger changes to avoid duplicated effort.

Pull requests are accepted for:
- Bug fixes
- Performance improvements
- New language support
- License/header improvements

### Tests

If your change affects header generation, license handling, or file parsing logic, please include tests or update existing ones.

Make sure all existing tests pass before submitting a PR.

### Development notes

- Keep changes minimal and focused
- Avoid breaking the public `:Header` API
- Prefer idempotent behavior (safe to run multiple times)

Open a GitHub [Issue](https://github.com/attilarepka/header.nvim/issues/new/choose) or [Pull request](https://github.com/attilarepka/header.nvim/pulls).

## License

This project is licensed under the [MIT license](LICENSE)
