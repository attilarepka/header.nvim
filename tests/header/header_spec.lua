require("plenary.reload").reload_module("header", true)
local header = require("header")

local function get_buffer_without_date(buffer, comments, constants)
    result = {}
    for _, line in ipairs(buffer) do
        if not line:match("^%" .. comments.comment .. " " .. constants.date_created) then
            table.insert(result, line)
        end
    end
    return result
end

local function build_minimal_expected_comments(file_name, comments, header)
    local result = {
        comments.comment .. " " .. header.constants.file_name .. " " .. file_name,
        comments.comment .. " " .. header.config.line_separator,
        "",
        file_name,
    }

    if comments.comment_start ~= nil then
        result = {
            comments.comment_start,
            comments.comment .. " " .. header.constants.file_name .. " " .. file_name,
            comments.comment .. " " .. header.config.line_separator,
            comments.comment_end,
            "",
            file_name,
        }
    end
    return result
end

local function build_extended_expected_comments(file_name, comments, constants, config)
    local result = {
        comments.comment .. " " .. constants.file_name .. " " .. file_name,
        comments.comment .. " " .. constants.project .. " " .. config.project,
        comments.comment .. " " .. constants.author .. " " .. config.author,
        comments.comment .. " " .. config.line_separator,
        comments.comment .. " " .. config.copyright_text,
        "",
        file_name,
    }

    if comments.comment_start ~= nil then
        result = {
            comments.comment_start,
            comments.comment .. " " .. constants.file_name .. " " .. file_name,
            comments.comment .. " " .. constants.project .. " " .. config.project,
            comments.comment .. " " .. constants.author .. " " .. config.author,
            comments.comment .. " " .. config.line_separator,
            comments.comment .. " " .. config.copyright_text,
            comments.comment_end,
            "",
            file_name,
        }
    end
    return result
end

describe("setup", function()
    before_each(function()
        header.reset()
    end)
    it("setup with default configs", function()
        local expected = {
            file_name = true,
            author = nil,
            project = nil,
            date_created = true,
            date_created_fmt = "%Y-%m-%d %H:%M:%S",
            line_separator = "------",
            copyright_text = nil,
        }
        header.setup()
        assert.are.same(expected, header.config)
    end)

    it("setup with custom configs", function()
        local expected = {
            file_name = true,
            author = "test_author",
            project = "test_project",
            date_created = true,
            date_created_fmt = "%Y-%m-%d %H:%M:%S",
            line_separator = "------",
            copyright_text = "test_copyright",
        }
        header.setup(expected)
        assert.are.same(expected, header.config)
    end)
end)

describe("add_headers", function()
    before_each(function()
        header.reset()
    end)
    it("should insert headers to file depending on file type", function()
        local filetypes = require("filetypes")
        for k, v in pairs(filetypes) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. k
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            header.add_headers()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            local comments = v()

            local expected = build_minimal_expected_comments(file_name, comments, header)

            local buffer_without_date = get_buffer_without_date(buffer, comments, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)
    it("should insert headers via autocommand", function()
        local filetypes = require("filetypes")
        for k, v in pairs(filetypes) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. k
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            vim.api.nvim_command("AddHeader")

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            local comments = v()

            local expected = build_minimal_expected_comments(file_name, comments, header)

            local buffer_without_date = get_buffer_without_date(buffer, comments, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)
    it("should insert additional brief information to header", function()
        local filetypes = require("filetypes")
        for k, v in pairs(filetypes) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. k
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            local config = {
                file_name = true,
                author = "test_author_name",
                project = "test_project_name",
                date_created = true,
                date_created_fmt = "%Y-%m-%d %H:%M:%S",
                line_separator = "------",
                copyright_text = "test_copyright_text",
            }
            header.setup(config)

            header.add_headers()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            local comments = v()
            local expected = build_extended_expected_comments(file_name, comments, header.constants, config)

            local buffer_without_date = get_buffer_without_date(buffer, comments, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)
    it("should update existing header files", function()
        local filetypes = require("filetypes")
        for k, v in pairs(filetypes) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. k
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            header.add_headers()
            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local comments = v()

            local config = {
                file_name = true,
                author = "test_author",
                project = "test_project",
                date_created = true,
                date_created_fmt = "%Y-%m-%d %H:%M:%S",
                line_separator = "------",
                copyright_text = "test_copyright",
            }
            -- update config with extended stuff
            header.setup(config)
            header.add_headers()

            buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            local expected = build_extended_expected_comments(file_name, comments, header.constants, config)

            local buffer_without_date = get_buffer_without_date(buffer, comments, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)
end)

describe("add_license_header", function()
    before_each(function()
        header.reset()
    end)
    it("should insert mit header to cpp file", function()
        local config = {
            author = "test_author",
        }
        header.setup(config)

        vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
        local file_name = "main.cc"
        vim.fn.setline(1, file_name)
        vim.api.nvim_buf_set_name(0, file_name)

        header.add_license_header("mit")

        local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        local expected = {
            "/*",
            "* Copyright (c) 2023 " .. config.author,
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
