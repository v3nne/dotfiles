return {
  "olimorris/codecompanion.nvim",
  -- opts = {},
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function ()
    require("codecompanion").setup({
      adapters = {
        gemini = function ()
          return require("codecompanion.adapters").extend("gemini", {
            schema = {
              model = { default = "gemini-2.5-pro" }
            }
          })
        end
      },
      strategies = {
        chat   = { adapter = "gemini" },
        inline = { adapter = "gemini" },
        cmd    = { adapter = "gemini" },
      },
    })
  end
}
