local M = {}

function M.create_user_commands(header)
    vim.api.nvim_create_user_command("AddHeader", function()
        header.add_headers()
    end, {})

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

    for _, name in ipairs(licenses) do
        vim.api.nvim_create_user_command("AddLicense" .. name:upper(), function()
            header.add_license_header(name)
        end, {})
    end

    vim.api.nvim_create_user_command("UpdateDateModified", function()
        header.update_date_modified()
    end, {})
end

return M
