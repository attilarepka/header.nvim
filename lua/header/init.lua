local config = require("header.config")
local commands = require("header.commands")
local core = require("header.core")

local M = {
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

M.setup = function(params)
    if not check_vim_version() then
        return
    end
    M.config = vim.tbl_extend("force", M.config, params or {})

    local file_cfg = config.read_config_file()
    if file_cfg then
        M.config = vim.tbl_extend("force", M.config, file_cfg)
    end

    commands.create_user_commands(M)
end

M.reset = function()
    M.config = vim.deepcopy(config.defaults)
end

M.add_header = function()
    if check_vim_version() then
        core.add_header(M)
    end
end

M.add_headers = function()
    vim.notify_once("header.add_headers() is deprecated, use header.add_header() instead", vim.log.levels.WARN)

    return M.add_header()
end

M.add_license_header = function(opts)
    if check_vim_version() then
        core.add_license_header(M, opts)
    end
end

return M
