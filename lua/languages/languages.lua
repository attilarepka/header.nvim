local languages = {}
languages.cpp = function()
    local comments = {
        comment_start = "/*",
        comment = "*",
        comment_end = "*/",
    }
    return comments
end
languages.python = function()
    local comments = {
        comment_start = nil,
        comment = "#",
        comment_end = nil,
    }
    return comments
end
languages.lua = function()
    local comments = {
        comment_start = "--[[",
        comment = "--",
        comment_end = "--]]",
    }
    return comments
end
languages.java = function()
    local comments = {
        comment_start = "/*",
        comment = "*",
        comment_end = "*/",
    }
    return comments
end
languages.javascript = function()
    local comments = {
        comment_start = "/*",
        comment = "*",
        comment_end = "*/",
    }
    return comments
end
languages.csharp = function()
    local comments = {
        comment_start = "/*",
        comment = "*",
        comment_end = "*/",
    }
    return comments
end
languages.swift = function()
    local comments = {
        comment_start = "/*",
        comment = "*",
        comment_end = "*/",
    }
    return comments
end
languages.ruby = function()
    local comments = {
        comment_start = "=begin",
        comment = "#",
        comment_end = "=end",
    }
    return comments
end
languages.kotlin = function()
    local comments = {
        comment_start = "/*",
        comment = "//",
        comment_end = "*/",
    }
    return comments
end
languages.scala = function()
    local comments = {
        comment_start = "/*",
        comment = "//",
        comment_end = "*/",
    }
    return comments
end
languages.go = function()
    local comments = {
        comment_start = "/*",
        comment = "//",
        comment_end = "*/",
    }
    return comments
end
languages.rust = function()
    local comments = {
        comment_start = "/*",
        comment = "//",
        comment_end = "*/",
    }
    return comments
end
languages.php = function()
    local comments = {
        comment_start = "/*",
        comment = "//",
        comment_end = "*/",
    }
    return comments
end
languages.shell = function()
    local comments = {
        comment_start = nil,
        comment = "#",
        comment_end = nil,
    }
    return comments
end
languages.haskell = function()
    local comments = {
        comment_start = "{-",
        comment = "--",
        comment_end = "-}",
    }
    return comments
end
languages.perl = function()
    local comments = {
        comment_start = "=pod",
        comment = "#",
        comment_end = "=cut",
    }
    return comments
end
languages.typescript = function()
    local comments = {
        comment_start = "/*",
        comment = "//",
        comment_end = "*/",
    }
    return comments
end
languages.coffeescript = function()
    local comments = {
        comment_start = "###",
        comment = "#",
        comment_end = "###",
    }
    return comments
end
languages.groovy = function()
    local comments = {
        comment_start = "/*",
        comment = "//",
        comment_end = "*/",
    }
    return comments
end
languages.dart = function()
    local comments = {
        comment_start = "/*",
        comment = "//",
        comment_end = "*/",
    }
    return comments
end
languages.r = function()
    local comments = {
        comment_start = nil,
        comment = "#",
        comment_end = nil,
    }
    return comments
end
return languages
