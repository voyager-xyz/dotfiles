return {
    {
        "mbbill/undotree",
        cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide", "UndotreeFocus" },
        keys = {
            { "<leader>U", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree" },
        },
        config = function()
            -- Optional: Set undotree window width and layout
            vim.g.undotree_WindowLayout = 2
            vim.g.undotree_SplitWidth = 40
        end,
    },
}