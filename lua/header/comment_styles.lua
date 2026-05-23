local M = {}

M.cstyle = {
    block = { start = "/*", line = "*", ["end"] = "*/" },
    line = { start = nil, line = "//", ["end"] = nil },
}

M.hash = {
    block = nil,
    line = { start = nil, line = "#", ["end"] = nil },
}

M.lua = {
    block = { start = "--[[", line = "--", ["end"] = "--]]" },
    line = { start = nil, line = "--", ["end"] = nil },
}

M.html = {
    block = { start = "<!--", line = "--", ["end"] = "-->" },
    line = nil,
}

M.haskell = {
    block = { start = "{-", line = "--", ["end"] = "-}" },
    line = { start = nil, line = "--", ["end"] = nil },
}

M.ruby = {
    block = { start = "=begin", line = "#", ["end"] = "=end" },
    line = { start = nil, line = "#", ["end"] = nil },
}

M.coffee = {
    block = { start = "###", line = "#", ["end"] = "###" },
    line = { start = nil, line = "#", ["end"] = nil },
}

return M
