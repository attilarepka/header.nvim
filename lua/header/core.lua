local comment_utils = require("header.comment_utils")
local util = require("header.util")
local license = require("header.license")
local languages = require("header.languages")

local M = {}

local function resolve_language()
    local ext = vim.fn.expand("%:e")
    local lang_fn = languages[ext]

    if not lang_fn then
        return nil
    end

    return lang_fn()
end

local function remove_old_headers(comment_style, insert_line)
    local buf = vim.api.nvim_get_current_buf()
    local total = vim.api.nvim_buf_line_count(buf)
    if total == 0 then
        return
    end

    local limit = math.min(300, total)
    local lines = vim.api.nvim_buf_get_lines(buf, insert_line, limit, false)

    local header_end = insert_line
    for i, line in ipairs(lines) do
        if not comment_utils.is_comment_line(line, comment_style) and not line:match("^%s*$") then
            header_end = insert_line + i - 1
            break
        end
        header_end = insert_line + i
    end

    if header_end < total then
        local next_line = vim.api.nvim_buf_get_lines(buf, header_end, header_end + 1, false)[1]
        if next_line and next_line:match("^%s*$") then
            header_end = header_end + 1
        end
    end

    if header_end > insert_line then
        vim.api.nvim_buf_set_lines(buf, insert_line, header_end, false, {})
    end
end

local function prepare_header_content(header, callback)
    if header.config.author_from_git then
        local gitname = vim.fn.systemlist("git config user.name")
        if vim.v.shell_error == 0 and #gitname > 0 then
            header.config.author = gitname[1]
        end
    end

    if header.config.license_from_file then
        local files = license.scan_license_files()
        if #files == 0 then
            callback(nil)
            return
        end
        if #files == 1 then
            callback(license.read_license_file(files[1]))
            return
        end
        if header.selected_license_file then
            callback(license.read_license_file(header.selected_license_file))
            return
        end
        license.select_license_file(files, function(f)
            callback(f and license.read_license_file(f) or nil)
        end, header)
        return
    end

    local file
    if header.config.file_full_path then
        file = vim.fn.expand("%:p")
    else
        file = vim.fn.expand("%:t")
    end

    local created = os.date(header.config.date_created_fmt, vim.fn.getftime(vim.fn.expand("%")))

    local hdrs = {}
    if header.config.file_name then
        table.insert(hdrs, header.constants.file_name .. " " .. file)
    end
    if header.config.project then
        table.insert(hdrs, header.constants.project .. " " .. header.config.project)
    end
    if header.config.author then
        table.insert(hdrs, header.constants.author .. " " .. header.config.author)
    end
    if header.config.date_created then
        table.insert(hdrs, header.constants.date_created .. " " .. created)
    end
    if header.config.date_modified then
        table.insert(hdrs, header.constants.date_modified .. " " .. os.date(header.config.date_modified_fmt))
    end
    if header.config.line_separator then
        table.insert(hdrs, header.config.line_separator)
    end
    if header.config.copyright_text then
        if type(header.config.copyright_text) == "string" then
            vim.list_extend(hdrs, util.string_to_table(header.config.copyright_text))
        else
            vim.list_extend(hdrs, header.config.copyright_text)
        end
    end
    callback(hdrs)
end

function M.add_header(header)
    local lang = resolve_language()

    if not lang then
        vim.notify_once("unsupported file type for adding header", vim.log.levels.ERROR)
        return
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local placement = lang.resolve_insertion(lines)

    if not placement.ok then
        vim.notify(placement.error, vim.log.levels.ERROR)
        return
    end

    local insert_line = placement.insert_line

    prepare_header_content(header, function(hdrs)
        if not hdrs then
            return
        end

        local new_hdrs = {}
        for i, line in ipairs(hdrs) do
            new_hdrs[i] = util.replace_all_tokens(line, header)
        end

        remove_old_headers(lang.comment_style, insert_line)
        local rendered = comment_utils.render_header(new_hdrs, lang.comment_style, header.config.use_block_header)
        vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, rendered)
    end)
end

function M.add_license_header(header, opts)
    local lang = resolve_language()

    if not lang then
        vim.notify_once("unsupported file type for adding header", vim.log.levels.ERROR)
        return
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local placement = lang.resolve_insertion(lines)

    if not placement.ok then
        vim.notify(placement.error, vim.log.levels.ERROR)
        return
    end

    local insert_line = placement.insert_line

    remove_old_headers(lang.comment_style, insert_line)

    local license_text = require("header.licenses." .. string.lower(opts))
    license_text = util.replace_all_tokens(license_text, header)

    local license_table = util.string_to_table(license_text)
    local rendered = comment_utils.render_header(license_table, lang.comment_style, header.config.use_block_header)
    vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, rendered)
end

function M.update_date_modified(header)
    local lang = resolve_language()

    if not lang then
        vim.notify("File type not supported for updating header", vim.log.levels.WARN)
        return
    end

    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 30, false)
    local header_end = comment_utils.find_header_end(lines, lang.comment_style)
    if not header_end then
        return
    end

    local modified = os.date(header.config.date_modified_fmt)
    local updated = false

    for i = 1, header_end do
        if lines[i]:find(header.constants.date_modified) then
            local prefix = (lang.comment_style.line and lang.comment_style.line.line)
                or (lang.comment_style.block and lang.comment_style.block.line)
                or ""
            lines[i] = prefix .. " " .. header.constants.date_modified .. " " .. modified
            updated = true
            break
        end
    end

    if updated then
        vim.api.nvim_buf_set_lines(buf, 0, header_end, false, vim.list_slice(lines, 1, header_end))
    end
end

return M
