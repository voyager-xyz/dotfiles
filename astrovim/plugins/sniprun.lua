return {
  "michaelb/sniprun",
  opts = {},
  build = "bash ./install.sh 1",
  cmd = "SnipRun",
  keys = {
    { "<leader>rr", "<cmd>SnipRun<CR>", mode = "n", desc = "SnipRun line" },
    { "<leader>rr", ":'<,'>SnipRun<CR>", mode = "v", desc = "SnipRun selection" },
  },
}