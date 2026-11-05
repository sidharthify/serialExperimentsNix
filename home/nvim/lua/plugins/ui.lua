return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
      news = { lazyvim = false, neovim = false },
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      term_colors = true,
      dim_inactive = { enabled = false },
      float = { transparent = false, solid = false },
      integrations = {
        aerial = true,
        blink_cmp = true,
        diffview = true,
        flash = true,
        gitsigns = true,
        grug_far = true,
        harpoon = true,
        mini = true,
        noice = true,
        octo = true,
        render_markdown = true,
        snacks = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },

  {
    "folke/noice.nvim",
    opts = {
      cmdline = { view = "cmdline" },
      presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      lsp = {
        progress = { enabled = false },
        hover = { silent = true },
        signature = { auto_open = { enabled = false } },
      },
      routes = {
        { filter = { event = "msg_show", find = "written" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d+L, %d+B" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "; after #%d+" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "; before #%d+" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d+ fewer lines" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d+ more lines" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d+ lines yanked" }, opts = { skip = true } },
        { filter = { event = "notify", find = "No information available" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "^ServiceReady$" }, opts = { skip = true } },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.component_separators = { left = "", right = "" }
      opts.options.section_separators = { left = "", right = "" }
      opts.sections.lualine_z = {}
    end,
  },

  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = "thin",
      },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      animate = { enabled = false },
      indent = {
        animate = { enabled = false },
        scope = { enabled = true },
        chunk = { enabled = false },
      },
      notifier = { timeout = 2500, style = "compact", top_down = false },
      statuscolumn = { folds = { open = false, git_hl = true } },
      words = { debounce = 300 },
      dashboard = {
        preset = {
          header = [[neovim]],
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      preset = "helix",
      delay = 400,
      icons = { rules = false },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = { max_lines = 3, multiline_threshold = 1, mode = "cursor" },
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = {
      preset = "minimal",
      options = {
        show_source = { enabled = true, if_many = true },
        multilines = { enabled = true, always_show = false },
        throttle = 50,
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      },
      inlay_hints = { enabled = false },
      codelens = { enabled = false },
    },
  },

  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        ghost_text = { enabled = false },
        menu = { border = "rounded" },
        documentation = { auto_show_delay_ms = 400, window = { border = "rounded" } },
      },
      signature = { window = { border = "rounded" } },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      render_modes = { "n", "c" },
      code = { sign = false, width = "block", right_pad = 1 },
      heading = { sign = false },
    },
  },
}
