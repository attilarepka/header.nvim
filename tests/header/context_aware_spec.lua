require("plenary.reload").reload_module("header", true)
local header = require("header")

describe("context_aware languages", function()
    before_each(function()
        header.reset()
    end)

    describe("bash/shell with shebang", function()
        it("should insert header after shebang", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "script.sh"
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            local config = {
                file_name = true,
                author = "test_author",
                project = "test_project",
                date_created = false,
                date_modified = false,
                line_separator = "------",
                use_block_header = true,
            }
            header.setup(config)

            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "#!/bin/bash",
                "echo 'hello'",
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.are.equal("#!/bin/bash", buffer[1])
            assert.is_true(buffer[2]:match("^#") ~= nil or buffer[2]:match("^%s*$") ~= nil)
            assert.are.equal("echo 'hello'", buffer[#buffer])
        end)

        it("should insert header at top if no shebang exists", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "script.sh"
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            local config = {
                file_name = true,
                author = "test_author",
                project = "test_project",
                date_created = false,
                date_modified = false,
                line_separator = "------",
                use_block_header = true,
            }
            header.setup(config)

            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "echo 'hello'",
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.is_true(buffer[1]:match("^#") ~= nil)
            assert.are.equal("echo 'hello'", buffer[#buffer])
        end)
    end)

    describe("python with shebang and encoding", function()
        it("should insert header after shebang and encoding declaration", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "script.py"
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            local config = {
                file_name = true,
                author = "test_author",
                date_created = false,
                date_modified = false,
                line_separator = "------",
                use_block_header = true,
            }
            header.setup(config)

            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "#!/usr/bin/env python3",
                "# -*- coding: utf-8 -*-",
                "import os",
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.are.equal("#!/usr/bin/env python3", buffer[1])
            assert.are.equal("# -*- coding: utf-8 -*-", buffer[2])
            assert.is_true(buffer[3]:match("^#") ~= nil)
            assert.are.equal("import os", buffer[#buffer])
        end)

        it("should insert header after shebang only if no encoding", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "script.py"
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            local config = {
                file_name = true,
                author = "test_author",
                date_created = false,
                date_modified = false,
                line_separator = "------",
                use_block_header = true,
            }
            header.setup(config)

            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "#!/usr/bin/env python3",
                "import os",
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.are.equal("#!/usr/bin/env python3", buffer[1])
            assert.is_true(buffer[2]:match("^#") ~= nil)
            assert.are.equal("import os", buffer[#buffer])
        end)
    end)

    describe("filetype aliases", function()
        it("should use the Python handler when only the filetype identifies the language", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "#!/usr/bin/env python3",
                "import os",
            })
            vim.api.nvim_buf_set_name(0, "script.unknown")
            vim.bo.filetype = "python"
            header.setup({
                file_name = true,
                date_created = false,
                date_modified = false,
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            assert.are.equal("#!/usr/bin/env python3", buffer[1])
            assert.is_true(buffer[2]:match("^#") ~= nil)
            assert.are.equal("import os", buffer[#buffer])
        end)

        it("should support Dockerfiles without a file extension", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, { "FROM alpine" })
            vim.api.nvim_buf_set_name(0, "Dockerfile")
            vim.bo.filetype = "dockerfile"
            header.setup({
                file_name = true,
                date_created = false,
                date_modified = false,
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            assert.is_true(buffer[1]:match("^#") ~= nil)
            assert.are.equal("FROM alpine", buffer[#buffer])
        end)

        it("should use HTML comments for Markdown filetypes without a recognized extension", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# Title" })
            vim.api.nvim_buf_set_name(0, "document.unknown")
            vim.bo.filetype = "markdown"
            header.setup({
                file_name = true,
                date_created = false,
                date_modified = false,
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            assert.are.equal("<!--", buffer[1])
            assert.are.equal("# Title", buffer[#buffer])
        end)
    end)

    describe("php with opening tag", function()
        it("should insert header after <?php tag", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "index.php"
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            local config = {
                file_name = true,
                author = "test_author",
                project = "test_project",
                date_created = false,
                date_modified = false,
                line_separator = "------",
                use_block_header = true,
            }
            header.setup(config)

            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "<?php",
                "echo 'hello';",
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.are.equal("<?php", buffer[1])
            assert.is_true(buffer[2]:match("^/") ~= nil or buffer[2]:match("^%s*$") ~= nil)
            assert.are.equal("echo 'hello';", buffer[#buffer])
        end)

        it("should use an HTML comment at the top if no PHP opening tag exists", function()
            vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
            local file_name = "index.php"
            vim.fn.setline(1, file_name)
            vim.api.nvim_buf_set_name(0, file_name)

            local config = {
                file_name = true,
                author = "test_author",
                project = "test_project",
                date_created = false,
                date_modified = false,
                line_separator = "------",
                use_block_header = true,
            }
            header.setup(config)

            vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                "<!DOCTYPE html>",
                "<html>",
            })

            header.add_header()

            local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            assert.are.equal("<!--", buffer[1])
            assert.are.equal("-->", buffer[#buffer - 3])
            assert.are.equal("<!DOCTYPE html>", buffer[#buffer - 1])
        end)
    end)
end)
