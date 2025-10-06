require("plenary.reload").reload_module("header", true)
local header = require("header")
local filetypes = require("header.filetypes")

local function get_buffer_without_date(buffer, comments, constants)
    local style
    if header.config.use_block_header and comments.block and comments.block.start then
        style = comments.block
    elseif comments.line and comments.line.line then
        style = comments.line
    else
        style = comments.block or comments.line
    end

    local result = {}
    for _, line in ipairs(buffer) do
        if
            not line:match("^%" .. style.line .. " " .. constants.date_created)
            and not line:match("^%" .. style.line .. " " .. constants.date_modified)
        then
            table.insert(result, line)
        end
    end
    return result
end

local function build_minimal_expected_comments(file_name, comments)
    local style
    if header.config.use_block_header and comments.block and comments.block.start then
        style = comments.block
    elseif comments.line and comments.line.line then
        style = comments.line
    else
        style = comments.block or comments.line
    end

    local result = {
        style.line .. " " .. header.constants.file_name .. " " .. file_name,
        style.line .. " " .. header.config.line_separator,
        "",
        file_name,
    }

    if style.start and style["end"] then
        result = {
            style.start,
            style.line .. " " .. header.constants.file_name .. " " .. file_name,
            style.line .. " " .. header.config.line_separator,
            style["end"],
            "",
            file_name,
        }
    end
    return result
end

local function build_extended_expected_comments(file_name, comments, constants, config)
    local style
    if config.use_block_header and comments.block and comments.block.start then
        style = comments.block
    elseif comments.line and comments.line.line then
        style = comments.line
    else
        style = comments.block or comments.line
    end

    local result = {}

    local function append_copyright_lines(text)
        if not text then return end
        if type(text) == "string" then
            for line in text:gmatch("[^\r\n]+") do
                table.insert(result, style.line .. " " .. line)
            end
        elseif type(text) == "table" then
            for _, line in ipairs(text) do
                table.insert(result, style.line .. " " .. line)
            end
        end
    end

    if style.start then table.insert(result, style.start) end

    table.insert(result, style.line .. " " .. constants.file_name .. " " .. file_name)
    table.insert(result, style.line .. " " .. constants.project .. " " .. config.project)
    table.insert(result, style.line .. " " .. constants.author .. " " .. config.author)
    table.insert(result, style.line .. " " .. config.line_separator)
    append_copyright_lines(config.copyright_text)

    if style["end"] then table.insert(result, style["end"]) end

    table.insert(result, "")
    table.insert(result, file_name)

    return result
end

describe("add_headers", function()
    header.setup()
    before_each(function()
        header.reset()
    end)

    it("should insert headers to file depending on file type", function()
        for k, v in pairs(filetypes) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. k
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            header.add_headers()
            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local comments = v()
            local expected = build_minimal_expected_comments(file_name, comments)
            local buffer_without_date = get_buffer_without_date(buffer, comments, header.constants)
            assert.are.same(expected, buffer_without_date)
        end
    end)

    it("should insert headers via autocommand", function()
        for k, v in pairs(filetypes) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. k
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            vim.api.nvim_command("AddHeader")

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local comments = v()
            local expected = build_minimal_expected_comments(file_name, comments)
            local buffer_without_date = get_buffer_without_date(buffer, comments, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)

    it("should insert additional brief information to header", function()
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
                use_block_header = true,
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
                use_block_header = true,
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

    it("should prefer to use the single-line comment type over block comment", function()
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
                use_block_header = false,
                copyright_text = "test_copyright",
            }

            local comparison_config = {
                file_name = true,
                author = "test_author",
                project = "test_project",
                date_created = true,
                date_created_fmt = "%Y-%m-%d %H:%M:%S",
                date_modified = true,
                date_modified_fmt = "%Y-%m-%d %H:%M:%S",
                line_separator = "------",
                use_block_header = true,
                copyright_text = "test_copyright",
            }

            header.setup(config)

            header.add_headers()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            local single_commented = v()
            local block_commented = v()

            local expected = build_extended_expected_comments(file_name, single_commented, header.constants, config)
            local buffer_without_date = get_buffer_without_date(buffer, single_commented, header.constants)

            assert.are.same(expected, buffer_without_date)

            if single_commented.comment_start == nil and block_commented.comment_start ~= nil then
                -- if comments and opposite_comments are different, we should not have the opposite
                -- comments in the buffer, this should only be true for
                -- languages that support both block and single-line comments
                expected =
                    build_extended_expected_comments(file_name, block_commented, header.constants, comparison_config)
                assert.are.not_same(expected, buffer_without_date)
            end
        end
    end)

    it("should support multiline copyright text as an array", function()
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
                use_block_header = true,
                copyright_text = {
                    "Copyright (c) 2023 Your Name",
                    "Your Company",
                    "All rights reserved."
                },
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

    it("should support multiline copyright text as a string with '\\n' separators", function()
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
                use_block_header = true,
                copyright_text = "Copyright (c) 2023 Your Name\nYour Company\nAll rights reserved."
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
end)
