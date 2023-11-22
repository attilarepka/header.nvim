local filetype_table = require("filetypes")

local header = {}

header.header_size = 9

header.config = {
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

header.constants = {
    file_name = "File name:",
    date_created = "Date created:",
    author = "Author:",
    project = "Project:",
    date_modified = "Date modified:",
}

local function comment_headers(header_lines, comments)
    local result = {}

    if comments.comment_start ~= nil then
        table.insert(result, comments.comment_start)
    end

    for i, entry in ipairs(header_lines) do
        entry = comments.comment .. " " .. entry
        table.insert(result, entry)
    end

    if comments.comment_end ~= nil then
        table.insert(result, comments.comment_end)
    end

    table.insert(result, "")

    return result
end

local function replace_token(str, token, value)
    local pattern = "{{%s*" .. token .. "%s*}}"
    local result = string.gsub(str, pattern, value or "")
    return result
end

local function string_to_table(str)
    local lines = {}
    for line in str:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    return lines
end

local function escape_special_characters(pattern)
    local special_chars = { "%", "^", "$", "(", ")", ".", "[", "]", "*", "+", "-", "?" }

    for _, char in ipairs(special_chars) do
        pattern = pattern:gsub("%" .. char, "%%" .. char)
    end

    return pattern
end

local function is_header_line(line, comments)
    if comments.comment_start ~= nil and comments.comment_end ~= nil then
        return line:match("^%s-" .. escape_special_characters(comments.comment_start))
            or line:match("^%s-" .. escape_special_characters(comments.comment))
            or line:match("^%s-" .. escape_special_characters(comments.comment_end))
    end
    return line:match("^%s-" .. escape_special_characters(comments.comment)) ~= nil
end

local function find_header_end(lines, comments)
    local header_end = #lines

    local is_header = true
    for i = 1, #lines do
        if is_header and not is_header_line(lines[i], comments) then
            is_header = false
            header_end = i - 1
        end
    end

    -- if header found, trim the blank line
    if header_end > 0 then
        return header_end + 1
    end

    return header_end
end

local function remove_old_headers(comments)
    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, header.header_size, false)
    local header_end = find_header_end(lines, comments)
    vim.api.nvim_buf_set_lines(buffer, 0, header_end, false, {})
end

local function get_header_lines(buffer, comments)
    local max_header_lines = vim.api.nvim_buf_get_lines(buffer, 0, header.header_size, false)
    local header_end = find_header_end(max_header_lines, comments)
    return vim.api.nvim_buf_get_lines(buffer, 0, header_end, false)
end

local function prepare_headers()
    local file_name = vim.fn.expand("%:t")
    local creation_date = vim.fn.getftime(vim.fn.expand("%"))

    -- Format modified_time as a human-readable string
    creation_date = os.date(header.config.date_created_fmt, creation_date)

    local headers = {}
    if header.config.file_name then
        table.insert(headers, header.constants.file_name .. " " .. file_name)
    end
    if header.config.project ~= nil then
        table.insert(headers, header.constants.project .. " " .. header.config.project)
    end
    if header.config.author ~= nil then
        table.insert(headers, header.constants.author .. " " .. header.config.author)
    end
    if header.config.date_created then
        table.insert(headers, header.constants.date_created .. " " .. creation_date)
    end
    if header.config.date_modified then
        local modified_date = os.date(header.config.date_modified_fmt)
        table.insert(headers, header.constants.date_modified .. " " .. modified_date)
    end
    if header.config.line_separator ~= nil then
        table.insert(headers, header.config.line_separator)
    end
    if header.config.copyright_text ~= nil then
        table.insert(headers, header.config.copyright_text)
    end

    return headers
end

local function add_headers()
    local file_extension = vim.fn.expand("%:e")

    local fn = filetype_table[file_extension]
    if fn then
        local headers = prepare_headers()
        local comments = fn()
        remove_old_headers(comments)
        local commented_headers = comment_headers(headers, comments)
        local buffer = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(buffer, 0, 0, false, commented_headers)
    else
        vim.notify_once("unsupported file type for adding header", vim.log.levels.ERROR)
    end
end

local function add_license_header(opts)
    local buffer = vim.api.nvim_get_current_buf()
    local file_extension = vim.fn.expand("%:e")

    local fn = filetype_table[file_extension]
    if fn then
        local license = require("licenses." .. string.lower(opts))
        license = replace_token(license, "project", header.config.project)
        license = replace_token(license, "organization", header.config.author)
        license = replace_token(license, "year", os.date("%Y"))
        local license_table = string_to_table(license)
        local comments = fn()
        local commented_headers = comment_headers(license_table, comments)
        vim.api.nvim_buf_set_lines(buffer, 0, 0, false, commented_headers)
    else
        vim.notify_once("unsupported file type for adding header", vim.log.levels.ERROR)
    end
end

local function update_date_modified()
    local buffer = vim.api.nvim_get_current_buf()
    local file_extension = vim.fn.expand("%:e")
    -- Check if the file extension is in the filetype_table
    if not filetype_table[file_extension] then
        -- vim.notify("File type not supported for updating header", vim.log.levels.WARN)
        return
    end
    local comments = filetype_table[file_extension]()
    local lines = get_header_lines(buffer, comments)

    if #lines > 0 and header.config.date_modified then
        local header_end = find_header_end(lines, comments)
        local modified_date = os.date(header.config.date_modified_fmt)

        for i, line in ipairs(lines) do
            if line:find(header.constants.date_modified) then
                lines[i] = comments.comment .. " " .. header.constants.date_modified .. " " .. modified_date
                break
            end
        end

        -- Replace only the header lines in the buffer
        vim.api.nvim_buf_set_lines(buffer, 0, header_end, false, lines)
    end
end

local function create_autocmds()
    vim.api.nvim_create_user_command("AddHeader", function()
        header.add_headers()
    end, { complete = "file", nargs = "?", bang = true })

    vim.api.nvim_create_user_command("AddLicenseAGPL3", function()
        add_license_header("agpl3")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseAPACHE", function()
        add_license_header("apache")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseBSD2", function()
        add_license_header("bsd2")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseBSD3", function()
        add_license_header("bsd3")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseCC0", function()
        add_license_header("cc0")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseGPL3", function()
        add_license_header("gpl3")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseISC", function()
        add_license_header("isc")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseMIT", function()
        add_license_header("mit")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseMPL", function()
        add_license_header("mpl")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseUNLICENSE", function()
        add_license_header("unlicense")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseWTFPL", function()
        add_license_header("wtfpl")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseX11", function()
        add_license_header("x11")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("AddLicenseZLIB", function()
        add_license_header("zlib")
    end, { complete = "file", nargs = "?", bang = true })
    vim.api.nvim_create_user_command("UpdateDateModified", function()
        update_date_modified()
    end, { complete = "file", nargs = "?", bang = true })
end

header.setup = function(params)
    header.config = vim.tbl_extend("force", header.config, params or {})
    create_autocmds()
end

header.reset = function()
    header.config = {
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
end

local function check_vim_version()
    if vim.version().minor < 8 then
        vim.notify_once("header.nvim: you must use neovim 0.8 or higher", vim.log.levels.ERROR)
        return
    end
end

header.add_license_header = function(opts)
    check_vim_version()
    add_license_header(opts)
end

header.add_headers = function()
    check_vim_version()
    add_headers()
end

header.update_date_modified = function()
    update_date_modified()
end

return header
