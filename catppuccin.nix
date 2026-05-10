{ config, pkgs, lib, ... }:

{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  catppuccin.cursors.enable = false;

  home-manager.users.sidharthify = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "mauve";
      cursors.enable = false;
    };

  };
}
