local languages = {}
languages.cpp = function(use_block_header)
    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.python = function(_)
    local comments = {
        comment_start = nil,
        comment = "#",
        comment_end = nil,
    }
    return comments
end
languages.lua = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "--[[" or nil,
        comment = "--",
        comment_end = use_block_header and "--]]" or nil,
    }
    return comments
end
languages.java = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.javascript = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.csharp = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.swift = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.ruby = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "=begin" or nil,
        comment = "#",
        comment_end = use_block_header and "=end" or nil,
    }
    return comments
end
languages.kotlin = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.scala = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.go = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.rust = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.php = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.shell = function(_)
    local comments = {
        comment_start = nil,
        comment = "#",
        comment_end = nil,
    }
    return comments
end
languages.haskell = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "{-" or nil,
        comment = "--",
        comment_end = use_block_header and "-}" or nil,
    }
    return comments
end
languages.perl = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "=pod" or nil,
        comment = "#",
        comment_end = use_block_header and "=cut" or nil,
    }
    return comments
end
languages.typescript = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.coffeescript = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "###" or nil,
        comment = "#",
        comment_end = use_block_header and "###" or nil,
    }
    return comments
end
languages.groovy = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.dart = function(use_block_header)
    if use_block_header ~= nil then
        use_block_header = true
    end

    local comments = {
        comment_start = use_block_header and "/*" or nil,
        comment = use_block_header and "*" or "//",
        comment_end = use_block_header and "*/" or nil,
    }
    return comments
end
languages.r = function(_)
    local comments = {
        comment_start = nil,
        comment = "#",
        comment_end = nil,
    }
    return comments
end

return languages
