require("plenary.reload").reload_module("header", true)

describe("setup", function()
  local header = require("header")
  it("setup with default configs", function()
    local expected = {
      file_name = true,
      author = nil,
      project = nil,
      date_created = true,
      date_created_fmt = "%Y-%m-%d %H:%M:%S",
      line_separator = "------",
      copyright_text = nil,
    }
    header.setup()
    assert.are.same(header.config, expected)
  end)

  it("setup with custom configs", function()
    local expected = {
      file_name = true,
      author = "test_author",
      project = "test_project",
      date_created = true,
      date_created_fmt = "%Y-%m-%d %H:%M:%S",
      line_separator = "------",
      copyright_text = "test_copyright",
    }
    header.setup(expected)
    assert.are.same(header.config, expected)
  end)
end)

describe("add_headers", function()
  require("plenary.reload").reload_module("header", true)
  local header = require("header")
  it("should insert headers to cpp file", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    local file_name = "main.cc"
    vim.fn.setline(1, file_name)
    vim.api.nvim_buf_set_name(0, file_name)

    header.add_headers()

    local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    local expected = {
      "/*",
      "* File name: " .. file_name,
      "* Date Created: 1970-01-01 00:59:59",
      "* ------",
      "*/",
      "",
      file_name,
    }

    assert.are.same(expected, buffer)
  end)
  it("should insert additional brief information to header", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    local file_name = "main.cc"
    vim.fn.setline(1, file_name)
    vim.api.nvim_buf_set_name(0, file_name)

    local config = {
      file_name = true,
      author = "test_author",
      project = "test_project",
      date_created = true,
      date_created_fmt = "%Y-%m-%d %H:%M:%S",
      line_separator = "------",
      copyright_text = "test_copyright",
    }
    header.setup(config)

    header.add_headers()

    local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    local expected = {
      "/*",
      "* File name: " .. file_name,
      "* Project: " .. config.project,
      "* Author: " .. config.author,

      "* Date Created: 1970-01-01 00:59:59",
      "* ------",
      "* " .. config.copyright_text,
      "*/",
      "",
      file_name,
    }

    assert.are.same(expected, buffer)
  end)
end)

describe("add_license_header", function()
  require("plenary.reload").reload_module("header", true)
  local header = require("header")
  it("should insert mit header to cpp file", function()
    local config = {
      author = "test_author",
    }
    header.setup(config)

    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    local file_name = "main.cc"
    vim.fn.setline(1, file_name)
    vim.api.nvim_buf_set_name(0, file_name)

    header.add_license_header("mit")

    local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    local expected = {
      "/*",
      "* Copyright (c) 2023 " .. config.author,
      "* Permission is hereby granted, free of charge, to any person obtaining a copy",
      '* of this software and associated documentation files (the "Software"), to deal',
      "* in the Software without restriction, including without limitation the rights",
      "* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell",
      "* copies of the Software, and to permit persons to whom the Software is",
      "* furnished to do so, subject to the following conditions:",
      "* The above copyright notice and this permission notice shall be included in all",
      "* copies or substantial portions of the Software.",
      '* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,',
      "* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF",
      "* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.",
      "* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,",
      "* DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR",
      "* OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE",
      "* OR OTHER DEALINGS IN THE SOFTWARE.",
      "*/",
      "",
      file_name,
    }

    assert.are.same(expected, buffer)
  end)
end)
