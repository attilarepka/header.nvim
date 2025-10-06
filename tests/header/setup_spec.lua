local header = require("header")

describe("setup", function()
    before_each(function() header.reset() end)

    it("setup with default configs", function()
        local expected = {
            allow_autocmds = true,
            file_name = true,
            author = nil,
            project = nil,
            date_created = true,
            date_created_fmt = "%Y-%m-%d %H:%M:%S",
            date_modified = true,
            date_modified_fmt = "%Y-%m-%d %H:%M:%S",
            line_separator = "------",
            use_block_header = true,
            copyright_text = nil,
            license_from_file = false,
            author_from_git = false,
        }
        header.setup()
        assert.are.same(expected, header.config)
    end)

    it("setup with custom configs", function()
        local expected = {
            allow_autocmds = false,
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
            license_from_file = false,
            author_from_git = false,
        }
        header.setup(expected)
        assert.are.same(expected, header.config)
    end)
end)
