local M = {}

function M.replace_token(str, token, value)
    local pattern = "{{%s*" .. token .. "%s*}}"
    return string.gsub(str, pattern, value or "")
end

function M.string_to_table(str)
    local lines = {}
    for line in str:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    return lines
end

function M.escape_special_characters(pattern)
    if not pattern then
        return ""
    end
    local special = { "%", "^", "$", "(", ")", ".", "[", "]", "*", "+", "-", "?" }
    for _, c in ipairs(special) do
        pattern = pattern:gsub("%" .. c, "%%" .. c)
    end
    return pattern
end

return M
