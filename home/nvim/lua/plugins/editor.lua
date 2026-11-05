return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.install_dir = vim.g.nix_ts_dir
      opts.ensure_installed = {}
    end,
  },

  {
    "coder/claudecode.nvim",
    opts = {
      terminal_cmd = "claude",
      terminal = {
        provider = "snacks",
        split_side = "right",
        split_width_percentage = 0.38,
      },
      diff_opts = {
        layout = "vertical",
        open_in_new_tab = false,
        keep_terminal_focus = false,
      },
    },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    opts = {
      enhanced_diff_hl = true,
      view = { merge_tool = { layout = "diff3_mixed" } },
    },
  },

  {
    "akinsho/git-conflict.nvim",
    event = "LazyFile",
    opts = {
      default_mappings = true,
      disable_diagnostics = true,
    },
  },

  {
    "mfussenegger/nvim-jdtls",
    opts = {
      jdtls = {
        handlers = {
          ["language/status"] = function() end,
          ["$/progress"] = function() end,
        },
      },
    },
  },

  {
    "pwntester/octo.nvim",
    opts = {
      suppress_missing_scope = { projects_v2 = true },
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Gedit", "GBrowse" },
  },

  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    init = function()
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_WindowLayout = 2
    end,
  },

  {
    "NMAC427/guess-indent.nvim",
    event = "BufReadPre",
    opts = {},
  },

  {
    "hat0uma/csvview.nvim",
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    opts = { view = { display_mode = "border" } },
  },

  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = { preview = { border = "rounded", winblend = 0 } },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = { "nixfmt" },
        fish = { "fish_indent" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.nix = { "statix", "deadnix" }
      opts.linters_by_ft.markdown = {}
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nixd = {
          settings = {
            nixd = {
              nixpkgs = { expr = 'import (builtins.getFlake "/etc/nixos").inputs.nixpkgs { }' },
              options = {
                nixos = {
                  expr = '(builtins.getFlake "/etc/nixos").nixosConfigurations.nixos.options',
                },
                home_manager = {
                  expr = '(builtins.getFlake "/etc/nixos").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []',
                },
              },
            },
          },
        },
        nil_ls = { enabled = false },
        fish_lsp = {},
        bashls = {},
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
            "--function-arg-placeholders=0",
            "--fallback-style=llvm",
          },
        },
      },
    },
  },
}
