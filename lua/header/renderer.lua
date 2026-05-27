local M = {}

function M.render_header(headers, comment_style, use_block_header)
    local style
    if use_block_header and comment_style.block and comment_style.block.start then
        style = comment_style.block
    elseif comment_style.line and comment_style.line.line then
        style = comment_style.line
    else
        style = comment_style.block or comment_style.line
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

local function escape_special_characters(pattern)
    if not pattern then
        return ""
    end
    local special = { "%", "^", "$", "(", ")", ".", "[", "]", "*", "+", "-", "?" }
    for _, c in ipairs(special) do
        pattern = pattern:gsub("%" .. c, "%%" .. c)
    end
    return pattern
end

function M.is_comment_line(line, comments)
    if not comments then
        return false
    end
    local patterns = {}

    local function add(p)
        if p then
            table.insert(patterns, escape_special_characters(p))
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
