return {
    "nvim-telescope/telescope.nvim",

    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    keys = {
        {
            "<leader>ff",
            function()
                require("telescope.builtin").find_files()
            end,
            desc = "Find files",
        },

        {
            "<leader>fo",
            function()
                require("telescope.builtin").oldfiles()
            end,
            desc = "Recent files",
        },

        {
            "<leader>fq",
            function()
                require("telescope.builtin").quickfix()
            end,
            desc = "Quickfix list",
        },

        {
            "<leader>fh",
            function()
                require("telescope.builtin").help_tags()
            end,
            desc = "Help tags",
        },

        {
            "<leader>fb",
            function()
                require("telescope.builtin").buffers()
            end,
            desc = "Buffers",
        },

        {
            "<leader>fg",
            function()
                require("telescope.builtin").live_grep()
            end,
            desc = "Live grep",
        },

        {
            "<leader>fw",
            function()
                require("telescope.builtin").grep_string({
                    search = vim.fn.expand("<cword>"),
                })
            end,
            desc = "Grep word under cursor",
        },

        {
            "<leader>fc",
            function()
                local filename = vim.fn.expand("%:t:r")

                require("telescope.builtin").grep_string({
                    search = filename,
                })
            end,
            desc = "Find current file references",
        },

        {
            "<leader>fs",
            function()
                require("telescope.builtin").grep_string()
            end,
            desc = "Find current string",
        },

        {
            "<leader>fi",
            function()
                require("telescope.builtin").find_files({
                    cwd = vim.fn.stdpath("config"),
                })
            end,
            desc = "Find Neovim config",
        },
    },

    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                    },
                },

                file_ignore_patterns = {
                    ".*%.lock$",
                    ".*%.lock.json$",
                },
            },
        })
    end,
}
