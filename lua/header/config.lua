local M = {}

M.defaults = {
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

M.constants = {
    file_name = "File name:",
    date_created = "Date created:",
    author = "Author:",
    project = "Project:",
    date_modified = "Date modified:",
}

function M.read_config_file()
    local f = io.open(".header.nvim", "r")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()
    if not content or content == "" then
        return nil
    end
    return vim.fn.json_decode(content)
end

return M
