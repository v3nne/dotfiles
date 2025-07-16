return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      hide_numbers    = true,
      shade_terminals = true,
      shading_factor  = 2,
      start_in_insert = true,
      persist_size    = true,
      direction       = "float",
      close_on_exit   = false, -- keep the terminal open in the background
      hidden          = true,
      open_mapping    = "<A-f>",
      float_opts      = {
        border        = "single",
        winblend      = 0,
      },
    })

    -- make Esc put you into Terminal-Normal mode,
    -- and in Terminal-Normal, pressing i drops you back into insert
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function()
        -- in Terminal-Insert (the shell), Esc → <C-\><C-n>
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = true, silent = true })

        -- in Terminal-Normal mode, i → re-enter insert (the shell)
        vim.keymap.set("n", "i", [[<Cmd>startinsert<CR>]], { buffer = true, silent = true })
      end
    })
  end
}

