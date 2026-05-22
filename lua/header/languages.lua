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

M.c = make_language(comment_styles.cstyle)
M.cc = make_language(comment_styles.cstyle)
M.cpp = make_language(comment_styles.cstyle)
M.h = make_language(comment_styles.cstyle)
M.hh = make_language(comment_styles.cstyle)
M.hpp = make_language(comment_styles.cstyle)
M.java = make_language(comment_styles.cstyle)
M.js = make_language(comment_styles.cstyle)
M.ts = make_language(comment_styles.cstyle)
M.tsx = make_language(comment_styles.cstyle)
M.cs = make_language(comment_styles.cstyle)
M.swift = make_language(comment_styles.cstyle)
M.kt = make_language(comment_styles.cstyle)
M.sc = make_language(comment_styles.cstyle)
M.go = make_language(comment_styles.cstyle)
M.rs = make_language(comment_styles.cstyle)
M.groovy = make_language(comment_styles.cstyle)
M.gvy = make_language(comment_styles.cstyle)
M.gy = make_language(comment_styles.cstyle)
M.gsh = make_language(comment_styles.cstyle)
M.dart = make_language(comment_styles.cstyle)

M.robot = make_language(comment_styles.hash)
M.r = make_language(comment_styles.hash)

M.lua = make_language(comment_styles.lua)

M.html = make_language(comment_styles.html)

M.hs = make_language(comment_styles.haskell)
M.lhs = make_language(comment_styles.haskell)

M.rb = make_language(comment_styles.ruby)
M.pl = make_language(comment_styles.ruby)

M.coffee = make_language(comment_styles.coffee)

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
