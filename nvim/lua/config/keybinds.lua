-- =============================================================================
-- KEYMAPS
-- =============================================================================

local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =============================================================================
-- Config
-- =============================================================================

map("n", "<leader>rl", function()
    vim.cmd("source " .. vim.fn.stdpath("config") .. "/init.lua")
end, {
    desc = "Reload config",
})

-- =============================================================================
-- Navigation
-- =============================================================================

-- Jump 5 lines
map("n", "<C-j>", "5j", {
    desc = "Jump down 5 lines",
})

map("n", "<C-k>", "5k", {
    desc = "Jump up 5 lines",
})

-- Jump 10 lines
map("n", "<C-d>", "10j", {
    desc = "Jump down 10 lines",
})

map("n", "<C-u>", "10k", {
    desc = "Jump up 10 lines",
})

-- =============================================================================
-- Editing
-- =============================================================================

map("n", "<leader>va", "ggVGY", {
    desc = "Yank entire file",
})

map("n", "<leader>ee", "$", {
    desc = "End of line",
})

map("n", "<leader>ww", "^", {
    desc = "Start of line",
})

map("n", "]q", "<cmd>cnext<CR>", {
    desc = "Next quickfix item",
})

map("n", "[q", "<cmd>cprev<CR>", {
    desc = "Previous quickfix item",
})

-- =============================================================================
-- Save
-- =============================================================================

map("n", "<leader>s", "<cmd>write<CR>", {
    desc = "Save",
})

map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR>", {
    desc = "Save",
})

map("n", "<Esc>", "<cmd>nohlsearch<CR>", {
    desc = "Clear search highlight",
})

-- =============================================================================
-- Windows
-- =============================================================================

map("n", "<C-h>", "<C-w>h", {
    desc = "Move left",
})

map("n", "<C-j>", "<C-w>j", {
    desc = "Move down",
})

map("n", "<C-k>", "<C-w>k", {
    desc = "Move up",
})

map("n", "<C-l>", "<C-w>l", {
    desc = "Move right",
})

map("n", "<leader>wv", "<cmd>vsplit<CR>", {
    desc = "Vertical split",
})

map("n", "<leader>ws", "<cmd>split<CR>", {
    desc = "Horizontal split",
})

map("n", "<leader>wc", "<cmd>close<CR>", {
    desc = "Close window",
})

map("n", "<leader>wo", "<cmd>only<CR>", {
    desc = "Only window",
})

-- =============================================================================
-- Buffers
-- =============================================================================

map("n", "<leader>bn", "<cmd>bnext<CR>", {
    desc = "Next buffer",
})

map("n", "<leader>bp", "<cmd>bprevious<CR>", {
    desc = "Previous buffer",
})

map("n", "<leader>bd", "<cmd>bdelete<CR>", {
    desc = "Delete buffer",
})

map("n", "<leader>bb", "<cmd>buffer #<CR>", {
    desc = "Previous buffer",
})

-- =============================================================================
-- LSP
-- =============================================================================

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = {
            buffer = args.buf,
            silent = true,
        }

        map("n", "gd", vim.lsp.buf.definition, {
            buffer = args.buf,
            desc = "Go to definition",
        })

        map("n", "K", vim.lsp.buf.hover, {
            buffer = args.buf,
            desc = "Hover documentation",
        })

        map("n", "gl", vim.diagnostic.open_float, {
            buffer = args.buf,
            desc = "Line diagnostics",
        })

        map({ "n", "v" }, "ga", vim.lsp.buf.code_action, {
            buffer = args.buf,
            desc = "Code action",
        })

        map("n", "[d", vim.diagnostic.goto_prev, {
            buffer = args.buf,
            desc = "Previous diagnostic",
        })

        map("n", "]d", vim.diagnostic.goto_next, {
            buffer = args.buf,
            desc = "Next diagnostic",
        })

        map("n", "<leader>rn", vim.lsp.buf.rename, {
            buffer = args.buf,
            desc = "Rename symbol",
        })

        map("n", "<leader>ca", vim.lsp.buf.code_action, {
            buffer = args.buf,
            desc = "Code action",
        })
    end,
})

-- =============================================================================
-- Diagnostics
-- =============================================================================

map("n", "<leader>xx", vim.diagnostic.setloclist, {
    desc = "Diagnostics",
})

map("n", "<leader>xd", vim.diagnostic.open_float, {
    desc = "Line diagnostics",
})
