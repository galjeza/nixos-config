return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    config = function()
      vim.cmd('colorscheme rose-pine-main')
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    lazy = true,
  },
  {
    'vague2k/vague.nvim',
    lazy = true,
    config = function()
      require('vague').setup({
        transparent = true,
      })
    end,
  },
}
