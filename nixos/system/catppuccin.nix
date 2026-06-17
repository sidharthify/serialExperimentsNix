{ config, pkgs, lib, ... }:

{
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  catppuccin.cursors.enable = false;
  catppuccin.plymouth.enable = true;

  home-manager.users.sidharthify = {
    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "mocha";
      accent = "mauve";
      cursors.enable = false;
    };
  };
}
