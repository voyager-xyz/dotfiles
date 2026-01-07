

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "pyright",
        "ruff-lsp",
        "stylua",
        "debugpy",
        "tree-sitter-cli",
      },
    },
  },
}
