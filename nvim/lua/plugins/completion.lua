return {
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",

        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "onsails/lspkind.nvim",
        },

        config = function()
            local cmp = require("cmp")
            local lspkind = require("lspkind")

            cmp.setup({
                -- -----------------------------------------------------------------
                -- Completion
                -- -----------------------------------------------------------------

                preselect = cmp.PreselectMode.Item,

                completion = {
                    completeopt = "menu,menuone,noinsert",
                },


                -- -----------------------------------------------------------------
                -- Window
                -- -----------------------------------------------------------------

                window = {
                    documentation = cmp.config.window.bordered(),
                },


                -- -----------------------------------------------------------------
                -- Formatting
                -- -----------------------------------------------------------------

                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                    }),
                },


                -- -----------------------------------------------------------------
                -- Keymaps
                -- -----------------------------------------------------------------

                mapping = cmp.mapping.preset.insert({
                    -- Confirm
                    ["<CR>"] = cmp.mapping.confirm({
                        select = false,
                    }),

                    -- Close completion
                    ["<C-e>"] = cmp.mapping.abort(),

                    -- Trigger completion
                    ["<C-Space>"] = cmp.mapping.complete(),

                    -- Navigate
                    ["<C-n>"] = cmp.mapping.select_next_item({
                        behavior = cmp.SelectBehavior.Select,
                    }),

                    ["<C-p>"] = cmp.mapping.select_prev_item({
                        behavior = cmp.SelectBehavior.Select,
                    }),

                    -- Documentation
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),

                    -- Tab
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif vim.snippet.active({ direction = 1 }) then
                            vim.snippet.jump(1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    -- Shift Tab
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif vim.snippet.active({ direction = -1 }) then
                            vim.snippet.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),


                -- -----------------------------------------------------------------
                -- Sources
                -- -----------------------------------------------------------------

                sources = {
                    {
                        name = "nvim_lsp",
                    },

                    {
                        name = "path",
                    },

                    {
                        name = "buffer",
                        keyword_length = 3,
                    },
                },
            })
        end,
    },
}
