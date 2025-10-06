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
            "* Permission is hereby granted, free of charge, to any person obtaining a copy",
            '* of this software and associated documentation files (the "Software"), to deal',
            "* in the Software without restriction, including without limitation the rights",
            "* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell",
            "* copies of the Software, and to permit persons to whom the Software is",
            "* furnished to do so, subject to the following conditions:",
            "* The above copyright notice and this permission notice shall be included in all",
            "* copies or substantial portions of the Software.",
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
end)
