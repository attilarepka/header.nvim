local comments = require("header.comments")
local util = require("header.util")
local license = require("header.license")
local filetypes = require("header.filetypes")

local M = {}

local function get_comment_style()
    local ext = vim.fn.expand("%:e")
    return filetypes[ext]
end

local function remove_old_headers(comments_table)
    local buf = vim.api.nvim_get_current_buf()
    local total = vim.api.nvim_buf_line_count(buf)
    if total == 0 then
        return
    end

    local limit = math.min(300, total)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, limit, false)
    local header_end = comments.find_header_end(lines, comments_table)
    if header_end == 0 then
        return
    end

    local next_line = vim.api.nvim_buf_get_lines(buf, header_end, header_end + 1, false)[1]
    if next_line and next_line:match("^%s*$") then
        header_end = header_end + 1
    end

    vim.api.nvim_buf_set_lines(buf, 0, header_end, false, {})
end

function M.add_headers(header)
    local comments_fn = get_comment_style()
    if not comments_fn then
        vim.notify_once("unsupported file type for adding header", vim.log.levels.ERROR)
        return
    end

    local comments_table = comments_fn()

    -- prepare headers (inline version)
    local function prepare(cb)
        if header.config.author_from_git then
            local gitname = vim.fn.systemlist("git config user.name")
            if vim.v.shell_error == 0 and #gitname > 0 then
                header.config.author = gitname[1]
            end
        end

        if header.config.license_from_file then
            local files = license.scan_license_files()
            if #files == 0 then
                cb(nil)
                return
            end
            if #files == 1 then
                cb(license.read_license_file(files[1]))
                return
            end
            if header.selected_license_file then
                cb(license.read_license_file(header.selected_license_file))
                return
            end
            license.select_license_file(files, function(f)
                cb(f and license.read_license_file(f) or nil)
            end, header)
            return
        end

        local file = vim.fn.expand("%:t")
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
        cb(hdrs)
    end

    prepare(function(hdrs)
        if not hdrs then
            return
        end

        local new_hrds = {}
        for i, line in ipairs(hdrs) do
            new_hrds[i] = util.replace_all_tokens(line, header)
        end

        remove_old_headers(comments_table)
        local commented = comments.comment_headers(new_hrds, comments_table, header.config.use_block_header)
        vim.api.nvim_buf_set_lines(0, 0, 0, false, commented)
    end)
end

function M.add_license_header(header, opts)
    local comments_fn = get_comment_style()
    if not comments_fn then
        vim.notify_once("unsupported file type for adding header", vim.log.levels.ERROR)
        return
    end

    local license_text = require("header.licenses." .. string.lower(opts))
    license_text = util.replace_all_tokens(license_text, header)

    local license_table = util.string_to_table(license_text)
    local comments_table = comments_fn()
    remove_old_headers(comments_table)
    local commented = comments.comment_headers(license_table, comments_table, header.config.use_block_header)
    vim.api.nvim_buf_set_lines(0, 0, 0, false, commented)
end

function M.update_date_modified(header)
    local comments_fn = get_comment_style()
    if not comments_fn then
        vim.notify("File type not supported for updating header", vim.log.levels.WARN)
        return
    end

    local buf = vim.api.nvim_get_current_buf()
    local comments_table = comments_fn()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 30, false)
    local header_end = comments.find_header_end(lines, comments_table)
    if not header_end then
        return
    end

    local modified = os.date(header.config.date_modified_fmt)
    local updated = false

    for i = 1, header_end do
        if lines[i]:find(header.constants.date_modified) then
            local prefix = (comments_table.line and comments_table.line.line)
                or (comments_table.block and comments_table.block.line)
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
