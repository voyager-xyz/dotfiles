-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Setup pytest terminal keybindings
local Terminal = require("toggleterm.terminal").Terminal
local last_pytest_args = ""

-- Run pytest with no args
vim.keymap.set("n", "<leader>tr", function()
  local pytest = Terminal:new({
    cmd = "poetry run pytest",
    direction = "tab",
    close_on_exit = false,
  })
  pytest:toggle()
end, {
  noremap = true,
  silent = true,
  desc = "Run pytest",
})

-- Run pytest with args (remembers last args)
vim.keymap.set("n", "<leader>tR", function()
  local args = vim.fn.input("pytest args: ", last_pytest_args)
  last_pytest_args = args
  
  local cmd = args ~= "" and "poetry run pytest " .. args or "poetry run pytest"
  local pytest = Terminal:new({
    cmd = cmd,
    direction = "tab",
    close_on_exit = false,
  })
  pytest:toggle()
end, {
  noremap = true,
  silent = true,
  desc = "Run pytest with args",
})

-- Register with which-key
local wk_status, wk = pcall(require, "which-key")
if wk_status then
  wk.add({
    { "<leader>tr", desc = "Run pytest" },
    { "<leader>tR", desc = "Run pytest with args" },
  })
end
