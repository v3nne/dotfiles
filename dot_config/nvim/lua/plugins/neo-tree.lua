vim.pack.add({
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/nvim-neo-tree/neo-tree.nvim"
})

require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "single",
  enable_git_status = true,
  enable_diagnostics = true,

  window = {
    position = "float",
    popup = {
      size = {
        height = "85%",
        width = "30%",
      },
      position = "50%",
    },
    mappings = {
      ["l"] = "open",
      ["h"] = "close_node",
      ["<Right>"] = "open",
      ["<Left>"] = "close_node",
      -- ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = false } },
    },
  },

  filesystem = {
    use_libuv_file_watcher = true,
    follow_current_file = {
      enabled = true,
    },
  },

  preview = {
    enabled = true,
  },
})

map("n", "<leader>E", ":Neotree toggle<CR>", "File [E]xplorer")

