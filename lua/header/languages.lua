local comment_styles = require("header.comment_styles")

local M = {}

local function make_language(comment_style, resolve_fn)
    return function()
        return {
            comment_style = comment_style,
            resolve_insertion = resolve_fn or function()
                return { ok = true, insert_line = 0 }
            end,
        }
    end
end

local simple_languages = {
    { "c", comment_styles.cstyle },
    { "cc", comment_styles.cstyle },
    { "cpp", comment_styles.cstyle },
    { "h", comment_styles.cstyle },
    { "hh", comment_styles.cstyle },
    { "hpp", comment_styles.cstyle },
    { "java", comment_styles.cstyle },
    { "js", comment_styles.cstyle },
    { "ts", comment_styles.cstyle },
    { "tsx", comment_styles.cstyle },
    { "cs", comment_styles.cstyle },
    { "swift", comment_styles.cstyle },
    { "kt", comment_styles.cstyle },
    { "sc", comment_styles.cstyle },
    { "go", comment_styles.cstyle },
    { "rs", comment_styles.cstyle },
    { "groovy", comment_styles.cstyle },
    { "gvy", comment_styles.cstyle },
    { "gy", comment_styles.cstyle },
    { "gsh", comment_styles.cstyle },
    { "dart", comment_styles.cstyle },
    { "yml", comment_styles.hash },
    { "yaml", comment_styles.hash },
    { "robot", comment_styles.hash },
    { "r", comment_styles.hash },
    { "lua", comment_styles.lua },
    { "html", comment_styles.html },
    { "hs", comment_styles.haskell },
    { "lhs", comment_styles.haskell },
    { "rb", comment_styles.ruby },
    { "pl", comment_styles.ruby },
    { "coffee", comment_styles.coffee },
}

for _, lang in ipairs(simple_languages) do
    M[lang[1]] = make_language(lang[2])
end

M.php = make_language(comment_styles.cstyle, function(lines)
    for i, line in ipairs(lines) do
        if line:match("^%s*<%?php") or line:match("^%s*<%?") then
            return { ok = true, insert_line = i }
        end
    end
    return { ok = true, insert_line = 0 }
end)

M.sh = make_language(comment_styles.hash, function(lines)
    if lines[1] and lines[1]:match("^#!") then
        return { ok = true, insert_line = 1 }
    end
    return { ok = true, insert_line = 0 }
end)

M.py = make_language(comment_styles.hash, function(lines)
    local insert_line = 0
    if lines[1] and lines[1]:match("^#!") then
        insert_line = 1
    end
    local next_line = lines[insert_line + 1]
    if next_line and next_line:match("coding[:=]") then
        insert_line = insert_line + 1
    end
    return { ok = true, insert_line = insert_line }
end)

return M
