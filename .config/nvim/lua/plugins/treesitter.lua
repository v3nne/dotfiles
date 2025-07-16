return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      -- vim stuff
      "lua", "vim", "vimdoc",

      -- webdev
      "javascript", "typescript", "jsx", "tsx", "css", "html",

      -- configuration
      "json", "yaml", "toml", "make", "gitignore",

      -- scripting
      "bash", "python",

      -- devops
      "dockerfile", "terraform",

      -- database
      "sql",
    }
  },
  highlight = {
    enable = true,
    -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
    --  If you are experiencing weird indenting issues, add the language to
    --  the list of additional_vim_regex_highlighting and disabled languages for indent.
    additional_vim_regex_highlighting = { 'ruby', 'markdown' },
  },
  indent = { enable = true },
  -- sync_install = false,
  config = function (_, opts)
    vim.g.markdown_fenced_languages = opts.ensure_installed
  end
}
