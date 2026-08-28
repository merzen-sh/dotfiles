 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#111418',
    base01 = '#1d2024',
    base02 = '#272a2f',
    base03 = '#8d9199',
    base04 = '#c3c6cf',
    base05 = '#e1e2e8',
    base06 = '#e1e2e8',
    base07 = '#e1e2e8',
    base08 = '#ffb4ab',
    base09 = '#d7bde4',
    base0A = '#bbc7db',
    base0B = '#a2c9fd',
    base0C = '#d7bde4',
    base0D = '#a2c9fd',
    base0E = '#bbc7db',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e1e2e8',          bg = '#111418' })
  hi('TelescopeBorder',         { fg = '#8d9199',             bg = '#111418' })
  hi('TelescopePromptNormal',   { fg = '#e1e2e8',          bg = '#111418' })
  hi('TelescopePromptBorder',   { fg = '#8d9199',             bg = '#111418' })
  hi('TelescopePromptPrefix',   { fg = '#a2c9fd',             bg = '#111418' })
  hi('TelescopePromptCounter',  { fg = '#c3c6cf',  bg = '#111418' })
  hi('TelescopePromptTitle',    { fg = '#111418',             bg = '#a2c9fd' })
  hi('TelescopePreviewTitle',   { fg = '#111418',             bg = '#bbc7db' })
  hi('TelescopeResultsTitle',   { fg = '#111418',             bg = '#d7bde4' })
  hi('TelescopeSelection',      { fg = '#e1e2e8',          bg = '#272a2f' })
  hi('TelescopeSelectionCaret', { fg = '#a2c9fd',             bg = '#272a2f' })
  hi('TelescopeMatching',       { fg = '#a2c9fd',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
