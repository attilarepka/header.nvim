local lng = require("languages.languages")
local header = {}

header.config = {
    file_name = true,
    author = nil,
    project = nil,
    date_created = true,
    date_created_fmt = "%Y-%m-%d %H:%M:%S",
    line_separator = "------",
    copyright_text = nil,
}

header.constants = {
    file_name = "File name:",
    date_created = "Date created:",
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

local function create_autocmds()
    vim.api.nvim_create_user_command("AddHeader", function()
        header.execute()
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
end

header.setup = function(params)
    header.config = vim.tbl_extend("force", {}, header.config, params or {})
    create_autocmds()
end

local function prepare_headers()
    local file_name = vim.fn.expand('%:t')
    local creation_date = vim.fn.getftime(vim.fn.expand('%'))

    -- Format modified_time as a human-readable string
    creation_date = os.date(header.config.date_created_fmt, creation_date)

    local headers = {}
    if header.config.file_name == true then
        table.insert(headers, "File name: " .. file_name)
    end
    if header.config.project ~= nil then
        table.insert(headers, "Project: " .. header.config.project)
    end
    if header.config.author ~= nil then
        table.insert(headers, "Author: " .. header.config.author)
    end
    if header.config.date_created ~= nil then
        table.insert(headers, "Date Created: " .. creation_date)
    end
    if header.config.line_separator ~= nil then
        table.insert(headers, header.config.line_separator)
    end
    if header.config.copyright_text ~= nil then
        table.insert(headers, header.config.copyright_text)
    end
    return headers
end

local filetype_table =
{
    ["c"] = lng.cpp,
    ["cc"] = lng.cpp,
    ["cpp"] = lng.cpp,
    ["h"] = lng.cpp,
    ["hh"] = lng.cpp,
    ["hpp"] = lng.cpp,
    ["py"] = lng.python,
    ["robot"] = lng.python,
    ["lua"] = lng.lua,
    ["java"] = lng.java,
    ["js"] = lng.javascript,
    ["cs"] = lng.csharp,
    ["swift"] = lng.swift,
    ["rb"] = lng.ruby,
    ["kt"] = lng.kotlin,
    ["sc"] = lng.scala,
    ["go"] = lng.go,
    ["rs"] = lng.rust,
    ["php"] = lng.php,
    ["sh"] = lng.shell,
    ["hs"] = lng.haskell,
    ["lhs"] = lng.haskell,
    ["pl"] = lng.perl,
    ["ts"] = lng.typescript,
    ["tsx"] = lng.typescript,
    ["coffee"] = lng.coffeescript,
    ["groovy"] = lng.groovy,
    ["gvy"] = lng.groovy,
    ["gy"] = lng.groovy,
    ["gsh"] = lng.groovy,
    ["dart"] = lng.dart,
    ["r"] = lng.r,
}

local function add_headers()
    -- TODO: check first few lines with regexp and if header found,
    -- notify, and do not update
    local buffer = vim.api.nvim_get_current_buf()
    local file_extension = vim.fn.expand('%:e')

    local fn = filetype_table[file_extension]
    if (fn) then
        local headers = prepare_headers()
        local comments = fn()
        local commented_headers = comment_headers(headers, comments)
        vim.api.nvim_buf_set_lines(buffer, 0, 0, false, commented_headers)
    else
        print("Unsupported file type:", file_extension)
    end
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

local function add_license_header(opts)
    local buffer = vim.api.nvim_get_current_buf()
    local file_extension = vim.fn.expand('%:e')

    local fn = filetype_table[file_extension]
    if (fn) then
        local license = require("licenses." .. string.lower(opts))
        license = replace_token(license, "project", header.config.project)
        license = replace_token(license, "organization", header.config.author)
        license = replace_token(license, "year", os.date("%Y"))
        local license_table = string_to_table(license)
        local comments = fn()
        local commented_headers = comment_headers(license_table, comments)
        vim.api.nvim_buf_set_lines(buffer, 0, 0, false, commented_headers)
    else
        print("Unsupported file type:", file_extension)
    end
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

return header
