require("plenary.reload").reload_module("header", true)
local header = require("header")

local function get_modified_date(buffer)
    for i, line in ipairs(buffer) do
        if line:find(header.constants.date_modified) then
            return buffer[i]
        end
    end
end

local function get_buffer_without_date(buffer, comments, constants)
    result = {}
    for _, line in ipairs(buffer) do
        if
            not line:match("^%" .. comments.comment .. " " .. constants.date_created)
            and not line:match("^%" .. comments.comment .. " " .. constants.date_modified)
        then
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
            date_modified = true,
            date_modified_fmt = "%Y-%m-%d %H:%M:%S",
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
            date_modified = true,
            date_modified_fmt = "%Y-%m-%d %H:%M:%S",
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
                date_modified = true,
                date_modified_fmt = "%Y-%m-%d %H:%M:%S",
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
                date_modified = true,
                date_modified_fmt = "%Y-%m-%d %H:%M:%S",
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

describe("update_date_modified", function()
    local os_module = package.loaded.os.date
    function os_date(...)
        return "1234-56-78 90:12:34"
    end

    before_each(function()
        header.reset()
    end)
    after_each(function()
        os.date = os_module
    end)
    it("should update existing header modified time", function()
        local filetypes = require("filetypes")
        for k, v in pairs(filetypes) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. k
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            local config = {
                file_name = true,
                author = "test_author",
                project = "test_project",
                date_created = true,
                date_created_fmt = "%Y-%m-%d %H:%M:%S",
                date_modified = true,
                date_modified_fmt = "%Y-%m-%d %H:%M:%S",
                line_separator = "------",
                copyright_text = "test_copyright",
            }
            -- update config with extended stuff
            header.setup(config)
            header.add_headers()

            buffer_old = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            os.date = os_date -- override os.date

            header.update_date_modified()
            buffer_updated = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.are_not.equal(buffer_old, buffer_updated)

            modified_date = get_modified_date(buffer_updated)
            assert.is_true(string.find(modified_date, os.date(), 0, true) > 0)
            break
        end
    end)

    it("should not modify the buffer if there is no header", function()
        -- Setup a buffer without a header
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Line 1", "Line 2", "Line 3" })
        local initial_buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        -- Call update_date_modified
        header.update_date_modified()

        -- Get the buffer after the update
        local updated_buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        -- Verify that the buffer has not changed
        assert.are.same(initial_buffer, updated_buffer)
    end)

    it("should not run for unsupported file extensions", function()
        -- Setup a buffer with an unsupported file extension
        local unsupported_extension = "unsupported_ext"
        local file_name = "test_file." .. unsupported_extension
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { file_name, "Line 2", "Line 3" })
        vim.api.nvim_buf_set_name(0, file_name)

        -- Call update_date_modified
        local header = require("header")
        header.update_date_modified()

        -- Get the buffer after the update
        local updated_buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        -- Verify that the buffer has not changed
        assert.are.same({ file_name, "Line 2", "Line 3" }, updated_buffer)
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
