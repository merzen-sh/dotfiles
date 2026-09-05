return {
    -- =========================================================================
    -- Mason
    -- =========================================================================
    {
        "mason-org/mason.nvim",
        opts = {},
    },

    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },

        opts = {
            ensure_installed = {
                "rust_analyzer",
                "jsonls",
                "html",
                "cssls",
                "tailwindcss",
                "ts_ls",
                "marksman",
                "yamlls",
                "oxlint",
                "emmet_ls",
                "svelte",
                "taplo",
                "clangd",
                "pyright",
                "jdtls",
            },

            automatic_installation = true,
        },
    },

    -- =========================================================================
    -- LSP Config
    -- =========================================================================

    {
        "neovim/nvim-lspconfig",

        config = function()
            -- -----------------------------------------------------------------
            -- Rust
            -- -----------------------------------------------------------------

            vim.lsp.config("rust_analyzer", {
                settings = {
                    ["rust-analyzer"] = {
                        -- cargo = {
                        --     allFeatures = true,
                        --     defaultFeature = "dev",
                        -- },
                    },
                },
            })

            -- -----------------------------------------------------------------
            -- JSON
            -- -----------------------------------------------------------------

            vim.lsp.config("jsonls", {
                settings = {
                    json = {
                        validate = {
                            enable = true,
                        },

                        schemas = {
                            {
                                fileMatch = {
                                    "package.json",
                                },

                                url = "https://json.schemastore.org/package",
                            },
                        },
                    },
                },
            })

            -- -----------------------------------------------------------------
            -- Enable LSP servers
            -- -----------------------------------------------------------------

            local servers = {
                "rust_analyzer",
                "jsonls",
                "html",
                "cssls",
                "tailwindcss",
                "ts_ls",
                "marksman",
                "yamlls",
                "oxlint",
                "emmet_ls",
                "svelte",
                "taplo",
                "clangd",
                "pyright",
                "jdtls",
            }

            for _, server in ipairs(servers) do
                vim.lsp.enable(server)
            end
        end,
    },
}
