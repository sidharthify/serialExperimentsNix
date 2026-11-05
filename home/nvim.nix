{ config, lib, pkgs, ... }:

let
  vp = pkgs.vimPlugins;

  plugins = with vp; [
    LazyVim
    lazy-nvim

    blink-cmp
    bufferline-nvim
    conform-nvim
    flash-nvim
    friendly-snippets
    gitsigns-nvim
    grug-far-nvim
    lazydev-nvim
    lualine-nvim
    mini-ai
    mini-icons
    mini-pairs
    noice-nvim
    nui-nvim
    nvim-lint
    nvim-lspconfig
    nvim-treesitter
    nvim-treesitter-textobjects
    nvim-ts-autotag
    persistence-nvim
    plenary-nvim
    snacks-nvim
    todo-comments-nvim
    tokyonight-nvim
    trouble-nvim
    ts-comments-nvim
    which-key-nvim
    { name = "catppuccin"; path = catppuccin-nvim; }

    claudecode-nvim
    mini-surround
    yanky-nvim
    neogen
    inc-rename-nvim
    dial-nvim
    { name = "harpoon"; path = harpoon2; }
    async-nvim
    aerial-nvim
    mini-files
    mini-move
    refactoring-nvim
    nvim-treesitter-context
    mini-hipatterns
    vim-startuptime
    octo-nvim

    SchemaStore-nvim
    clangd_extensions-nvim
    rustaceanvim
    crates-nvim
    venv-selector-nvim
    nvim-jdtls
    render-markdown-nvim
    markdown-preview-nvim
    cmake-tools-nvim
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-nio
    nvim-dap-python
    nvim-dap-go
    one-small-step-for-vimkind
    neotest
    neotest-python
    neotest-golang
    FixCursorHold-nvim

    tiny-inline-diagnostic-nvim
    diffview-nvim
    git-conflict-nvim
    vim-fugitive
    undotree
    guess-indent-nvim
    csvview-nvim
    nvim-bqf
    auto-save-nvim
  ];

  mkEntry = p:
    if p ? name && p ? path && !(lib.isDerivation p) then
      p
    else
      { name = lib.getName p; path = p; };

  lazyPath = pkgs.linkFarm "lazy-plugins" (map mkEntry plugins);

  tsDir = pkgs.symlinkJoin {
    name = "nvim-treesitter-site";
    paths = vp.nvim-treesitter.withAllGrammars.dependencies
      ++ [ "${vp.nvim-treesitter}/runtime" ];
  };
in
{
  catppuccin.nvim.enable = false;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;
    withPython3 = false;
    withNodeJs = false;

    extraWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath config.programs.neovim.extraPackages)
    ];

    extraPackages = with pkgs; [
      git
      lazygit
      ripgrep
      fd
      wl-clipboard
      gh
      gcc
      gnumake
      unzip
      curl
      fzf
      tree-sitter
      imagemagick
      ghostscript

      lua-language-server
      stylua
      nixd
      nil
      nixfmt
      statix
      deadnix
      clang-tools
      neocmakelsp
      cmake-format
      pyright
      ruff
      rust-analyzer
      gopls
      gofumpt
      gotools
      delve
      vscode-extensions.vadimcn.vscode-lldb.adapter
      (python3.withPackages (ps: [ ps.debugpy ]))
      golangci-lint
      vtsls
      prettierd
      prettier
      vscode-langservers-extracted
      yaml-language-server
      taplo
      marksman
      markdownlint-cli2
      dockerfile-language-server
      docker-compose-language-service
      hadolint
      bash-language-server
      shellcheck
      shfmt
      fish-lsp
      kotlin-language-server
      ktlint
      jdt-language-server
      jdk
    ];

    initLua = ''
      vim.g.nix_ts_dir = "${tsDir}"
      vim.opt.rtp:prepend("${vp.lazy-nvim}")
      vim.g.sqlite_clib_path = "${pkgs.sqlite.out}/lib/libsqlite3.so"

      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          { "mason-org/mason.nvim", enabled = false },
          { "mason-org/mason-lspconfig.nvim", enabled = false },
          { "jay-babu/mason-nvim-dap.nvim", enabled = false },
          { import = "extras" },
          { import = "plugins" },
        },
        defaults = { lazy = false, version = false },
        dev = {
          path = "${lazyPath}",
          patterns = { "" },
          fallback = false,
        },
        install = { missing = false, colorscheme = { "catppuccin", "habamax" } },
        lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json",
        checker = { enabled = false },
        change_detection = { enabled = false, notify = false },
        rocks = { enabled = false },
        ui = { border = "rounded" },
        performance = {
          reset_packpath = true,
          rtp = {
            reset = true,
            paths = { "${tsDir}" },
            disabled_plugins = {
              "gzip",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
    '';
  };

  xdg.configFile."nvim/lua".source = ./nvim/lua;
}
