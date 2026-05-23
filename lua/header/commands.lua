local M = {}

local licenses = {
    "agpl3",
    "apache",
    "bsd2",
    "bsd3",
    "cc0",
    "gpl3",
    "isc",
    "mit",
    "mpl",
    "unlicense",
    "wtfpl",
    "x11",
    "zlib",
}

local function is_license(name)
    if not name then
        return false
    end

    name = name:lower()

    for _, license in ipairs(licenses) do
        if license == name then
            return true
        end
    end

    return false
end

local function deprecated(old, new)
    vim.notify_once(
        ("%s is deprecated and will be removed in a future release. Use %s instead."):format(old, new),
        vim.log.levels.WARN
    )
end

function M.create_user_commands(header)
    vim.api.nvim_create_user_command("Header", function(opts)
        local arg = vim.trim(opts.args or "")

        if arg == "" then
            header.add_header()
            return
        end

        local license = arg:lower()

        if is_license(license) then
            header.add_license_header(license)
            return
        end

        vim.notify(("Unknown header command or license: %s"):format(arg), vim.log.levels.ERROR)
    end, {
        nargs = "?",

        complete = function(arg_lead)
            local matches = {}

            arg_lead = arg_lead:lower()

            for _, license in ipairs(licenses) do
                if license:find("^" .. arg_lead) then
                    table.insert(matches, license)
                end
            end

            return matches
        end,
    })

    vim.api.nvim_create_user_command("AddHeader", function()
        deprecated(":AddHeader", ":Header")
        header.add_header()
    end, {})

    for _, name in ipairs(licenses) do
        local old_cmd = "AddLicense" .. name:upper()
        local new_cmd = ":Header " .. name

        vim.api.nvim_create_user_command(old_cmd, function()
            deprecated(":" .. old_cmd, new_cmd)
            header.add_license_header(name)
        end, {})
    end
end

return M
