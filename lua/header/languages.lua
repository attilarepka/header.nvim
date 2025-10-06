local languages = {}

languages.cpp = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.python = function()
    return {
        block = nil,
        line = { start = nil, line = "#", ["end"] = nil },
    }
end

languages.lua = function()
    return {
        block = { start = "--[[", line = "--", ["end"] = "--]]" },
        line = { start = nil, line = "--", ["end"] = nil },
    }
end

languages.java = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.javascript = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.csharp = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.swift = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.ruby = function()
    return {
        block = { start = "=begin", line = "#", ["end"] = "=end" },
        line = { start = nil, line = "#", ["end"] = nil },
    }
end

languages.kotlin = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.scala = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.go = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.rust = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.php = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.shell = function()
    return {
        block = nil,
        line = { start = nil, line = "#", ["end"] = nil },
    }
end

languages.haskell = function()
    return {
        block = { start = "{-", line = "--", ["end"] = "-}" },
        line = { start = nil, line = "--", ["end"] = nil },
    }
end

languages.perl = function()
    return {
        block = { start = "=begin", line = "#", ["end"] = "=cut" },
        line = { start = nil, line = "#", ["end"] = nil },
    }
end

languages.typescript = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.coffeescript = function()
    return {
        block = { start = "###", line = "#", ["end"] = "###" },
        line = { start = nil, line = "#", ["end"] = nil },
    }
end

languages.groovy = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.dart = function()
    return {
        block = { start = "/*", line = "*", ["end"] = "*/" },
        line = { start = nil, line = "//", ["end"] = nil },
    }
end

languages.r = function()
    return {
        block = nil,
        line = { start = nil, line = "#", ["end"] = nil },
    }
end

return languages
