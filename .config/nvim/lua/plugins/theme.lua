return {
 	{
 	  "xiyaowong/nvim-transparent",
 	  lazy = false,
 	  priority = 999,
 	  opts = {
 	    extra_groups = {
        -- which-key, Lazy
 	      "NormalFloat", "FloatBorder", "FloatTitle",
        -- blink.cmp
        "BlinkCmpMenu", "BlinkCmpMenuBorder", "BlinkCmpMenuSelection",
        "BlinkCmpDoc", "BlinkCmpDocBorder", "BlinkCmpDocSeparator",
        -- Command bar's suggestions window
        -- "Pmenu", "PmenuSel",
      }
 	  }
 	},
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_transparent_background = 1
      vim.g.gruvbox_material_float_style = "dim"
      vim.g.gruvbox_material_diagnostic_line_highlight = 1
      vim.cmd.colorscheme('gruvbox-material')
    end
  }
}
