-- Compatibility shim for nvim-treesitter's archived `master` branch on Neovim 0.12.
--
-- Neovim 0.12 changed query directive/predicate handlers so that `match[capture]`
-- is a list of nodes (`TSNode[]`) instead of a single `TSNode`. nvim-treesitter
-- master still assumes a single node, so `#set-lang-from-info-string!` and
-- friends end up passing a table to `vim.treesitter.get_node_text()`, which fails
-- with "attempt to call method 'range' (a nil value)".
--
-- Re-register the affected handlers with list-aware unwrapping.

local M = {}

local query = require("vim.treesitter.query")

local html_script_type_languages = {
    ["importmap"] = "json",
    ["module"] = "javascript",
    ["application/ecmascript"] = "javascript",
    ["text/ecmascript"] = "javascript",
}

local non_filetype_match_injection_language_aliases = {
    ex = "elixir",
    pl = "perl",
    sh = "bash",
    uxn = "uxntal",
    ts = "typescript",
}

local opts = { force = true }

-- Neovim 0.12 passes `match[id]` as a list of nodes; older versions passed a node.
local function get_node(match, id)
    local capture = match[id]
    if type(capture) == "table" then
        return capture[1]
    end
    return capture
end

local function get_parser_from_markdown_info_string(injection_alias)
    local filetype = vim.filetype.match({ filename = "a." .. injection_alias })
    return filetype or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
end

local function valid_args(name, pred, count, strict_count)
    local arg_count = #pred - 1

    if strict_count then
        if arg_count ~= count then
            vim.api.nvim_err_writeln(string.format("%s must have exactly %d arguments", name, count))
            return false
        end
    elseif arg_count < count then
        vim.api.nvim_err_writeln(string.format("%s must have at least %d arguments", name, count))
        return false
    end

    return true
end

function M.apply()
    -- Ensure nvim-treesitter's own handlers are registered first so that this
    -- module reliably overrides them.
    require("nvim-treesitter")

    query.add_predicate("nth?", function(match, _, _, pred)
        if not valid_args("nth?", pred, 2, true) then
            return
        end

        local node = get_node(match, pred[2])
        local n = tonumber(pred[3])
        if node and node:parent() and node:parent():named_child_count() > n then
            return node:parent():named_child(n) == node
        end

        return false
    end, opts)

    query.add_predicate("is?", function(match, _, bufnr, pred)
        if not valid_args("is?", pred, 2) then
            return
        end

        -- Avoid circular dependencies
        local locals = require("nvim-treesitter.locals")
        local node = get_node(match, pred[2])
        local types = { unpack(pred, 3) }

        if not node then
            return true
        end

        local _, _, kind = locals.find_definition(node, bufnr)

        return vim.tbl_contains(types, kind)
    end, opts)

    query.add_predicate("kind-eq?", function(match, _, _, pred)
        if not valid_args(pred[1], pred, 2) then
            return
        end

        local node = get_node(match, pred[2])
        local types = { unpack(pred, 3) }

        if not node then
            return true
        end

        return vim.tbl_contains(types, node:type())
    end, opts)

    query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
        local node = get_node(match, pred[2])
        if not node then
            return
        end

        local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
        local configured = html_script_type_languages[type_attr_value]
        if configured then
            metadata["injection.language"] = configured
        else
            local parts = vim.split(type_attr_value, "/", {})
            metadata["injection.language"] = parts[#parts]
        end
    end, opts)

    query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
        local node = get_node(match, pred[2])
        if not node then
            return
        end

        local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
        metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
    end, opts)

    -- Just avoid some annoying warnings for this directive
    query.add_directive("make-range!", function() end, opts)

    query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
        local id = pred[2]
        local node = get_node(match, id)
        if not node then
            return
        end

        local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
        if not metadata[id] then
            metadata[id] = {}
        end
        metadata[id].text = string.lower(text)
    end, opts)
end

return M
