return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "DaikyXendo/nvim-material-icon",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup({
            view = {
                width = 35,
                side = "left",
            },
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
            git = {
                enable = true,
                ignore = false,
            },
            filesystem_watchers = {
                enable = true,
                ignore_dirs = {
                    "target",
                    "node_modules",
                    ".git",
                },
            },
            filters = {
                dotfiles = false,
                git_ignored = false,
                custom = { "^.git$" },
            },
            actions = {
                open_file = {
                    quit_on_open = true,
                },
            },
        })

        -- Keymaps
        vim.keymap.set("n", "<leader>cd", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
        vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find file in NvimTree" })
    end,
}
