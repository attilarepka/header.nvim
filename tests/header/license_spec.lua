require("plenary.reload").reload_module("header", true)
local header = require("header")

describe("add_license_header", function()
    before_each(function() header.reset() end)

    it("should insert mit header to cpp file", function()
        local config = { author = "test_author" }
        header.setup(config)

        vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        local file_name = "main.cc"
        vim.fn.setline(1, file_name)
        vim.api.nvim_buf_set_name(0, file_name)

        header.add_license_header("mit")
        local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        local current_year = os.date("%Y")
        local expected = {
            "/*",
            "* Copyright (c) " .. current_year .. " " .. config.author,
            "* ",
            "* Permission is hereby granted, free of charge, to any person obtaining a copy",
            '* of this software and associated documentation files (the "Software"), to deal',
            "* in the Software without restriction, including without limitation the rights",
            "* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell",
            "* copies of the Software, and to permit persons to whom the Software is",
            "* furnished to do so, subject to the following conditions:",
            "* ",
            "* The above copyright notice and this permission notice shall be included in all",
            "* copies or substantial portions of the Software.",
            "* ",
            '* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,',
            "* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF",
            "* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.",
            "* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,",
            "* DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR",
            "* OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE",
            "* OR OTHER DEALINGS IN THE SOFTWARE.",
            "*/",
            "",
            file_name,
        }

        assert.are.same(expected, buffer)
    end)

    it("should replace existing header with license header", function()
        local config = { author = "test_author" }
        header.setup(config)

        vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        local file_name = "main.py"
        vim.fn.setline(1, file_name)
        vim.api.nvim_buf_set_name(0, file_name)

        header.add_header()

        local buffer_with_header = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        assert.is_true(#buffer_with_header > 0)
        assert.is_true(buffer_with_header[1]:find("main.py") ~= nil)

        header.add_license_header("mit")

        local buffer_with_license = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        local has_old_header = false
        for _, line in ipairs(buffer_with_license) do
            if line:find("File name:") then
                has_old_header = true
                break
            end
        end
        assert.is_false(has_old_header, "Old header should be removed when adding license")

        local has_license = false
        for _, line in ipairs(buffer_with_license) do
            if line:find("Permission is hereby granted") then
                has_license = true
                break
            end
        end
        assert.is_true(has_license, "License text should be present")

        assert.are.equal(file_name, buffer_with_license[#buffer_with_license])
    end)

    it("should replace header with license in context-aware language (python with shebang)", function()
        local config = { author = "test_author" }
        header.setup(config)

        vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        local file_name = "script.py"
        vim.fn.setline(1, file_name)
        vim.api.nvim_buf_set_name(0, file_name)

        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            "#!/usr/bin/env python3",
            "# File name: script.py",
            "# Date created: 2026-01-01",
            "# ------",
            "",
            "import os",
            "print('hello')",
        })

        header.add_license_header("mit")

        local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        assert.are.equal("#!/usr/bin/env python3", buffer[1])

        assert.is_true(buffer[2]:find("Copyright") ~= nil or buffer[2]:find("#") ~= nil)

        local has_old_header = false
        for _, line in ipairs(buffer) do
            if line:find("File name:") then
                has_old_header = true
                break
            end
        end
        assert.is_false(has_old_header, "Old header should be removed")

        local has_import = false
        for _, line in ipairs(buffer) do
            if line:find("import os") then
                has_import = true
                break
            end
        end
        assert.is_true(has_import, "Original code should be preserved")
    end)
end)
