local M = {}

M.defaults = {
    allow_autocmds = true,
    file_name = true,
    file_full_path = false,
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
    file_name_label = nil,
    date_created_label = nil,
    author_label = nil,
    project_label = nil,
    date_modified_label = nil,
}

M.constants = {
    file_name = "File name",
    date_created = "Date created",
    author = "Author",
    project = "Project",
    date_modified = "Date modified",
}

function M.get_label(config, constants, field)
    local label = config[field .. "_label"] or constants[field]
    return label .. ":"
end

function M.read_config_file()
    local f = io.open(".header.nvim", "r")
    if not f then
        return nil
    end
    local ok, content = pcall(function()
        return f:read("*a")
    end)
    f:close()

    if not ok then
        vim.notify("header.nvim: failed to read .header.nvim", vim.log.levels.WARN)
        return nil
    end

    if not content or content == "" then
        return nil
    end

    local ok_decode, decoded = pcall(vim.fn.json_decode, content)
    if not ok_decode then
        vim.notify("header.nvim: invalid JSON in .header.nvim: " .. decoded, vim.log.levels.WARN)
        return nil
    end

    return decoded
end

return M
