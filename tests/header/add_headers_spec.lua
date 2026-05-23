require("plenary.reload").reload_module("header", true)
local header = require("header")
local languages = require("header.languages")
local config_mod = require("header.config")

local function get_buffer_without_date(buffer, comment_style, constants)
    local style
    if header.config.use_block_header and comment_style.block and comment_style.block.start then
        style = comment_style.block
    elseif comment_style.line and comment_style.line.line then
        style = comment_style.line
    else
        style = comment_style.block or comment_style.line
    end

    local result = {}
    for _, line in ipairs(buffer) do
        if
            not line:match("^%" .. style.line .. " " .. config_mod.get_label(header.config, constants, "date_created"))
            and not line:match("^%" .. style.line .. " " .. config_mod.get_label(header.config, constants, "date_modified"))
        then
            table.insert(result, line)
        end
    end
    return result
end

local function build_minimal_expected_comments(file_name, comment_style)
    local style
    if header.config.use_block_header and comment_style.block and comment_style.block.start then
        style = comment_style.block
    elseif comment_style.line and comment_style.line.line then
        style = comment_style.line
    else
        style = comment_style.block or comment_style.line
    end

    local result = {
        style.line .. " " .. header.config_mod.get_label(header.config, constants, "file_name") .. " " .. file_name,
        style.line .. " " .. header.config.line_separator,
        "",
        file_name,
    }

    if style.start and style["end"] then
        result = {
            style.start,
            style.line .. " " .. header.config_mod.get_label(header.config, constants, "file_name") .. " " .. file_name,
            style.line .. " " .. header.config.line_separator,
            style["end"],
            "",
            file_name,
        }
    end
    return result
end

local function build_extended_expected_comments(file_name, comment_style, constants, config)
    local style
    if config.use_block_header and comment_style.block and comment_style.block.start then
        style = comment_style.block
    elseif comment_style.line and comment_style.line.line then
        style = comment_style.line
    else
        style = comment_style.block or comment_style.line
    end

    local result = {}

    local function append_copyright_lines(text)
        if not text then
            return
        end
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

    if style.start then
        table.insert(result, style.start)
    end

    table.insert(result, style.line .. " " .. config_mod.get_label(header.config, constants, "file_name") .. " " .. file_name)
    table.insert(result, style.line .. " " .. config_mod.get_label(header.config, constants, "project") .. " " .. config.project)
    table.insert(result, style.line .. " " .. config_mod.get_label(header.config, constants, "author") .. " " .. config.author)
    table.insert(result, style.line .. " " .. config.line_separator)
    append_copyright_lines(config.copyright_text)

    if style["end"] then
        table.insert(result, style["end"])
    end

    table.insert(result, "")
    table.insert(result, file_name)

    return result
end

local function get_all_extensions()
    local exts = {}
    for ext, lang_fn in pairs(languages) do
        table.insert(exts, ext)
    end
    return exts
end

describe("add_header", function()
    header.setup()
    before_each(function()
        header.reset()
    end)

    it("should insert headers to file depending on file type", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            header.add_header()
            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local lang = languages[ext]()
            local expected = build_minimal_expected_comments(file_name, lang.comment_style)
            local buffer_without_date = get_buffer_without_date(buffer, lang.comment_style, header.constants)
            assert.are.same(expected, buffer_without_date)
        end
    end)

    it("should insert headers via autocommand", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            vim.api.nvim_command("AddHeader")

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local lang = languages[ext]()
            local expected = build_minimal_expected_comments(file_name, lang.comment_style)
            local buffer_without_date = get_buffer_without_date(buffer, lang.comment_style, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)

    it("should insert additional brief information to header", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
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

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            local lang = languages[ext]()
            local expected = build_extended_expected_comments(file_name, lang.comment_style, header.constants, config)

            local buffer_without_date = get_buffer_without_date(buffer, lang.comment_style, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)

    it("should update existing header files", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            header.add_header()
            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local lang = languages[ext]()

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
            header.setup(config)
            header.add_header()

            buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            local expected = build_extended_expected_comments(file_name, lang.comment_style, header.constants, config)

            local buffer_without_date = get_buffer_without_date(buffer, lang.comment_style, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)

    it("should prefer to use the single-line comment type over block comment", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
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

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            local lang = languages[ext]()
            local single_commented = lang.comment_style
            local block_commented = lang.comment_style

            local expected = build_extended_expected_comments(file_name, single_commented, header.constants, config)
            local buffer_without_date = get_buffer_without_date(buffer, single_commented, header.constants)

            assert.are.same(expected, buffer_without_date)

            -- Only test the difference if language actually has BOTH block and line comment_style
            if
                lang.comment_style.line
                and lang.comment_style.line.line
                and lang.comment_style.block
                and lang.comment_style.block.start
            then
                expected =
                    build_extended_expected_comments(file_name, block_commented, header.constants, comparison_config)
                assert.are.not_same(expected, buffer_without_date)
            end
        end
    end)

    it("should support multiline copyright text as an array", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
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
                    "Copyright (c) 2026 Your Name",
                    "Your Company",
                    "All rights reserved.",
                },
            }
            header.setup(config)

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local lang = languages[ext]()
            local expected = build_extended_expected_comments(file_name, lang.comment_style, header.constants, config)
            local buffer_without_date = get_buffer_without_date(buffer, lang.comment_style, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)

    it("should support multiline copyright text as a string with '\\n' separators", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
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
                copyright_text = "Copyright (c) 2026 Your Name\nYour Company\nAll rights reserved.",
            }

            header.setup(config)
            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local lang = languages[ext]()
            local expected = build_extended_expected_comments(file_name, lang.comment_style, header.constants, config)
            local buffer_without_date = get_buffer_without_date(buffer, lang.comment_style, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)

    it("should use full path when file_full_path is true", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
            local full_path = "/home/user/projects/myproject/" .. file_name
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, full_path)

            header.setup({ file_full_path = true })
            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local lang = languages[ext]()
            local expected = build_minimal_expected_comments(full_path, lang.comment_style)
            expected[#expected] = file_name
            local buffer_without_date = get_buffer_without_date(buffer, lang.comment_style, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)

    it("should use filename only when file_full_path is false (default)", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
            local full_path = "/home/user/projects/myproject/" .. file_name
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, full_path)

            header.setup({ file_full_path = false })
            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local lang = languages[ext]()
            local expected = build_minimal_expected_comments(file_name, lang.comment_style)
            local buffer_without_date = get_buffer_without_date(buffer, lang.comment_style, header.constants)

            assert.are.same(expected, buffer_without_date)
        end
    end)
    it("should use custom labels when *_label options are set", function()
        for _, ext in ipairs(get_all_extensions()) do
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "main." .. ext
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            header.setup({
                file_name_label = "Datei",
                author = "test_author",
                author_label = "Autor",
                project = "test_project",
                project_label = "Projekt",
                date_created_label = "Erstellt",
                date_modified_label = "Geändert",
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            local found_file_label = false
            local found_author_label = false
            local found_project_label = false
            for _, line in ipairs(buffer) do
                if line:find("Datei:", 1, true) then
                    found_file_label = true
                end
                if line:find("Autor:", 1, true) then
                    found_author_label = true
                end
                if line:find("Projekt:", 1, true) then
                    found_project_label = true
                end
            end

            assert.is_true(found_file_label)
            assert.is_true(found_author_label)
            assert.is_true(found_project_label)
        end
    end)
end)
