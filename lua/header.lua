local filetype_table = require("filetypes")

local header = {}

header.header_size = 9
header.selected_license_file = nil

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
    license_from_file = false,
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

    for _, entry in ipairs(header_lines) do
        if entry == "" then
            table.insert(result, comments.comment)
        else
            table.insert(result, comments.comment .. " " .. entry)
        end
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
    if not pattern then
        return ""
    end
    local special_chars = { "%", "^", "$", "(", ")", ".", "[", "]", "*", "+", "-", "?" }

    for _, char in ipairs(special_chars) do
        pattern = pattern:gsub("%" .. char, "%%" .. char)
    end

    return pattern
end

local function find_block_comment_end(lines, comments)
    local start_pat = escape_special_characters(comments.comment_start or "")
    local end_pat = escape_special_characters(comments.comment_end or "")

    if start_pat == "" or end_pat == "" then
        return 0 -- Cannot proceed without both start and end
    end

    local found_start = false

    for i, line in ipairs(lines) do
        if not found_start then
            if line:find(start_pat) then
                found_start = true
            end
        else
            if line:find(end_pat) then
                return i -- End of block header (inclusive)
            end
        end
    end

    return 0 -- No complete block comment found
end

local function find_line_comment_header_end(lines, comments)
    if not comments or not comments.comment then
        return 0
    end

    local comment_pat = "^%s*" .. escape_special_characters(comments.comment)
    local last_comment_line = 0

    for i, line in ipairs(lines) do
        if line:match(comment_pat) or line:match("^%s*$") then
            last_comment_line = i
        else
            break
        end
    end

    return last_comment_line
end

local function find_header_end(lines, comments)
    if comments.comment_start and comments.comment_end then
        return find_block_comment_end(lines, comments)
    else
        return find_line_comment_header_end(lines, comments)
    end
end

local function remove_old_headers(comments)
    local buffer = vim.api.nvim_get_current_buf()
    local total_lines = vim.api.nvim_buf_line_count(buffer)
    if total_lines == 0 then
        return
    end

    -- Scan up to 300 lines as OSS licenses can be really long
    local scan_limit = math.min(300, total_lines)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, scan_limit, false)

    local header_end = find_header_end(lines, comments)
    if header_end == 0 then
        return -- No header found; do nothing
    end

    -- Optionally trim the following blank line
    local next_line = vim.api.nvim_buf_get_lines(buffer, header_end, header_end + 1, false)[1]
    if next_line and next_line:match("^%s*$") then
        header_end = header_end + 1
    end

    vim.api.nvim_buf_set_lines(buffer, 0, header_end, false, {})
end

local function get_header_lines(buffer, comments)
    local max_header_lines = vim.api.nvim_buf_get_lines(buffer, 0, header.header_size, false)
    local header_end = find_header_end(max_header_lines, comments)
    return vim.api.nvim_buf_get_lines(buffer, 0, header_end, false)
end

local function scan_license_files()
    local possible_names = {
        "^LICENSE$",
        "^LICENSE%.md$",
        "^LICENSE%-.*$",
        "^COPYING$",
        "^COPYING%.md$",
        "^UNLICENSE$",
        "^UNLICENSE%.md$",
        "^LICENCE$", -- British spelling
        "^LICENCE%.md$",
        "^LICENCE%-.*$",
        "^NOTICE$",
        "^NOTICE%.md$",
        "^LEGAL$",
        "^LEGAL%.md$",
    }

    local license_files = {}
    local p = io.popen("ls -a") -- Or "dir /b" for Windows
    if not p then
        return license_files
    end

    for file in p:lines() do
        for _, pattern in ipairs(possible_names) do
            if file:match(pattern) then
                table.insert(license_files, file)
                break
            end
        end
    end
    p:close()

    return license_files
end

