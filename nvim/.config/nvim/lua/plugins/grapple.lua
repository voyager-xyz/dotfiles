return {
  {
    "cbochs/grapple.nvim",
    config = function()
      require("grapple").setup({
        -- Add any specific configuration options here
        scope = "global", -- Example: set the scope to global
      })

      -- Key mappings for grapple
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }

      map("n", "<leader>mm", "<cmd>Grapple toggle_tags<CR>", opts)
      map("n", "<leader>ma", "<cmd>Grapple tag<CR>", opts)
      map("n", "<leader>md", "<cmd>Grapple untag<CR>", opts)
      map("n", "<leader>mt", "<cmd>Grapple toggle<CR>", opts)
      map("n", "<leader>mn", "<cmd>Grapple cycle forward<CR>", opts)
      map("n", "<leader>mp", "<cmd>Grapple cycle backward<CR>", opts)
    end,
  },
}
