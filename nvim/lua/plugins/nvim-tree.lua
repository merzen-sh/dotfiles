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
                side = "right",
            },
            renderer = {
                icons = {
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                    },
                    glyphs = {
                        git = {
                            unstaged = '',
                            staged = '',
                            unmerged = '',
                            renamed = '➜',
                            untracked = '',
                            deleted = 'D',
                            ignored = 'I',
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
                    quit_on_open = false,
                },
            },
        })

        -- Re-apply base46 nvim-tree highlights after setup
        local ok, base46 = pcall(require, "base46")
        if ok and base46.current_theme and base46.theme_tables[base46.current_theme] then
            local highlights = base46.get_integration("nvimtree")
            if highlights then
                for hlname, hlopts in pairs(highlights) do
                    vim.api.nvim_set_hl(0, hlname, hlopts)
                end
            end
        end

        -- Keymaps
        vim.keymap.set('n', '<leader>cd', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })
        vim.keymap.set('n', '<leader>ef', ':NvimTreeFindFile<CR>', { desc = 'Find file in NvimTree' })
    end,
}
