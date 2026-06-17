{ config, pkgs, lib, ... }:

{
  programs.vscodium = {
  enable = true;
  package = pkgs.vscodium;
  mutableExtensionsDir = true;
  profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      ritwickdey.liveserver
      eamodio.gitlens
      formulahendry.auto-rename-tag
      formulahendry.auto-close-tag
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-toolsai.jupyter-renderers
      ms-toolsai.vscode-jupyter-cell-tags
      ms-toolsai.vscode-jupyter-slideshow
      ms-vscode.cmake-tools
      twxs.cmake
      rust-lang.rust-analyzer
      serayuzgur.crates
      tamasfe.even-better-toml
      streetsidesoftware.code-spell-checker
      pkief.material-icon-theme
    ];
    userSettings = {
      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.iconTheme" = lib.mkForce "material-icon-theme";
    };
  };
};
}
