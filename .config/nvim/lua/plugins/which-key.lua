return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = {
    "echasnovski/mini.icons",
    "nvim-tree/nvim-web-devicons"
  },
  opts = {
    delay = 1000,
    win = {
      border = "single", -- none (default) | single | double | rounded | solid | shadow
      -- padding = { 0, 0 },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}

