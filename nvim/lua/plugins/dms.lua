return {
  "AvengeMedia/base46",
  priority = 1000,
  opts = {},
  config = function(_, opts)
    require("base46").setup(opts)
    vim.cmd.colorscheme("dms")
  end,
}
