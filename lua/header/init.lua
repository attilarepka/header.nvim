local config = require("header.config")
local commands = require("header.commands")
local core = require("header.core")

local header = {
    config = config.defaults,
    constants = config.constants,
    selected_license_file = nil,
}

local function check_vim_version()
    if vim.version().minor < 8 then
        vim.notify_once("header.nvim: requires Neovim ≥0.8", vim.log.levels.ERROR)
        return false
    end
    return true
end

header.setup = function(params)
    if not check_vim_version() then
        return
    end
    header.config = vim.tbl_extend("force", header.config, params or {})

    local file_cfg = config.read_config_file()
    if file_cfg then
        header.config = vim.tbl_extend("force", header.config, file_cfg)
    end

    commands.create_user_commands(header)
end

header.reset = function()
    header.config = vim.deepcopy(config.defaults)
end

header.add_headers = function()
    if check_vim_version() then
        core.add_headers(header)
    end
end

header.add_license_header = function(opts)
    if check_vim_version() then
        core.add_license_header(header, opts)
    end
end

header.update_date_modified = function()
    if check_vim_version() then
        core.update_date_modified(header)
    end
end

return header
