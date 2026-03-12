return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function()
      -- vim.cmd('colorscheme rose-pine')
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    lazy = true,
  },
  {
    'vague2k/vague.nvim',
    lazy = false,
    config = function()
      require('vague').setup({
        transparent = true,
        vim.cmd.colorscheme("vague")
      })
      vim.cmd('colorscheme vague')
    end,
  },
}
