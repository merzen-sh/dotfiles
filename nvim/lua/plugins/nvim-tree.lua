return {
    "nvim-tree/nvim-tree.lua",

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    keys = {
        {
            "<leader>cd",
            "<cmd>NvimTreeToggle<CR>",
            desc = "Toggle NvimTree",
        },

        {
            "<leader>ef",
            "<cmd>NvimTreeFindFile<CR>",
            desc = "Find file in NvimTree",
        },
    },

    opts = {
        -- =====================================================================
        -- View
        -- =====================================================================

        view = {
            width = 35,
            side = "left",
        },


        -- =====================================================================
        -- Renderer
        -- =====================================================================

        renderer = {
            icons = {
                show = {
                    file = true,
                    folder = false,
                    folder_arrow = true,
                    git = true,
                },

                glyphs = {
                    git = {
                        unstaged = "",
                        staged = "",
                        unmerged = "",
                        renamed = "➜",
                        untracked = "",
                        deleted = "",
                        ignored = "I",
                    },
                },
            },
        },


        -- =====================================================================
        -- Git
        -- =====================================================================

        git = {
            enable = true,
            ignore = false,
        },


        -- =====================================================================
        -- Filesystem Watchers
        -- =====================================================================

        filesystem_watchers = {
            enable = true,

            ignore_dirs = {
                "target",
                "node_modules",
                ".git",
            },
        },


        -- =====================================================================
        -- Filters
        -- =====================================================================

        filters = {
            dotfiles = false,
            git_ignored = false,

            custom = {
                "^.git$",
            },
        },


        -- =====================================================================
        -- Actions
        -- =====================================================================

        actions = {
            open_file = {
                quit_on_open = true,
            },
        },
    },
}
