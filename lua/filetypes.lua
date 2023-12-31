local languages = require("languages")

local filetype_table = {}

filetype_table = {
    ["c"] = languages.cpp,
    ["cc"] = languages.cpp,
    ["cpp"] = languages.cpp,
    ["h"] = languages.cpp,
    ["hh"] = languages.cpp,
    ["hpp"] = languages.cpp,
    ["py"] = languages.python,
    ["robot"] = languages.python,
    ["lua"] = languages.lua,
    ["java"] = languages.java,
    ["js"] = languages.javascript,
    ["cs"] = languages.csharp,
    ["swift"] = languages.swift,
    ["rb"] = languages.ruby,
    ["kt"] = languages.kotlin,
    ["sc"] = languages.scala,
    ["go"] = languages.go,
    ["rs"] = languages.rust,
    ["php"] = languages.php,
    ["sh"] = languages.shell,
    ["hs"] = languages.haskell,
    ["lhs"] = languages.haskell,
    ["pl"] = languages.perl,
    ["ts"] = languages.typescript,
    ["tsx"] = languages.typescript,
    ["coffee"] = languages.coffeescript,
    ["groovy"] = languages.groovy,
    ["gvy"] = languages.groovy,
    ["gy"] = languages.groovy,
    ["gsh"] = languages.groovy,
    ["dart"] = languages.dart,
    ["r"] = languages.r,
}

return filetype_table
