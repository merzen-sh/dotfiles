return {
    {
        "nvim-treesitter/nvim-treesitter",
        -- ⚡ Explicitly pull the legacy branch where .configs still works
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            -- This works perfectly on the master branch
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "svelte", "html", "css", "javascript", "typescript" },
                highlight = {
                    enable = true,
                },
            })

            -- Neovim 0.12 compatibility for nvim-treesitter master's predicates
            require("config.treesitter_compat").apply()
        end,
    },
}
