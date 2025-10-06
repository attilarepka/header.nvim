require("plenary.reload").reload_module("header", true)
local header = require("header")
local filetypes = require("header.filetypes")

local function get_modified_date(buffer)
    for i, line in ipairs(buffer) do
        if line:find(header.constants.date_modified) then
            return buffer[i]
        end
    end
end

describe("update_date_modified", function()
    local os_module = package.loaded.os.date

    local function os_date() return "1234-56-78 90:12:34" end

    before_each(function() header.reset() end)
    after_each(function() os.date = os_module end)

    it("should update existing header modified time", function()
        for k, _ in pairs(filetypes) do
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
                use_block_header = true,
                copyright_text = "test_copyright",
            }
            header.setup(config)
            header.add_headers()

            local buffer_old = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            os.date = os_date

            header.update_date_modified()
            local buffer_updated = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.are_not.equal(buffer_old, buffer_updated)

            local modified_date = get_modified_date(buffer_updated)
            assert.is_true(string.find(modified_date, os.date(), 0, true) > 0)
            break
        end
    end)

    it("should not modify the buffer if there is no header", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Line 1", "Line 2", "Line 3" })
        local initial_buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        header.update_date_modified()
        local updated_buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        assert.are.same(initial_buffer, updated_buffer)
    end)

    it("should not run for unsupported file extensions", function()
        local unsupported_extension = "unsupported_ext"
        local file_name = "test_file." .. unsupported_extension
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { file_name, "Line 2", "Line 3" })
        vim.api.nvim_buf_set_name(0, file_name)

        header.update_date_modified()
        local updated_buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        assert.are.same({ file_name, "Line 2", "Line 3" }, updated_buffer)
    end)
end)
