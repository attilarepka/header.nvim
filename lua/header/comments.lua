local util = require("header.util")
local M = {}

function M.comment_headers(headers, comments, use_block_header)
    local style
    if use_block_header and comments.block and comments.block.start then
        style = comments.block
    elseif comments.line and comments.line.line then
        style = comments.line
    else
        style = comments.block or comments.line
    end

    local result = {}
    if style.start then
        table.insert(result, style.start)
    end
    for _, h in ipairs(headers) do
        if style.line then
            table.insert(result, style.line .. " " .. h)
        else
            table.insert(result, h)
        end
    end
    if style["end"] then
        table.insert(result, style["end"])
    end
    table.insert(result, "")
    return result
end

function M.is_comment_line(line, comments)
    if not comments then
        return false
    end
    local patterns = {}

    local function add(p)
        if p then
            table.insert(patterns, util.escape_special_characters(p))
        end
    end

    if comments.block then
        add(comments.block.start)
        add(comments.block.line)
        add(comments.block["end"])
    end
    if comments.line and comments.line.line then
        add(comments.line.line)
    end

    for _, pat in ipairs(patterns) do
        if pat ~= "" and line:match("^%s*" .. pat) then
            return true
        end
    end
    return false
end

function M.find_header_end(lines, comments)
    local last = 0
    for i, line in ipairs(lines) do
        if M.is_comment_line(line, comments) then
            last = i
        elseif line:match("^%s*$") then
            last = i
            break
        else
            break
        end
    end
    return last
end

return M
