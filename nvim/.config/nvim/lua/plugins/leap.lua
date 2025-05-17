return {
  "ggandor/leap.nvim",
  dependencies = {
    "tpope/vim-repeat",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["s"] = { "<Plug>(leap-forward)", desc = "Leap forward" },
            ["S"] = { "<Plug>(leap-backward)", desc = "Leap backward" },
            ["gs"] = {  
              function() 
                require("leap.remote").action() 
              end,
              desc = "Leap remote operation",},
          },
          x = {
            ["s"] = { "<Plug>(leap-forward)", desc = "Leap forward" },
            ["S"] = { "<Plug>(leap-backward)", desc = "Leap backward" },
            ["gs"] = {
              function() 
                require("leap.remote").action() 
              end,
              desc = "Leap remote operation", },
          },
          o = {
            ["s"] = { "<Plug>(leap-forward)", desc = "Leap forward" },
            ["S"] = { "<Plug>(leap-backward)", desc = "Leap backward" },
            ["gs"] = {  
              function() 
                require("leap.remote").action() 
              end,
              desc = "Leap remote operation",},
          },
        },
      },
    },
  },
  specs = {
    {
      "catppuccin",
      optional = true,
      ---@type CatppuccinOptions
      opts = { integrations = { leap = true } },
    },
  },
  opts = {},
}