local function select_license_file(options, callback)
    local current_line = 1
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, options)

    local height = #options
    local width = 30
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
    })

    local ns = vim.api.nvim_create_namespace("popup_select_ns")
    local function update_highlight()
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns, "Visual", current_line - 1, 0, -1)
    end
    update_highlight()

    vim.api.nvim_echo({
        {
            "multiple license files found. use ↑↓ or j/k to move, enter to select, q to quit",
            "Comment",
        },
    }, false, {})

    local function move_cursor(delta)
        current_line = current_line + delta
        if current_line < 1 then
            current_line = #options
        end
        if current_line > #options then
            current_line = 1
        end
        update_highlight()
    end

    local function select_option()
        local choice = options[current_line]
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_echo({}, false, {})
        header.selected_license_file = choice
        callback(choice)
    end

    local function close()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_echo({}, false, {})
        callback(nil)
    end

    local function map(key, func)
        vim.api.nvim_buf_set_keymap(buf, "n", key, "", {
            callback = func,
            noremap = true,
            silent = true,
        })
    end

    map("j", function()
        move_cursor(1)
    end)
    map("k", function()
        move_cursor(-1)
    end)
    map("<down>", function()
        move_cursor(1)
    end)
    map("<up>", function()
        move_cursor(-1)
    end)
    map("<cr>", select_option)
    map("q", close)

    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"
end

local function read_license_file(license_file)
    local header_file = io.open(license_file, "r")
    if not header_file then
        return nil
    end

    local content = header_file:read("*a")
    header_file:close()

    if not content or content == "" then
        return nil
    end

    return vim.split(content, "\n", { plain = true })
end

local function prepare_headers(callback)
    if header.config.license_from_file then
        local license_files = scan_license_files()

        if #license_files > 0 then
            if #license_files == 1 then
                local headers = read_license_file(license_files[1])
                callback(headers)
                return
            end

            if header.selected_license_file then
                local headers = read_license_file(header.selected_license_file)
                callback(headers)
                return
            end

            select_license_file(license_files, function(license_file)
                if license_file then
                    header.selected_license_file = license_file
                    local headers = read_license_file(license_file)
                    callback(headers)
                else
                    callback(nil)
                end
            end)
            return
        else
            callback(nil)
            return
        end
    end

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

    callback(headers)
end

local function add_headers()
    local file_extension = vim.fn.expand("%:e")
    local fn = filetype_table[file_extension]

    if fn then
        prepare_headers(function(headers)
            if headers then
                local comments = fn()
                remove_old_headers(comments)
                local commented_headers = comment_headers(headers, comments)
                local buffer = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_set_lines(buffer, 0, 0, false, commented_headers)
            end
        end)
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
        remove_old_headers(comments)
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
        vim.notify("File type not supported for updating header", vim.log.levels.WARN)
        return
    end
    local comments = filetype_table[file_extension]()
    local lines = get_header_lines(buffer, comments)

    if #lines > 0 and header.config.date_modified then
        local header_end = find_header_end(lines, comments)
        local modified_date = os.date(header.config.date_modified_fmt)

        for i, line in ipairs(lines) do
            if line:find(header.constants.date_modified) then
                local comment_start = line:find(comments.comment)
                local line_beginning = line:sub(1, comment_start - 1)
                lines[i] = line_beginning
                    .. comments.comment
                    .. " "
                    .. header.constants.date_modified
                    .. " "
                    .. modified_date
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

local function read_config_file()
    local header_file = io.open(".header.nvim", "r")
    if not header_file then
        return nil
    end

    local header_file_content = header_file:read("*a")
    header_file:close()

    if not header_file_content or header_file_content == "" then
        return nil
    end

    return vim.fn.json_decode(header_file_content)
end

header.setup = function(params)
    -- Read the project configuration file
    local file_config = read_config_file()

    -- Override header config with params passed to setup
    header.config = vim.tbl_extend("force", header.config, params or {})

    -- Override the default configuration with the project's configuration
    if file_config then
        header.config = vim.tbl_extend("force", header.config, file_config)
    end

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
        license_from_file = false,
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
