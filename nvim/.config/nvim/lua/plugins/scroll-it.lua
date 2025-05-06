return {
    {
        "jackplus-xyz/scroll-it.nvim",
        config = function()
            require("scroll-it").setup({
                -- Add any custom configuration here if needed
                scroll_speed = 5, -- Example: Set scroll speed
            })
        end,
    },
}
