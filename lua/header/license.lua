local util = require("header.util")
local M = {}

function M.scan_license_files()
    local names = {
        "^LICENSE$",
        "^LICENSE%.md$",
        "^LICENSE%-.*$",
        "^COPYING$",
        "^COPYING%.md$",
        "^UNLICENSE$",
        "^UNLICENSE%.md$",
        "^LICENCE$",
        "^LICENCE%.md$",
        "^LICENCE%-.*$",
        "^NOTICE$",
        "^NOTICE%.md$",
        "^LEGAL$",
        "^LEGAL%.md$",
    }

    local found = {}
    local p = io.popen("ls -a")
    if not p then
        return found
    end

    for f in p:lines() do
        for _, pat in ipairs(names) do
            if f:match(pat) then
                table.insert(found, f)
                break
            end
        end
    end
    p:close()
    return found
end

function M.read_license_file(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()
    if not content or content == "" then
        return nil
    end
    return vim.split(content, "\n", { plain = true })
end

function M.select_license_file(options, callback, header)
    local current = 1
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, options)
    local h, w = #options, 30
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = math.floor((vim.o.lines - h) / 2),
        col = math.floor((vim.o.columns - w) / 2),
        width = w,
        height = h,
        style = "minimal",
        border = "rounded",
    })

    local ns = vim.api.nvim_create_namespace("popup_select_ns")
    local function highlight()
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns, "Visual", current - 1, 0, -1)
    end
    highlight()

    local function move(d)
        current = ((current - 1 + d) % #options) + 1
        highlight()
    end

    local function select()
        local choice = options[current]
        vim.api.nvim_win_close(win, true)
        header.selected_license_file = choice
        callback(choice)
    end

    local function quit()
        vim.api.nvim_win_close(win, true)
        callback(nil)
    end

    local function map(k, f)
        vim.api.nvim_buf_set_keymap(buf, "n", k, "", { callback = f, noremap = true, silent = true })
    end

    map("j", function()
        move(1)
    end)
    map("k", function()
        move(-1)
    end)
    map("<down>", function()
        move(1)
    end)
    map("<up>", function()
        move(-1)
    end)
    map("<cr>", select)
    map("q", quit)

    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"
end

return M
