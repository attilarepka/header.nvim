local M = {}

local function replace_token(str, token, value)
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

function M.replace_all_tokens(license_text, header)
    license_text = replace_token(license_text, "project", header.config.project)
    license_text = replace_token(license_text, "organization", header.config.author)
    license_text = replace_token(license_text, "year", os.date("%Y"))
    return license_text
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
